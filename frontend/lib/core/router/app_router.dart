import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../features/chat/presentation/chat.dart';
import '../widgets/custom_tabbar.dart';
import '../../core/widgets/splash_screen.dart';

import '../../features/fitness/fitness_hub.dart';



final GoRouter appRouter = GoRouter(
  initialLocation: '/fitness',
  routes: [
    // Pages without bottom tab bar
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(path: '/marketplace', builder: (context, state) => const MarketplacePage()),

    // ShellRoute for persistent bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainTabScaffold(
        child: child,
        currentLocation: state.location,
      ),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/fitness', builder: (context, state) => const FitnessHubScreen()),
        GoRoute(path: '/social', builder: (context, state) => const SocialPage()),
        GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      ],
    ),
  ],
);
