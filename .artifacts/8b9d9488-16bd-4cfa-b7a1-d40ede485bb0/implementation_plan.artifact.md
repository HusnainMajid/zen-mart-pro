# Implementation Plan - Vendor Module (Part 2)

This plan outlines the completion of the Vendor Module, focusing on Order Management, Customer Reviews, Low Stock Alerts, Sales Analytics, and Reporting (including PDF export).

## User Review Required

> [!IMPORTANT]
> - **Order Flow Constraints:** Vendors will be restricted to specific status transitions (Pending → Accepted → Preparing → Ready For Pickup). Transitions to "Delivered" will be handled by the system or rider in a future module.
> - **PDF Export:** I will add `pdf` and `printing` packages to `pubspec.yaml` to support sales report generation.
> - **Model Updates:** `OrderModel` will be expanded to support detailed order tracking (items, tax, discount, notes, etc.).

## Proposed Changes

### 1. Dependencies
- **[MODIFY] [pubspec.yaml](file:///C:/Users/Husnain/Desktop/zen_mart_pro/pubspec.yaml)**: Add `pdf` and `printing` packages.

### 2. Models
- **[MODIFY] [order_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/order_model.dart)**:
    - Add `items` (List of `OrderItemModel`), `tax`, `discount`, `deliveryAddress`, `orderNotes`, `shopId`.
- **[NEW] [order_item_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/order_item_model.dart)**: id, productId, name, price, quantity, total.
- **[NEW] [review_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/review_model.dart)**: id, customerId, customerName, shopId, rating, comment, reply, createdAt.
- **[NEW] [sales_report_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/sales_report_model.dart)**: date, totalRevenue, totalOrders, completedOrders, cancelledOrders, bestSellingProducts.

### 3. Services
- **[NEW] [order_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/order_service.dart)**: Vendor-specific order fetching and status updates with transition validation.
- **[NEW] [review_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/review_service.dart)**: Fetch reviews for shop and implement reply logic.
- **[NEW] [vendor_report_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/vendor_report_service.dart)**: Aggregate sales data and generate PDF documents.

### 4. Providers
- **[NEW] [vendor_order_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/vendor_order_provider.dart)**: Manage shop orders, search, and status flow logic.
- **[NEW] [review_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/review_provider.dart)**: Manage ratings and feedback.
- **[NEW] [vendor_report_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/vendor_report_provider.dart)**: Handle sales analytics and report generation states.

### 5. UI Implementation
- **[NEW] [vendor_order_list_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_order_list_screen.dart)**: Filterable list of orders.
- **[NEW] [vendor_order_details_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_order_details_screen.dart)**: Detailed breakdown with status update controls.
- **[NEW] [vendor_reviews_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_reviews_screen.dart)**: Feedback management.
- **[NEW] [vendor_reports_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_reports_screen.dart)**: Sales dashboard with charts and export button.
- **[MODIFY] [vendor_dashboard.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/vendor/vendor_dashboard.dart)**: Add Low Stock and Sales performance widgets.

### 6. Routing
- **[MODIFY] [routes.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/routes.dart)**: Add `vendorOrders`, `vendorOrderDetails`, `vendorReviews`, `vendorReports`.
- **[MODIFY] [app_router.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/app_router.dart)**: Register new vendor routes.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero errors.

### Manual Verification
- **Order Flow:** Verify that a vendor can only move status from Pending to Accepted, etc., and cannot jump statuses or mark as Delivered.
- **Reviews:** Post a dummy review in Firestore and verify the vendor can see and reply to it.
- **Analytics:** Check if charts accurately reflect order totals.
- **PDF Export:** Verify that a sales report PDF is generated with correct layout and data.
