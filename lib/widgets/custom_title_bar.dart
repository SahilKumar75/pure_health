import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'glass_container.dart';

class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;

  const CustomTitleBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.height = kToolbarHeight + 16, // Increased height for better visibility
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.zero,
      child: SizedBox(
        height: height,
        child: AppBar(
          title: Text(title),
          centerTitle: true,
          leading: leading,
          actions: actions ?? [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(CupertinoIcons.person_crop_circle, size: 28),
                onPressed: () {
                  // TODO: Implement account section navigation
                },
              ),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
