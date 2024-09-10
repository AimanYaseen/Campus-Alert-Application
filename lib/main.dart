import 'package:collegealert/Admin/AdminHomepage.dart';
import 'package:collegealert/Admin/AlertsPage.dart';
import 'package:collegealert/Admin/StaffInfo.dart';
import 'package:collegealert/Admin/StudentsInfo.dart';
import 'package:collegealert/Admin/UploadAlerts.dart';
import 'package:collegealert/Authentication/ForgorPass.dart';
import 'package:collegealert/Authentication/SignIn.dart';
import 'package:collegealert/Authentication/Signup.dart';
import 'package:collegealert/Home/AddComplain.dart';
import 'package:collegealert/Home/Complains.dart';
import 'package:collegealert/Home/Notification_screen.dart';
import 'package:collegealert/Home/ProfilePage.dart';
import 'package:collegealert/Home/StudentDashboard.dart';
import 'package:collegealert/Staff/StaffHomepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';  // Import Get package
import 'package:page_flip_builder/page_flip_builder.dart'; // Import page_flip_builder
import 'dart:async'; // For Timer
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
   return GetMaterialApp(
      title: 'College Alert App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/studenthomepage') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return StudentHomepage(username: args['username']);
            },
          );
        } else if (settings.name == '/adminhomepage') {
          return MaterialPageRoute(builder: (context) => AdminHomePage());
        } else if (settings.name == '/staffhomepage') {
          return MaterialPageRoute(builder: (context) => StaffHomePage());
        }
        return null; // If no matching route, return null
      },
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/resetpassword': (context) => ResetPassword(),
        '/uploadStudentAlert': (context) => UploadAlertsPage(),
        '/uploadStaffAlert': (context) => UploadAlertsPage(),
        '/alertsPage': (context) => AlertsPage(),
        '/studentsPage': (context) => StudentsInformationPage(),
        '/staffPage': (context) => StaffInformationPage(),
        '/complain': (context) => AllComplainsPage(),
        '/notification': (context) => NotificationScreen(),
        '/profile': (context) => ProfilePage(),
        '/addcomplain': (context) => AddComplainPage(),
        
        // Other routes that don't need parameters can stay here
      },
      debugShowCheckedModeBanner: false,
    );
}
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final pageFlipKey = GlobalKey<PageFlipBuilderState>();
  Gradient _backgroundGradient = LinearGradient(
    colors: [
      Colors.black87,
      Colors.deepPurple.shade900,
      Colors.purple.shade600,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Gradient _targetGradient = LinearGradient(
    colors: [
      Colors.deepPurple.shade900,
      Colors.purple.shade600,
      Colors.black87,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    // Automatically flip the page after 8 seconds and change gradient
    Timer(Duration(seconds: 6), () {
      setState(() {
        _backgroundGradient = _targetGradient;
      });
      Timer(Duration(seconds: 0), () {
        pageFlipKey.currentState?.flip();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 4),
        decoration: BoxDecoration(
          gradient: _backgroundGradient,
        ),
        child: PageFlipBuilder(
          key: pageFlipKey,
          frontBuilder: (_) => _buildSplashContent(),
          backBuilder: (_) => LoginPage(),
          flipAxis: Axis.horizontal, // Flip horizontally
          maxTilt: 0.003,
          maxScale: 0.2,
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo and text in a row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular container for logo with gradient shadow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/AlertLogo.PNG',
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20), // Space between logo and text
            // Text beside the logo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AlertMeFyy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Stay Informed, Stay Ahead',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 30),
        // Loading Indicator
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    ),
  );
}
}