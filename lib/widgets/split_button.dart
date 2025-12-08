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

class _SplitButtonState extends State<SplitButton> with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideOverlay() async {
    await _animationController.reverse();
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmall = screenWidth < 450;
    final borderRadius = isMobile ? 22.0 : 24.0;
    final height = isMobile ? 44.0 : 48.0;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: null,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 0),
              child: Material(
                elevation: 4,
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(borderRadius),
                shadowColor: Colors.black26,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: SizeTransition(
                    sizeFactor: _expandAnimation,
                    axis: Axis.horizontal,
                    axisAlignment: 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isSelected = index == widget.selectedIndex;

                        return InkWell(
                          onTap: () {
                            _hideOverlay();
                            widget.onOptionSelected(index);
                          },
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                if (option.icon != null) ...[
                                  Icon(
                                    option.icon,
                                    size: isMobile ? 18 : 20,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                  if (!isSmall) const SizedBox(width: 8),
                                ],
                                if (!isSmall || option.icon == null)
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmall = screenWidth < 380; // Hide label on very small screens

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: isMobile ? 44 : 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(isMobile ? 22 : 24),
        ),
        child: Row(
          key: _buttonKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobile ? 22 : 24),
                  bottomLeft: Radius.circular(isMobile ? 22 : 24),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 10 : 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        size: isMobile ? 18 : 20,
                        color: theme.colorScheme.onPrimary,
                      ),
                      if (!isSmall) ...[
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          widget.label,
                          style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: isMobile ? 13 : 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: isMobile ? 20 : 24,
              color: theme.colorScheme.onPrimary.withOpacity(0.3),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleMenu,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(isMobile ? 22 : 24),
                  bottomRight: Radius.circular(isMobile ? 22 : 24),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 12,
                    vertical: isMobile ? 10 : 12,
                  ),
                  child: Icon(
                    _overlayEntry != null ? Icons.arrow_right : Icons.arrow_drop_down,
                    size: isMobile ? 20 : 24,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
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