import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const BreadcrumbNavigation({
    Key? key,
    required this.items,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkCream.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildBreadcrumbItem(items[i], i == items.length - 1),
            if (i < items.length - 1) _buildSeparator(),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item, bool isLast) {
    return MouseRegion(
      cursor: item.onTap != null && !isLast
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isLast ? null : item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isLast
                ? AppColors.accentPink.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: isLast
                      ? AppColors.accentPink
                      : AppColors.mediumGray,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                item.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLast
                      ? AppColors.charcoal
                      : AppColors.mediumGray,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        CupertinoIcons.chevron_right,
        size: 14,
        color: AppColors.mediumGray.withOpacity(0.5),
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}
