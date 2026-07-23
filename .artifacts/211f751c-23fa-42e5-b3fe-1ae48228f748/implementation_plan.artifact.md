# Firestore Index Resolution - Vendor Dashboard

The Vendor Dashboard is failing to load because the Firestore query `getShopOrdersStream` and `getShopOrdersOnce` in `VendorOrderService` requires a composite index.

## User Review Required

No breaking changes are required. The fix is to add a missing composite index to Firestore.

## Proposed Changes

### [Firestore]
- Create a composite index in the Firestore console with the following details:
  - Collection: `orders`
  - Field 1: `shopId` (Ascending)
  - Field 2: `orderTime` (Descending)
  - Query Scope: Collection

## Verification Plan

### Manual Verification
- After creating the index in the Firebase Console and waiting for it to be enabled, go back to the app and click the "Retry" button on the Vendor Dashboard. The dashboard should load correctly.
