import 'dart:convert';
import 'dart:developer';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/ui/chat_screen/chat_screen.dart';
import 'package:customer/ui/help_support_screen/help_support_screen.dart';
import 'package:customer/ui/intercityOrders/intercity_payment_order_screen.dart';
import 'package:customer/ui/orders/payment_order_screen.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
  if (message.notification != null) {
    log(message.notification.toString());
    NotificationService().display(message);
  }
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initInfo() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized || request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (response) {
        // if (response.payload != null) {
        //   var data = jsonDecode(response.payload!);
        //   handleMessageClick(payload: data);
        // }
      });
      setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage((message) => firebaseMessageBackgroundHandle(message));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log("::::::::::::onMessageOpenedApp:::::::::::::::::");
      handleMessageClick(payload: message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      log("::::::::::::getInitialMessage:::::::::::::::::");
      if (message?.data != null) {
        await Preferences.setBoolean(Preferences.notificationPlayload, true);
        log("Preferences.getBoolean(Preferences.notificationPlayload) :::: ${Preferences.getBoolean(Preferences.notificationPlayload)}");
        handleMessageClick(payload: message?.data);
      }
    });
    await FirebaseMessaging.instance.subscribeToTopic("goRide_customer");
  }

  Future<void> handleMessageClick({required dynamic payload}) async {
    log("handleMessageClick :::::: ${payload.toString()}");
    final data = payload;

    if (data != null) {
      if (data['type'] == "admin_chat") {
        UserModel? customer = await FireStoreUtils.getUserProfile(data['driverId']);
        Get.to(HelpSupportScreen(
          userId: customer?.id,
          userName: customer?.fullName,
          userProfileImage: customer?.profilePic,
          token: customer?.fcmToken,
          isShowAppbar: true,
        ));
      } else if (data['type'] == "chat") {
        UserModel? customer = await FireStoreUtils.getUserProfile(data['customerId']);
        DriverUserModel? driver = await FireStoreUtils.getDriver(data['driverId']);
        Get.to(ChatScreens(
          driverId: driver!.id,
          customerId: customer!.id,
          customerName: customer.fullName,
          customerProfileImage: customer.profilePic,
          driverName: driver.fullName,
          driverProfileImage: driver.profilePic,
          orderId: data['orderId'],
          token: driver.fcmToken,
        ));
      } else if (data['type'] == "city_order_complete") {
        OrderModel? orderModel = await FireStoreUtils.getOrder(data['orderId']);
        Get.to(const PaymentOrderScreen(), arguments: {
          "orderModel": orderModel,
        });
      } else if (data['type'] == "intercity_order_complete") {
        InterCityOrderModel? orderModel = await FireStoreUtils.getInterCityOrder(data['orderId']);
        Get.to(const InterCityPaymentOrderScreen(), arguments: {
          "orderModel": orderModel,
        });
      }
    }
  }

  static Future<String> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        '0',
        'goRide-customer',
        description: 'Show QuickLAI Notification',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name, channelDescription: 'your channel Description', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
