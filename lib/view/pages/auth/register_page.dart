import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/model/models.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  final verifiedIcon = const Icon(Icons.verified);
  verifyButton(void Function() onTap) => SizedBox(
        width: 55,
        child: CustomClickableText(title: "Verify", onTap: onTap),
      );

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final pinController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isEmailVerified = false;
  bool isPhoneVerified = false;

  late int? otp;
  late final User user;

  get emailSuffixIcon =>
      isEmailVerified ? widget.verifiedIcon : widget.verifyButton(verifyEmail);
  get phoneSuffixIcon =>
      isPhoneVerified ? widget.verifiedIcon : widget.verifyButton(verifyPhone);

  @override
  void initState() {
    super.initState();
    user = User();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(cs),
      body: CustomBackground(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 10),
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            // showWelcomeText(cs),
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    title: "First Name",
                    controller: firstNameController,
                    icon: const Icon(Icons.person_rounded),
                    hintText: "Chris",
                    validator: firstNameValidator,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    title: "Last Name",
                    controller: lastNameController,
                    icon: const Icon(Icons.person_rounded),
                    hintText: "Evans",
                    validator: lastNameValidator,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    title: "Email",
                    hintText: "username@xyz.com",
                    controller: emailController,
                    icon: const Icon(Icons.alternate_email_rounded),
                    suffixIcon: emailSuffixIcon,
                    canRequestFocus: !isEmailVerified,
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    title: "Phone Number",
                    controller: phoneNumberController,
                    icon: const Icon(Icons.phone_rounded),
                    suffixIcon: phoneSuffixIcon,
                    hintText: "03123456789",
                    canRequestFocus: !isPhoneVerified,
                    validator: phoneNumberValidator,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    title: "Password",
                    controller: passwordController,
                    icon: const Icon(Icons.key_rounded),
                    hintText: "Password101#",
                    validator: passwordValidator,
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    title: "Confirm Password",
                    controller: confirmPasswordController,
                    icon: const Icon(Icons.key_rounded),
                    hintText: "Password101#",
                    validator: (value) => confirmPasswordValidator(
                      value,
                      passwordController.text,
                    ),
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  CustomAnimatedButton(
                    title: "Create Buyer Account",
                    onTap: saveBuyer,
                  ),
                  const SizedBox(height: 10),
                  CustomAnimatedButton(
                    title: "Create Seller Account",
                    onTap: saveSeller,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verifyEmail() async {
    if (emailController.text.contains(RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+",
    ))) {
      showFullScreenDialog(context);
      final authService = context.read<AuthService>();
      final response = await authService.verifyEmail(
        email: emailController.text,
        forgot: false,
      );
      if (mounted) {
        Navigator.pop(context);
      }
      if (response == -1 && mounted) {
        showErrorSnackBar(context, "Email already taken");
      } else if (mounted) {
        otp = response;
        showPinDialog(
          context: context,
          text: "Enter 4 digit PIN sent to the given email address",
          pinController: pinController,
          onComplete: (value) {
            if (value == otp.toString()) {
              pinController.clear();
              Navigator.pop(context);
              setState(() {
                isEmailVerified = true;
              });
            }
          },
        );
      }
    }
  }

  void verifyPhone() async {
    if (phoneNumberController.text.contains(RegExp(r"03[0-4]{1}[0-9]{8}"))) {
      showFullScreenDialog(context);
      final response = await context
          .read<AuthService>()
          .verifyPhone(phone: phoneNumberController.text);
      if (mounted) {
        Navigator.pop(context);
      }
      if (response! && mounted) {
        showErrorSnackBar(context, "Phone number already taken");
      } else if (mounted) {
        showPinDialog(
          context: context,
          text: "Enter 4 digit PIN sent to the given phone number",
          pinController: pinController,
          onComplete: (value) {
            if (value == "0000") {
              pinController.clear();
              Navigator.pop(context);
              setState(() {
                isPhoneVerified = true;
              });
            }
          },
        );
      }
    }
  }

  String? emailValidator(value) {
    if (value == null ||
        !value.contains(
          RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-z]+"),
        )) {
      return "Invalid email";
    }
    user.email = emailController.text;
    return null;
  }

  String? firstNameValidator(value) {
    if (value == null || value.length < 3) {
      return "At least 3 characters required";
    } else if (value.length > 20) {
      return "First Name too long. Max 20 characters";
    }
    user.firstName = firstNameController.text;
    return null;
  }

  String? lastNameValidator(value) {
    if (value == null || value.length < 3) {
      return "At least 3 characters required";
    } else if (value.length > 20) {
      return "Last Name too long. Max 20 characters";
    }
    user.lastName = lastNameController.text;
    return null;
  }

  String? phoneNumberValidator(value) {
    if (value == null || !value.contains(RegExp(r'^03[0-4]{1}[0-9]{8}$'))) {
      return "Invalid phone number";
    }
    user.phone = phoneNumberController.text;
    return null;
  }

  String? passwordValidator(value) {
    if (value == null || value.length < 6) {
      return "Password too short";
    }
    user.password = passwordController.text;
    return null;
  }

  String? confirmPasswordValidator(value, String password) {
    if (value == null || value.length < 6) {
      return "Password too short";
    } else if (value != password) {
      return "Passwords do not match";
    }

    return null;
  }

  AppBar buildAppBar(ColorScheme cs) {
    return AppBar(
      backgroundColor: cs.primary.withOpacity(0.1),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: cs.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      title: const Text("Welcome to eMarket"),
    );
  }

  Widget showWelcomeText(ColorScheme cs) {
    return CustomRichText(
      texts: const [" ", "You'll Find It"],
      styles: [
        TextStyle(
          color: cs.secondary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        TextStyle(
          color: cs.primary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ],
    );
  }

  Future<void> saveBuyer() async {
    if (!isPhoneVerified) {
      showErrorDialog(context, "Verify your phone before processing further");
    } else if (!isEmailVerified) {
      showErrorDialog(context, "Verify your email before processing further");
    } else if (formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      final response = await authService.register(
        context: context,
        type: "buyer",
        user: user,
      );
      if (response == 401 && mounted) {
        showErrorSnackBar(context, "Error! Please try again");
      } else if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    }
  }

  Future<void> saveSeller() async {
    if (!isEmailVerified) {
      showErrorDialog(
        context,
        "Verify your email address before processing further",
      );
    } else if (!isPhoneVerified) {
      showErrorDialog(
        context,
        "Verify your phone number before processing further",
      );
    } else if (formKey.currentState!.validate()) {
      // Assuming AddSellerDetailsPage is a page where additional seller details are captured
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddSellerDetailsPage(user: user),
        ),
      );
    }
  }
}
