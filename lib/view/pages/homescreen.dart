import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HttpService http;

  bool loadMore = true;
  int offset = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  final List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    http = context.read<HttpService>();
    _fetchDeals();
    _fetchData(0);
    _filteredProducts.addAll(_allProducts);
    initializeScroller();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<dynamic> images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 3),
        children: [
          buildSearchBox(),
          const SizedBox(height: 10),
          buildTitleText("Featured Products"),
          const SizedBox(height: 10),
          ImageSlider(imageUrls: images),
          const SizedBox(height: 10),
          buildTitleText("All Products"),
          ProductGrid(products: _filteredProducts),
        ],
      ),
    );
  }

  Padding buildTitleText(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Padding buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: SizedBox(
        height: 50,
        child: TextField(
          onChanged: _searchProducts,
          decoration: InputDecoration(
            hintText: 'Search...',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26.0),
            ),
          ),
        ),
      ),
    );
  }

  void initializeScroller() {
    _scrollController.addListener(() async {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 20 &&
          loadMore) {
        offset += 10;
        await _fetchData(offset);
        if (context.mounted) {
          setState(() {
            _filteredProducts = _allProducts;
          });
        }
      }
    });
  }

  Future<void> _fetchDeals() async {
    try {
      final result = await http.get(route: "deal/getDeals");
      if (context.mounted && result.statusCode == 200) {
        final results = jsonDecode(result.body)["Deals"];
        if (results != null) {
          setState(() {
            images.addAll(results.map((deal) => deal["image_url"]).toList());
          });
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        showErrorDialog(
          context,
          "Error loading data. Check your internet connection and retry",
        );
      }
    }
  }

  Future<void> _fetchData(int offset) async {
    try {
      final result = await http.get(
        route: "product/all",
        queryParams: {"offset": offset.toString()},
      );
      if (context.mounted && result.statusCode == 200) {
        final results = jsonDecode(result.body)['products'];
        if (results != null && results.length < 10) {
          loadMore = false;
        }
        if (results != null) {
          setState(() {
            _allProducts.addAll(
              results
                  .map((value) => {
                        "id": value['id'],
                        "name": value['name'],
                        "price": value['price'],
                        "stock": value['stock'],
                        "imageUrl": value['imageUrl']
                      })
                  .toList(),
            );
            _filteredProducts = _allProducts;
          });
        }
      } else if (result.statusCode == 404) {
        if (mounted) {
          showErrorDialog(context, "Error loading data");
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        showErrorDialog(
          context,
          "Error loading data. Check your internet connection and try again",
        );
      }
    }
  }

  void _searchProducts(String query) {
    if (context.mounted) {
      setState(() {
        _filteredProducts = _allProducts.where((product) {
          return product['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }
}
