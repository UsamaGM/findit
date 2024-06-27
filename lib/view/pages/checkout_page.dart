import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late String address;
  late String addressId;
  late bool hasAddress;
  final double delivery = 99;
  final double taxes = 5;
  final List<String> paymentMethods = [
    "Credit/Debit",
    "Easypaisa",
    "JazzCash",
    "COD"
  ];

  String paymentMethod = "Enter the payment method";
  int paymentTypeId = 1;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void updatePayment(String value) {
    setState(() {
      paymentMethod = value;
    });
  }

  void updateAddressId(value) {
    setState(() {
      addressId = value;
    });
  }

  void updatePaymentId(int value) {
    setState(() {
      paymentTypeId = value;
    });
  }

  Future<void> _fetchData() async {
    try {
      final result = await context.read<HttpService>().get(
        route: "address/byId",
        queryParams: {"id": context.read<Shared>().userId},
      );

      final response = jsonDecode(result.body);

      hasAddress = response['house_no'] != null;
      if (hasAddress) {
        address =
            "House no: ${response['house_no']}, Street ${response['street']}, ${response['city']} ${response['province']}";
        addressId = response['id'];
      } else {
        address = "Add new address";
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final double finalPrice = widget.details['totalPrice'] + delivery + taxes;
    final details = widget.details;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: CustomButton(
            onTap: () async {
              final body = {
                "buyerId": context.read<Shared>().userId,
                "totalPrice": finalPrice,
                "shippingAddressId": addressId,
                "paymentTypeId": paymentTypeId,
                "paymentDetail": paymentMethod,
                "productIds": details['productIds'],
                "quantities": details['quantities'],
              };

              try {
                await context
                    .read<HttpService>()
                    .post(route: "order/add", body: body);
                if (context.mounted) {
                  buildAlertDialog(context);
                }
              } catch (error) {
                debugPrint(error.toString());
              }
            },
            title: "Place Order",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  CheckoutOption(
                    text: "Delivery Address",
                    detail: address,
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryAddress(
                            updateAddressId: updateAddressId,
                          ),
                        ),
                      );
                    },
                  ),
                  CheckoutOption(
                    text: "Payment Method",
                    detail: "${paymentMethods[paymentTypeId]}: $paymentMethod",
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentMethod(
                            update: updatePayment,
                            updateId: updatePaymentId,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  BottomLine(
                    text: "Subtotal",
                    value: details['totalPrice'].toString(),
                  ),
                  BottomLine(text: "Delivery", value: "Rs.$delivery"),
                  BottomLine(text: "Taxes", value: "$taxes"),
                  BottomLine(text: "Total", value: "Rs.$finalPrice"),
                ],
              );
            }
            return const CustomSpinKit();
          },
        ),
      ),
    );
  }

  void buildAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Placed!'),
          content: const Text('Your order has been placed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({
    super.key,
    required this.text,
    required this.value,
  });

  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.secondary)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: cs.secondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: cs.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutOption extends StatelessWidget {
  final String text;
  final String detail;
  final VoidCallback ontap;

  const CheckoutOption({
    super.key,
    required this.text,
    required this.detail,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: ontap,
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.secondary),
          ),
        ]),
      ),
    );
  }
}
