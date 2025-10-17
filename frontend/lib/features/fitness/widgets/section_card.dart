import 'package:flutter/material.dart';
import '../models/hub_item.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.item});
  final HubItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
  try {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => item.page),
    );
  } catch (e, st) {
    debugPrint('Navigation error: $e\n$st');
  }
},

      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Colors.black12),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40),
              const SizedBox(height: 12),
              Text(item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                'Tap to open',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
