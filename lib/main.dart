import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vm_24/firebase_msg.dart';
import 'package:vm_24/view/profile_view.dart';
import 'view/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import the new file containing all notification logic
import 'notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging
  await FirebaseMsg().initFCM();
  // Initialize Notification Channel on Android, using constants from the service file
  await NotificationService.plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(NotificationService.androidChannel);

  // Set foreground notification presentation options for Android, iOS, and macOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginPage()
    },
  ));
}


// On app startup to check login state
    Future<bool> checkLoginState() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false; // Default to false if not found
    }
class VMApp extends StatelessWidget {
  const VMApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 FIX: Use FutureBuilder to wait for the asynchronous checkLoginState()
    return FutureBuilder<bool>(
      future: checkLoginState(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // Show a loading screen while checking the state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Get the result (default to false if an error occurred or data is null)
        final bool isLoggedIn = snapshot.data ?? false;

        // Build the main MaterialApp with the initial route based on the login state
        return MaterialApp(
          // Define all routes here, including the home/initial route
          initialRoute: isLoggedIn ? '/profile' : '/login',
          routes: {
            // Note: Since you seem to want HomeScreen to be the post-login view,
            // I'm using '/home' for it. If ProfileView is the post-login landing,
            // you'd set the route for '/home' to ProfileView().
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomeScreen(),
            // Add other required routes here
            '/profile': (context) => ProfileView(),
            
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use the NotificationService class from the separate file
  final NotificationService _notificationService = NotificationService();
  String _fcmToken = 'Fetching token...';

  @override
  void initState() {
    super.initState();
    // 1. Initialize local notifications settings (needed for foreground display)
    _notificationService.initializeLocalNotifications();
    // 2. Set up listener for foreground messages
    _notificationService.setupForegroundMessageListener();
    // 3. Handle messages that opened the app (terminated/background state)
    _notificationService.handleTerminatedStateMessage(context);
    // 4. Get and display the FCM token
    _getFCMToken();
  }

  void _getFCMToken() async {
    String? token = await _notificationService.getDeviceToken();
    setState(() {
      _fcmToken = token ?? 'Failed to get token.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Notifications Example'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent back button after login
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.notifications_active,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ready to Receive Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Use the token below to send test messages from the Firebase Console.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FCM Device Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _fcmToken,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Example button to test navigation to one of the defined routes
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
                icon: const Icon(Icons.settings),
                label: const Text('Go to Settings (Example Route)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}