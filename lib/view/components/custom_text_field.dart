import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    required this.controller,
    this.hintText,
    this.validator,
    this.obscure = false,
    this.keyboardType,
    this.icon,
    this.suffixIcon,
    this.canRequestFocus = true,
  });

  final String title;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final Icon? icon;
  final Widget? suffixIcon;
  final bool canRequestFocus;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      style: TextStyle(color: cs.primary),
      keyboardType: keyboardType,
      canRequestFocus: canRequestFocus,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(color: cs.secondary, fontWeight: FontWeight.bold),
        hintText: hintText,
        hintStyle: TextStyle(color: cs.secondary),
        prefixIcon: icon,
        prefixIconColor: cs.primary,
        suffixIcon: suffixIcon,
        suffixIconColor: cs.secondary,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    );
  }
}
