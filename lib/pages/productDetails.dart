import 'package:flutter/material.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  ProductDetailPage({required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _productDetails;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    final response = await NetworkUtil.tryRequest(
        '/api/v1/product/productDetails/${widget.productId}',
        headers: {'Content-Type': 'application/json'});
    if (response != null && response.statusCode == 200) {
      var productData = json.decode(response.body)['product'];
      setState(() {
        _productDetails = productData;
        _isLoading = false;
      });
      _getLatLongFromAddress(productData['userId']['shopAddress']);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_markers.isNotEmpty) {
      moveCameraToFirstMarker();
    }
  }

  void moveCameraToFirstMarker() {
    var firstMarkerLocation = _markers.first.position;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: firstMarkerLocation,
        zoom: 15,
      ),
    ));
  }

  void _getLatLongFromAddress(String? address) async {
    if (address == null) {
      print("No address provided");
      return;
    }
    try {
      List<Location> locations = await locationFromAddress(address);
      var firstLocation = locations.first;
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('shopLoc'),
          position: LatLng(firstLocation.latitude, firstLocation.longitude),
        ));
      });
      if (mapController != null) {
        moveCameraToFirstMarker();
      }
    } catch (e) {
      print("Failed to get location: $e for address: $address");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _productDetails == null
              ? Center(child: Text('Product details not available.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_productDetails?['title'] ?? 'No title',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _productDetails?['images'] != null &&
                                _productDetails!['images'].isNotEmpty
                            ? Image.network(_productDetails!['images'][0])
                            : Text("No image available"),
                        SizedBox(height: 10),
                        Text('Price: PKR ${_productDetails?['price'] ?? 'N/A'}',
                            style: TextStyle(
                                fontSize: 20, color: Colors.orangeAccent)),
                        SizedBox(height: 10),
                        Text(
                            'Condition: ${_productDetails?['condition'] ?? 'N/A'}'),
                        SizedBox(height: 10),
                        Text(
                            'Description: ${_productDetails?['description'] ?? 'No description provided'}'),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Shop Address: ${_productDetails?['userId']['shopAddress'] ?? 'No address provided'}'),
                              SizedBox(height: 10),
                              Container(
                                height: 250, // Set the height for the map
                                width: double
                                    .infinity, // Set the width to match the container
                                child: GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(0, 0), // Default position
                                    zoom: 2, // Default zoom
                                  ),
                                  markers: _markers,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
