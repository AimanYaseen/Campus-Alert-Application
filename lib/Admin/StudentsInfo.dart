import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentsInformationPage extends StatefulWidget {
  @override
  _StudentsInformationPageState createState() =>
      _StudentsInformationPageState();
}

class _StudentsInformationPageState extends State<StudentsInformationPage> {
  bool _isSearching = false; // Track search mode
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? Text(
                'All Students',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase(); // Case-insensitive search
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
                      _isSearching = true; // Enable search mode
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.purpleAccent),
                  onPressed: () {
                    setState(() {
                      _isSearching = false; // Disable search mode
                      _searchController.clear();
                      _searchQuery = ''; // Clear search query
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
              .where('role', isEqualTo: 'Student')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No Students Found'));
            }

            // Filter the list of students based on the search query
            var filteredStudents = snapshot.data!.docs.where((doc) {
              var studentData = doc.data() as Map<String, dynamic>;
              var username = studentData['username'] ?? '';
              return username.toLowerCase().contains(_searchQuery);
            }).toList();

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                var student = filteredStudents[index].data() as Map<String, dynamic>;
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
                      student['username'] ?? 'No Name',
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
                          'Email: ${student['email'] ?? 'No Email'}',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'UserID: ${student['userId'] ?? 'No UserID'}',
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
