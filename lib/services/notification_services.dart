import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do/ui/pages/notification_screen.dart';

import '../models/task.dart';
class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// initializeNotification makes initialization of setting of android & ios to receive notifications
  String selectedNotificationPayload = '';

  final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();
  initializeNotification()async{
    tz.initializeTimeZones(); //Initialise the time zone database
  //  tz.setLocalLocation(tz.getLocation(timeZoneName)); // Once the time zone database has been initialised, developers may optionally want to set a default local location/time zone

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project


    final AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('appicon');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse)async{
          onDidReceiveNotificationResponse(notificationResponse.payload as NotificationResponse);
          });
  }



  // Displaying a notification ,this is in time

  displayNotification({required String title, required String body})async{
     AndroidNotificationDetails androidNotificationDetails =
     const   AndroidNotificationDetails(
       'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
        priority: Priority.high,
        showWhen:false,
       playSound: true,
       onlyAlertOnce: true,
       channelShowBadge: true,
    );

     NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails,
        payload: 'Default_Sound');
  }

  cancelNotification(Task task) async{
    await flutterLocalNotificationsPlugin.cancel(task.id!);
  }
  cancelAllNotification() async{
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  //  Notifications scheduling

  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _nextInstanceOfTenAM(hour, minutes,task.remind!,task.repeat!,task.date!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}|${task.startTime}|',
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minutes,int remind,String repeat,String date) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print('now = $now');

    var formattedDate =  DateFormat.yMd().parse(date);
   final tz.TZDateTime fd = tz.TZDateTime.from(formattedDate, tz.local);

    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);


    scheduledDate = afterRemind(remind, scheduledDate);

    if (scheduledDate.isBefore(now)) { // it means if the date is passed
      if(repeat=='Daily') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 1, hour, minutes);
      }
            if(repeat=='Weekly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 7, hour, minutes);
      }
            if(repeat=='Monthly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, (now.month)+1,
            formattedDate.day, hour, minutes);
        /*
        (now.month)+1  // == > this means will increase month 1
            formattedDate.day,// ==> but day will remain as it,so i didn't increase it 1
         */
      }
      scheduledDate = afterRemind(remind, scheduledDate); // i called scheduledDate again to subtract minutes after editing on scheduledDate
    }


    print('Final ScheduledDate = $scheduledDate');

    return scheduledDate;
  }

  tz.TZDateTime afterRemind(int remind, tz.TZDateTime scheduledDate) {
    if(remind==5){
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));
    }
       if(remind==10){
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));
    }
       if(remind==15){
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 15));
    }
       if(remind==20){
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 20));
    }
    return scheduledDate;
  }

  Future<void> requestAndroidPermissions() async {
    // Request permissions for Android
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // Selected Notifications

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Get.to(NotificationScreen(payload: payload!));
  }


 // It used older ios versions and now it is useless
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    Get.dialog(Text(body!));
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      debugPrint('My payload is ' + payload);
      await Get.to(() => NotificationScreen(payload:payload));
    });
  }
}













