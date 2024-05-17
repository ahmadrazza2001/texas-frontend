import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:texasmobiles/api/network_util.dart';

class NewProductPage extends StatefulWidget {
  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _batteryController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  String _productType = "Select Type";
  String _condition = "Select Condition";

  final ImagePicker _picker = ImagePicker();
  final CloudinaryPublic cloudinary =
      CloudinaryPublic('dicebox', 'trynbuy', cache: false);
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoading = false;
  List<String> productTypes = ['Mobile', 'Tablet', 'Laptop'];
  List<String> productConditions = ['new', 'used'];

  List<String> imageUrls = [];

  void handleImageSelection() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      List<Future> uploadTasks =
          pickedFiles.map((file) => uploadImage(file.path)).toList();
      await Future.wait(uploadTasks);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath,
            resourceType: CloudinaryResourceType.Image),
      );
      imageUrls.add(response.secureUrl);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> createProduct() async {
    if (imageUrls.isEmpty) {
      print('Please upload some images before creating the product.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? token = await _storage.read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
      '/api/v1/product/createProduct',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'battryHealth': _batteryController.text,
        'keywords':
            _keywordsController.text.split(',').map((s) => s.trim()).toList(),
        'images': imageUrls,
        'productType': _productType,
      },
    );

    if (response != null && response.statusCode == 201) {
      print('Product created successfully!');
      Navigator.pop(context);
    } else {
      print('Failed to create product: ${response?.body}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Device",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orangeAccent,
        // automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title or Name'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          InputDecoration(labelText: 'Brief Description'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Product Price'),
                    ),
                    TextField(
                      controller: _batteryController,
                      decoration:
                          InputDecoration(labelText: 'Battery Health in %'),
                    ),
                    DropdownButtonFormField<String>(
                      value:
                          _condition != "Select Condition" ? _condition : null,
                      onChanged: (String? newValue) {
                        setState(() {
                          _condition = newValue!;
                        });
                      },
                      items: productConditions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Condition',
                      ),
                    ),
                    TextField(
                      controller: _keywordsController,
                      decoration: InputDecoration(
                          labelText: 'Keywords (separate with comma)'),
                    ),
                    DropdownButtonFormField<String>(
                      value:
                          _productType != "Select Type" ? _productType : null,
                      onChanged: (String? newValue) {
                        setState(() {
                          _productType = newValue!;
                        });
                      },
                      items: productTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Type',
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: handleImageSelection,
                      child: Text('Select Images'),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: createProduct,
                      child: Text('Create'),
                      // style: ButtonStyle(backgroundColor: black),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
