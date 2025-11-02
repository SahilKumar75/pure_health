import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pure_health/app/config/app_router.dart';
import 'package:pure_health/shared/widgets/quick_navigation_menu.dart';

class KeyboardShortcutsHandler extends StatefulWidget {
  final Widget child;

  const KeyboardShortcutsHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<KeyboardShortcutsHandler> createState() => _KeyboardShortcutsHandlerState();
}

class _KeyboardShortcutsHandlerState extends State<KeyboardShortcutsHandler> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final hasModifier = HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;

    if (!hasModifier) return;

    // Cmd/Ctrl + K = Quick Navigation
    if (event.logicalKey == LogicalKeyboardKey.keyK) {
      QuickNavigationMenu.show(context);
      return;
    }

    // Cmd/Ctrl + 1-7 = Navigate to specific pages
    final numberKeys = {
      LogicalKeyboardKey.digit1: 0,
      LogicalKeyboardKey.digit2: 1,
      LogicalKeyboardKey.digit3: 2,
      LogicalKeyboardKey.digit4: 3,
      LogicalKeyboardKey.digit5: 4,
      LogicalKeyboardKey.digit6: 5,
      LogicalKeyboardKey.digit7: 6,
    };

    if (numberKeys.containsKey(event.logicalKey)) {
      final index = numberKeys[event.logicalKey]!;
      if (index < AppRouter.navigationItems.length) {
        final route = AppRouter.getRouteByIndex(index);
        if (context.mounted) {
          context.go(route);
        }
      }
      return;
    }

    // Cmd/Ctrl + P = Reports (PDF generation)
    if (event.logicalKey == LogicalKeyboardKey.keyP) {
      if (context.mounted) {
        context.go('/reports');
      }
      return;
    }

    // Cmd/Ctrl + E = Export CSV
    if (event.logicalKey == LogicalKeyboardKey.keyE) {
      if (context.mounted) {
        context.go('/reports');
      }
      return;
    }

    // Cmd/Ctrl + M = Map view
    if (event.logicalKey == LogicalKeyboardKey.keyM) {
      if (context.mounted) {
        context.go('/');
      }
      return;
    }

    // Cmd/Ctrl + / = Show keyboard shortcuts help
    if (event.logicalKey == LogicalKeyboardKey.slash) {
      _showKeyboardShortcutsHelp();
      return;
    }
  }

  void _showKeyboardShortcutsHelp() {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}

class KeyboardShortcutsHelpDialog extends StatelessWidget {
  const KeyboardShortcutsHelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '⌨️',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Keyboard Shortcuts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildShortcutSection('Navigation', [
              _ShortcutItem('⌘K', 'Quick Navigation'),
              _ShortcutItem('⌘1-7', 'Navigate to page'),
              _ShortcutItem('⌘M', 'Go to Map'),
            ]),
            const SizedBox(height: 16),
            _buildShortcutSection('Actions', [
              _ShortcutItem('⌘P', 'Generate Report'),
              _ShortcutItem('⌘E', 'Export CSV'),
            ]),
            const SizedBox(height: 16),
            _buildShortcutSection('Help', [
              _ShortcutItem('⌘/', 'Show shortcuts'),
              _ShortcutItem('ESC', 'Close dialogs'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutSection(String title, List<_ShortcutItem> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...shortcuts.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      s.shortcut,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    s.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ShortcutItem {
  final String shortcut;
  final String description;

  const _ShortcutItem(this.shortcut, this.description);
}
