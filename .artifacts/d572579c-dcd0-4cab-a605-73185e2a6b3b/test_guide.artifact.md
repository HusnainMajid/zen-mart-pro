# Zen Mart Pro - Complete Testing Guide

Follow this step-by-step flow to test all core functionalities of the app.

## 1. Super Admin Flow (Setup)
*   **Login**: Use `admin@zenmartpro.com` and password (as set in your environment).
*   **Dashboard**: Verify you see counts for Vendors, Shops, Customers, and Riders.
*   **Manage Shops**:
    *   Add a new Shop.
    *   Ensure the Shop status is 'Active'.
*   **Manage Vendors**:
    *   Add a new Vendor.
    *   Note the credentials generated.
*   **Assign Shop**:
    *   Assign the newly created Shop to the new Vendor.

## 2. Vendor Flow (Inventory Management)
*   **Login**: Use the credentials created by the Admin.
*   **Dashboard**: Verify you see the assigned Shop name and zero stats initially.
*   **Categories**:
    *   Add at least two categories (e.g., "Electronics", "Groceries").
    *   Verify they appear instantly.
*   **Products**:
    *   Add a few products to your categories.
    *   Set prices, discounts, and stock levels.
    *   Verify the Dashboard counts update (Total Products, Total Categories).

## 3. Customer Flow (Shopping)
*   **Signup**: Create a new customer account.
*   **Dashboard**:
    *   Verify the "Welcome [Name]!" greeting.
    *   Verify the Categories you created as Vendor appear.
    *   Verify the Featured Shops and Recent Products appear.
*   **Search**:
    *   Search for a product by name.
    *   Verify the text you type is visible (black/dark color).
*   **Shop Details**:
    *   Open a Shop. Verify the "OPEN" status and contact info.
*   **Address Management**:
    *   Go to Profile -> Saved Addresses.
    *   Add a new address (Verify NO permission error).
*   **Shopping Cart**:
    *   Add items from different shops (if applicable).
    *   Go to Cart, update quantities, and verify total calculation.
*   **Checkout**:
    *   Select your address.
    *   Add an "Order Note" (e.g., "Leave at the door").
    *   Place the Order.
*   **Order Tracking**:
    *   Go to Order History -> Track Order.
    *   Verify the 7-level timeline appears.

## 4. Rider Flow (Delivery)
*   **Login**: Use rider credentials (created by Admin).
*   **Status**: Toggle "Online" button.
*   **Delivery**: (Once Vendor accepts and assigns, or if auto-assigned) View requests and update status.

## 5. End-to-End Real-Time Sync
*   As **Vendor**: Open an Order. Change status to "Accepted", then "Preparing".
*   As **Customer**: Keep the Tracking screen open. Verify the timeline updates LIVE without refresh.
