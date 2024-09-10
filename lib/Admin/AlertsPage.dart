import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegealert/Admin/AlertDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AlertsPage extends StatefulWidget {
  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _selectedFilter = 'All';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _customStartDate = DateTime.now();
  DateTime _customEndDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: _isSearching
      ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by ID or Name...',
            border: InputBorder.none,
          ),
          autofocus: true,
          style: TextStyle(color: Colors.purpleAccent), // Set text color here
          onChanged: (value) {
            setState(() {});
          },
        )
      : Text(
          'All Alerts',
          style: TextStyle(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
  backgroundColor: Colors.black,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.purpleAccent),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  actions: [
    IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.purpleAccent),
      onPressed: () {
        setState(() {
          if (_isSearching) {
            _searchController.clear();
          }
          _isSearching = !_isSearching;
        });
      },
    ),
  ],
),


      body: Column(
        children: [
          _isSearching
              ? Container()
              : Column(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.all(8),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                            _updateDateRange();
                          });
                        },
                        items: <String>[
                          'All',
                          'This Week',
                          'This Month',
                          'This Year',
                          'Previous Week',
                          'Previous Year',
                          'Custom Date'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text('Filter by Date'),
                      ),
                    ),
                    if (_selectedFilter == 'Custom Date')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                  text: '${_customStartDate.toLocal()}'.split(' ')[0],
                                ),
                                onTap: () async {
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _customStartDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (selectedDate != null && selectedDate != _customStartDate) {
                                    setState(() {
                                      _customStartDate = selectedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                  text: '${_customEndDate.toLocal()}'.split(' ')[0],
                                ),
                                onTap: () async {
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _customEndDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (selectedDate != null && selectedDate != _customEndDate) {
                                    setState(() {
                                      _customEndDate = selectedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredAlertsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Alerts Found'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var alert = doc.data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlertDetailsPage(alertId: doc.id),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${doc.id}',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
  DateFormat('dd/MM/yyyy').format((alert['date'] as Timestamp).toDate()),
  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
),

                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${alert['title']}',
                                      style: TextStyle(fontSize:18,
                                      color:  Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.grey.shade200, Colors.grey.shade300],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${alert['description']}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

Stream<QuerySnapshot> _getFilteredAlertsStream() {
  final alertsCollection = FirebaseFirestore.instance.collection('Alerts');
  
  String searchText = _searchController.text.toLowerCase();
  
  // If searching, return the query by alertId or title
  if (_isSearching && searchText.isNotEmpty) {
    return alertsCollection
      .where('alertId', isEqualTo: searchText)
      .snapshots();
  } else if (_isSearching && searchText.isNotEmpty) {
    return alertsCollection
      .where('title', isGreaterThanOrEqualTo: searchText)
      .where('title', isLessThanOrEqualTo: searchText + '\uf8ff') // To handle prefix search for strings
      .snapshots();
  }

  // Date filtering logic
  DateTime now = DateTime.now();
  DateTime startDate;
  DateTime endDate;

  switch (_selectedFilter) {
    case 'This Week':
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = startDate.add(Duration(days: 7));
      break;
    case 'This Month':
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
      break;
    case 'This Year':
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year + 1, 1, 1);
      break;
    case 'Previous Week':
      startDate = now.subtract(Duration(days: now.weekday + 6));
      endDate = startDate.add(Duration(days: 7));
      break;
    case 'Previous Year':
      startDate = DateTime(now.year - 1, 1, 1);
      endDate = DateTime(now.year, 1, 1);
      break;
    case 'Custom Date':
      startDate = _customStartDate;
      endDate = _customEndDate;
      break;
    default:
      // Default range, return all alerts without filtering
      return alertsCollection.snapshots();
  }

  // Query Firestore for alerts within the date range using Timestamp
  return alertsCollection
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
      .snapshots();
}



  void _updateDateRange() {
    DateTime now = DateTime.now();
    switch (_selectedFilter) {
      case 'This Week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = _startDate.add(Duration(days: 7));
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'This Year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year + 1, 1, 1);
        break;
      case 'Previous Week':
        _startDate = now.subtract(Duration(days: now.weekday + 6));
        _endDate = _startDate.add(Duration(days: 7));
        break;
      case 'Previous Year':
        _startDate = DateTime(now.year - 1, 1, 1);
        _endDate = DateTime(now.year, 1, 1);
        break;
      default:
        _startDate = now.subtract(Duration(days: 365 * 5)); // Default range
        _endDate = now;
    }
  }
}
