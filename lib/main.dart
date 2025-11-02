import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:pure_health/core/theme/app_theme.dart';
import 'package:pure_health/app/config/app_router.dart';
import 'package:pure_health/shared/widgets/keyboard_shortcuts_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return KeyboardShortcutsHandler(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'PureHealth',
            theme: AppTheme.getLightTheme(),
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
