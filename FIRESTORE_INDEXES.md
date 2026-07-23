# Firestore Composite Indexes - Zen Mart Pro

The following Firestore queries require manual composite index creation in the Firebase Console. You can create them by clicking the links provided in the debug console errors when these queries run, or manually adding them.

| Collection Name | Filter (where) Fields | Sort (orderBy) Fields | Required Composite Index | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `orders` | `shopId` (==) | `orderTime` (DESC) | `shopId` ASC, `orderTime` DESC | Vendor order history |
| `orders` | `shopId` (==), `orderTime` (>=, <=) | - | `shopId` ASC, `orderTime` ASC | Vendor sales reports |
| `orders` | `customerId` (==) | `orderTime` (DESC) | `customerId` ASC, `orderTime` DESC | Customer order history |
| `products` | `shopId` (==) | `createdAt` (DESC) | `shopId` ASC, `createdAt` DESC | Vendor/Customer product browsing |
| `vendor_categories` | `shopId` (==) | `displayOrder` (ASC) | `shopId` ASC, `displayOrder` ASC | Shop-specific categories (REQUIRED for Vendor Dashboard) |
| `reviews` | `shopId` (==) | `createdAt` (DESC) | `shopId` ASC, `createdAt` DESC | Shop feedback management |

## How to handle "FAILED_PRECONDITION" errors
If you see an error like `The query requires an index. You can create it here: https://console.firebase.google.com/...`, simply click the link while your app is running in debug mode to automatically configure the index.

## Performance Note
Composite indexes are essential for queries with:
1. Multiple inequality filters.
2. An equality filter AND an inequality filter.
3. An equality/inequality filter AND a sort.
