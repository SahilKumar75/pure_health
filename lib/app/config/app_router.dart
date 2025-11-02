import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pure_health/features/home/presentation/pages/home_page.dart';
import 'package:pure_health/features/profile/presentation/pages/profile_page.dart';
import 'package:pure_health/features/history/history_report_page.dart';
import 'package:pure_health/features/settings/presentation/pages/settings_page.dart';
import 'package:pure_health/features/chat/presentation/pages/chat_page.dart';
import 'package:pure_health/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pure_health/features/reports/presentation/pages/reports_page.dart';

/// Cupertino page transition
CustomTransitionPage<T> cupertinoPage<T>({required Widget child}) =>
    CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          CupertinoPageTransition(
            primaryRouteAnimation: animation,
            secondaryRouteAnimation: secondaryAnimation,
            linearTransition: true,
            child: child,
          ),
    );

/// Navigation configuration
class AppRouter {
  /// Navigation items for sidebar
  static const List<Map<String, dynamic>> navigationItems = [
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
      'icon': 'history',
      'label': 'History',
      'index': 2,
      'route': '/history',
    },
    {
      'icon': 'settings',
      'label': 'Settings',
      'index': 3,
      'route': '/settings',
    },
    {
      'icon': 'chat',
      'label': 'Chat',
      'index': 4,
      'route': '/chat',
    },
    {
      'icon': 'reports',
      'label': 'Reports',
      'index': 5,
      'route': '/reports',
    },
    {
      'icon': 'profile',
      'label': 'Profile',
      'index': 6,
      'route': '/profile',
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
            const Text(
              '❌ Page not found',
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
                cupertinoPage(child: const HomePage()),
          ),

          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                cupertinoPage(child: const DashboardPage()),
          ),

          // Chat
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) =>
                cupertinoPage(child: const ChatPage()),
          ),

          // Reports
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) =>
                cupertinoPage(child: const ReportsPage()),
          ),

          // History
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) =>
                cupertinoPage(child: const HistoryReportPage()),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                cupertinoPage(child: const SettingsPage()),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                cupertinoPage(child: const ProfilePage()),
          ),
        ],
      ),
    ],
  );
}
