import 'package:flutter/material.dart';
import 'package:pure_health/app/config/router.dart';
import 'package:pure_health/app/config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: glassTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
