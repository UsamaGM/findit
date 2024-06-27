import 'package:findit/controller/services/services.dart';
import 'package:findit/view/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:findit/view/components/components.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, required this.id});

  final String id;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CustomAppBar(title: "Change your password", cs: cs),
      body: CustomBackground(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      title: "New Password",
                      controller: newPasswordController,
                      obscure: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Password too short";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      title: "Confirm New Password",
                      hintText: "Password123#",
                      controller: confirmNewPasswordController,
                      obscure: true,
                      validator: (value) {
                        if (value == null ||
                            value != newPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              CustomAnimatedButton(
                title: "Change Password",
                onTap: changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changePassword() async {
    try {
      final response = await context.read<HttpService>().post(
          route: 'auth/changePassword',
          body: {"id": widget.id, "password": newPasswordController.text});
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else if (mounted) {
        showErrorDialog(context, "Error changing password");
      }
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, "Error changing password");
      }
    }
  }
}
