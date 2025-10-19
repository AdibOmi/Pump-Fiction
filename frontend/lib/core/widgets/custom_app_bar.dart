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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppBar(
      backgroundColor: isLight ? const Color.fromARGB(255, 255, 255, 255) : Colors.transparent,
      flexibleSpace: isLight
          ? null
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/starry_sky.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
      elevation: 10,
      centerTitle: true,
      title: Column(
        // MainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/pump_logo.png',
            height: 60,
          ),
          // Text('Home', style: TextStyle(fontSize: 10),),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: isLight ? Colors.black87 : Colors.white),
          onPressed: () {
            context.go('/settings');
          },
        ),
      ],
    );
  }
}
