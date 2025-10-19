# Home Page Enhancement - Implementation Guide

## Summary of Changes

This guide outlines the enhancements made to the Home Page to add the following features:

1. ✅ **Update Current Weight** - Tap on the "Current" card to update weight via trackers
2. ✅ **Suggested Weight** - Calculate suggested weight based on BMI (instead of "Goal")
3. ✅ **Workout Tracker** - Check if workout was logged today and mark as done
4. ✅ **Protein Intake** - Calculate protein target based on body weight (2.0g per kg)

---

## Changes Required

### 1. Convert from ConsumerWidget to ConsumerStatefulWidget

**File:** `frontend/lib/features/home/presentation/pages/home_page.dart`

**Change class declaration:**

```dart
// FROM:
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

// TO:
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final WorkoutLogRepository _workoutRepo = WorkoutLogRepository();
  bool _hasWorkedOutToday = false;
  bool _isCheckingWorkout = true;
```

### 2. Add Required Imports

Add these imports at the top of the file:

```dart
import '../../../fitness/progress/trackers/tracker_provider.dart';
import '../../../fitness/progress/trackers/tracker_models.dart';
import '../../../fitness/repositories/workout_log_repository.dart';
```

### 3. Add initState to Check Today's Workout

```dart
@override
void initState() {
  super.initState();
  _checkTodayWorkout();
}

Future<void> _checkTodayWorkout() async {
  try {
    final logs = await _workoutRepo.getAllWorkoutLogs(limit: 30);
    final today = DateTime.now();
    final hasWorkout = logs.any((log) => 
      log.date.year == today.year &&
      log.date.month == today.month &&
      log.date.day == today.day
    );
    
    if (mounted) {
      setState(() {
        _hasWorkedOutToday = hasWorkout;
        _isCheckingWorkout = false;
      });
    }
  } catch (e) {
    print('Error checking workout: $e');
    if (mounted) {
      setState(() {
        _isCheckingWorkout = false;
      });
    }
  }
}
```

### 4. Add Helper Methods

```dart
/// Calculate BMI and suggest healthy weight range
double _calculateSuggestedWeight(double? currentWeight, double? heightCm) {
  if (heightCm == null || heightCm <= 0) return 65.0; // Default fallback
  
  // Healthy BMI range is 18.5-24.9
  // Using BMI of 22 (middle of healthy range) as ideal
  final heightM = heightCm / 100;
  final idealWeight = 22 * heightM * heightM;
  
  return double.parse(idealWeight.toStringAsFixed(1));
}

/// Calculate protein intake based on body weight
/// Standard recommendation: 1.6-2.2g per kg for active individuals
/// Using 2.0g per kg as target
Map<String, double> _calculateProteinIntake(double? weightKg) {
  if (weightKg == null || weightKg <= 0) {
    return {'current': 0, 'target': 120};
  }
  
  final targetProtein = (weightKg * 2.0).roundToDouble();
  // Current is 0 for now - would need to track from nutrition logs
  return {'current': 0, 'target': targetProtein};
}

/// Get current weight from trackers (Body Weight tracker)
double? _getCurrentWeightFromTrackers(List<Tracker> trackers) {
  try {
    final weightTracker = trackers.firstWhere(
      (t) => t.name.toLowerCase().contains('weight') || t.name.toLowerCase().contains('body'),
      orElse: () => throw Exception('No weight tracker'),
    );
    
    if (weightTracker.entries.isNotEmpty) {
      // Entries are sorted newest first
      return weightTracker.entries.first.value;
    }
  } catch (e) {
    // No weight tracker or no entries
  }
  return null;
}
```

### 5. Add Weight Update Dialog

```dart
/// Show dialog to update weight
Future<void> _showUpdateWeightDialog(BuildContext context, List<Tracker> trackers) async {
  final weightController = TextEditingController();
  
  // Find or create weight tracker
  Tracker? weightTracker;
  try {
    weightTracker = trackers.firstWhere(
      (t) => t.name.toLowerCase().contains('weight') || 
             t.name.toLowerCase().contains('body'),
    );
  } catch (e) {
    // No weight tracker exists, need to create one
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update Weight'),
      content: TextField(
        controller: weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Weight (kg)',
          hintText: 'Enter your current weight',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final weight = double.tryParse(weightController.text);
            if (weight == null || weight <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid weight')),
              );
              return;
            }

            try {
              if (weightTracker == null) {
                // Create new weight tracker
                await ref.read(trackersProvider.notifier).addTracker(
                  name: 'Body Weight',
                  unit: 'kg',
                );
                // Refresh to get the new tracker
                final newTrackers = ref.read(trackersProvider);
                weightTracker = newTrackers.firstWhere(
                  (t) => t.name == 'Body Weight',
                );
              }

              // Add entry
              await ref.read(trackersProvider.notifier).addEntry(
                weightTracker!.id,
                TrackerEntry(
                  date: DateTime.now(),
                  value: weight,
                ),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Weight updated to ${weight}kg')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
```

