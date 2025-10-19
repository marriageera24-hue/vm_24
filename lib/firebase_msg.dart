import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 1. GLOBAL INSTANCE & CHANNEL DEFINITION (Moved outside the class for global access)
// We make these variables final and accessible globally since they are used by top-level functions.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel localNotificationChannel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max, // Essential for heads-up notifications
);

class FirebaseMsg {
  final msgService = FirebaseMessaging.instance;
  // Static variable to hold the token
  static String? _fcmToken;
  static String? get token => _fcmToken;

  initFCM() async {
    // 💡 FIX 1: CALL THE INITIALIZATION FUNCTION
    await initializeLocalNotifications();
    
    // Set iOS presentation options to ensure the notification appears in the foreground
    await msgService.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    msgService.requestPermission();
    _fcmToken = await msgService.getToken();
    print("tken:$_fcmToken");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
  }
}

// 2. INITIALIZATION FUNCTION (Remains the same, using global variables)
Future<void> initializeLocalNotifications() async {
  // Create Android Channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(localNotificationChannel);

  // Settings for Android & iOS
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          requestAlertPermission: true, 
          requestBadgePermission: true,
          requestSoundPermission: true,
      );
      
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('Local notification tapped! Payload: ${response.payload}');
    },
  );
}

// 3. THE SHOW FUNCTION (Moved outside the handler to be accessible)
Future<void> showLocalNotification({
  String? title, 
  String? body, 
  Map<String, dynamic>? data, // Optional data payload
}) async {
  final NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      localNotificationChannel.id, 
      localNotificationChannel.name,
      channelDescription: localNotificationChannel.description,
      importance: Importance.max, 
      priority: Priority.high,
      ticker: 'ticker',
    ),
  );

  final int id = DateTime.now().millisecondsSinceEpoch % 100000;

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
    // Convert data map to a JSON string for the payload (used on tap)
    payload: data?.toString() ?? 'default_payload',
  );
}


// HANDLER within the class for Foreground messages
void _handleForegroundNotification(RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  // 4. CALL THE NOW-ACCESSIBLE FUNCTION
  if (message.notification != null) {
    showLocalNotification(
      title: message.notification!.title, 
      body: message.notification!.body,
      data: message.data, // Pass data for potential handling on tap
    );
  }
  // The rest of the showLocalNotification code is removed from here.
}


// TOP-LEVEL FUNCTION: Required for background/terminated state handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); 
  print("Handling a background message: ${message.messageId}");
  print("Background message data: ${message.data}");
  final type = message.data['type'];
  final uuid = message.data['uuid'];

  print(type + "|||||||" + uuid);

  //TODO: Handle background message
}