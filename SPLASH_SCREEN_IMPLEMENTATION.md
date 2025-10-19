# Loading Splash Screen Implementation

## Summary

Implemented a smart loading splash screen that:
1. Shows while initial app data is being loaded
2. Automatically retries failed API calls up to 2 times
3. Provides visual feedback on loading status
4. Handles errors gracefully with retry option

## What Was Changed

### 1. Created LoadingSplashScreen ([loading_splash_screen.dart](frontend/lib/core/widgets/loading_splash_screen.dart))

**Features:**
- ✅ Displays splash screen image while loading
- ✅ Shows loading status text ("Loading profile...", "Loading trackers...", etc.)
- ✅ Animated fade-in effect
- ✅ Circular progress indicator
- ✅ Success checkmark when complete
- ✅ Error dialog with retry option

**Data Being Loaded:**
1. **Profile** - User's name, weight, fitness goals
2. **Trackers** - Body weight tracker and other custom trackers
3. **Routines** - Workout routines with exercises

**Retry Logic:**
- Each API call is retried up to **2 times** if it fails
- Wait time increases between retries (1s, then 2s)
- All retries happen while keeping the splash screen visible
- If all retries fail, shows error dialog with option to retry manually

### 2. Updated Router ([app_router.dart](frontend/lib/core/router/app_router.dart:22))

- Added `/loading` route that shows the LoadingSplashScreen
- Changed initial location from `/login` to `/`
- Original splash screen (`/`) still shows first, then navigates to login

### 3. Updated Login Flow ([login_page.dart](frontend/lib/features/authentication/presentation/pages/login_page.dart:62))

- After successful login, navigates to `/loading` instead of `/home`
- User sees loading splash with retry logic
- Only navigates to `/home` after all data is successfully loaded

## Flow Diagram

```
App Start
  ↓
Original Splash (/)
  ↓ (4 seconds)
Login Page (/login)
  ↓ (user logs in)
Loading Splash (/loading) ← NEW!
  ↓ (loads data with retries)
  ├─ Load Profile (retry up to 2x)
  ├─ Load Trackers (retry up to 2x)
  └─ Load Routines (retry up to 2x)
  ↓ (all data loaded)
Home Page (/home)
```

## Error Handling

**If Profile API Fails:**
1. Attempt 1 fails → wait 1s → Attempt 2
2. Attempt 2 fails → wait 2s → Attempt 3
3. Attempt 3 fails → Show error dialog

**If Trackers or Routines API Fails:**
- Same retry logic (up to 2 retries with increasing wait time)

**Error Dialog Options:**
- **Go to Login** - Returns to login page
- **Retry** - Resets retry counters and tries loading again

## Loading Status Messages

The splash screen shows real-time status:
- "Loading profile..."
- "Loading trackers..."
- "Loading routines..."
- "Ready!" (when complete)
- "Failed to load data" (on error)

## Console Logs

When loading, you'll see:
```
🚀 LoadingSplash: Starting initial data load...
🔄 LoadingSplash: Loading profile (attempt 1/3)
✅ LoadingSplash: Profile loaded
🔄 LoadingSplash: Loading trackers (attempt 1/3)
✅ LoadingSplash: Trackers loaded
🔄 LoadingSplash: Loading routines (attempt 1/3)
✅ LoadingSplash: Routines loaded
✅ LoadingSplash: All data loaded successfully!
```

On failure:
```
❌ LoadingSplash: Profile load failed (attempt 1): <error>
🔄 LoadingSplash: Loading profile (attempt 2/3)
```

## Benefits

1. **Better UX** - User knows app is loading, not frozen
2. **Reliability** - Auto-retry prevents transient network failures
3. **Error Recovery** - Manual retry option if auto-retry fails
4. **No Empty States** - Home page always has data loaded
5. **Performance** - Parallel loading of all data sources

## Testing

To test retry logic:
1. Turn off internet/backend
2. Login
3. Watch splash screen retry API calls
4. See error dialog after 3 attempts
5. Turn on internet
6. Click "Retry" button
7. Data loads successfully

## Future Improvements

- Add specific error messages for each API
- Show which specific data source failed
- Add network connectivity detection
- Cache data locally for offline mode
- Skip loading if data is already cached
