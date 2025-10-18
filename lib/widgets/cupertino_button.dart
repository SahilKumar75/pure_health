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
    return Container(
      decoration: BoxDecoration(
        color: color?.withOpacity(0.7) ?? CupertinoColors.activeBlue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        color: Colors.transparent,
        child: Text(text),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
