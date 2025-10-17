import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainTabScaffold extends StatelessWidget {
  final Widget child;
  final String currentLocation; 
  const MainTabScaffold({super.key, required this.child, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;

    if (currentLocation.startsWith('/fitness')) currentIndex = 1;
    else if (currentLocation.startsWith('/social')) currentIndex = 2;
    else if (currentLocation.startsWith('/chat')) currentIndex = 3;

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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Fitness'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Social'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
        ],
      ),
    );
  }
}
