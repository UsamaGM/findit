import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomSpinKit extends StatelessWidget {
  const CustomSpinKit({super.key, this.color, this.size});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SpinKitWave(
      color: color ?? Theme.of(context).colorScheme.primary,
      size: size ?? 50,
    );
  }
}
