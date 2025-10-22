import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final glassTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'SF Pro', // iOS font
  primaryColor: CupertinoColors.black,
  scaffoldBackgroundColor: const Color(0xFF343434),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF343434),
    elevation: 0,
    iconTheme: const IconThemeData(color: CupertinoColors.black),
    titleTextStyle: const TextStyle(
      color: CupertinoColors.black,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'SF Pro',
    ),
    shape: Border(
      bottom: BorderSide(
        color: Colors.white.withOpacity(0.22),
        width: 1.2,
      ),
    ),
  ),
  cardColor: Colors.white.withOpacity(0.16),
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
  primaryColor: CupertinoColors.black,
  barBackgroundColor: const Color(0xFF343434),
  scaffoldBackgroundColor: const Color(0xFF343434),
  textTheme: const CupertinoTextThemeData(
    textStyle: TextStyle(
      color: CupertinoColors.black,
      fontFamily: 'SF Pro',
      fontSize: 16,
    ),
  ),
);
