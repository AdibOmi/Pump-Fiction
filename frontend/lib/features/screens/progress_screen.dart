import 'package:flutter/material.dart';
import 'exercise_progress_screen.dart';
import 'progress_photos_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildCard(
              context,
              title: 'Exercise Progress', // <- renamed
              subtitle: 'View progress graphs for each exercise',
              icon: Icons.show_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
  builder: (_) => const ExerciseProgressScreen(exerciseName: ''),
),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              title: 'Progress Photos',
              subtitle: 'Track your body transformation over time',
              icon: Icons.photo_camera,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressPhotosScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              title: 'Custom Trackers',
              subtitle: 'Monitor custom metrics like weight or PRs',
              icon: Icons.bar_chart,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
