import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class MainTabScaffold extends StatelessWidget {
  final Widget child;
  final String currentLocation;
  const MainTabScaffold({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int currentIndex = 0;

    if (currentLocation.startsWith('/fitness'))
      currentIndex = 1;
    else if (currentLocation.startsWith('/social'))
      currentIndex = 2;
    else if (currentLocation.startsWith('/chat'))
      currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/fitness');
              break;
            case 2:
              context.go('/social');
              break;
            case 3:
              context.go('/chat');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_outlined),
            activeIcon: const Icon(Icons.fitness_center),
            label: l10n.fitness,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups_outlined),
            activeIcon: const Icon(Icons.groups),
            label: l10n.social,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_outlined),
            activeIcon: const Icon(Icons.chat),
            label: l10n.chat,
          ),
        ],
      ),
    );
  }
}
