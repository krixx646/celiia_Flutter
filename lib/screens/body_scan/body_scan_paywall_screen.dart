import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../services/scanner_billing_service.dart';

/// Buy one body scan (€7.99 store product) or redeem a coach/trial code.
class BodyScanPaywallScreen extends StatefulWidget {
  const BodyScanPaywallScreen({super.key});

  @override
  State<BodyScanPaywallScreen> createState() => _BodyScanPaywallScreenState();
}

class _BodyScanPaywallScreenState extends State<BodyScanPaywallScreen> {
  final ScannerBillingService _billing = ScannerBillingService();
  final TextEditingController _codeController = TextEditingController();

  ScannerEntitlement? _entitlement;
  ProductDetails? _product;
  bool _loading = true;
  bool _buying = false;
  bool _redeeming = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _billing.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _billing.ensureListening();
      // Best-effort: finish any purchase that never got verified.
      unawaited(_billing.restorePendingPurchases());
      final entitlement = await _billing.fetchEntitlement();
      final product = await _billing.loadSingleScanProduct();
      if (!mounted) return;
      setState(() {
        _entitlement = entitlement;
        _product = product;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is ScannerBillingException
            ? e.message
            : AppLocalizations.of(context).bodyScanPaywallLoadFailed;
      });
    }
  }

  Future<void> _buy() async {
    final product = _product;
    if (product == null || _buying) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buying = true;
      _error = null;
      _success = null;
    });
    try {
      final result = await _billing.buySingleScan(product);
      if (!mounted) return;
      Navigator.of(context).pop(result.remaining);
    } on ScannerBillingException catch (e) {
      if (!mounted) return;
      if (e.code == 'canceled') {
        setState(() => _buying = false);
        return;
      }
      setState(() {
        _buying = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _buying = false;
        _error = AppLocalizations.of(context).bodyScanPaywallPurchaseFailed;
      });
    }
  }

  Future<void> _redeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _redeeming) return;
    HapticFeedback.lightImpact();
    setState(() {
      _redeeming = true;
      _error = null;
      _success = null;
    });
    try {
      final result = await _billing.redeemCode(code);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _redeeming = false;
        _codeController.clear();
        _success = l10n.bodyScanPaywallRedeemOk(
          result.scansGranted,
          result.remaining,
        );
      });
      await _load();
    } on ScannerBillingException catch (e) {
      if (!mounted) return;
      setState(() {
        _redeeming = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _redeeming = false;
        _error = AppLocalizations.of(context).bodyScanPaywallRedeemFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);
    final priceLabel = _product?.price ?? l10n.bodyScanPaywallPriceFallback;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        foregroundColor: theme.textPrimary,
        title: Text(l10n.bodyScanPaywallTitle),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Text(
                    l10n.bodyScanPaywallHeadline,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: theme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.bodyScanPaywallBody,
                    style: TextStyle(
                      color: theme.textSecondary,
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_entitlement != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.border),
                      ),
                      child: Text(
                        l10n.bodyScanPaywallRemaining(_entitlement!.remaining),
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (_product == null || _buying) ? null : _buy,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: _buying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.bodyScanPaywallBuy(priceLabel),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  if (_product == null) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.bodyScanPaywallStoreUnavailable,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    l10n.bodyScanPaywallCodeTitle,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.bodyScanPaywallCodeBody,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: l10n.bodyScanPaywallCodeHint,
                      filled: true,
                      fillColor: theme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _redeeming ? null : _redeem,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: _redeeming
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: theme.textPrimary,
                              ),
                            )
                          : Text(
                              l10n.bodyScanPaywallRedeem,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (_success != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _success!,
                      style: TextStyle(
                        color: theme.accentOrange,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
