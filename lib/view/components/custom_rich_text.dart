import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    super.key,
    required this.texts,
    required this.styles,
  });

  final List<String> texts;
  final List<TextStyle> styles;

  @override
  Widget build(BuildContext context) {
    if (texts.length != styles.length) {
      throw const FormatException(
        "Number of styles must equal number of texts",
      );
    }
    return RichText(
      text: TextSpan(
        children: List.generate(texts.length, (index) {
          return TextSpan(text: texts[index], style: styles[index]);
        }),
      ),
    );
  }
}
