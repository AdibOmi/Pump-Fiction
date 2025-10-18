import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class OurProgramsPage extends StatelessWidget {
  const OurProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ourPrograms)),
      body: const Center(child: Text('Coming Soon')),
    );
  }
}
