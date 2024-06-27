import 'package:flutter/material.dart';

class CartEntity extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isSelected;
  final ValueSetter<bool>? onChanged;
  final void Function() update;

  const CartEntity({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onChanged,
    required this.update,
  });

  @override
  createState() => _CartEntityState();
}

class _CartEntityState extends State<CartEntity> {
  late int quantity;
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    quantity = widget.item["quantity"];
    isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            spreadRadius: 0.2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool? value) {
              setState(() {
                isSelected = value ?? false;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(isSelected);
              }
            },
          ),
          const SizedBox(width: 4.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.item["image"],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.item["name"],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  "Rs.${widget.item["price"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                          widget.item["quantity"] = quantity;
                          widget.update();
                        }
                      },
                    ),
                    Text(
                      "Quantity: $quantity",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                        widget.item["quantity"] = quantity;
                        widget.update();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
