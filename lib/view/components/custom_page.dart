import 'package:findit/controller/methods/connection.dart';
import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';

class CustomWidget extends StatefulWidget {
  const CustomWidget({super.key, required this.child});

  final Widget child;

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  void retry() async {
    if (await isConnected()) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isConnected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return widget.child;
          }
          return ErrorScreen(
            message: "Check your internet connection and try again",
            onRetry: retry,
          );
        }
        return const CustomSpinKit();
      },
    );
  }
}
