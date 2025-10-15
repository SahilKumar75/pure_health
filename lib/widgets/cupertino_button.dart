import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'glass_container.dart';

class CupertinoButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const CupertinoButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(32),
      blur: 8,
      opacity: 0.18,
      padding: EdgeInsets.zero,
      child: CupertinoButton(
        color: color?.withOpacity(0.7) ?? CupertinoColors.activeBlue.withOpacity(0.7),
        child: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}
