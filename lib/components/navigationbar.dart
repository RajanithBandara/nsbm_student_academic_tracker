import 'package:flutter/material.dart';

class NavigationItem {
  final Icon icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
}

class CustomNavigationBar extends StatefulWidget {
  final List<NavigationItem> items;

  final int currentIndex;

  final ValueChanged<int> onTap;

  final Color backgroundColor;

  final Color selectedColor;

  final Color unselectedColor;

  final double elevation;

  final TextStyle? labelStyle;

  final bool showLabels;

  const CustomNavigationBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.elevation = 8.0,
    this.labelStyle,
    this.showLabels = true,
  }) : super(key: key);

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.elevation,
      color: widget.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final int index = entry.key;
          final NavigationItem item = entry.value;
          final bool isSelected = index == widget.currentIndex;
          return Expanded(
            child: InkWell(
              onTap: () => widget.onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        color:
                        isSelected ? widget.selectedColor : widget.unselectedColor,
                      ),
                      child: item.icon,
                    ),
                    if (widget.showLabels)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.label,
                          style: widget.labelStyle ??
                              TextStyle(
                                color: isSelected
                                    ? widget.selectedColor
                                    : widget.unselectedColor,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
