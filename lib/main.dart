import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patroli/ui/LoginPage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'help/firebase_options.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


// Setup flutter_local_notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showNotification(message);
  print("📩 Pesan di background: ${message.notification?.title}");
}

// Fungsi untuk menampilkan notifikasi sistem
Future<void> _showNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'nicepatrol_channel', // channel id
      'NicePatrol Notifications', // channel name
      channelDescription: 'Channel untuk notifikasi NicePatrol',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
    // bisa handle klik notifikasi di sini jika mau
    print('🔔 Notifikasi ditekan dengan payload: ${response.payload}');
  });

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const NicePatrolApp());
}

class NicePatrolApp extends StatefulWidget {
  const NicePatrolApp({super.key});

  @override
  State<NicePatrolApp> createState() => _NicePatrolAppState();
}

class _NicePatrolAppState extends State<NicePatrolApp> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  
  Future<void> _sendFCMTokenToServer(String? fcmToken) async {
  if (fcmToken == null || fcmToken.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final bearerToken = prefs.getString('token') ?? '';

  if (bearerToken.isEmpty) {
    print("⚠️ Bearer token tidak ditemukan di SharedPreferences");
    return;
  }

  final url = Uri.parse('http://www.programmerkreatif.biz.id:7787/api/auth/savetokenfcm');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: json.encode({
        'fcm_token': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ FCM token berhasil disimpan ke server");
    } else {
      print("❌ Gagal simpan FCM token: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("🚨 Error saat kirim FCM token: $e");
  }
}

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Minta izin notifikasi (iOS, Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Ambil token FCM
      String? token = await messaging.getToken();
      print("🔑 FCM Token: $token");

      setState(() {
        _fcmToken = token;
      });


      
      // Kirim token FCM ke server
      await _sendFCMTokenToServer(token);


      // Listener pesan di foreground → munculkan notifikasi sistem
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📢 Pesan di foreground: ${message.notification?.title}');
        _showNotification(message);
      });

      // Listener ketika notifikasi di-tap saat app background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📨 Notifikasi dibuka dari background: ${message.notification?.title}');
        if (message.notification != null && mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(message.notification!.title ?? "Notifikasi"),
              content: Text(message.notification!.body ?? ""),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        }
      });
    } else {
      print("🚫 Izin notifikasi ditolak");
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NicePatrol',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.manropeTextTheme(),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
