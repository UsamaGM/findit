import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/pages/auth/auth.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';
import 'package:findit/controller/methods/methods.dart';
import 'package:findit/controller/enums.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pinController = TextEditingController();

  int? otp;
  String? id;
  bool emailSent = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(cs: cs, title: "Verify Email"),
      body: CustomBackground(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 10),
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: formKey,
                child: CustomTextField(
                  title: "Email",
                  icon: const Icon(Icons.alternate_email_rounded),
                  hintText: "user@example.com",
                  controller: emailController,
                  canRequestFocus: !emailSent,
                  validator: emailValidator,
                  suffixIcon: showSuffixIcon(),
                ),
              ),
              if (!emailSent)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomAnimatedButton(
                      title: "Send Email",
                      onTap: verifyEmail,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      "A recovery PIN will be sent to the provided email address. Make sure that the email is accessible before submitting the request.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 15),
              if (emailSent)
                Column(
                  children: [
                    Text(
                      "Email sent successfully",
                      style: TextStyle(
                        color: cs.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text("Enter the PIN from the email"),
                    const SizedBox(height: 15),
                    CustomPinput(
                      controller: pinController,
                      onCompleted: onCompleted,
                      validator: pinValidator,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyEmail() async {
    if (emailController.text.contains(RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+",
    ))) {
      try {
        final response = await context
            .read<AuthService>()
            .verifyEmail(email: emailController.text, forgot: true);

        if (response == -1 && mounted) {
          showErrorSnackBar(context, "Email already taken");
        } else {
          otp = response['otp'];
          id = response['id'];
          setState(() {
            emailSent = true;
          });
        }
      } catch (error) {
        if (mounted) {
          showErrorDialog(context, "Error sending Email");
        }
      }
    }
  }

  void onCompleted(value) {
    if (value == otp.toString()) {
      navigateWithSlideEffect(
        context: context,
        child: ChangePasswordPage(id: id!),
        animationDirection: AnimationDirection.ttb,
      );
      pinController.clear();
    } else {
      showErrorDialog(context, "Invalid PIN! Try again");
      pinController.clear();
    }
  }

  String? pinValidator(value) {
    if (value == null || value.length != 4) {
      return "Invalid PIN";
    }
    return null;
  }

  IconButton? showSuffixIcon() {
    return emailSent
        ? IconButton(
            onPressed: () {
              setState(() {
                emailSent = false;
              });
            },
            icon: const Icon(Icons.edit_rounded),
          )
        : null;
  }

  String? emailValidator(value) {
    if (value == null ||
        !value.contains(
            RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'))) {
      return "Invalid Email";
    }
    return null;
  }
}
