import 'dart:convert';

import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/controller/services/services.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  List<dynamic> allSellers = [];
  List<dynamic> filteredSellers = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (filteredSellers.isEmpty) {
            return Center(
              child: Text(
                "No shops yet",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: filteredSellers.length,
              itemBuilder: (context, index) {
                final seller = filteredSellers[index];
                return ListTile(
                  title: Text(seller['name']!),
                  subtitle: Text('${seller['city']} - ${seller['type']}'),
                );
              },
            );
          }
        } else {
          return const CustomSpinKit();
        }
      },
    );
  }

  Future<void> fetchData() async {
    try {
      final data =
          await context.read<HttpService>().get(route: 'seller/allSellers');

      if (data.statusCode == 404) {
        filteredSellers = allSellers = [];
        if (mounted) showErrorDialog(context, "Error loading data");
      } else if (data.statusCode == 200) {
        final sellers = jsonDecode(data.body)['sellers'];
        allSellers = sellers
            .map((value) => {
                  'name': value['name'],
                  'city': value['city'],
                  'type': value['type'],
                  'contact': value['contact'],
                })
            .toList();
        filteredSellers = allSellers;
      }
    } catch (_) {
      if (mounted) {
        showErrorDialog(
          context,
          "Error loading data. Please check your internet connection",
        );
      }
    }
  }
}
