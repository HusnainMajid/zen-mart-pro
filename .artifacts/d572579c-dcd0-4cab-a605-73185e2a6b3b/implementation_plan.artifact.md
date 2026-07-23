# Implementation Plan - Project-wide UI Overflow Fixes

This plan addresses the "Bottom Overflowed" issues in various card components across the project by ensuring responsive layouts and flexible text handling.

## Proposed Changes

### Admin Module

#### [MODIFY] [admin_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/admin_dashboard.dart)
- Increase `childAspectRatio` from `1.1` to `1.2` or `1.3` to provide more vertical space for summary cards.
- Use `FittedBox` for the count text to prevent it from pushing boundaries.

#### [MODIFY] [customers_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/customers_screen.dart)
- Refine `_CustomerCard`'s `trailing` widget. Use a more compact layout or ensure it doesn't exceed `ListTile` height.
- Reduce vertical padding if necessary.

#### [MODIFY] [vendors_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/vendors_screen.dart) and [riders_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/riders_screen.dart)
- Apply similar fixes as `customers_screen.dart` to `_VendorCard` and `_RiderCard`.

### Rider Module

#### [MODIFY] [rider_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/rider/rider_dashboard.dart)
- Increase `childAspectRatio` in `_buildStatsGrid` from `1.1` to `1.3`.
- Use `FittedBox` for stat values.

### Vendor Module

#### [MODIFY] [vendor_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_dashboard.dart)
- Increase `childAspectRatio` in `_buildStatsGrid` from `1.4` to `1.5` (if needed, 1.4 is generally okay but higher is safer).
- Ensure `_buildStatCard` handles long titles gracefully.

### Customer Module

#### [MODIFY] [customer_home.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/customer_home.dart)
- In `_buildProductCard`, ensure the `Column` doesn't overflow the fixed `SizedBox` height (`220`).
- Use `Flexible` or `Expanded` widgets where appropriate.

#### [MODIFY] [wishlist_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/wishlist_screen.dart)
- Increase `childAspectRatio` from `0.7` to `0.75` or `0.8` to accommodate the "Add to Cart" button and text.

## Verification Plan

### Manual Verification
- Test on small screen devices (emulated) to ensure the red overflow banners are gone.
- Verify that text is still legible and not overly squashed by `FittedBox`.
