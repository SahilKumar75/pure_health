import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return CupertinoButton(
      color: color ?? CupertinoColors.activeBlue,
      child: Text(text),
      onPressed: onPressed,
    );
  }
}
