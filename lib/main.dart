import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:village/config/theme.dart';
import 'package:village/firebase_options.dart';
import 'dart:io';
import 'package:village/services/local_storage/shared_preference.dart';
import 'package:village/services/network_service/network_error_screen.dart';
import 'package:village/services/network_service/network_notifier.dart';
import 'package:village/services/routes/route_name/route_name.dart';
import 'package:village/services/routes/route_page/route_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'services/api/notification_service/notifiction_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isIOS) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase background initialization failed: $e");
  }
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isIOS) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print("Firebase initialization failed: $e");
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  await NotificationService.init();
  await SharedPreferencesHelper().init();
  String? deviceToken = await NotificationService.getToken();
  if(deviceToken != null){
    print("--------- DEVICE TOKEN ---------");
    print(deviceToken);
    SharedPreferencesHelper().setString("DToken",deviceToken);
    print("--------------------------------");
  }else{
    print("Device token is null");
  }


  if (!Platform.isIOS) {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("App launched from terminated state via notification");
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnectedAsync = ref.watch(networkStatusProvider);

    final isConnected = isConnectedAsync.maybeWhen(
      data: (value) => value,
      orElse: () => true,
    );

    return GetMaterialApp(
      title: 'SSJSC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (!isConnected)
              const NetworkOverlay()
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}