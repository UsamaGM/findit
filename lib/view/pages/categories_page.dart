import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> images = [];

  @override
  void initState() {
    super.initState();
    fetchDeals();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
        children: [
          const SizedBox(height: 10),
          ImageSlider(imageUrls: images),
          const SizedBox(height: 10),
          CategoryBoxes(),
        ],
      ),
    );
  }

  Future<void> fetchDeals() async {
    try {
      final response =
          await context.read<HttpService>().get(route: "deal/getDeals");
      final results = jsonDecode(response.body)["Deals"];
      if (results != null) {
        setState(() {
          images = results.map((image) => image["image_url"]).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        showErrorDialog(context, "Error loading data");
      }
    }
  }
}
