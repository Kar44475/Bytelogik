import 'package:flutter/material.dart';

/// Lightweight reusable text field used on auth screens.
class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
