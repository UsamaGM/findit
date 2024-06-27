import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(children: [
      SizedBox(
        width: 170,
        height: 100,
        child: Image.asset(
          "assets/images/logo.png",
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        "   FindIt!",
        style: TextStyle(
          color: cs.onBackground,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          fontFamily: "BaskerVille",
        ),
      ),
    ]);
  }
}
