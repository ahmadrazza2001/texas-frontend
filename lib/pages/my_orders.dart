import 'package:flutter/material.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    String? token = await NetworkUtil.storage.read(key: 'authToken');
    if (token == null) {
      print("Authentication token not found");
      return;
    }

    final response = await NetworkUtil.tryRequest(
      '/api/v1/user/myOrders',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response != null && response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'success' && data['count'] > 0) {
        setState(() {
          _orders = data['orders'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "No orders found")),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch orders')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text("No orders found"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    var order = _orders[index];
                    // Format the date
                    DateTime orderDate = DateTime.parse(order['createdAt']);
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(orderDate);
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order['_id'].substring(order['_id'].length - 5)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          Text(
                            '${order['orderProductTitle']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PKR ${order['orderProductPrice']}',
                          ),
                          Text(
                            '${order['orderStatus']}',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      trailing: Text('Order Date: $formattedDate'),
                    );
                  },
                ),
    );
  }
}
