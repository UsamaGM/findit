import 'package:findit/view/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/controller/services/services.dart';

void main() async {
  await Shared.init();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => HttpService()),
        Provider(create: (context) => AuthService()),
        Provider(create: (context) => Shared()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eMarket',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
