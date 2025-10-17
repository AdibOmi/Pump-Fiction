import 'package:flutter/material.dart';
import 'our_programs_page.dart';
import 'custom_routines_page.dart';

class RoutineHubPage extends StatelessWidget {
  const RoutineHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routine')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChoiceCard(
            title: 'Our Programs',
            subtitle: 'Curated plans (PPL, UL, Full-body)',
            icon: Icons.auto_awesome,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OurProgramsPage()),
            ),
          ),
          const SizedBox(height: 16),
          _ChoiceCard(
            title: 'Custom Routines',
            subtitle: 'Build your own weekly plan',
            icon: Icons.tune,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomRoutinesPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(blurRadius: 10, offset: Offset(0, 6), color: Colors.black12),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primary.withOpacity(.10),
              ),
              child: Icon(icon, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
