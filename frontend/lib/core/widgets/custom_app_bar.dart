import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showHamburger;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showHamburger = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showHamburger
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