### 6. Update build() Method

In the build method, add:

```dart
final trackers = ref.watch(trackersProvider);
```

### 7. Update Weight Display in Header Card

Replace the weight calculation section:

```dart
// Get weight from trackers first, fallback to profile
final trackerWeight = _getCurrentWeightFromTrackers(trackers);
final displayWeight = trackerWeight ?? p?.weightKg;
final weight = displayWeight != null ? '${displayWeight.toStringAsFixed(1)} kg' : '-- kg';
```

### 8. Replace Stats Cards Section

Replace the hardcoded "Current" and "Goal" cards with dynamic versions:

```dart
profileAsync.when(
  data: (profile) {
    final trackerWeight = _getCurrentWeightFromTrackers(trackers);
    final currentWeight = trackerWeight ?? profile?.weightKg;
    final suggestedWeight = _calculateSuggestedWeight(currentWeight, profile?.heightCm);
    
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => _showUpdateWeightDialog(context, trackers),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _plainText('Current', theme.textTheme.bodySmall!),
                        Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _plainText(
                      currentWeight != null ? '${currentWeight.toStringAsFixed(1)} kg' : '-- kg',
                      theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 2,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _plainText('Suggested', theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.primary,
                  )),
                  const SizedBox(height: 6),
                  _plainText(
                    '${suggestedWeight.toStringAsFixed(1)} kg',
                    theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  },
  loading: () => /* Loading widgets */,
  error: (_, __) => const SizedBox.shrink(),
)
```

### 9. Update Habits & Goals Section

Replace the hardcoded habits section with dynamic tracking:

```dart
ListTile(
  title: const Text('Workout today'),
  subtitle: _isCheckingWorkout 
    ? const Text('Checking...')
    : Text(_hasWorkedOutToday ? 'Completed ✓' : 'Mark as done'),
  trailing: _isCheckingWorkout
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : Icon(
        _hasWorkedOutToday 
          ? Icons.check_circle 
          : Icons.check_circle_outline,
        color: _hasWorkedOutToday ? Colors.green : Colors.grey,
      ),
),
const Divider(height: 1),
// Protein intake tracker
profileAsync.when(
  data: (profile) {
    final trackerWeight = _getCurrentWeightFromTrackers(trackers);
    final weight = trackerWeight ?? profile?.weightKg;
    final proteinData = _calculateProteinIntake(weight);
    final current = proteinData['current']!.toInt();
    final target = proteinData['target']!.toInt();
    
    return ListTile(
      title: const Text('Protein intake'),
      subtitle: Text('$current/$target g (${(weight ?? 0).toStringAsFixed(1)}kg × 2.0g)'),
      trailing: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nutrition tracking coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.add),
      ),
    );
  },
  loading: () => const ListTile(
    title: Text('Protein intake'),
    subtitle: Text('Loading...'),
  ),
  error: (_, __) => const ListTile(
    title: Text('Protein intake'),
    subtitle: Text('0/120 g'),
  ),
)
```

---

## Features Implemented

### 1. Weight Update Functionality
- Tap on "Current" weight card to open a dialog
- Enter new weight value
- Automatically creates "Body Weight" tracker if it doesn't exist
- Adds entry to tracker with current date
- Updates display immediately

### 2. Suggested Weight (BMI-based)
- Calculates suggested weight using BMI formula
- Uses BMI of 22 (middle of healthy range 18.5-24.9)
- Formula: `22 × (height_m)²`
- Displays in place of "Goal"

### 3. Workout Tracker
- Checks workout logs on page init
- Looks for workouts logged today
- Shows green checkmark if workout completed
- Shows outline if not done yet
- Loading indicator while checking

### 4. Protein Intake Calculator
- Calculates target: `body_weight_kg × 2.0g`
- Standard recommendation for active individuals
- Displays as: `current/target g (weight × 2.0g)`
- Current is 0 until nutrition tracking is added

---

## Testing

1. **Weight Update:**
   - Tap on "Current" card
   - Enter weight (e.g., 70)
   - Verify it updates and shows in header

2. **Suggested Weight:**
   - Check that it shows calculated BMI-based weight
   - Verify it updates when height changes in profile

3. **Workout Tracker:**
   - Log a workout today
   - Refresh home page
   - Verify checkmark is green and says "Completed ✓"

4. **Protein Intake:**
   - Verify formula: weight × 2.0
   - Example: 70kg → 140g target

---

## Future Enhancements

- [ ] Add actual nutrition tracking for current protein intake
- [ ] Make workout tracker clickable to log quick workout
- [ ] Add water intake tracker
- [ ] Add sleep tracker
- [ ] Show weekly workout streak

---

**Last Updated:** October 19, 2025
