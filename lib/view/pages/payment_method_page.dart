import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod(
      {super.key, required this.update, required this.updateId});

  final Function(String value) update;
  final Function(int value) updateId;

  @override
  createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  String? selectedPaymentMethod = "cod";

  final formKey = GlobalKey<FormState>();
  final cvvController = TextEditingController();
  final expiryController = TextEditingController();
  final accountController = TextEditingController();

  void onChanged(String? value) {
    if (value == null) return;
    if (value == "easypaisa") {
      widget.updateId(2);
    } else if (value == "jazzcash") {
      widget.updateId(3);
    } else if (value == "cod") {
      widget.updateId(4);
    } else {
      widget.updateId(1);
    }

    setState(() {
      selectedPaymentMethod = value;
    });
  }

  String? cardValidator(String? value) {
    if (value == null || value.length != 16) {
      return "Enter a valid card number";
    } else {
      return null;
    }
  }

  String? accountValidator(String? value) {
    if (value == null || value.length != 11) {
      return "Enter a valid account number";
    } else {
      return null;
    }
  }

  String? cvvValidator(String? value) {
    if (value == null || value.length != 3) {
      return "Enter a valid CVV";
    } else {
      return null;
    }
  }

  String? dateValidator(String? value) {
    if (value == null ||
        value.length != 5 ||
        !RegExp(r"^\d{2}/\d{2}$").hasMatch(value)) {
      return "Enter a valid expiry date";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Methods",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                minimumSize: Size(MediaQuery.of(context).size.width - 30, 45),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Confirm Payment Method",
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                if (selectedPaymentMethod != "cod" &&
                    formKey.currentState?.validate() == false) {
                  return;
                }
                widget.update(accountController.text.isEmpty
                    ? "Cash on Delivery"
                    : accountController.text);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: _buildOptions(),
    );
  }

  Widget _buildOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.credit_card_outlined),
                    SizedBox(width: 5),
                    Text("Credit/Debit Card"),
                  ],
                ),
                value: 'card',
                groupValue: selectedPaymentMethod,
                onChanged: onChanged,
              ),
              PaymentOption(
                value: "easypaisa",
                image: "assets/images/epaisa.png",
                name: "EasyPaisa",
                selectedPaymentMethod: selectedPaymentMethod,
                onChanged: onChanged,
              ),
              PaymentOption(
                value: "jazzcash",
                image: "assets/images/jcash.png",
                name: "JazzCash",
                selectedPaymentMethod: selectedPaymentMethod,
                onChanged: onChanged,
              ),
              PaymentOption(
                value: "cod",
                image: "assets/images/COD.png",
                name: "Cash On Delivery",
                selectedPaymentMethod: selectedPaymentMethod,
                onChanged: onChanged,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 194, 194, 194),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selectedPaymentMethod != "cod")
            Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 10, 0, 10),
                    child: Text(
                      selectedPaymentMethod == "card"
                          ? "Enter Card Details :"
                          : "Enter Account Details :",
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: selectedPaymentMethod == "card"
                          ? CustomTextField(
                              title: "Card Number",
                              hintText: "4931 4213 4123 2133",
                              controller: accountController,
                              validator: cardValidator,
                            )
                          : CustomTextField(
                              title: "Account Number",
                              hintText: "03123456789",
                              controller: accountController,
                              validator: accountValidator,
                            ),
                    ),
                  ),
                  if (selectedPaymentMethod == "card")
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width / 2) - 40,
                            child: CustomTextField(
                              title: "CVV",
                              hintText: "344",
                              controller: cvvController,
                              validator: cvvValidator,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width / 2) - 15,
                            child: CustomTextField(
                              title: "Expiry Date",
                              hintText: "03/23",
                              controller: expiryController,
                              validator: dateValidator,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PaymentOption extends StatelessWidget {
  final String image;
  final String name;
  final String value;
  final String? selectedPaymentMethod;
  final Function(String?) onChanged;

  const PaymentOption({
    super.key,
    required this.value,
    required this.image,
    required this.name,
    required this.selectedPaymentMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Image.asset(image, scale: 11),
          const SizedBox(width: 5),
          Text(name),
        ],
      ),
      value: value,
      groupValue: selectedPaymentMethod,
      onChanged: onChanged,
    );
  }
}
