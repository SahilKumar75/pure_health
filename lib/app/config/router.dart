import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pure_health/features/home/presentation/pages/home_page.dart';
import 'package:pure_health/features/profile/presentation/pages/profile_page.dart';
import 'package:pure_health/features/history/history_report_page.dart';
import 'package:pure_health/features/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';

CustomTransitionPage<T> cupertinoPage<T>({required Widget child}) => CustomTransitionPage<T>(
  child: child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) => CupertinoPageTransition(
    primaryRouteAnimation: animation,
    secondaryRouteAnimation: secondaryAnimation,
    linearTransition: true,
    child: child,
  ),
);

final GoRouter appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => cupertinoPage(child: const HomePage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => cupertinoPage(child: const ProfilePage()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => cupertinoPage(child: const HistoryReportPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => cupertinoPage(child: const SettingsPage()),
        ),
      ],
    ),
  ],
);
