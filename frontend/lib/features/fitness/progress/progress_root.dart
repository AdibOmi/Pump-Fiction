import 'package:flutter/material.dart';
import 'progress_page.dart';
import 'trackers/trackers_page.dart';
import '../../../l10n/app_localizations.dart';

class ProgressRoot extends StatelessWidget {
  const ProgressRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progress)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.show_chart),
              title: Text(l10n.workoutProgress),
              subtitle: Text(l10n.graphsBasedOnYourLoggedWorkouts),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.track_changes),
              title: Text(l10n.yourTrackers),
              subtitle: Text(l10n.createCustomTrackersAndLogValues),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrackersPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
