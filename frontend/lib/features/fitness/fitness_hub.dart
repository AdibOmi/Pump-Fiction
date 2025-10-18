import 'package:flutter/material.dart';
import 'routine/routine_hub.dart';
import 'workout/workout_page.dart';
import 'nutrition/nutrition_page.dart';
import 'progress/progress_page.dart';
import 'widgets/section_card.dart';
import 'models/hub_item.dart';
import 'progress/progress_root.dart';
import '../../l10n/app_localizations.dart';
import 'journal/presentation/pages/journal_sessions_page.dart';

class FitnessHubScreen extends StatelessWidget {
  const FitnessHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final items = <HubItem>[
      HubItem(l10n.routine, Icons.event_note, const RoutineHubPage()),
      HubItem(l10n.workout, Icons.fitness_center, const WorkoutPage()),
      HubItem(l10n.nutrition, Icons.restaurant, const NutritionPage()),
      HubItem(l10n.progress, Icons.show_chart, const ProgressRoot()),
      HubItem('Journal', Icons.book, const JournalSessionsPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fitness)),
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
