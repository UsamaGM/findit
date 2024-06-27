import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();

  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();

  var _types;
  bool isSaving = false;
  int index = 0;

  File? image;
  final picker = ImagePicker();

  final List<String> _imageUrls = [];

  @override
  void dispose() {
    super.dispose();
    remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchTypes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextField(
                        title: "Product Name",
                        hintText: "iPhone 15 Pro Max",
                        controller: productNameController,
                        validator: productNameValidator,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        title: "Stock",
                        hintText: "100",
                        controller: stockController,
                        validator: stockValidator,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        title: "Price",
                        hintText: "1500.99",
                        controller: priceController,
                        validator: priceValidator,
                      ),
                      const SizedBox(height: 15),
                      CustomDropDown(
                        items: _types,
                        onChanged: onChanged,
                        title: "Types",
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        title: "Description",
                        hintText: "Best smartphone on the market",
                        controller: descriptionController,
                        validator: descriptionValidator,
                      ),
                      const SizedBox(height: 15),
                      image == null
                          ? const Text('No image selected.')
                          : Image.file(image!),
                      const SizedBox(height: 15),
                      CustomButton(
                        onTap: () {
                          getImage();
                        },
                        title: 'Select Image',
                      ),
                      const SizedBox(height: 15),
                      CustomAnimatedButton(
                        title: "Save",
                        onTap: saveProduct,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const CustomSpinKit();
          }
        },
      ),
    );
  }

  String? descriptionValidator(value) {
    if (value == null || value.length < 10) {
      return "Must be 10 or more characters";
    }
    return null;
  }

  String? priceValidator(value) {
    if (!value!.contains(RegExp(r'[0-9]'))) {
      return "Only numbers allowed";
    }
    return null;
  }

  String? stockValidator(value) {
    if (!value!.contains(RegExp(r'[0-9]'))) {
      return "Only numbers allowed";
    }
    return null;
  }

  String? productNameValidator(value) {
    if (value == null || value.length < 3) {
      return "Must be 3 or more characters";
    }
    return null;
  }

  void onChanged(value) {
    _types.firstWhere((element) {
      if (element['name'] == value) {
        index = element['id'];
        return true;
      }
      return false;
    });
  }

  void remove() {
    productNameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
  }

  void clear() {
    productNameController.clear();
    priceController.clear();
    stockController.clear();
    descriptionController.clear();
    _imageUrls.clear();
  }

  Future<void> uploadImage() async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dfyuh1mjk/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'wsz35klv'
      ..files.add(await http.MultipartFile.fromPath('file', image!.path));
    await request.send().then((value) async {
      if (value.statusCode == 200) {
        final body = await value.stream.toBytes();
        final responseString = String.fromCharCodes(body);
        final jsnoMap = jsonDecode(responseString);
        final imageUrl = jsnoMap['secure_url'] as String;
        _imageUrls.clear();
        _imageUrls.add(imageUrl);
      } else {
        showErrorSnackBar(context, "Unable to updload the image");
      }
    });
  }

  Future<bool> fetchTypes() async {
    final http = context.read<HttpService>();

    try {
      final result = await http.get(route: 'productType/all');

      _types = jsonDecode(result.body)['types']
          .map<DropdownMenuItem<String>>(
            (value) => DropdownMenuItem(
              value: value['name'] as String,
              child: Text(value['name']),
            ),
          )
          .toList();
    } catch (error) {
      // ignore: use_build_context_synchronously
      showErrorSnackBar(context, "Server connection failed");

      return false;
    }

    return false;
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        uploadImage();
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  Future<void> saveProduct() async {
    if (formKey.currentState!.validate()) {
      final id = context.read<Shared>().userId;
      setState(() {
        isSaving = true;
      });

      await context.read<HttpService>().post(route: 'product/add', body: {
        "sellerId": id,
        "name": productNameController.text,
        "price": double.parse(priceController.text),
        "stock": int.parse(stockController.text),
        "description": descriptionController.text,
        "typeId": index,
        "imageUrls": _imageUrls,
      }).then(
        (value) {
          if (value.statusCode == 200) {
            showDialog(
              context: context,
              builder: (contex) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                content: Text(
                  "Product added successfully",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                actions: [
                  CustomButton(
                    title: "OK",
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
            clear();
          } else if (value.statusCode == 400) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                contentPadding: const EdgeInsets.all(8),
                content: Text(
                  "Product already exists! Update it?",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                actions: [
                  CustomButton(
                    title: 'No',
                    onTap: () => Navigator.pop(context),
                  ),
                  CustomButton(
                    title: "Yes",
                    onTap: () async {
                      try {
                        await context.read<HttpService>().post(
                          route: "product/update",
                          body: {
                            "sellerId": id,
                            "name": productNameController.text,
                            "price": double.parse(priceController.text),
                            "stock": int.parse(stockController.text),
                            "description": descriptionController.text,
                            "typeId": index,
                            "images": image,
                          },
                        ).then((value) {
                          Navigator.of(context).pop();
                        });
                      } catch (error) {
                        // ignore: use_build_context_synchronously
                        showErrorSnackBar(context, error.toString());
                      }
                    },
                  ),
                ],
              ),
            );
            clear();
          } else {
            showErrorSnackBar(context, "Failed to add product");
          }

          setState(() {
            isSaving = false;
          });
        },
      );
    }
  }
}
