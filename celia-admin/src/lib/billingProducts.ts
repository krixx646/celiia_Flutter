/** Catalog of body-scan IAP products shared by verify routes and the app. */

export const BODY_SCAN_PRODUCTS = {
  'eu.thefit.celia.body_scan.single': { scans: 1 },
} as const;

export type BodyScanProductId = keyof typeof BODY_SCAN_PRODUCTS;

export const BODY_SCAN_PRODUCT_IDS = Object.keys(
  BODY_SCAN_PRODUCTS
) as BodyScanProductId[];

export function scansForProduct(productId: string): number | null {
  const entry = BODY_SCAN_PRODUCTS[productId as BodyScanProductId];
  return entry ? entry.scans : null;
}

export function isBodyScanProductId(productId: string): productId is BodyScanProductId {
  return productId in BODY_SCAN_PRODUCTS;
}
