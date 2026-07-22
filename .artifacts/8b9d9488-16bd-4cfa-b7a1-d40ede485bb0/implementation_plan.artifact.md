# Implementation Plan - Complete Customer Module

This plan outlines the end-to-end implementation of the Customer Module, covering shopping, checkout, order tracking, notifications, and profile management.

## User Review Required

> [!IMPORTANT]
> - **Cart Persistence:** I will implement the shopping cart using a Firestore collection `cart` as requested, ensuring the cart follows the user across devices.
> - **Skeleton Loading:** I will add the `skeletonizer` package to provide professional loading states for the Home and List screens.
> - **Real-time Tracking:** The order tracking will use Firestore streams to provide instant updates when status changes occur.

## Proposed Changes

### 1. Dependencies
- **[MODIFY] [pubspec.yaml](file:///C:/Users/Husnain/Desktop/zen_mart_pro/pubspec.yaml)**: Add `skeletonizer: any`.

### 2. Models
- **[NEW] [address_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/address_model.dart)**: Manage saved delivery addresses.
- **[NEW] [cart_item_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/cart_item_model.dart)**: Individual items within a cart.
- **[NEW] [notification_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/notification_model.dart)**: In-app notifications for order status.
- **[NEW] [wishlist_model.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/models/wishlist_model.dart)**: Manage user's favorite products.

### 3. Services
- **[NEW] [cart_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/cart_service.dart)**: Firestore-based cart management.
- **[NEW] [wishlist_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/wishlist_service.dart)**: Handle saved items.
- **[NEW] [address_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/address_service.dart)**: CRUD for user addresses.
- **[NEW] [notification_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/notification_service.dart)**: Fetch and manage user notifications.
- **[NEW] [customer_order_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/customer_order_service.dart)**: `placeOrder`, `cancelOrder`, and real-time tracking streams.

### 4. Providers
- **[NEW] [cart_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/cart_provider.dart)**: Business logic for pricing, tax, and item manipulation.
- **[NEW] [wishlist_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/wishlist_provider.dart)**.
- **[NEW] [address_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/address_provider.dart)**.
- **[NEW] [customer_order_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/customer_order_provider.dart)**.
- **[NEW] [notification_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/notification_provider.dart)**.

### 5. UI Implementation
#### Navigation
- **[NEW] [customer_main_nav.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/customer_main_nav.dart)**: Bottom navigation wrapper (Home, Shops, Orders, Profile).

#### Home & Discovery
- **[MODIFY] [customer_home.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/customer_home.dart)**: Modern dashboard with banners, featured sections, and horizontal category lists.
- **[NEW] [all_shops_view.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/all_shops_view.dart)**: Searchable list of shops.
- **[NEW] [shop_details_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/shop_details_screen.dart)**: View specific shop products and ratings.
- **[NEW] [product_details_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/product_details_screen.dart)**: Image gallery, description, reviews, and add-to-cart.

#### Transactional
- **[NEW] [cart_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/cart_screen.dart)**: Edit quantities and view totals.
- **[NEW] [checkout_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/checkout_screen.dart)**: Address selection, payment, and order placement.

#### Post-Order
- **[NEW] [order_history_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/order_history_screen.dart)**: List of past and current orders.
- **[NEW] [order_tracking_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/order_tracking_screen.dart)**: Visual timeline of order status.

#### Profile & Management
- **[NEW] [customer_profile_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/customer_profile_screen.dart)**.
- **[NEW] [address_list_screen.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/screens/customer/address_list_screen.dart)**.

### 6. Routing
- **[MODIFY] [routes.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/routes.dart)**: Register all customer routes.
- **[MODIFY] [app_router.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/core/routes/app_router.dart)**: Update initial location for customers to the new main nav.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero errors.

### Manual Verification
- **E2E Flow:** Add product to wishlist -> Move to cart -> Select address -> Place order -> Track order status.
- **Real-time:** Use a second device/emulator as Admin to update order status and verify immediate UI update and notification on Customer side.
- **Validation:** Try checking out with empty cart or invalid address.
