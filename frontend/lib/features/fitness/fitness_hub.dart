import 'package:flutter/material.dart';
import 'routine/routine_hub.dart';
import 'workout/workout_page.dart';
import 'nutrition/nutrition_page.dart';
import 'progress/progress_page.dart';
import 'widgets/section_card.dart';
import 'models/hub_item.dart';
import 'progress/progress_root.dart';


class FitnessHubScreen extends StatelessWidget {
  const FitnessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <HubItem>[
      HubItem('Routine', Icons.event_note, const RoutineHubPage()),
      HubItem('Workout', Icons.fitness_center, const WorkoutPage()),
      HubItem('Nutrition', Icons.restaurant, const NutritionPage()),
      HubItem('Progress', Icons.show_chart, const ProgressRoot()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              childAspectRatio: 4.3,
            ),
            itemBuilder: (context, i) => SectionCard(item: items[i]),
          ),
        ),
      ),
    );
  }
}
