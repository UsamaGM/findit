import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class DeliveryAddress extends StatefulWidget {
  const DeliveryAddress({super.key, required this.updateAddressId});

  final Function(String value) updateAddressId;

  @override
  createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends State<DeliveryAddress> {
  final formKey = GlobalKey<FormState>();

  final houseNoController = TextEditingController();
  final streetNoController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();

  final List<String> provinces = [
    "Sindh",
    "Punjab",
    "Balochistan",
    "KPK",
    "Gilgit"
  ];

  String selectedProvince = "Sindh";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Address",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextField(
                title: "Street/Area",
                hintText: "Bleeker St.",
                controller: streetNoController,
                validator: streetValidator,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: CustomTextField(
                      title: "City",
                      hintText: "New York",
                      controller: cityController,
                      validator: cityValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: CustomTextField(
                      title: "House/Apartment No.",
                      hintText: "307",
                      controller: houseNoController,
                      validator: houseValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: CustomDropDown(
                      items: provinces.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                      onChanged: (String? newvalue) {
                        setState(() {
                          selectedProvince = newvalue ?? selectedProvince;
                        });
                      },
                      title: selectedProvince,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: CustomTextField(
                      title: "Postal Code",
                      hintText: "65200",
                      controller: postalCodeController,
                      validator: postalCodeValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomAnimatedButton(
                title: "Save",
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final response = await context.read<HttpService>().post(
                        route: "address/add",
                        body: {
                          "id": context.read<Shared>().userId,
                          "house": houseNoController.text,
                          "street": streetNoController.text,
                          "city": cityController.text,
                          "province": selectedProvince,
                          "postalCode": postalCodeController.text,
                        },
                      );
                      if (response.statusCode == 200) {
                        debugPrint(response.body);
                        final result = jsonDecode(response.body);

                        widget.updateAddressId(result['id']);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } else if (response.statusCode == 400 &&
                          context.mounted) {
                        showErrorSnackBar(
                          context,
                          "Address already exists",
                        );
                      } else if (context.mounted) {
                        showErrorDialog(context, "Error while saving address");
                      }
                    } catch (error) {
                      if (context.mounted) {
                        showErrorSnackBar(context, "An error occurred: $error");
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? postalCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter a valid Postal Code";
    }
    return null;
  }

  String? houseValidator(String? value) {
    if (value == null || value.length > 4) {
      return "Max 4 characters";
    } else if (value.length < 2) {
      return "Min 2 characters";
    }
    return null;
  }

  String? cityValidator(String? value) {
    if (value == null || value.length > 28) {
      return "Max 28 characters";
    } else if (value.length < 2) {
      return "Min 2 characters";
    }
    return null;
  }

  String? streetValidator(String? value) {
    if (value == null || value.length > 40) {
      return "Max 40 characters";
    } else if (value.length < 5) {
      return "Min 5 characters";
    }
    return null;
  }
}
