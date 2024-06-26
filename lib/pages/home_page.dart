import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:texasmobiles/api/network_util.dart';
import 'package:texasmobiles/pages/login_page.dart';
import 'package:texasmobiles/pages/my_orders.dart';
import 'package:texasmobiles/pages/new_order.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:texasmobiles/pages/productDetails.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  Map<String, dynamic> _profile = {};
  String _selectedCondition = 'new';
  Map<String, dynamic> _cart = {};
  bool _isVendorRequestActive = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchProfile();
  }

  Future<void> _fetchProducts() async {
    final response = await NetworkUtil.tryRequest('/api/v1/product/allProducts',
        headers: {'Content-Type': 'application/json'});
    if (response != null && response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body)['body'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    String? token = await _storage.read(key: 'authToken');
    if (token == null) {
      print('No token found');
      return;
    }
    final response = await NetworkUtil.tryRequest(
      '/api/v1/user/myProfile',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response != null && response.statusCode == 200) {
      var profileData = json.decode(response.body)['data']['user'];
      setState(() {
        _profile = profileData;
        _isVendorRequestActive = profileData['requestForVendor'] ?? false;
        _isLoading = false;
      });
    } else {
      print('Failed to fetch profile');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addToCart(
      String productId, String productName, String price, String imageUrl) {
    setState(() {
      double basePrice = double.tryParse(price) ?? 0;
      if (_cart.containsKey(productId)) {
        _cart[productId]['quantity'] += 1;
      } else {
        _cart[productId] = {
          'name': productName,
          'basePrice': basePrice,
          'totalPrice': basePrice,
          'imageUrl': imageUrl,
          'quantity': 1,
        };
      }
      _cart[productId]['totalPrice'] =
          _cart[productId]['basePrice'] * _cart[productId]['quantity'];
    });
  }

  void _requestVendorStatus(bool newValue) async {
    if (!newValue || _isVendorRequestActive) {
      return;
    }

    String? token = await _storage.read(key: 'authToken');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication token not found")),
      );
      return;
    }

    final response = await NetworkUtil.tryRequest('/api/v1/user/requestVendor',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'requestForVendor': 'true'
        });

    if (response != null && response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _isVendorRequestActive = true;
          _profile['requestForVendor'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? "Request sent successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(data['message'] ?? "Failed to send vendor request")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Failed to send vendor request with status code: ${response?.statusCode}")),
      );
    }
  }

  Widget _navigationTab() {
    return Container(
      color: Colors.orange[50],
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _conditionButton('New', 'new'),
          _conditionButton('Used', 'used'),
        ],
      ),
    );
  }

  Widget _conditionButton(String title, String condition) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCondition == condition
            ? Colors.orangeAccent
            : Colors.orange[50],
      ),
      onPressed: () {
        setState(() {
          _selectedCondition = condition;
        });
      },
      child: Text(title),
    );
  }

  Widget _homeContent() {
    // Adding a filter directly in the builder to handle conditions dynamically
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _navigationTab(),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Latest Ads',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    var product = _products[index];
                    if (product['condition'] == _selectedCondition) {
                      // Ensure product has the condition and it matches
                      // Check if product contains all required fields
                      if (product.containsKey('images') &&
                          product['images'].isNotEmpty &&
                          product.containsKey('userId') &&
                          product['userId'].containsKey('shopAddress')) {
                        return _buildProductTile(
                            product['title'],
                            product['price'].toString(),
                            product['images']
                                [0], // Assuming 'images' is a list and not null
                            product['_id'],
                            product['userId'][
                                'shopAddress'], // Assuming 'userId' is a map with 'shopAddress'
                            product[
                                'productStatus']); // Check if 'productStatus' exists
                      }
                    }
                    return SizedBox(); // Return an empty box for non-matching products or incomplete data
                  },
                ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductTile(String productName, String price, String imageUrl,
      String productId, String userId, String productStatus) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailPage(productId: productId)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: Image.network(
              imageUrl,
              width: 55,
              height: 55,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
            title: Text(productName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PKR $price',
                    style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.sentiment_very_satisfied,
                        size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text('${productStatus}',
                        style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () =>
                    addToCart(productId, productName, price, imageUrl)),
          ),
        ),
      ),
    );
  }

  Widget _cartContent() {
    SizedBox(
      height: 10,
    );
    Text('Cart',
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
    if (_cart.isEmpty) {
      return Center(
        child: Text("Empty Cart",
            style: TextStyle(color: Colors.black, fontSize: 18)),
      );
    } else {
      List<Widget> cartList = _cart.keys.map((key) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Card(
            color: Colors.orange[50],
            child: ListTile(
              leading:
                  Image.network(_cart[key]['imageUrl'], width: 50, height: 50),
              title: Text(_cart[key]['name'],
                  style: TextStyle(color: Colors.black, fontSize: 12)),
              subtitle: Text(
                  'PKR ${_cart[key]['totalPrice'].toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      if (_cart[key]['quantity'] > 1) {
                        setState(() {
                          _cart[key]['quantity'] -= 1;
                          _cart[key]['totalPrice'] =
                              _cart[key]['basePrice'] * _cart[key]['quantity'];
                        });
                      } else {
                        _removeFromCart(key);
                      }
                    },
                  ),
                  Text('${_cart[key]['quantity']}',
                      style:
                          TextStyle(color: Colors.orangeAccent, fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _cart[key]['quantity'] += 1;
                        _cart[key]['totalPrice'] =
                            _cart[key]['basePrice'] * _cart[key]['quantity'];
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFromCart(key),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();

      return Column(
        children: [
          Expanded(
            child: ListView(children: cartList),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewOrderPage(cartItems: _cart),
                  ),
                );
              },
              child: Text('Add Shipping Details',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _removeFromCart(String productId) {
    setState(() {
      _cart.remove(productId);
    });
  }

  Widget _profileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                (_profile['firstName'] ?? '') +
                    ' ' +
                    (_profile['lastName'] ?? ''),
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent)),
            Text('@${_profile['username'] ?? 'N/A'}',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            Text('${_profile['email'] ?? 'N/A'}',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            Text('Status: ${_profile['accountStatus'] ?? 'N/A'}',
                style: TextStyle(fontSize: 13, color: Colors.green)),
            SizedBox(height: 20),
            Text('Actions',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Switch to vendor account:',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  trailing: Transform.scale(
                    scale: 0.75, // Adjust the size by changing the scale
                    child: Switch(
                      value: _isVendorRequestActive,
                      onChanged: _requestVendorStatus,
                      activeColor: Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40), // Space before logout button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the login screen directly
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Background color of the button
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _homeContent();
      case 1:
        return _cartContent();
      case 2:
        return _profileContent();
      default:
        return _homeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TexasMobiles", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.layers_rounded),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyOrders()));
            },
          )
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orangeAccent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart_checkout),
                  if (_cart.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_cart.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
      ),
    );
  }
}
