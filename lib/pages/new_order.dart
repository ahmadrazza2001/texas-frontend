import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'package:texasmobiles/pages/home_page.dart';

class NewOrderPage extends StatefulWidget {
  final Map<String, dynamic> cartItems;

  NewOrderPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _NewOrderPageState createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> placeOrder() async {
    String? token = await NetworkUtil.storage.read(key: 'authToken');
    if (token == null) {
      print('Authentication token is not available.');
      return;
    }

    Map<String, dynamic> shippingDetails = {
      'orderedBy': _nameController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'phone': _phoneController.text,
    };

    int orderCount = 0;
    int successfulOrders = 0;

    widget.cartItems.forEach((productId, productDetails) async {
      String url = '/api/v1/user/newOrder/$productId';
      final response = await NetworkUtil.tryRequest(
        url,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'shippingDetails': shippingDetails,
          'orderProductPrice': productDetails['basePrice'].toString(),
          'orderProductQuantity': productDetails['quantity'].toString(),
        },
      );

      orderCount++;

      if (response != null && response.statusCode == 201) {
        print('Order for product $productId placed successfully: ${response.body}');
        successfulOrders++;
      } else {
        print('Failed to place order for product $productId');
      }

      if (orderCount == widget.cartItems.length) {
        if (successfulOrders == widget.cartItems.length) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              ModalRoute.withName('/')
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Not all orders were successfully placed.'))
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: placeOrder,
              child: Text('Place Order', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
