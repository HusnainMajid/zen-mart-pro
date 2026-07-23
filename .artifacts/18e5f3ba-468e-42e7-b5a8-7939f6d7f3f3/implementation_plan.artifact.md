# Authentication & State Management Refactor

The `[cloud_firestore/permission-denied]` error during account switching without a full app restart is caused by stale provider state (specifically the VendorDashboardProvider holding old `shopId` or stream subscriptions) and potentially inconsistent `AuthProvider` state after logout/login.

## User Review Required

- We will implement a `resetAllProviders()` mechanism in the `SessionProvider` or a dedicated manager.
- We will ensure `AuthProvider` fully clears user data and notifies listeners before the new login starts.

## Proposed Changes

### [Core/Auth]

#### [MODIFY] [AuthProvider](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/auth_provider.dart)
- Explicitly reset `_currentUser` and call `notifyListeners()` on logout.
- Ensure that the login process correctly clears any potential leftover state.

#### [MODIFY] [SessionProvider](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/session_provider.dart)
- Add a `clearSession()` method that triggers cleanup for all domain-specific providers (Cart, VendorDashboard, etc.).

#### [MODIFY] [VendorDashboardProvider](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/vendor_dashboard_provider.dart)
- Add a `reset()` method to clear `_stats`, `_errorMessage`, and cancel the `_orderSubscription`.

## Verification Plan

### Manual Verification
1. Log in as Vendor -> navigate to dashboard -> ensure data loads.
2. Logout.
3. Log in as Customer/Admin.
4. Logout.
5. Log in as the SAME Vendor or a DIFFERENT Vendor.
6. Verify Dashboard loads correct shop data without errors.
