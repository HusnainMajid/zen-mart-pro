# Implementation Plan - Fix Firestore Retrieval Error

The error "Failed to retrieve user data from Firestore" is likely caused by **Firestore Security Rules** being set to "Locked Mode" or the Firestore database not being initialized in the Firebase Console.

## User Review Required

> [!IMPORTANT]
> To fully fix this, you must ensure that Firestore is enabled in your Firebase Console and that the rules allow authenticated users to read/write to the `users` collection.
>
> **Recommended Rules for Development:**
> ```
> service cloud.firestore {
>   match /databases/{database}/documents {
>     match /users/{userId} {
>       allow read, write: if request.auth != null && request.auth.uid == userId;
>     }
>   }
> }
> ```

## Proposed Changes

### Data & Services

#### [MODIFY] [firestore_service.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/services/firestore_service.dart)
- Improve error handling to identify specific Firebase exceptions.
- If a `permission-denied` error occurs, provide a clear instruction to the user about updating Firestore rules.
- Add logging to help diagnose which specific field might be failing during `fromMap` conversion.

### Business Logic

#### [MODIFY] [auth_provider.dart](file:///C:/Users/Husnain/Desktop/zen_mart_pro/lib/providers/auth_provider.dart)
- Wrap Firestore calls with more granular try-catch blocks.
- Ensure that if Firestore is unavailable, the user is informed that their account was authenticated but their profile could not be loaded.

## Verification Plan

### Manual Verification
- Attempt login/register: If it fails, check if the SnackBar now provides more specific guidance (e.g., "Permission Denied - Check Firestore Rules").
- Once rules are updated in the console, verify that login/register proceeds smoothly to the dashboard.
