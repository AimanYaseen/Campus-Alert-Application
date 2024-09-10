import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegealert/Admin/backgroundpainter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Notification_screen.dart';
import '../services/Notification_service.dart';
import '../services/get_service_key.dart';

class StudentHomepage extends StatefulWidget {
  final String username;

  StudentHomepage({required this.username});

  @override
  _StudentHomepageState createState() => _StudentHomepageState();
}

class _StudentHomepageState extends State<StudentHomepage> {
  NotificationService _notificationService = NotificationService();
  final GetServerKey _getServerKey = GetServerKey();
  late Stream<QuerySnapshot> _eventsStream;
  late Stream<QuerySnapshot> _alertsStream;

  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();
    _notificationService.getDeviceToken();
    _notificationService.firebaseInit(context);
    _notificationService.setupInteractMessage(context);
    getServiceToken();

    // Initialize the streams to fetch events and alerts
    _eventsStream = FirebaseFirestore.instance
        .collection('Events')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _alertsStream = FirebaseFirestore.instance
        .collection('Alerts')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> getServiceToken() async {
    String serverToken = await _getServerKey.getServerKeyToken();
    print("Server Token => $serverToken");
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu, // Drawer icon
                color: Colors.purpleAccent, // Set the drawer icon color here
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
      title: Text(
        'Welcome, ${widget.username}',
        style: TextStyle(
          color: Colors.purpleAccent,
        ),
      ),
      backgroundColor: Colors.black,
      actions: [
        GestureDetector(
          onTap: () => Get.to(() => NotificationScreen()),
          child: Container(
            margin: EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(4, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.notifications,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
      ],
    ),
            drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: NetBackgroundPainter(),
                    child: Center(
                      child: Text(
                        'AlertMeFyy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the drawer
                      },
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.black),
              title: Text('Alerts', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                Navigator.pushNamed(context, '/alertsPage');
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement, color: Colors.black),
              title: Text('Complaints', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                Navigator.pushNamed(context, '/complain');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text('Profile', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Divider(
              color: Colors.deepPurple, // Purple color for the divider
              thickness: 2, // Thickness of the divider
              indent: 16, // Space from the start of the drawer
              endIndent: 16, // Space from the end of the drawer
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.deepPurple)),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Welcome to AlertMeFyy!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Stay informed, Stay Ahead',
                        style: TextStyle(fontSize: 18, color: Colors.grey[200]),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Divider(color: Colors.deepPurpleAccent),
                Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
  stream: _eventsStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Text(
          'No upcoming events',
          style: TextStyle(color: Colors.deepPurpleAccent),
        ),
      );
    }
    return Column(
      children: snapshot.data!.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Card(
            margin: EdgeInsets.all(0), // Remove default margin of the Card
            elevation: 0, // Remove default elevation of the Card
            color: Colors.transparent, // Make Card's background transparent
            child: ListTile(
              title: Text(
                data['title'] ?? 'No Title',
                style: TextStyle(
                  color: Colors.deepPurple, // Deep purple color for title
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                data['message'] ?? 'No Message',
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 14 // Grey color for message
                ),
              ),
              trailing: Text(
                '${(data['timestamp'] as Timestamp).toDate().toLocal().toString()}',
                style: TextStyle(color: Colors.grey.shade900,
                fontWeight: FontWeight.bold, fontSize:12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  },
),
                SizedBox(height: 20),
                Text(
                  'Latest Alerts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: _alertsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No new alerts',
                          style: TextStyle(color: Colors.deepPurpleAccent),
                        ),
                      );
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(data['title'] ?? 'No Title', style: TextStyle(
                                color: Colors.deepPurple, 
                                fontWeight: FontWeight.bold)),
                                subtitle: Text(data['description'] ?? 'No Description', style: TextStyle(color: Colors.black)),
                                trailing: Text(
                                  '${(data['date'] as Timestamp).toDate().toLocal().toString()}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              if (data['imageUrl'] != null && data['imageUrl'] != '')
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    data['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Created By: ${data['createdBy']}',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complains',
          ),
        ],
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/studenthomepage');
              break;
            case 1:
              Navigator.pushNamed(context, '/notification');
              break;
            case 2:
              Navigator.pushNamed(context, '/addcomplain');
              break;
          }
        },
      ),
    );
  }
}
