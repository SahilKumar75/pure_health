import 'package:flutter/material.dart';
import 'package:pure_health/core/utils/responsive_utils.dart';

/// Responsive grid that automatically adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = _getColumns(context);
    
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((child) {
              final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  int _getColumns(BuildContext context) {
    if (context.isMobile) {
      return mobileColumns ?? 1;
    } else if (context.isTablet) {
      return tabletColumns ?? 2;
    } else {
      return desktopColumns ?? 3;
    }
  }
}

/// Responsive card grid specifically for dashboard-style layouts
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> cards;
  final EdgeInsets? padding;
  final double? spacing;

  const ResponsiveCardGrid({
    Key? key,
    required this.cards,
    this.padding,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultSpacing = ResponsiveUtils.getSpacing(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );

    return ResponsiveGrid(
      spacing: spacing ?? defaultSpacing,
      runSpacing: spacing ?? defaultSpacing,
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      padding: padding ?? EdgeInsets.all(context.horizontalPadding),
      children: cards,
    );
  }
}

/// Responsive row that stacks vertically on mobile
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool forceColumn;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16,
    this.forceColumn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shouldStack = context.isMobile || forceColumn;

    if (shouldStack) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: _mapCrossAlignment(crossAxisAlignment),
        children: _buildChildrenWithSpacing(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _buildChildrenWithSpacing(),
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(
          width: spacing,
          height: spacing,
        ));
      }
    }
    return result;
  }

  CrossAxisAlignment _mapCrossAlignment(CrossAxisAlignment crossAlignment) {
    switch (crossAlignment) {
      case CrossAxisAlignment.start:
        return CrossAxisAlignment.start;
      case CrossAxisAlignment.end:
        return CrossAxisAlignment.end;
      case CrossAxisAlignment.center:
        return CrossAxisAlignment.center;
      case CrossAxisAlignment.stretch:
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }
}

/// Responsive container with max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.maxContentWidth,
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: context.verticalPadding,
        ),
        color: decoration == null ? color : null,
        decoration: decoration,
        child: child,
      ),
    );
  }
}
