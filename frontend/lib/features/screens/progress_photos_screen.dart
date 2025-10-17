import 'package:flutter/material.dart';

class ProgressPhotosScreen extends StatelessWidget {
  const ProgressPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Photos')),
      body: const Center(
        child: Text('Coming soon: add front/side/back photos and compare over time.'),
      ),
    );
  }
}
