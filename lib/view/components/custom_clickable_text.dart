import 'package:flutter/material.dart';

class CustomClickableText extends StatelessWidget {
  const CustomClickableText({
    super.key,
    required this.title,
    required this.onTap,
    this.alignment = Alignment.center,
  });

  final String title;
  final void Function() onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      heightFactor: 1.50,
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
