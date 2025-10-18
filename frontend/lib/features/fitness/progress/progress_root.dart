import 'package:flutter/material.dart';
import 'progress_page.dart';
import 'trackers/trackers_page.dart';

class ProgressRoot extends StatelessWidget {
  const ProgressRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Workout Progress'),
              subtitle: const Text('Graphs based on your logged workouts'),
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
              title: const Text('Your Trackers'),
              subtitle: const Text('Create custom trackers and log values'),
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
