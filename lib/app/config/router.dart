import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pure_health/features/home/presentation/pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    // Add more routes here as needed
  ],
);
