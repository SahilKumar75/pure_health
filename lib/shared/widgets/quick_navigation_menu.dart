import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/app/config/app_router.dart';

class QuickNavigationMenu extends StatefulWidget {
  const QuickNavigationMenu({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppColors.charcoal.withOpacity(0.7),
      builder: (context) => const QuickNavigationMenu(),
    );
  }

  @override
  State<QuickNavigationMenu> createState() => _QuickNavigationMenuState();
}

class _QuickNavigationMenuState extends State<QuickNavigationMenu>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  List<NavigationItem> _allItems = [];
  List<NavigationItem> _filteredItems = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeItems();
    _filteredItems = List.from(_allItems);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
    _searchFocus.requestFocus();

    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeItems() {
    final iconMap = {
      'home': CupertinoIcons.home,
      'dashboard': CupertinoIcons.chart_bar_fill,
      'history': CupertinoIcons.time,
      'settings': CupertinoIcons.settings,
      'chat': CupertinoIcons.chat_bubble_2,
      'reports': CupertinoIcons.doc_fill,
      'profile': CupertinoIcons.person_circle,
    };

    _allItems = AppRouter.navigationItems.map((item) {
      return NavigationItem(
        label: item['label'] as String,
        icon: iconMap[item['icon']] ?? CupertinoIcons.home,
        route: AppRouter.getRouteByIndex(item['index'] as int),
        keywords: [item['label'] as String],
        shortcut: '⌘${(item['index'] as int) + 1}',
      );
    }).toList();

    // Add additional quick actions
    _allItems.addAll([
      NavigationItem(
        label: 'Generate PDF Report',
        icon: CupertinoIcons.doc_text_fill,
        route: '/reports',
        keywords: ['pdf', 'report', 'generate', 'export'],
        shortcut: '⌘P',
      ),
      NavigationItem(
        label: 'Export CSV Data',
        icon: CupertinoIcons.table_fill,
        route: '/reports',
        keywords: ['csv', 'export', 'data', 'download'],
        shortcut: '⌘E',
      ),
      NavigationItem(
        label: 'View Water Quality Map',
        icon: CupertinoIcons.map_fill,
        route: '/',
        keywords: ['map', 'location', 'water', 'quality'],
        shortcut: '⌘M',
      ),
    ]);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          return item.label.toLowerCase().contains(query) ||
              item.keywords.any((keyword) => keyword.toLowerCase().contains(query));
        }).toList();
      }
      _selectedIndex = 0;
    });
  }

  void _navigateToSelected() {
    if (_filteredItems.isEmpty) return;
    
    final selectedItem = _filteredItems[_selectedIndex];
    Navigator.of(context).pop();
    
    if (context.mounted) {
      context.go(selectedItem.route);
    }
  }

  void _moveSelection(int direction) {
    setState(() {
      _selectedIndex = (_selectedIndex + direction).clamp(0, _filteredItems.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _moveSelection(1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _moveSelection(-1);
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _navigateToSelected();
          }
        }
      },
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 600,
                    constraints: const BoxConstraints(maxHeight: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.darkCream.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withOpacity(0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSearchBar(),
                        if (_filteredItems.isNotEmpty) _buildItemsList(),
                        if (_filteredItems.isEmpty) _buildEmptyState(),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkCream.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            color: AppColors.accentPink,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Search pages and actions...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.mediumGray,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.body.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkCream.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.darkCream.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              'ESC',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumGray,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final isSelected = index == _selectedIndex;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _selectedIndex = index);
                _navigateToSelected();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPink.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border(
                    left: BorderSide(
                      color: isSelected
                          ? AppColors.accentPink
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentPink.withOpacity(0.15)
                            : AppColors.darkCream.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: isSelected
                            ? AppColors.accentPink
                            : AppColors.mediumGray,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? AppColors.charcoal
                              : AppColors.mediumGray,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (item.shortcut != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkCream.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.darkCream.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          item.shortcut!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mediumGray,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            '🔍',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'No results found',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCream.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: AppColors.darkCream.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKeyHint('↑↓', 'Navigate'),
          const SizedBox(width: 16),
          _buildKeyHint('↵', 'Select'),
          const SizedBox(width: 16),
          _buildKeyHint('ESC', 'Close'),
        ],
      ),
    );
  }

  Widget _buildKeyHint(String key, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.darkCream.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            key,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.charcoal,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mediumGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final String route;
  final List<String> keywords;
  final String? shortcut;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.keywords,
    this.shortcut,
  });
}
