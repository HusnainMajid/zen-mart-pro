# Implementation Plan - Super Admin Management Module (Part 2)

This plan covers the completion of the Super Admin module, including Category Management, Shop Banners, Enhanced Shop/Product/Order viewing, Complaint Management, and Analytics with Charts.

## User Review Required

> [!IMPORTANT]
> - **Charts:** I will add `fl_chart` to `pubspec.yaml` for data visualization.
> - **Product/Order Models:** I will implement comprehensive models for Products and Orders to support the "View All" features, even though the creation of these entities belongs to other modules.
> - **Storage:** `StorageService` will handle image uploads to Firebase Storage for Categories and Banners.

## Proposed Changes

### 1. Project Configuration
- **[pubspec.yaml](file:///C:/Users/Husnain/Desktop/zen_mart_pro/pubspec.yaml)**: Add `fl_chart: any`.

### 2. Models
- `CategoryModel`: id, name, description, icon, status, createdAt.
- `ComplaintModel`: id, customerId, customerName, subject, message, reply, status, createdAt, updatedAt.
- `AnalyticsModel`: Stats for revenue, orders, top sellers.
- `ProductModel`: id, name, shopId, vendorId, categoryId, price, stock, status, imageUrl, createdAt.
- `OrderModel`: id, orderNumber, customerId, vendorId, riderId, paymentMethod, total, status, orderTime, deliveryTime.
- `ShopBannerModel`: id, imageUrl, isActive, createdAt.

### 3. Services
- `CategoryService`: CRUD for global categories.
- `ComplaintService`: Manage system complaints.
- `AnalyticsService`: Aggregate data for reports.
- `StorageService`: General Firebase Storage handler.
- `ProductService`: View global product list.
- `OrderService`: View global order list.

### 4. Providers
- `CategoryProvider`
- `ComplaintProvider`
- `AnalyticsProvider`
- `ShopBannerProvider`
- `AdminOrderProvider`
- `AdminProductProvider`

### 5. UI Implementation
- **Category Management**: List with search, add/edit dialogs.
- **Shop Banner Management**: Upload/Delete banners with preview.
- **Enhanced Tables**: Responsive DataTables for Shops, Products, and Orders.
- **Complaint Module**: View list, detail view with reply functionality.
- **Reports & Analytics**: Dashboard with `fl_chart` integration.

### 6. Navigation
- **[routes.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/routes.dart)**: Add routes for new admin features.
- **[app_router.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/app_router.dart)**: Register new routes.
- **[admin_drawer.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/admin/admin_drawer.dart)**: Update navigation links.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure type safety and zero errors.

### Manual Verification
- **Category CRUD**: Verify duplicate name prevention and image upload.
- **Banner Management**: Upload a banner and verify it appears in Firestore/Storage.
- **Data Tables**: Test search, filtering, and pagination on Shops/Products/Orders.
- **Complaints**: Open a complaint, reply, and change status.
- **Analytics**: Verify charts display data correctly.
- **Responsive Layout**: Check all new screens on mobile and tablet.
