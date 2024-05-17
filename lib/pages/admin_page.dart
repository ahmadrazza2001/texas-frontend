import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:texasmobiles/api/network_util.dart';
import 'package:texasmobiles/pages/login_page.dart';
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<dynamic> _requests = [];
  List<dynamic> _vendors = [];
  Map<String, dynamic> _profile = {};
  Map<String, bool> _approvedRequests = {};

  @override
  void initState() {
    super.initState();
    _fetchDataBasedOnIndex();
  }

  Future<void> _fetchDataBasedOnIndex() async {
    if (_selectedIndex == 0) {
      _fetchVendorRequests();
    } else if (_selectedIndex == 1) {
      _fetchVendors();
    } else {
      _fetchProfile();
    }
  }

  Future<void> _fetchVendorRequests() async {
    _isLoading = true;
    String? token = await FlutterSecureStorage().read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
      '/api/v1/admin/getVendorRequests',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response != null && response.statusCode == 200) {
      setState(() {
        _requests = json.decode(response.body)['data']['users'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        print('Failed to fetch vendor requests');
      });
    }
  }

  Future<void> _fetchVendors() async {
    _isLoading = true;
    String? token = await FlutterSecureStorage().read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
      '/api/v1/admin/getVendors',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response != null && response.statusCode == 200) {
      setState(() {
        _vendors = json.decode(response.body)['data']['users'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        print('Failed to fetch vendors');
      });
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
        print('Failed to fetch profile');
      });
    }
  }

  List<Widget> _widgetOptions() => [
        _buildRequestPage(),
        _buildVendorsPage(),
        _buildProfilePage(),
      ];

  Widget _buildRequestPage() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Vendor Requests'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchVendorRequests,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(child: Text("No vendor requests yet"))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    var request = _requests[index];
                    bool isApproved =
                        _approvedRequests[request['_id']] ?? false;
                    return Card(
                      child: ListTile(
                        title: Text('@${request['username']}'),
                        subtitle: Text(
                          '${request['firstName']} ${request['lastName']} wants to become a vendor.',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: ElevatedButton(
                          child: Text(
                            isApproved ? "Approved" : "Approve",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: isApproved
                              ? null
                              : () {
                                  _approveVendorRequest(request['_id'], index);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isApproved ? Colors.grey : Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _approveVendorRequest(String userId, int index) async {
    String? token = await FlutterSecureStorage().read(key: 'authToken');
    final response = await NetworkUtil.tryRequest(
        '/api/v1/admin/updateUserRole/$userId',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'role': 'vendor'
        });

    if (response != null && response.statusCode == 200) {
      setState(() {
        _approvedRequests[userId] = true; // Mark as approved
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vendor approved successfully!")),
      );
      _fetchVendorRequests(); // Optionally refresh requests or handle UI update directly
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to approve request")),
      );
    }
  }

  Widget _buildVendorsPage() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Vendors'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchVendors,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _vendors.isEmpty
              ? Center(child: Text("No vendors yet"))
              : ListView.builder(
                  itemCount: _vendors.length,
                  itemBuilder: (context, index) {
                    var vendor = _vendors[index];
                    return Card(
                      color: Colors.orange[50],
                      child: ListTile(
                        title: Text(
                          vendor['username'],
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                        subtitle: Text('Email: ${vendor['email']}'),
                        trailing: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Block",
                              style: TextStyle(color: Colors.red),
                            )),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      (_profile['firstName'] ?? '') +
                          ' ' +
                          (_profile['lastName'] ?? ''),
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('@${_profile['username'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                  Text('${_profile['email'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                  SizedBox(height: 10),
                  // Text('Status: ${_profile['accountStatus'] ?? 'N/A'}', style: TextStyle(fontSize: 15, color: Colors.green)),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child:
                          Text('Logout', style: TextStyle(color: Colors.white)),
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
      _fetchDataBasedOnIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Texas Admin"),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_rounded),
            label: 'Vendors',
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
