import 'package:flutter/material.dart';

class SplitButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final List<SplitButtonOption> options;
  final int selectedIndex;
  final ValueChanged<int> onOptionSelected;

  const SplitButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.options,
    required this.selectedIndex,
    required this.onOptionSelected,
  });

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> {
  final GlobalKey _buttonKey = GlobalKey();

  void _showMenu() async {
    final RenderBox button = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    debugPrint('Opening menu at position: $position');

    final int? selected = await showMenu<int>(
      context: context,
      position: position,
      items: widget.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return PopupMenuItem<int>(
          value: index,
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 20),
                const SizedBox(width: 12),
              ],
              Text(option.label),
            ],
          ),
        );
      }).toList(),
    );

    debugPrint('Selected menu item: $selected');

    if (selected != null) {
      debugPrint('Calling onOptionSelected with index: $selected');
      widget.onOptionSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        key: _buttonKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main action button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divider line
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
          // Dropdown button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showMenu,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplitButtonOption {
  final String label;
  final IconData? icon;

  const SplitButtonOption({
    required this.label,
    this.icon,
  });
}
