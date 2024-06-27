import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';

class CustomAnimatedButton extends StatefulWidget {
  const CustomAnimatedButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final Future<void> Function() onTap;

  @override
  State<CustomAnimatedButton> createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton> {
  bool animate = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      splashColor: cs.primary,
      onTap: updatedOnTap,
      child: Ink(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: animate
              ? CustomSpinKit(size: 20, color: cs.onPrimary)
              : Text(
                  widget.title,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  Future<void> updatedOnTap() async {
    setState(() {
      animate = true;
    });
    try {
      await widget.onTap();
    } finally {
      setState(() {
        animate = false;
      });
    }
  }
}
