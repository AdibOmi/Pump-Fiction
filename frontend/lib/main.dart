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
    const bool debugSkipAuth = true; // flip to false when done

    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Pump Fiction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) {
        if (debugSkipAuth) {
          // Provide a Navigator so push() works
          return Navigator(
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const FitnessHubScreen()),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
