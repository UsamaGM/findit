import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CustomPinput extends StatelessWidget {
  const CustomPinput({
    super.key,
    required this.controller,
    required this.onCompleted,
    required this.validator,
  });

  final TextEditingController controller;
  final void Function(String?) onCompleted;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: controller,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      keyboardType: TextInputType.number,
      onCompleted: onCompleted,
      validator: validator,
      defaultPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
