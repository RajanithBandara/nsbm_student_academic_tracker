import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;

  final Widget child;

  final Color color;

  final Color textColor;

  final double borderRadius;

  final double elevation;

  final EdgeInsetsGeometry padding;

  final double? width;

  final double? height;

  final Gradient? gradient;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.width,
    this.height,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Button content is centered and uses a DefaultTextStyle for text colors.
    Widget content = Center(
      child: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: child,
      ),
    );

    return Material(
      color: gradient == null ? color : Colors.transparent,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            child: content,
          ),
        ),
      ),
    );
  }
}
