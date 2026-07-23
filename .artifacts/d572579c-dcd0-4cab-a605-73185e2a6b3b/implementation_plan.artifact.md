# Implementation Plan - Final Project Cleanup and Error Resolution

This plan addresses the remaining compilation errors and lint warnings project-wide to ensure the application builds and runs smoothly.

## Proposed Changes

### 1. Fix Broken Syntax and Misplaced Labels

#### [MODIFY] [shops_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/shops_screen.dart)
- Already applied a fix to the `try` block where `shopData` instantiation was malformed, resolving 100+ cascading errors.

### 2. Address Deprecated Member Usages

#### [MODIFY] [riders_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/riders_screen.dart)
- Change `value` to `initialValue` in `DropdownButtonFormField`.

#### [MODIFY] [vendors_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/vendors_screen.dart)
- Change `value` to `initialValue` in `DropdownButtonFormField`.

#### [MODIFY] [add_edit_product_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/add_edit_product_screen.dart)
- Change `value` to `initialValue` in `DropdownButtonFormField`.

#### [MODIFY] [vendor_product_list_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_product_list_screen.dart)
- Change `value` to `initialValue` in `DropdownButtonFormField`.

### 3. Resolve Asynchronous Context Usage (Lint Warnings)

#### [MODIFY] [vendor_category_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_category_screen.dart)
- Add `if (!context.mounted) return;` before using `Navigator` or `SnackBarHelper` after `await` calls.

#### [MODIFY] [vendor_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_dashboard.dart)
- Add `if (!mounted) return;` before using `context` in asynchronous methods.

### 4. Address RadioListTile Deprecations

#### [MODIFY] [checkout_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/checkout_screen.dart)
- Update `RadioListTile` usage to adhere to the latest Flutter standards if necessary, or ensure the current usage is safely suppressed if it's a false positive on `groupValue`. (Actually, I'll update it to the recommended pattern).

## Verification Plan

### Automated Verification
- Run `flutter analyze` to ensure 0 issues found.

### Manual Verification
- Build and run the app to confirm it launches without errors.
- Navigate to the affected screens (Shops, Vendors, Riders, Dashboard) to ensure UI functionality is intact.
