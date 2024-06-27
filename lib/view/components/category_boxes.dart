import 'dart:convert';
import 'dart:math';

import 'package:findit/controller/services/services.dart';
import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// ignore: must_be_immutable
class CategoryBoxes extends StatelessWidget {
  CategoryBoxes({super.key});

  final List<Color> colors = [
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.teal,
    Colors.pinkAccent,
    Colors.cyan,
    Colors.greenAccent,
    Colors.brown,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.indigo,
    Colors.brown,
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.deepPurple,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.orange,
    Colors.amber,
    Colors.blueGrey,
    Colors.teal,
    Colors.indigoAccent,
    Colors.deepOrange,
    Colors.blue,
    Colors.brown,
    Colors.pinkAccent,
  ];

  List<dynamic> categories = [];

  Future<void> _fetchData(BuildContext context) async {
    final results =
        await context.read<HttpService>().get(route: "category/all");
    if (context.mounted && results.statusCode == 200) {
      categories = (jsonDecode(results.body)['categories'] as List)
          .map((category) => {
                "title": category['name'],
                "icon": category['icon'],
                "color": colors[Random().nextInt(colors.length)]
              })
          .toList();
    } else {
      // Handle error here if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<void>(
        future: _fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomSpinKit());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading categories"));
          }
          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: categories.map((category) {
              return ChoiceCard(category: category);
            }).toList(),
          );
        },
      ),
    );
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.category});

  final dynamic category;

  IconData? getIconData(String iconName) {
    try {
      return MdiIcons.fromString(iconName);
    } catch (e) {
      return MdiIcons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {},
      child: SizedBox(
        height: 100,
        width: 100,
        child: Card(
          color: category['color'],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  getIconData(category['icon']),
                  size: 45.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  category['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
