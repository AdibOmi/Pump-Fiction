import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../fitness/presentation/pages/fitness_page.dart';
import '../../../social/presentation/pages/social_page.dart';
import '../../../marketplace/presentation/pages/marketplace_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages corresponding to bottom navigation tabs
  final List<Widget> _pages = [
    const DashboardPage(),
    const FitnessPage(),
    const SocialPage(),
    const MarketplacePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pump Fiction'),
      drawer: const CustomDrawer(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
