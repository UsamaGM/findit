import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.title,
    this.hintText,
  });

  final String title;
  final String? hintText;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      items: items,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(color: cs.secondary, fontWeight: FontWeight.bold),
        hintText: hintText,
        hintStyle: TextStyle(color: cs.secondary),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      onChanged: onChanged,
    );
  }
}
