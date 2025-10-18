import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  //final VoidCallback onDrawerTap;
  //final VoidCallback onSettingsTap;

  const CustomAppBar({
    super.key,
    // required this.onDrawerTap,
    // required this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/starry_sky.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      elevation: 10,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: Column(
        // MainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/pump_logo.png', height: 50),
          Text(
            AppLocalizations.of(context)!.home,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            context.go('/settings');
          },
        ),
      ],
    );
  }
}
