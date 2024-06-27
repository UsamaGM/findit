import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/model/models.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class AuthService {
  final HttpService server = HttpService();

  Future<dynamic> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final response = await server.post(
      route: "auth/login",
      body: {"email": email, "password": password},
    );

    if (context.mounted && response.statusCode == 200) {
      final userId = jsonDecode(response.body)["userId"];

      await context.read<Shared>().setUserId(userId);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } else if (context.mounted) {
      showErrorSnackBar(context, response.body);
      return response.statusCode;
    }

    return null;
  }

  Future<dynamic> verifyEmail({
    required String email,
    required bool forgot,
  }) async {
    final response = await server.post(
      route: "auth/verifyEmail",
      body: {"email": email, "forgot": forgot},
    );

    if (response.statusCode == 400) {
      return -1;
    } else {
      return jsonDecode(response.body);
    }
  }

  Future<bool?> verifyPhone({required String phone}) async {
    final response = await server.post(
      route: "auth/verifyPhone",
      body: {"phone": phone},
    );

    return response.statusCode == 400;
  }

  Future<dynamic> register({
    required BuildContext context,
    required String type,
    required User user,
  }) async {
    final response = await server.post(
      route: "auth/register",
      body: {"type": type, "user": user.toJson()},
    );

    if (context.mounted && response.statusCode == 200) {
      final userId = jsonDecode(response.body)["userId"];

      await context.read<Shared>().setUserId(userId);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } else if (context.mounted) {
      showErrorSnackBar(context, jsonDecode(response.body)["message"]);
      return 401;
    }

    return null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await context.read<Shared>().deleteUserId();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
