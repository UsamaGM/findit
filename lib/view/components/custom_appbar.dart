import 'package:flutter/material.dart';

AppBar CustomAppBar({required String title, required ColorScheme cs}) {
  return AppBar(
    backgroundColor: cs.primary.withOpacity(0.1),
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: cs.onBackground,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    title: Text(title),
  );
}
