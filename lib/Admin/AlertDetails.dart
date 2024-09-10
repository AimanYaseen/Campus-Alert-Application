import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegealert/Admin/UpdateAlert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertDetailsPage extends StatefulWidget {
  final String alertId;

  AlertDetailsPage({required this.alertId});

  @override
  _AlertDetailsPageState createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage> {
  // Function to show the bottom sheet
  Future<bool?> _showUpdateBottomSheet(BuildContext context, Map<String, dynamic> alertData) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return UpdateAlertSheet(alertData: alertData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Alert Details',
          style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.purpleAccent),
            onPressed: () async {
              final docSnapshot = await FirebaseFirestore.instance.collection('Alerts').doc(widget.alertId).get();
              if (docSnapshot.exists) {
                var alertData = docSnapshot.data() as Map<String, dynamic>;
                final result = await _showUpdateBottomSheet(context, alertData);
                if (result == true) {
                  setState(() {});
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert not found!')));
              }
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/alertsPage', (route) => true);
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Alerts').doc(widget.alertId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Alert not found'));
            }

            var alert = snapshot.data!.data() as Map<String, dynamic>;

            // Format the date
            String formattedDate = '';
            if (alert['date'] != null) {
              DateTime alertDate = (alert['date'] as Timestamp).toDate();
              formattedDate = DateFormat('MMMM dd, yyyy').format(alertDate);
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alert Image with Placeholder
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: alert['imageUrl'] != null
                            ? Image.network(alert['imageUrl'], fit: BoxFit.cover, loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : Center(child: CircularProgressIndicator());
                              })
                            : Container(
                                color: Colors.grey.shade300,
                                child: Icon(Icons.image, size: 100, color: Colors.grey.shade600),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Alert Title
                    Text(
                      alert['title'] ?? '',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white70),
                        SizedBox(width: 5),
                        Text('Date: $formattedDate', style: TextStyle(fontSize: 18, color: Colors.white70)),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Created By
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.white70),
                        SizedBox(width: 5),
                        Text('Created By: ${alert['createdBy'] ?? ''}', style: TextStyle(fontSize: 18, color: Colors.white70)),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Description Card
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shadowColor: Colors.black54,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              alert['description'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
