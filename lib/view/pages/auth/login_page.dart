import 'package:findit/view/pages/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/methods/navigation.dart';
import 'package:findit/controller/services/services.dart';
import 'package:findit/controller/enums.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 10),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Logo(),
            const SizedBox(height: 100),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    title: "Email",
                    controller: _emailController,
                    icon: const Icon(Icons.alternate_email_rounded),
                    hintText: "user101@something.com",
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    title: "Password",
                    controller: _passwordController,
                    icon: const Icon(Icons.key_rounded),
                    hintText: "Password101#",
                    obscure: true,
                    validator: _passwordValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomClickableText(
              title: "Forgot Password?",
              alignment: Alignment.centerRight,
              onTap: _forgotPasswordAction,
            ),
            const SizedBox(height: 10),
            CustomAnimatedButton(
              title: "LogIn",
              onTap: () => _loginAction(context),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("New to eMarket? "),
                CustomClickableText(
                  title: "Register here",
                  onTap: () => navigateWithSlideEffect(
                    context: context,
                    animationDirection: AnimationDirection.rtl,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    child: const RegisterPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _emailValidator(value) {
    if (value == null ||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)) {
      return "Invalid email";
    }
    return null;
  }

  String? _passwordValidator(value) {
    if (value == null || value.length < 6) {
      return "Password too short";
    }
    return null;
  }

  void _forgotPasswordAction() {
    navigateWithSlideEffect(
      context: context,
      child: const ForgotPasswordPage(),
      animationDirection: AnimationDirection.btt,
    );
  }

  Future<void> _loginAction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthService>().login(
              context: context,
              email: _emailController.text,
              password: _passwordController.text,
            );
      } catch (error) {
        if (context.mounted) {
          showErrorSnackBar(context, 'Login failed: ${error.toString()}');
        }
      }
    }
  }
}
