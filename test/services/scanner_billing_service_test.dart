import 'dart:convert';

import 'package:celia_flutter/services/scanner_billing_products.dart';
import 'package:celia_flutter/services/scanner_billing_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth auth;

  setUp(() {
    auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'token');
    ScannerBillingService.backendBaseUrl = () => 'https://example.test';
  });

  ScannerBillingService serviceReturning(
    Object body, {
    int status = 200,
    void Function(http.Request request)? onRequest,
  }) {
    final client = MockClient((request) async {
      onRequest?.call(request);
      return http.Response(
        jsonEncode(body),
        status,
        headers: {'content-type': 'application/json'},
      );
    });
    return ScannerBillingService(firebaseAuth: auth, httpClient: client);
  }

  test('product id matches the one the server grants scans for', () {
    expect(
      ScannerBillingProducts.singleScan,
      'eu.thefit.celia.body_scan.single',
    );
    expect(ScannerBillingProducts.all, {ScannerBillingProducts.singleScan});
  });

  group('fetchEntitlement', () {
    test('parses balance and sends the bearer token', () async {
      late http.Request seen;
      final service = serviceReturning(
        {
          'remaining': 3,
          'bonusScans': 2,
          'periodRemaining': 1,
          'scansLimit': 1,
          'scansUsed': 0,
          'tier': 'free',
          'resetsAt': '2026-11-05T14:00:00.000Z',
          'productId': 'eu.thefit.celia.body_scan.single',
        },
        onRequest: (r) => seen = r,
      );

      final entitlement = await service.fetchEntitlement();

      expect(entitlement.remaining, 3);
      expect(entitlement.bonusScans, 2);
      expect(entitlement.periodRemaining, 1);
      expect(entitlement.resetsAt, isNotNull);
      expect(seen.url.path, '/api/mobile/entitlements');
      expect(seen.headers['Authorization'], 'Bearer token');
    });
  });

  group('redeemCode', () {
    test('posts the trimmed code and returns the new balance', () async {
      late http.Request seen;
      final service = serviceReturning(
        {'ok': true, 'scansGranted': 3, 'remaining': 4},
        onRequest: (r) => seen = r,
      );

      final result = await service.redeemCode('  COACH-TRIAL1 ');

      expect(result.scansGranted, 3);
      expect(result.remaining, 4);
      expect(seen.url.path, '/api/mobile/scanner-codes/redeem');
      expect(jsonDecode(seen.body), {'code': 'COACH-TRIAL1'});
    });

    test('surfaces the server message and code for a rejected code', () async {
      final service = serviceReturning(
        {'error': 'That code has expired', 'code': 'expired'},
        status: 400,
      );

      expect(
        service.redeemCode('OLD'),
        throwsA(
          isA<ScannerBillingException>()
              .having((e) => e.code, 'code', 'expired')
              .having((e) => e.message, 'message', 'That code has expired'),
        ),
      );
    });

    test('fails clearly when signed out', () async {
      when(() => auth.currentUser).thenReturn(null);
      final service = serviceReturning({'ok': true});

      expect(
        service.redeemCode('ANY'),
        throwsA(
          isA<ScannerBillingException>().having(
            (e) => e.code,
            'code',
            'notSignedIn',
          ),
        ),
      );
    });
  });
}
