import 'package:flutter/material.dart';
import '../screens/exercise_progress_screen.dart';
import '../screens/progress_photos_screen.dart';

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
              title: const Text('Exercise Progress'),
              subtitle: const Text('Track progress graphs by exercise'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExerciseProgressScreen(exerciseName: '')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Progress Photos'),
              subtitle: const Text('Front / side / back (coming soon)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProgressPhotosScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
