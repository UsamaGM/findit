import 'package:flutter/material.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:findit/view/components/components.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
  });

  final List<dynamic>? products;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products!.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailsPage(id: products![index]['id']),
                ),
              );
            },
            child: ProductItem(
              imageUrl: products![index]['imageUrl'] as String,
              productName: products![index]['name'] as String,
              price: products![index]['price'],
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          childAspectRatio: 0.7,
          crossAxisSpacing: 0,
          mainAxisSpacing: 8,
        ),
      ),
    );
  }
}
