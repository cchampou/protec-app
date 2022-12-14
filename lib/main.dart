import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:protec_app/screens/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/alert.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Déclenchement PC',
    description:
        'Déclenchement nécessitant une réponse immédiate de votre part',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  runApp(const Application());
}

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (navigatorKey.currentContext is BuildContext) {
      Navigator.of(navigatorKey.currentContext as BuildContext).push(
          MaterialPageRoute(
              builder: (context) =>
                  AlertScreen(eventId: message.data['eventId'])));
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'ADPC69 - ProtecApp',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const Home(),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        final String path = settings.name!;
        if (path.startsWith('/event/')) {
          final args = path.split('/');

          return MaterialPageRoute(
            builder: (context) {
              return AlertScreen(eventId: args[2]);
            },
          );
        }
        return null;
      },
    );
  }
}
