# Implementation Plan - Project Simplification (Removal of Image Storage)

This plan outlines the complete removal of Firebase Storage dependencies and the transition to a purely text-and-numeric data model for Firestore. This is designed for an internship-level task to eliminate complexity and storage-related errors.

## User Review Required

> [!IMPORTANT]
> - All image pickers will be removed from the UI.
> - Products, Shops, and Profiles will display high-quality Material icons or static asset placeholders instead of dynamic images.
> - Firebase Storage will no longer be required or used by the application.
> - **Firestore Rules** provided below must be applied to ensure successful login and data access.

### Recommended Firestore Rules (Open for Development)
Paste these into the **Rules** tab of your Firestore Database in the Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Proposed Changes

### 1. Model Simplification
Refactor models to match the requested minimal structure:
- **[MODIFY] product_model.dart**: Remove `images` list and `imageUrl`. Retain only name, description, category, price, stock, discount, shopId, vendorId, createdAt.
- **[MODIFY] shop_model.dart**: Remove `banner` and `logo`. Retain only shopName, address, owner (uid), phone, description.
- **[MODIFY] user_model.dart**: Remove `profileImage`.
- **[MODIFY] category_model.dart**: Remove `iconUrl`.

### 2. Service & Provider Refactoring
- **[DELETE] storage_service.dart**: Completely remove the service that handles binary uploads.
- **[MODIFY] All Services**: Remove any logic that interacts with `StorageService`.
- **[MODIFY] All Providers**:
    - `VendorProductProvider`: Remove multi-image upload logic. Simplify `addProduct` and `updateProduct` to only save textual fields.
    - `VendorCategoryProvider`: Remove icon upload logic.
    - `ShopProvider`: Remove branding (logo/banner) update logic.

### 3. UI Refinement (Project-wide)
Replace all image picking and displaying components:
- **[MODIFY] add_edit_product_screen.dart**: Remove the "Media" section and image picker.
- **[MODIFY] shop_profile_screen.dart**: Remove "Branding" section (Logo/Banner upload).
- **[MODIFY] category_management_screen.dart**: Remove icon picker.
- **[MODIFY] Dashboard & List Screens**: Replace `CachedNetworkImage` and `NetworkImage` with `Icon` widgets (e.g., `Icons.inventory_2`, `Icons.store`, `Icons.person`).

### 4. Code Quality
- Fix every compile error caused by the removal of fields and services.
- Remove all unused imports project-wide.

## Verification Plan

### Manual Verification
1. **Login**: Verify login works with the provided rules.
2. **Product Creation**: Add a product without images and verify it saves in Firestore.
3. **Dashboard Stats**: Confirm the product counter still updates correctly.
4. **Lists**: Verify that all lists display professional placeholder icons.
5. **No Errors**: Ensure no red snackbars or crashes occur during any operation.

### Automated Tests
- Run `flutter analyze` to ensure a 100% clean report.
