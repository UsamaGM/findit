import 'dart:convert';
import 'package:findit/view/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

// ignore: must_be_immutable
class SellerDashboardPage extends StatelessWidget {
  SellerDashboardPage({super.key});

  Map<String, String> data = {};

  Future<bool> _fetchData(BuildContext context) async {
    final id = context.read<Shared>().userId;

    try {
      final response = await context.read<HttpService>().get(
        route: "user/fromId",
        queryParams: {"id": id!},
      );
      final result = jsonDecode(response.body)['user'];

      data = {"id": id, "name": result['name']};
      return true;
    } catch (error) {
      return false;
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UserCard(data: data),
                    const SizedBox(height: 25),
                    CustomButton(
                      title: "Add new Product",
                      onTap: () =>
                          _navigateTo(context, const AddProductScreen()),
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      onTap: () =>
                          _navigateTo(context, const SellerOrderPage()),
                      title: 'View Orders',
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      onTap: () =>
                          _navigateTo(context, const InventoryManagementPage()),
                      title: 'Manage Inventory',
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  "Connection failure",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
          } else {
            return const Center(child: CustomSpinKit());
          }
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.data});

  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/person1.jpg'),
            ),
            const SizedBox(height: 16),
            Text(
              data['name']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Seller ID: ${data['id']}'),
          ],
        ),
      ),
    );
  }
}
