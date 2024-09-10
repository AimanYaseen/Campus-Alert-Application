import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffInformationPage extends StatefulWidget {
  @override
  _StaffInformationPageState createState() => _StaffInformationPageState();
}

class _StaffInformationPageState extends State<StaffInformationPage> {
  bool _isSearching = false; // Track whether search is active
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? Text(
                'All Active Staff',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase(); // For case-insensitive search
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by username',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
        backgroundColor: Colors.black,
        actions: !_isSearching
            ? [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.purpleAccent),
                  onPressed: () {
                    setState(() {
                      _isSearching = true; // Activate search mode
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.purpleAccent),
                  onPressed: () {
                    setState(() {
                      _isSearching = false; // Deactivate search mode
                      _searchController.clear();
                      _searchQuery = ''; // Reset search query
                    });
                  },
                ),
              ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.purple.shade500,
              Colors.lightBlueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where('role', isEqualTo: 'Staff')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No Staff Found'));
            }

            // Filter staff list by search query (case-insensitive)
            var filteredStaff = snapshot.data!.docs.where((doc) {
              var staffData = doc.data() as Map<String, dynamic>;
              var username = staffData['username'] ?? '';
              return username.toLowerCase().contains(_searchQuery);
            }).toList();

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredStaff.length,
              itemBuilder: (context, index) {
                var staff = filteredStaff[index].data() as Map<String, dynamic>;
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade200, Colors.blueGrey.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      staff['username'] ?? 'No Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email: ${staff['email'] ?? 'No Email'}',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'UserID: ${staff['userId'] ?? 'No UserID'}',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
