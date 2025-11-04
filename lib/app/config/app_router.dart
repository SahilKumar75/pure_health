import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pure_health/features/home/presentation/pages/home_page.dart';
import 'package:pure_health/features/profile/presentation/pages/profile_page.dart';
import 'package:pure_health/features/history/history_report_page.dart';
import 'package:pure_health/features/settings/presentation/pages/settings_page.dart';
import 'package:pure_health/features/ai_analysis/presentation/pages/ai_analysis_page.dart';
import 'package:pure_health/features/dashboard/presentation/pages/dashboard_page.dart';

/// Custom smooth page transition with fade + slide effect
CustomTransitionPage<T> smoothPage<T>({required Widget child}) =>
    CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
    );

/// Navigation configuration
class AppRouter {
  /// Navigation items for sidebar - Ordered by priority (Profile and Settings at bottom)
  static const List<Map<String, dynamic>> navigationItems = [
    // High Priority Items
    {
      'icon': 'home',
      'label': 'Home',
      'index': 0,
      'route': '/',
    },
    {
      'icon': 'dashboard',
      'label': 'Dashboard',
      'index': 1,
      'route': '/dashboard',
    },
    {
      'icon': 'ai',
      'label': 'AI Analysis',
      'index': 2,
      'route': '/ai-analysis',
    },
    {
      'icon': 'history',
      'label': 'History',
      'index': 3,
      'route': '/history',
    },
    // Bottom Section - User Settings
    {
      'icon': 'profile',
      'label': 'Profile',
      'index': 4,
      'route': '/profile',
    },
    {
      'icon': 'settings',
      'label': 'Settings',
      'index': 5,
      'route': '/settings',
    },
  ];

  /// Get route by index
  static String getRouteByIndex(int index) {
    try {
      final item = navigationItems.firstWhere(
        (item) => item['index'] == index,
        orElse: () => {'route': '/'},
      );
      return item['route'] as String;
    } catch (e) {
      return '/';
    }
  }

  /// Get index by route
  static int getIndexByRoute(String route) {
    try {
      final item = navigationItems.firstWhere(
        (item) => item['route'] == route,
        orElse: () => {'index': 0},
      );
      return item['index'] as int;
    } catch (e) {
      return 0;
    }
  }

  /// GoRouter configuration with Cupertino transitions
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              state.uri.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                smoothPage(child: const HomePage()),
          ),

          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                smoothPage(child: const DashboardPage()),
          ),

          // AI Analysis
          GoRoute(
            path: '/ai-analysis',
            name: 'ai-analysis',
            pageBuilder: (context, state) =>
                smoothPage(child: const AIAnalysisPage()),
          ),

          // History
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) =>
                smoothPage(child: const HistoryReportPage()),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                smoothPage(child: const SettingsPage()),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                smoothPage(child: const ProfilePage()),
          ),
        ],
      ),
    ],
  );
}
