import 'package:flutter/material.dart';

class OurProgramsPage extends StatelessWidget {
  const OurProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Programs')),
      body: const Center(
        child: Text(
          'Here you’ll show built-in routines (e.g. PPL, Full Body, Upper-Lower, etc.)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
