import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../config/env.dart';
import 'scanner_billing_products.dart';

class ScannerEntitlement {
  const ScannerEntitlement({
    required this.remaining,
    required this.bonusScans,
    required this.periodRemaining,
    required this.scansLimit,
    required this.scansUsed,
    required this.tier,
    required this.productId,
    this.resetsAt,
  });

  final int remaining;
  final int bonusScans;
  final int periodRemaining;
  final int scansLimit;
  final int scansUsed;
  final String tier;
  final String productId;
  final DateTime? resetsAt;

  factory ScannerEntitlement.fromJson(Map<String, dynamic> json) {
    return ScannerEntitlement(
      remaining: _int(json['remaining']),
      bonusScans: _int(json['bonusScans']),
      periodRemaining: _int(json['periodRemaining']),
      scansLimit: _int(json['scansLimit'], fallback: 1),
      scansUsed: _int(json['scansUsed']),
      tier: json['tier']?.toString() ?? 'free',
      productId:
          json['productId']?.toString() ?? ScannerBillingProducts.singleScan,
      resetsAt: DateTime.tryParse(
        json['resetsAt']?.toString() ?? '',
      )?.toLocal(),
    );
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class ScannerPurchaseResult {
  const ScannerPurchaseResult({
    required this.scansGranted,
    required this.remaining,
    this.alreadyProcessed = false,
  });

  final int scansGranted;
  final int remaining;
  final bool alreadyProcessed;
}

class ScannerBillingException implements Exception {
  const ScannerBillingException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'ScannerBillingException($code, $message)';
}

/// Store purchases for body scans, plus redeem codes and entitlement reads.
class ScannerBillingService {
  ScannerBillingService({
    FirebaseAuth? firebaseAuth,
    http.Client? httpClient,
    InAppPurchase? inAppPurchase,
  }) : _injectedAuth = firebaseAuth,
       _httpClient = httpClient ?? http.Client(),
       _injectedIap = inAppPurchase;

  final FirebaseAuth? _injectedAuth;
  final http.Client _httpClient;
  final InAppPurchase? _injectedIap;

  /// Resolved on use so API calls (redeem, entitlements) work, and can be
  /// tested, without a store plugin being registered.
  InAppPurchase get _iap => _injectedIap ?? InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Map<String, Completer<PurchaseDetails>> _pending = {};

  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  bool get storeAvailableOnThisDevice {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> ensureListening() async {
    if (_purchaseSub != null) return;
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) {
        for (final completer in _pending.values) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
        _pending.clear();
      },
    );
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          const ScannerBillingException('Billing closed', code: 'closed'),
        );
      }
    }
    _pending.clear();
  }

  Future<ScannerEntitlement> fetchEntitlement() async {
    final json = await _get('/api/mobile/entitlements');
    return ScannerEntitlement.fromJson(json);
  }

  Future<ProductDetails?> loadSingleScanProduct() async {
    if (!storeAvailableOnThisDevice) return null;
    final available = await _iap.isAvailable();
    if (!available) return null;
    await ensureListening();
    final response = await _iap.queryProductDetails(
      ScannerBillingProducts.all,
    );
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.firstWhere(
      (p) => p.id == ScannerBillingProducts.singleScan,
      orElse: () => response.productDetails.first,
    );
  }

  /// Buy one body scan. Verifies with our backend, then completes the store
  /// transaction so Google/Apple can finish consumption.
  Future<ScannerPurchaseResult> buySingleScan(ProductDetails product) async {
    if (!storeAvailableOnThisDevice) {
      throw const ScannerBillingException(
        'In-app purchases are only available on Android and iOS',
        code: 'unsupportedPlatform',
      );
    }
    await ensureListening();

    final completer = Completer<PurchaseDetails>();
    _pending[product.id] = completer;

    final param = PurchaseParam(productDetails: product);
    final started = await _iap.buyConsumable(
      purchaseParam: param,
      // iOS consumes via completePurchase; Android needs explicit consume.
      autoConsume: defaultTargetPlatform == TargetPlatform.iOS,
    );
    if (!started) {
      _pending.remove(product.id);
      throw const ScannerBillingException(
        'Could not start the purchase',
        code: 'startFailed',
      );
    }

    final details = await completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _pending.remove(product.id);
        throw const ScannerBillingException(
          'Purchase timed out',
          code: 'timeout',
        );
      },
    );

    if (details.status == PurchaseStatus.canceled) {
      throw const ScannerBillingException(
        'Purchase cancelled',
        code: 'canceled',
      );
    }
    if (details.status == PurchaseStatus.error) {
      throw ScannerBillingException(
        details.error?.message ?? 'Purchase failed',
        code: 'storeError',
      );
    }

    // If verification throws, the purchase is deliberately left unfinished so
    // the store re-delivers it on the next launch or restore and we retry.
    final result = await _verifyWithBackend(details);
    await _finishPurchase(details);
    return result;
  }

  /// Tells the store the purchase is done. Android consumables must be
  /// consumed (not just acknowledged) or the user can never buy another one;
  /// that happens only after the server has credited the scans.
  Future<void> _finishPurchase(PurchaseDetails details) async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        details is GooglePlayPurchaseDetails) {
      final addition = _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      await addition.consumePurchase(details);
      return;
    }
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }

  /// Finishes any store purchases that never got a backend grant (crash mid-buy).
  Future<void> restorePendingPurchases() async {
    if (!storeAvailableOnThisDevice) return;
    final available = await _iap.isAvailable();
    if (!available) return;
    await ensureListening();
    await _iap.restorePurchases();
  }

  Future<ScannerPurchaseResult> redeemCode(String code) async {
    final json = await _post('/api/mobile/scanner-codes/redeem', {
      'code': code.trim(),
    });
    return ScannerPurchaseResult(
      scansGranted: ScannerEntitlement._int(json['scansGranted']),
      remaining: ScannerEntitlement._int(json['remaining']),
    );
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // The store is still processing payment; nothing to verify yet.
      if (purchase.status == PurchaseStatus.pending) continue;

      final waiting = _pending[purchase.productID];
      if (waiting != null && !waiting.isCompleted) {
        _pending.remove(purchase.productID);
        waiting.complete(purchase);
        continue;
      }

      // Orphaned / restored consumable: verify, then finish it.
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          await _verifyWithBackend(purchase);
          await _finishPurchase(purchase);
        } catch (_) {
          // Left unfinished so the next launch or restore retries it.
        }
      } else if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<ScannerPurchaseResult> _verifyWithBackend(
    PurchaseDetails details,
  ) async {
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final json = await _post('/api/mobile/purchases/verify', {
      'platform': platform,
      'productId': details.productID,
      'purchaseToken': details.verificationData.serverVerificationData,
      'verificationData': details.verificationData.serverVerificationData,
      'transactionId': details.purchaseID,
    });
    return ScannerPurchaseResult(
      scansGranted: ScannerEntitlement._int(json['scansGranted'], fallback: 1),
      remaining: ScannerEntitlement._int(json['remaining']),
      alreadyProcessed: json['alreadyProcessed'] == true,
    );
  }

  Future<Uri> _uri(String path) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw const ScannerBillingException(
        'CELIA_BACKEND_BASE_URL is not set',
        code: 'notConfigured',
      );
    }
    return Uri.parse('$base$path');
  }

  Future<String> _idToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ScannerBillingException(
        'Please sign in again',
        code: 'notSignedIn',
      );
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const ScannerBillingException(
        'Please sign in again',
        code: 'notSignedIn',
      );
    }
    return token;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = await _uri(path);
    final token = await _idToken();
    late http.Response res;
    try {
      res = await _httpClient
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const ScannerBillingException(
        'Request timed out',
        code: 'network',
      );
    } catch (e) {
      throw ScannerBillingException(e.toString(), code: 'network');
    }
    return _decode(res);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = await _uri(path);
    final token = await _idToken();
    late http.Response res;
    try {
      res = await _httpClient
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw const ScannerBillingException(
        'Request timed out',
        code: 'network',
      );
    } catch (e) {
      throw ScannerBillingException(e.toString(), code: 'network');
    }
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json = {};
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else if (decoded is Map) {
        json = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      json = {};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return json;
    throw ScannerBillingException(
      json['error']?.toString() ?? 'Request failed (${res.statusCode})',
      code: json['code']?.toString(),
    );
  }
}
