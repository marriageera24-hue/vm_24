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
  runApp(const VMApp());
}


// On app startup to check login state
/*************  ✨ Windsurf Command ⭐  *************/
/// Checks whether the user is logged in or not by checking the 'isLoggedIn' key in SharedPreferences.
/// If the key is not found, it defaults to false.

/*******  30bdb980-b0fa-4349-8cc3-a716a6bcbdd5  *******/
    Future<bool> checkLoginState() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false; // Default to false if not found
    }

class VMApp extends StatelessWidget {
  const VMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginState(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // ... (loading state logic) ...

        final bool isLoggedIn = snapshot.data ?? false;

        // Build the main MaterialApp with the initial route based on the login state
        return MaterialApp(
          // Define ONLY the routes you want
          initialRoute: isLoggedIn ? '/profile' : '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/profile': (context) => ProfileView(),
          },
        );
      },
    );
  }
}
 