import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';






class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Simple helper for plain, borderless text
  static Widget _plainText(String text, TextStyle style) => Text(text, style: style);













  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + greeting
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: const AssetImage('assets/images/default.jpg'),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _plainText('Welcome, Alif', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        _plainText('Bodybuilding Program', theme.textTheme.bodyMedium!),
                      ],
                    ),
                  ),
                  
                ],
              ),

              const SizedBox(height: 20),

              // Stats cards row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _plainText('Current', theme.textTheme.bodySmall!),
                            const SizedBox(height: 6),
                            _plainText('58 kg', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _plainText('Goal', theme.textTheme.bodySmall!),
                            const SizedBox(height: 6),
                            _plainText('65 kg', theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),


              const SizedBox(height: 20),

              // Recent routines / placeholder
              _plainText('Your Programs', theme.textTheme.titleMedium!),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('Custom: Push', style: theme.textTheme.titleSmall),
                  subtitle: Text('1 day • 3 exercises', style: theme.textTheme.bodySmall),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
                  onTap: () => Navigator.of(context).pushNamed('/routines'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}