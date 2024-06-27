import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    Future<void> loadData() async {
      final userId = context.read<Shared>().userId;

      await Future.delayed(const Duration(seconds: 2), () {
        if (userId != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const CustomWidget(child: HomePage()),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      });
    }

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Logo(),
              const SizedBox(height: 20),
              Text(
                'FindIt!',
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'Pacifico',
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 60,
                    ),
                  ],
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              const CustomSpinKit(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
