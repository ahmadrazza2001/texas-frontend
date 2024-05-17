import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:texasmobiles/pages/login_page.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'package:texasmobiles/pages/productDetails.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  Map<String, String> _shopAddresses = {};
  String _selectedCondition = 'new';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await NetworkUtil.tryRequest('/api/v1/product/allProducts',
        headers: {'Content-Type': 'application/json'});
    if (response != null && response.statusCode == 200) {
      List<dynamic> products = json.decode(response.body)['body'];
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProductTile(String productName, String price, String imageUrl,
      String productId, String userId, String productStatus) {
    return InkWell(
      // Use InkWell for onTap functionality
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
                // Row(
                //   children: [
                //     Icon(Icons.location_on, size: 16),
                //     SizedBox(width: 4),
                //     Text('${userId}'),
                //   ],
                // ),
                Row(
                  children: [
                    Icon(
                      Icons.sentiment_very_satisfied,
                      size: 16,
                      color: Colors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${productStatus}',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = _products
        .where((product) => product['condition'] == _selectedCondition)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("TexasMobiles"),
        backgroundColor: Colors.orangeAccent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          _navigationTab(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];
                      return _buildProductTile(
                          product['title'],
                          product['price'].toString(),
                          product['images'][0],
                          product['_id'],
                          product['userId']['shopAddress'],
                          product['productStatus']);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1 || index == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.orange[100],
      ),
    );
  }
}
