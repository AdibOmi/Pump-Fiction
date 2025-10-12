import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'fitness/fitness_hub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool debugSkipAuth = true; // <-- set to false when re-enabling auth

    return MaterialApp.router(
      routerConfig: appRouter, // keep your existing router
      title: 'Pump Fiction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // Wrap/override routed content during development
      builder: (context, child) {
        if (debugSkipAuth) {
          return const FitnessHubScreen(); // <-- bypass login/signup
        }
// normal routed content
      },
    );
  }
}
