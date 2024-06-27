import 'package:flutter/material.dart';
import 'package:findit/view/components/components.dart';

void showErrorDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.error_rounded),
      content: Text(text),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String text) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: cs.errorContainer,
      content: Text(
        text,
        style: TextStyle(color: cs.onErrorContainer),
      ),
    ),
  );
}

void showFullScreenDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: cs.background.withOpacity(0.25),
      child: const CustomSpinKit(),
    ),
  );
}

void showPinDialog({
  required BuildContext context,
  required String text,
  required void Function(String?) onComplete,
  required TextEditingController pinController,
}) {
  final cs = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: cs.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          CustomPinput(
            controller: pinController,
            onCompleted: onComplete,
            validator: (value) {
              if (value == null || value.length < 4) {
                return "Invalid PIN";
              }
              return null;
            },
          ),
        ],
      ),
    ),
  );
}
