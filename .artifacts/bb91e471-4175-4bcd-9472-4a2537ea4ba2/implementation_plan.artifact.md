# Project Stabilization: Phase 2 - Fixing Compilation Errors

## Goal
Resolve multiple compilation errors across several screens and providers that were identified during the failed build process.

## User Review Required
- **IMPORTANT**: The errors indicate method signature mismatches in providers (`AdminOrderProvider`, `VendorDashboardProvider`) and logic errors in `all_orders_screen.dart` (incorrect `_OrderDataSource` usage). I will align the code with the expected class interfaces.

## Open Questions
- None.

## Proposed Changes

### [Component: Providers]
- **[MODIFY] [vendor_dashboard_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/vendor_dashboard_provider.dart)**
    - Rename/Add `fetchDashboardData` method as expected by UI screens.
- **[MODIFY] [admin_order_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/admin_order_provider.dart)**
    - Add/Rename method to `fetchAllOrders` as expected by UI screens.

### [Component: Screens]
- **[MODIFY] [vendor_order_details_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_order_details_screen.dart)**
    - Fix positional arguments mismatch in `updateStatus` call.
- **[MODIFY] [all_orders_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/all_orders_screen.dart)**
    - Fix `_OrderDataSource` logic (color property usage).
- **[MODIFY] [admin_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/admin_dashboard.dart)**
    - Fix `Future.wait` argument type error.
- **[MODIFY] [vendor_category_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_category_screen.dart)**
    - Update method call to match `VendorDashboardProvider`.
- **[MODIFY] [vendor_product_list_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_product_list_screen.dart)**
    - Update method call to match `VendorDashboardProvider`.
- **[MODIFY] [add_edit_product_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/add_edit_product_screen.dart)**
    - Update method call to match `VendorDashboardProvider`.
- **[MODIFY] [all_shops_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/all_shops_screen.dart)**
    - Update method call to match `AdminOrderProvider`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure 0 errors.

### Manual Verification
- Attempt a clean build and run to confirm the app launches.
