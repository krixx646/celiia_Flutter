/// Store product IDs for the body-scan paywall.
///
/// Must match App Store Connect / Play Console and
/// `celia-admin/src/lib/billingProducts.ts`.
class ScannerBillingProducts {
  ScannerBillingProducts._();

  static const singleScan = 'eu.thefit.celia.body_scan.single';

  static const all = <String>{singleScan};
}
