import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../fitness/progress/trackers/tracker_provider.dart';
import '../../../fitness/progress/trackers/tracker_models.dart';
import '../../../fitness/repositories/workout_log_repository.dart';
import '../../../fitness/state/routines_provider.dart';
import '../../../fitness/models/routine_models.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final WorkoutLogRepository _workoutRepo = WorkoutLogRepository();
  bool _hasWorkedOutToday = false;
  bool _isCheckingWorkout = true;

  @override
  void initState() {
    super.initState();
    _checkTodayWorkout();
  }

  Future<void> _checkTodayWorkout() async {
    try {
      final logs = await _workoutRepo.getAllWorkoutLogs(limit: 30);
      final today = DateTime.now();
      final hasWorkout = logs.any(
        (log) =>
            log.date.year == today.year &&
            log.date.month == today.month &&
            log.date.day == today.day,
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

  /// Calculate BMI and suggest healthy weight range
  double _calculateSuggestedWeight(double? currentWeight, double? heightCm) {
    if (heightCm == null || heightCm <= 0) return 65.0; // Default fallback

    // Healthy BMI range is 18.5-24.9
    // Using BMI of 22 (middle of healthy range) as ideal
    final heightM = heightCm / 100;
    final idealWeight = 22 * heightM * heightM;

    return double.parse(idealWeight.toStringAsFixed(1));
  }

  /// Get today's workout day from active routine
  /// Returns the day label (e.g., "Push", "Pull", "Legs") or "Rest Day"
  String _getTodaysWorkout(List<RoutinePlan> routines) {
    print('🏋️ _getTodaysWorkout: ${routines.length} routines available');
    if (routines.isEmpty) return 'Rest Day';

    // Find the active (non-archived) routine
    final activeRoutine = routines.firstWhere(
      (r) => !r.isArchived,
      orElse: () => routines.first,
    );
    print('🏋️ Active routine: ${activeRoutine.title}, mode: ${activeRoutine.mode}');

    if (activeRoutine.dayPlans.isEmpty) return 'Rest Day';
    print('🏋️ Day plans: ${activeRoutine.dayPlans.length} days');
    
    // For weekly mode, match by day of week
    if (activeRoutine.mode == PlanMode.weekly) {
      final today = DateTime.now().weekday; // 1=Monday, 7=Sunday
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final todayName = dayNames[today - 1];
      
      // Find matching day plan
      final todayPlan = activeRoutine.dayPlans.firstWhere(
        (day) => day.label.toLowerCase().contains(todayName.toLowerCase()),
        orElse: () => activeRoutine.dayPlans.first,
      );
      
      // If the day has no exercises, it's a rest day
      if (todayPlan.exercises.isEmpty) return 'Rest Day';
      
      return todayPlan.label;
    }
    
    // For nDays mode, cycle through days based on workout count
    // This is simplified - you might want to track actual cycle position
    final dayIndex = DateTime.now().day % activeRoutine.dayPlans.length;
    final todayPlan = activeRoutine.dayPlans[dayIndex];
    
    if (todayPlan.exercises.isEmpty) return 'Rest Day';
    return todayPlan.label;
  }

  /// Get current weight from trackers (Body Weight tracker)
  double? _getCurrentWeightFromTrackers(List<Tracker> trackers) {
    try {
      final weightTracker = trackers.firstWhere(
        (t) =>
            t.name.toLowerCase().contains('weight') ||
            t.name.toLowerCase().contains('body'),
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

  /// Show dialog to update weight
  Future<void> _showUpdateWeightDialog(
    BuildContext context,
    List<Tracker> trackers,
  ) async {
    final weightController = TextEditingController();

    // Find or create weight tracker
    Tracker? weightTracker;
    try {
      weightTracker = trackers.firstWhere(
        (t) =>
            t.name.toLowerCase().contains('weight') ||
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
                  await ref
                      .read(trackersProvider.notifier)
                      .addTracker(name: 'Body Weight', unit: 'kg');
                  // Refresh to get the new tracker
                  final newTrackers = ref.read(trackersProvider);
                  weightTracker = newTrackers.firstWhere(
                    (t) => t.name == 'Body Weight',
                  );
                }

                // Add entry
                await ref
                    .read(trackersProvider.notifier)
                    .addEntry(
                      weightTracker!.id,
                      TrackerEntry(date: DateTime.now(), value: weight),
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Weight updated to ${weight}kg')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Simple helper for plain, borderless text
  // Simple helper for plain, borderless text
  static Widget _plainText(String text, TextStyle style) =>
      Text(text, style: style);

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage: Building home page...');
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final trackers = ref.watch(trackersProvider);
    print('🏠 HomePage: About to watch routinesProvider...');
    final routines = ref.watch(routinesProvider);
    print('🏠 HomePage: RoutinesProvider watched! Routines count: ${routines.length}');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width header card: avatar + greeting (now bound to profile data)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: profileAsync.when(
                    data: (profile) {
                      // profile is UserProfileModel?
                      final UserProfileModel? p = profile;
                      final rawName = p?.fullName;
                      final name = rawName != null && rawName.isNotEmpty
                          ? 'Welcome, $rawName'
                          : 'Welcome';
                      final program = p?.fitnessGoal != null
                          ? p!.fitnessGoal!.displayName
                          : 'No Program';

                      // Get weight from trackers first, fallback to profile
                      final trackerWeight = _getCurrentWeightFromTrackers(
                        trackers,
                      );
                      final displayWeight = trackerWeight ?? p?.weightKg;
                      final weight = displayWeight != null
                          ? '${displayWeight.toStringAsFixed(1)} kg'
                          : '-- kg';

                      return Row(
                        children: [
                          const SizedBox(width: 8),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage('assets/images/default.jpg'),
                                fit: BoxFit.cover,
                              ),
                              color: theme.colorScheme.surface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Texts occupy the remaining width
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _plainText(
                                  name,
                                  theme.textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _plainText(
                                  program,
                                  theme.textTheme.bodyMedium!,
                                ),
                                const SizedBox(height: 6),
                                _plainText(
                                  'Weight: $weight',
                                  theme.textTheme.bodySmall!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => Row(
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/default.jpg'),
                              fit: BoxFit.cover,
                            ),
                            color: theme.colorScheme.surface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _plainText(
                                'Loading...',
                                theme.textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _plainText(
                                'Please wait',
                                theme.textTheme.bodyMedium!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    error: (err, stack) => Row(
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/default.jpg'),
                              fit: BoxFit.cover,
                            ),
                            color: theme.colorScheme.surface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _plainText(
                                'Welcome',
                                theme.textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _plainText(
                                'No program found',
                                theme.textTheme.bodyMedium!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats cards row
              profileAsync.when(
                data: (profile) {
                  final trackerWeight = _getCurrentWeightFromTrackers(trackers);
                  final currentWeight = trackerWeight ?? profile?.weightKg;
                  final suggestedWeight = _calculateSuggestedWeight(
                    currentWeight,
                    profile?.heightCm,
                  );

                  return Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () =>
                                _showUpdateWeightDialog(context, trackers),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _plainText(
                                        'Current',
                                        theme.textTheme.bodySmall!,
                                      ),
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _plainText(
                                    currentWeight != null
                                        ? '${currentWeight.toStringAsFixed(1)} kg'
                                        : '-- kg',
                                    theme.textTheme.titleLarge!.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _plainText(
                                  'Suggested',
                                  theme.textTheme.bodySmall!.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _plainText(
                                  '${suggestedWeight.toStringAsFixed(1)} kg',
                                  theme.textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _plainText('Current', theme.textTheme.bodySmall!),
                              const SizedBox(height: 6),
                              _plainText(
                                '--',
                                theme.textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _plainText(
                                'Suggested',
                                theme.textTheme.bodySmall!,
                              ),
                              const SizedBox(height: 6),
                              _plainText(
                                '--',
                                theme.textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Primary CTA
              // Card(
              //   elevation: 1,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(12.0),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('Ready for your next workout?', style: theme.textTheme.bodyMedium),
              //               const SizedBox(height: 8),
              //               ElevatedButton(
              //                 onPressed: () {
              //                   // TODO: wire to routine picker
              //                 },
              //                 style: ElevatedButton.styleFrom(
              //                   backgroundColor: const Color(0xFFFF8383),
              //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //                 ),
              //                 child: const Padding(
              //                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              //                   child: Text('Start Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         OutlinedButton(
              //           onPressed: () {},
              //           child: const Text('Quick Log'),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 18),

              // Recent Activity
              // Text('Recent activity', style: theme.textTheme.titleMedium),
              // const SizedBox(height: 8),
              // SizedBox(
              //   height: 120,
              //   child: ListView.separated(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: 3,
              //     separatorBuilder: (_, __) => const SizedBox(width: 12),
              //     itemBuilder: (context, index) {
              //       return Card(
              //         elevation: 2,
              //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //         child: Container(
              //           width: 220,
              //           padding: const EdgeInsets.all(12),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('Workout ${index + 1}', style: theme.textTheme.titleSmall),
              //               const SizedBox(height: 6),
              //               Text('Legs • 45 min', style: theme.textTheme.bodySmall),
              //               const Spacer(),
              //               LinearProgressIndicator(value: (index + 1) * 0.25),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              const SizedBox(height: 18),

              // Quick Actions (minimal)
              // Text('Shortcuts', style: theme.textTheme.titleMedium),
              // const SizedBox(height: 8),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     _shortcutButton(context, Icons.fitness_center, 'New Routine'),
              //     _shortcutButton(context, Icons.add, 'Add Exercise'),
              //     _shortcutButton(context, Icons.chat_bubble_outline, 'Coach'),
              //   ],
              // ),
              const SizedBox(height: 18),

              // Habit / Goal Tracker
              Text('Habits & Goals', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Workout today'),
                      subtitle: _isCheckingWorkout
                          ? const Text('Checking...')
                          : Text(
                              _hasWorkedOutToday
                                  ? 'Completed ✓'
                                  : 'Mark as done',
                            ),
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
                              color: _hasWorkedOutToday
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Today\'s Workout'),
                      subtitle: Text(
                        _getTodaysWorkout(routines),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getTodaysWorkout(routines) == 'Rest Day'
                              ? Colors.grey
                              : theme.colorScheme.primary,
                        ),
                      ),
                      trailing: Icon(
                        _getTodaysWorkout(routines) == 'Rest Day'
                            ? Icons.hotel
                            : Icons.fitness_center,
                        color: _getTodaysWorkout(routines) == 'Rest Day'
                            ? Colors.grey
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shortcutButton(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon, size: 28, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // no helper functions
}
