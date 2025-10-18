# Profile Page Data Loading Fix

## Problem Identified
The profile page was not displaying existing user data (name, email, etc.) from the backend API.

## Root Cause
The issue was in the profile page's data loading mechanism:

1. **Timing Issue**: The `_loadProfileData` function was called inside `addPostFrameCallback` with a fragile condition
2. **State Management**: The condition checked if `fullNameController.text.isEmpty`, which could fail on widget rebuilds
3. **No Tracking**: There was no way to track if data had already been loaded, causing potential multiple loads or no loads

## Fixes Applied

### 1. Added Data Loading State Tracking
```dart
bool _isDataLoaded = false; // Track if data has been loaded
```

### 2. Updated `_loadProfileData` Method
- Added check for `_isDataLoaded` flag to prevent duplicate loads
- Wrapped all state updates in `setState()` for proper UI refresh
- Added debug logging to track data flow

### 3. Improved Data Loading Trigger
Changed from:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (profile != null && fullNameController.text.isEmpty) {
    _loadProfileData(profile);
  }
});
```

To:
```dart
if (profile != null && !_isDataLoaded) {
  Future.microtask(() => _loadProfileData(profile));
}
```

### 4. Added Debug Logging
Added comprehensive logging throughout the data flow:
- **Repository**: Logs API calls, responses, and errors
- **Provider**: Logs profile fetching and results
- **UI**: Logs when data is loaded into form fields

## How the Data Flow Works

1. **User opens Profile Page**
2. **Provider (`userProfileProvider`) initializes**
   - Calls `UserProfileRepository.getProfile()`
3. **Repository makes API call**
   - GET request to `/profile/me`
   - Auth token automatically added by `AuthInterceptor`
4. **Backend returns profile data**
   - Includes: id, user_id, email, full_name, phone_number, etc.
5. **Data is parsed into `UserProfileModel`**
6. **Provider returns data to UI**
7. **Profile Page detects new data**
   - Calls `_loadProfileData()` via `Future.microtask`
8. **UI fields are populated**
   - TextControllers updated with values
   - Dropdown values set
   - `_isDataLoaded` flag set to true

## Testing Steps

### 1. Check Backend API
Ensure the backend is running and the profile endpoint works:
```bash
cd backend
python -m app.main
```

### 2. Test Profile API Directly
If logged in, you can test the endpoint:
- Check network logs in VS Code Debug Console
- Look for API calls to `/profile/me`

### 3. Run the Flutter App
```bash
cd frontend
flutter run
```

### 4. Monitor Debug Logs
When navigating to the profile page, you should see:
```
📱 Fetching user profile...
🔍 Calling API: /profile/me
✅ API Response Status: 200
✅ API Response Data: {...}
✅ Profile parsed successfully: user@example.com
📱 Profile fetched: user@example.com, John Doe
🔄 Loading profile data into UI...
   Email: user@example.com
   Full Name: John Doe
   Phone: +1234567890
✅ Profile data loaded into UI successfully
```

## Expected Behavior After Fix

1. ✅ When user opens profile page, existing data loads automatically
2. ✅ Email field shows the user's email (read-only)
3. ✅ Name field shows the user's full name if it exists
4. ✅ Phone, weight, height, and other fields populate if data exists
5. ✅ Dropdowns (gender, fitness goal, etc.) are pre-selected if values exist
6. ✅ User can edit and save changes

## If Issues Persist

### Check Authentication
```dart
// In Flutter DevTools or logs, verify:
// 1. Access token is stored
// 2. Auth interceptor is adding token to requests
```

### Check Backend Profile Creation
The backend automatically creates an empty profile if it doesn't exist:
```python
# In user_profile_controller.py
if not profile:
    profile = await service.create_profile(user_id, {})
```

### Verify Profile Model Mapping
Ensure JSON keys match between backend and frontend:
- Backend uses snake_case: `full_name`, `phone_number`
- Frontend model uses `@JsonKey` annotations to map correctly

## Common Issues and Solutions

### Issue: Profile returns null
**Solution**: Check if user is authenticated and token is valid

### Issue: Fields still empty after loading
**Solution**: Check debug logs - data might not be in the database yet

### Issue: Only email shows, nothing else
**Solution**: This is expected if profile was just created - other fields are optional

### Issue: Data loads but disappears on edit
**Solution**: Make sure you're not overwriting controller text after user edits

## Files Modified

1. `frontend/lib/features/profile/presentation/pages/profile_page.dart`
   - Added `_isDataLoaded` flag
   - Updated `_loadProfileData` method
   - Changed data loading trigger mechanism
   - Added debug logging

2. `frontend/lib/features/profile/presentation/providers/profile_providers.dart`
   - Added debug logging to track profile fetching

3. `frontend/lib/features/profile/data/repositories/user_profile_repository.dart`
   - Added comprehensive debug logging for API calls

## Next Steps

After verifying the fix works:
1. Remove or reduce debug logging (change to proper logging framework)
2. Add error handling UI feedback
3. Add loading indicators during data fetch
4. Consider adding pull-to-refresh functionality
