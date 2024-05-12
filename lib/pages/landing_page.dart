import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'package:texasmobiles/pages/login_page.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
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

  Widget _buildProductCard(
      String productName, String price, String imageUrl, String productType) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(imageUrl,
                width: double.infinity, height: 150, fit: BoxFit.cover),
            SizedBox(height: 5),
            Text(productName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: Icon(Icons.add_shopping_cart),
              label: Text('Add'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        pauseAutoPlayOnTouch: true,
        viewportFraction: 0.8,
      ),
      items: _products.map((product) {
        String imageUrl = (product['images'] is List)
            ? product['images'][0]
            : product['images'];
        return Builder(builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(color: Colors.amber),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          );
        });
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Texas Mobiles"),
        backgroundColor: Colors.orangeAccent,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Login', style: TextStyle(color: Colors.black)))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _isLoading ? CircularProgressIndicator() : _buildMainCarousel(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('New Arrivals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 330,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _products.map((product) {
                  String imageUrl = (product['images'] is List)
                      ? product['images'][0]
                      : product['images'];

                  String productType = product['productType'] ?? 'unknown';
                  return _buildProductCard(product['title'],
                      product['price'].toString(), imageUrl, productType);
                }).toList(),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTapItem(context, index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_checkout), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.amber[800],
      ),
    );
  }

  void _onTapItem(BuildContext context, int index) {
    setState(() {
      _currentIndex = index;
    });
    if (_currentIndex == 1 || _currentIndex == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
