# Implementation Plan - Super Admin Management Module (Part 1)

This plan covers the implementation of the Super Admin dashboard and management screens for Vendors, Shops, Customers, and Riders.

## User Review Required

> [!IMPORTANT]
> - **Secondary Firebase Instance:** To create Vendor and Rider Auth accounts without signing out the Super Admin, a secondary Firebase app instance will be used in the `AuthService` logic.
> - **Firestore Structure:** As requested, separate collections (`users`, `shops`, `vendors`, `customers`, `riders`) will be managed.
> - **Part 1 Scope:** Product, Order, and Category management logic will be deferred to Part 2 as per instructions. Drawer links will be present but screens will be minimal placeholders.

## Proposed Changes

### 1. Models
Create data models to represent core entities:
- `[NEW] ShopModel`: [shop_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/shop_model.dart)
- `[NEW] VendorModel`: [vendor_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/vendor_model.dart) (Extends user data for vendors)
- `[NEW] RiderModel`: [rider_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/rider_model.dart)

### 2. Services
Implement Firestore and Auth logic for management:
- `[NEW] VendorService`: CRUD and Auth creation.
- `[NEW] ShopService`: CRUD and assignment logic.
- `[NEW] CustomerService`: View and activation toggle.
- `[NEW] RiderService`: CRUD.

### 3. Providers
Manage state for the admin module:
- `[NEW] VendorProvider`, `ShopProvider`, `CustomerProvider`, `RiderProvider`.

### 4. Navigation & Routes
- `[MODIFY] Routes`: [routes.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/routes.dart) - Add admin sub-routes.
- `[MODIFY] AppRouter`: [app_router.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/app_router.dart) - Register new admin routes.

### 5. Super Admin UI
Implement professional, responsive admin interface:
- `[NEW] AdminDrawer`: Shared navigation component.
- `[MODIFY] AdminDashboard`: [admin_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/admin_dashboard.dart) - Add summary cards.
- `[NEW] VendorsScreen`, `ShopsScreen`, `CustomersScreen`, `RidersScreen`.
- `[NEW] AssignShopScreen`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no linting/compilation errors.
- Mentally verify role-based navigation logic in `AppRouter`.

### Manual Verification
- **Login as Super Admin:** Verify stats cards on dashboard.
- **Vendor Management:** Create a vendor, verify Firestore entry and simulated Auth entry (via dialog).
- **Shop Management:** Create a shop, assign to vendor.
- **Customer Management:** Search and deactivate a customer.
- **Rider Management:** Create and edit a rider.
- **Responsive Layout:** Check drawer and dashboard layout on different screen sizes.
