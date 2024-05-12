import 'package:flutter/material.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'package:texasmobiles/pages/login_page.dart';
import 'package:texasmobiles/pages/new_product_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VendorScreen extends StatefulWidget {
  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<dynamic> _products = [];
  List<dynamic> _orders = [];
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _fetchDataBasedOnIndex();
  }

  Future<void> _fetchDataBasedOnIndex() async {
    if (_selectedIndex == 0) {
      _fetchProducts();
    } else if (_selectedIndex == 1) {
      _fetchOrders();
    } else {
      _fetchProfile();
    }
  }

  Future<void> _fetchProducts() async {
    _isLoading = true;
    String? token = await FlutterSecureStorage().read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
      '/api/v1/product/myPublicProducts',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response != null && response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body)['body'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch products');
    }
  }

  Future<void> _fetchOrders() async {
    _isLoading = true;
    String? token = await FlutterSecureStorage().read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
      '/api/v1/user/vendorOrders',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response != null && response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      List<dynamic> orders = responseBody['orders'] ?? [];
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch orders');
    }
  }

  Future<void> _fetchProfile() async {
    _isLoading = true;
    String? token = await FlutterSecureStorage().read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
      '/api/v1/user/myProfile',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response != null && response.statusCode == 200) {
      setState(() {
        _profile = json.decode(response.body)['data']['user'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch profile');
    }
  }

  List<Widget> _widgetOptions() => [
        _buildProductsPage(),
        _buildOrdersPage(),
        _buildProfilePage(),
      ];
  Widget _buildProductsPage() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Products'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NewProductPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text("You don't have any products yet"))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    var product = _products[index];
                    List<Widget> keywordChips =
                        product['keywords'].map<Widget>((keyword) {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(keyword,
                            style: TextStyle(color: Colors.black45)),
                      );
                    }).toList();

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: (product['images'] != null &&
                                product['images'].isNotEmpty)
                            ? Image.network(
                                product['images'][0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50, height: 50, color: Colors.grey[300]),
                        contentPadding: EdgeInsets.all(10),
                        title: Text(product['title'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${product['description']}'),
                            SizedBox(height: 10),
                            Wrap(children: keywordChips),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                print('Edit option selected');
                                break;
                              case 'delete':
                                print('Delete option selected');
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry>[
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildOrdersPage() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Orders'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text("No orders yet"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    var order = _orders[index];
                    bool isCompleted = order['orderStatus'] == 'completed';
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(order['productTitle'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Ordered by: ${order['customer']['firstName']} ${order['customer']['lastName']}\n'
                            'Email: ${order['customer']['email']}\n'
                            'Phone: ${order['shippingDetails']['phone']}\n'
                            'Payment Method: ${order['paymentType']}\n'
                            'Address: ${order['shippingDetails']['address']}'),
                        trailing: ElevatedButton(
                          onPressed: isCompleted
                              ? null
                              : () => _completeOrder(order['orderId'], index),
                          child: Text(isCompleted ? 'Completed' : 'Complete'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _completeOrder(String orderId, int index) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'authToken');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Authentication token is not available.'),
      ));
      return;
    }

    final response = await NetworkUtil.tryRequest(
      '/api/v1/user/completeOrder/$orderId',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: {"orderStatus": "completed"},
    );

    if (response != null && response.statusCode == 200) {
      setState(() {
        _orders[index]['orderStatus'] = 'completed';
      });
    } else if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Failed to complete order: ${json.decode(response.body)['message']}'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send request to complete order.'),
      ));
    }
  }

  Widget _buildProfilePage() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0), // Add padding around the content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Align text to the start of the column
                children: <Widget>[
                  Text(
                      (_profile['firstName'] ?? '') +
                          ' ' +
                          (_profile['lastName'] ?? ''),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5), // Internal padding for the username
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: Text('@${_profile['username'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 18, color: Colors.black26)),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5), // Internal padding for the email
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: Text('${_profile['email'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 18, color: Colors.black26)),
                  ),
                  SizedBox(height: 10),
                  Text('Status: ${_profile['accountStatus'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 18, color: Colors.green)),
                  Spacer(), // Use Spacer to push the logout button to the bottom of the screen
                  Align(
                    // Align the logout button to the center at the bottom
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0 && _products.isEmpty) {
        _isLoading = true;
        _fetchProducts();
      } else if (_selectedIndex == 1 && _orders.isEmpty) {
        _isLoading = true;
        _fetchOrders();
      } else if (_selectedIndex == 2 && _profile.isEmpty) {
        _isLoading = true;
        _fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Try'nBuy",
          style: TextStyle(color: Colors.orangeAccent),
        ),
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
