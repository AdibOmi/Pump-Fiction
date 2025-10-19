import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/data/models/user_profile_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Simple helper for plain, borderless text
  static Widget _plainText(String text, TextStyle style) => Text(text, style: style);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
  final profileAsync = ref.watch(userProfileProvider);

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: profileAsync.when(
                    data: (profile) {
                      // profile is UserProfileModel?
                      final UserProfileModel? p = profile;
                      final rawName = p?.fullName;
                      final name = rawName != null && rawName.isNotEmpty ? 'Welcome, $rawName' : 'Welcome';
                      final program = p?.fitnessGoal != null ? p!.fitnessGoal!.displayName : 'No Program';
                      final weight = p?.weightKg != null ? '${p!.weightKg} kg' : '-- kg';

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
                                _plainText(name, theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                _plainText(program, theme.textTheme.bodyMedium!),
                                const SizedBox(height: 6),
                                _plainText('Weight: $weight', theme.textTheme.bodySmall!),
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
                              _plainText('Loading...', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              _plainText('Please wait', theme.textTheme.bodyMedium!),
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
                              _plainText('Welcome', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              _plainText('No program found', theme.textTheme.bodyMedium!),
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
              Row(
                children: [
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
                            _plainText('Current', theme.textTheme.bodySmall!),
                            const SizedBox(height: 6),
                            _plainText('58 kg', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _plainText('Goal', theme.textTheme.bodySmall!),
                            const SizedBox(height: 6),
                            _plainText('65 kg', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Workout today'),
                      subtitle: const Text('Mark as done'),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Protein intake'),
                      subtitle: const Text('80/120 g'),
                      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon, size: 28, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // no helper functions
}
