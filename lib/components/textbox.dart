import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double borderRadius;
  final bool isPassword;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  final Color textColor;
  final Color iconColor;
  final Color labelColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.borderRadius = 8.0,
    this.isPassword = false,
    this.borderColor = Colors.blue,
    this.focusedBorderColor = Colors.blue,
    this.enabledBorderColor = Colors.grey,
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
    this.labelColor = Colors.black,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      style: TextStyle(color: widget.textColor),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: widget.labelColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.enabledBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.focusedBorderColor, width: 2.0),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}
