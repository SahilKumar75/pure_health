import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';

class CupertinoSwitchWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const CupertinoSwitchWidget({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AppColors.darkVanilla,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: AppColors.dimText,
    );
  }
}
