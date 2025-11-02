import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';

class CupertinoLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CupertinoLoader({
    Key? key,
    this.size = 32,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.darkVanilla,
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
