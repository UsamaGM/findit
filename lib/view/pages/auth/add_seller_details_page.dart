import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:provider/provider.dart';
import 'package:findit/controller/services/services.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/model/models.dart';

class AddSellerDetailsPage extends StatefulWidget {
  const AddSellerDetailsPage({super.key, required this.user});

  final User user;

  @override
  createState() => _AddSellerDetailsPageState();
}

class _AddSellerDetailsPageState extends State<AddSellerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final cnicNumberController = TextEditingController();
  final cnicIssuanceDateController = TextEditingController();
  final fatherNameController = TextEditingController();
  late HttpService http;
  late List<dynamic> _categories = [];
  List<DropdownMenuItem<String>> categoryList = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    http = context.read<HttpService>();
    fetchCategories();
  }

  @override
  void dispose() {
    cnicNumberController.dispose();
    cnicIssuanceDateController.dispose();
    fatherNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    title: "CNIC Number",
                    hintText: "4550123456789",
                    controller: cnicNumberController,
                    validator: cnicNumberValidator,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: "CNIC Issuance Date",
                    controller: cnicIssuanceDateController,
                    validator: cnicIssuanceDateValidator,
                    canRequestFocus: false,
                    suffixIcon: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => showBottomPicker(context),
                      child: const Icon(Icons.date_range_rounded),
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: "Father Name",
                    hintText: "Abbu Jaan",
                    controller: fatherNameController,
                    validator: fatherNameValidator,
                  ),
                  const SizedBox(height: 15),
                  CustomDropDown(
                    title: "Category",
                    items: categoryList,
                    onChanged: (value) {
                      setState(() {
                        final selectedCategory = _categories.firstWhere(
                          (element) => element['name'] == value,
                        );
                        index = selectedCategory['id'];
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  CustomAnimatedButton(
                    title: "Save",
                    onTap: () => saveSeller(context),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(route: 'category/all');
      if (response.statusCode == 200) {
        _categories = jsonDecode(response.body)["categories"];
        setState(() {
          categoryList = _categories.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem(
              value: value['name'],
              child: Text(value['name']),
            );
          }).toList();
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  // Data validators
  String? cnicNumberValidator(value) {
    if (value == null || !value.contains(RegExp(r'^[0-9]{5}\d{7}[0-9]$'))) {
      return "Invalid CNIC Number";
    }
    return null;
  }

  String? cnicIssuanceDateValidator(value) {
    if (value == null || value.isEmpty) {
      return "Invalid date";
    }
    return null;
  }

  String? fatherNameValidator(value) {
    if (value == null || value.length < 3) {
      return "At least 3 characters for father name";
    } else if (value.length > 30) {
      return "Father Name too long. Max 30 characters";
    }
    return null;
  }

  void showBottomPicker(BuildContext context) {
    final now = DateTime.now();
    BottomPicker.date(
      dismissable: true,
      displayCloseIcon: false,
      minDateTime: DateTime(now.year - 10, now.month, now.day),
      maxDateTime: DateTime(now.year, now.month, now.day),
      buttonSingleColor: Theme.of(context).colorScheme.primary,
      onSubmit: (value) {
        setState(() {
          cnicIssuanceDateController.text =
              "${value.month}/${value.day}/${value.year}";
        });
      },
    ).show(context);
  }

  Future<void> saveSeller(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = context.read<AuthService>();
        final seller = Seller(
          id: widget.user.id,
          firstName: widget.user.firstName,
          lastName: widget.user.lastName,
          email: widget.user.email,
          phone: widget.user.phone,
          password: widget.user.password,
          cnic: cnicNumberController.text,
          categoryId: index,
        );
        final value = await authService.register(
          context: context,
          type: "seller",
          user: seller,
        );
        if (value == 401) {
          // Handle error
        }
      } catch (error) {
        // Handle error
      }
    }
  }
}
