import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final glassTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'SF Pro', // iOS font
  primaryColor: CupertinoColors.activeBlue,
  scaffoldBackgroundColor: CupertinoColors.extraLightBackgroundGray.withOpacity(0.7),
  appBarTheme: AppBarTheme(
    backgroundColor: CupertinoColors.systemGrey6.withOpacity(0.6),
    elevation: 0,
    iconTheme: const IconThemeData(color: CupertinoColors.activeBlue),
    titleTextStyle: const TextStyle(
      color: CupertinoColors.black,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'SF Pro',
    ),
  ),
  cardColor: CupertinoColors.systemGrey6.withOpacity(0.5),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: CupertinoColors.black,
      fontFamily: 'SF Pro',
      fontSize: 16,
    ),
  ),
);

final glassCupertinoTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: CupertinoColors.activeBlue,
  barBackgroundColor: CupertinoColors.systemGrey6.withOpacity(0.6),
  scaffoldBackgroundColor: CupertinoColors.extraLightBackgroundGray.withOpacity(0.7),
  textTheme: const CupertinoTextThemeData(
    textStyle: TextStyle(
      color: CupertinoColors.black,
      fontFamily: 'SF Pro',
      fontSize: 16,
    ),
  ),
);
