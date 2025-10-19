import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import '../../features/fitness/progress/trackers/tracker_provider.dart';
import '../../features/fitness/state/routines_provider.dart';

/// Splash screen that shows while initial data is being loaded
/// Retries failed API calls up to 2 times before giving up
class LoadingSplashScreen extends ConsumerStatefulWidget {
  const LoadingSplashScreen({super.key});

  @override
  ConsumerState<LoadingSplashScreen> createState() => _LoadingSplashScreenState();
}

class _LoadingSplashScreenState extends ConsumerState<LoadingSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  bool _isLoading = true;
  String _loadingStatus = 'Loading...';
  int _profileRetries = 0;
  int _trackersRetries = 0;
  int _routinesRetries = 0;

  final int maxRetries = 2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Start loading data
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    print('🚀 LoadingSplash: Starting initial data load...');

    try {
      // Load all data in parallel with retries
      await Future.wait([
        _loadProfileWithRetry(),
        _loadTrackersWithRetry(),
        _loadRoutinesWithRetry(),
      ]);

      print('✅ LoadingSplash: All data loaded successfully!');

      // Wait a bit for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _loadingStatus = 'Ready!';
          _isLoading = false;
        });

        // Navigate to home
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      print('❌ LoadingSplash: Failed to load data after retries: $e');

      if (mounted) {
        setState(() {
          _loadingStatus = 'Failed to load data';
          _isLoading = false;
        });

        // Show error and retry option
        _showErrorDialog();
      }
    }
  }

  Future<void> _loadProfileWithRetry() async {
    while (_profileRetries <= maxRetries) {
      try {
        setState(() {
          _loadingStatus = 'Loading profile...';
        });

        print('🔄 LoadingSplash: Loading profile (attempt ${_profileRetries + 1}/${maxRetries + 1})');

        // Force refresh profile
        await ref.read(userProfileProvider.notifier).refresh();

        print('✅ LoadingSplash: Profile loaded');
        return;
      } catch (e) {
        _profileRetries++;
        print('❌ LoadingSplash: Profile load failed (attempt $_profileRetries): $e');

        if (_profileRetries > maxRetries) {
          throw Exception('Failed to load profile after $maxRetries retries');
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: _profileRetries));
      }
    }
  }

  Future<void> _loadTrackersWithRetry() async {
    while (_trackersRetries <= maxRetries) {
      try {
        setState(() {
          _loadingStatus = 'Loading trackers...';
        });

        print('🔄 LoadingSplash: Loading trackers (attempt ${_trackersRetries + 1}/${maxRetries + 1})');

        // Force refresh trackers
        await ref.read(trackersProvider.notifier).refresh();

        print('✅ LoadingSplash: Trackers loaded');
        return;
      } catch (e) {
        _trackersRetries++;
        print('❌ LoadingSplash: Trackers load failed (attempt $_trackersRetries): $e');

        if (_trackersRetries > maxRetries) {
          throw Exception('Failed to load trackers after $maxRetries retries');
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: _trackersRetries));
      }
    }
  }

  Future<void> _loadRoutinesWithRetry() async {
    while (_routinesRetries <= maxRetries) {
      try {
        setState(() {
          _loadingStatus = 'Loading routines...';
        });

        print('🔄 LoadingSplash: Loading routines (attempt ${_routinesRetries + 1}/${maxRetries + 1})');

        // Force refresh routines
        await ref.read(routinesProvider.notifier).refresh();

        print('✅ LoadingSplash: Routines loaded');
        return;
      } catch (e) {
        _routinesRetries++;
        print('❌ LoadingSplash: Routines load failed (attempt $_routinesRetries): $e');

        if (_routinesRetries > maxRetries) {
          throw Exception('Failed to load routines after $maxRetries retries');
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: _routinesRetries));
      }
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Loading Failed'),
        content: const Text(
          'Failed to load your data. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('Go to Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset retry counters
              _profileRetries = 0;
              _trackersRetries = 0;
              _routinesRetries = 0;
              // Retry loading
              _loadInitialData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              // Background image
              SizedBox.expand(
                child: Image.asset(
                  'assets/images/splash_screen.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              // Loading indicator at bottom
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading) ...[
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadingStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadingStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
