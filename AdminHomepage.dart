import 'package:collegealert/Admin/UploadEvents.dart';
import 'package:collegealert/Admin/backgroundpainter.dart';
import 'package:collegealert/services/Notification_service.dart';
import 'package:collegealert/services/get_service_key.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:intl/intl.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();
  final String _adminUserId = 'tXAf7SqCSCcaXW0amomiWvZrBDN2';
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection('Events');

  int _totalStudents = 0;
  int _totalStaff = 0;
  String _adminUsername = 'Admin Username';
  String _adminEmail = 'admin@example.com';
  String _adminPhotoUrl = '';
NotificationService _notificationService = NotificationService();
final GetServerKey _getServerKey = GetServerKey();


  


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _notificationService.requestNotificationPermission();
    _notificationService.getDeviceToken();
    _notificationService.firebaseInit(context);
   _notificationService.setupInteractMessage(context);
    getServiceToken();
  }
  
  Future<void> getServiceToken() async {
    String serverToken = await _getServerKey.getServerKeyToken();
    print("Server Token => $serverToken");
  }

  Future<void> _fetchUserData() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');

    try {
      // Fetch admin details
      final adminSnapshot = await usersCollection.doc(_adminUserId).get();
      final adminData = adminSnapshot.data();
      if (adminData != null) {
        setState(() {
          _adminUsername = adminData['username'] ?? 'Admin Username';
          _adminEmail = adminData['email'] ?? 'admin@example.com';
          _adminPhotoUrl = adminData['photoUrl'] ?? '';
        });
        print(
            'Admin data fetched successfully: $_adminUsername, $_adminEmail, $_adminPhotoUrl');
      } else {
        print('Admin document does not exist');
      }

      // Fetch total students and staff
      final studentsSnapshot =
          await usersCollection.where('role', isEqualTo: 'Student').get();
      final staffSnapshot =
          await usersCollection.where('role', isEqualTo: 'Staff').get();

      setState(() {
        _totalStudents = studentsSnapshot.docs.length;
        _totalStaff = staffSnapshot.docs.length;
      });
      print('Total students: $_totalStudents, Total staff: $_totalStaff');
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _uploadPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);

      try {
        // Upload file to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('admin_photos/$_adminUserId.jpg');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => {});
        final photoUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new photo URL
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(_adminUserId)
            .update({
          'photoUrl': photoUrl,
        });

        setState(() {
          _adminPhotoUrl = photoUrl;
        });
      } catch (e) {
        print('Error uploading photo: $e');
      }
    }
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.purple.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              _adminUsername,
              style: TextStyle(fontSize: 18),
            ),
            accountEmail: Text(
              _adminEmail,
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: GestureDetector(
              onTap: _uploadPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: _adminPhotoUrl.isNotEmpty
                        ? NetworkImage(_adminPhotoUrl)
                        : AssetImage('assets/images/admin.jpg') as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.deepPurple),
            title: Text('Student Information'),
            onTap: () => _navigateTo('/studentsPage'),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text('Staff Information'),
            onTap: () => _navigateTo('/staffPage'),
          ),
          ListTile(
  leading: Icon(Icons.notifications, color: Colors.deepPurple),
  title: Text('All Alerts'),
  onTap: () => _navigateTo('/alertsPage'),
),
ListTile(
  leading: Icon(Icons.notifications, color: Colors.deepPurple),
  title: Text('Students Complains'),
  onTap: () => _navigateTo('/complain'),
),


          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: () => _navigateTo('/login'),
          ),
        ],
      ),
    );
  }

Widget _buildPieChart() {
  int totalUsers = _totalStudents + _totalStaff;

  return PieChart(
    PieChartData(
      sections: [
        PieChartSectionData(
          value: _totalStudents.toDouble(),
          color: Colors.black,
          title: _totalStudents > 0
              ? 'Students ${(_totalStudents / totalUsers * 100).toStringAsFixed(1)}%'
              : 'Students 0%',
          titleStyle: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          radius: 80,  // Reduced the size of the chart
        ),
        PieChartSectionData(
          value: _totalStaff.toDouble(),
          color: Colors.lightBlueAccent,
          title: _totalStaff > 0
              ? 'Staff ${(_totalStaff / totalUsers * 100).toStringAsFixed(1)}%'
              : 'Staff 0%',
          titleStyle: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          radius: 80,  // Reduced the size of the chart
        ),
      ],
      centerSpaceRadius: 40,
      sectionsSpace: 0,
      borderData: FlBorderData(show: false),
      startDegreeOffset: 270,
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
          // No touch functionality
        },
      ),
    ),
  );
}





 Widget _buildLegend(String text, Color color) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        color: color,
      ),
      SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16, // Set the font size to 16
          fontWeight: FontWeight.bold, // Make the text bold
        ),
      ),
    ],
  );
}
Widget _buildUploadEventsButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UploadEventsPage()),
        );
      },
      child: Text('Upload Events'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.purpleAccent,
        padding: EdgeInsets.symmetric(vertical: 12.0),
        textStyle: TextStyle(fontSize: 18),
      ),
    ),
  );
}
//-------------NOTIFICATIONS WIDGET-------------
  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: eventsRef.orderBy('timestamp', descending: true).limit(5).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> event = document.data()! as Map<String, dynamic>;
              // Format timestamp
              String formattedDate = event['timestamp']?.toDate() != null
                  ? DateFormat('dd/MM/yyyy').format(event['timestamp'].toDate())
                  : 'No Date';

              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.arrow_forward_ios, // Replace dot with arrow icon
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            event['title'] ?? 'No Title',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      event['message'] ?? 'No Message',
                    ),
                    onTap: () {
                      // Optionally, navigate to the details page of the event
                    },
                  ),
                  Divider( // Add Divider after each notification
                    color: Colors.deepPurple.shade400,
                    thickness: 1,
                  ),
                ],
              );
            }).toList(),
          );
        } else {
          return Text(
            'No recent events found',
            style: TextStyle(color: Colors.white),
          );
        }
      },
    );
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'WELCOME, Admin',
        style: TextStyle(
          color: Colors.purpleAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.purpleAccent,
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            'assets/images/image_no_bg.png',
            height: 40,
            width: 40,
          ),
        ),
      ],
    ),
    drawer: _buildDrawer(),
    body: SingleChildScrollView(
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUploadEventsButton(context),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/uploadStudentAlert');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      height: 100,
                      child: Center(
                        child: Text(
                          'Upload Alert for Students',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 100,
                  color: Colors.grey[400],
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/uploadStaffAlert');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      height: 100,
                      child: Center(
                        child: Text(
                          'Upload Alert for Staff',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Section with pie chart
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: NetBackgroundPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Students & Staff Distribution',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),  // Added more space after heading
                        Container(
                          height: 200,  // Reduced the size of the chart container
                          width: 200,
                          child: _buildPieChart(),
                        ),
                        SizedBox(height: 18),
                       Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusts spacing between the two items
  children: [
    _buildLegend('Total Students: $_totalStudents', Colors.black),
    _buildLegend('Total Staff: $_totalStaff', Colors.lightBlueAccent),
  ],
),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Notification Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade500,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Events/Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildNotificationsList(),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}