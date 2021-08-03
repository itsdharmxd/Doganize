import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;

import 'package:rxdart/rxdart.dart';
import 'dart:convert';

import 'package:time_range_picker/time_range_picker.dart';

class NotificationPlugin {
  int currentid = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  Int64List l;
  var initializationSettings;
  NotificationPlugin._() {
    print('1');
    l = Int64List(10);
    l[0] = 1000;
    l[1] = 2000;
    l[2] = 3000;
    l[3] = 4000;
    l[4] = 5000;
    l[5] = 6000;
    l[6] = 7000;
    l[7] = 8000;
    l[8] = 9000;
    l[9] = 10000;
    print('2');
    init();
    print('3');
  }
  init() async {
    print('4');
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    print('5');
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    print('6');
    initializePlatformSpecifics();
    print('7');
  }

  initializePlatformSpecifics() {
    print('8');
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
    print('9');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        );
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );
    print('10');
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    print('11');
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    print('12');
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
    print('13');
  }

  setOnNotificationClick(Function onNotificationClick) async {
    print('14');
    print(initializationSettings);
    print(onNotificationClick);
    print(flutterLocalNotificationsPlugin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
    print('15');
  }

  Future<void> showNotification(String func) async {
    var androidChannelSpecifies = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.Max,
      autoCancel: false,
      priority: Priority.High,

      playSound: true,
      // icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ledColor: Colors.blue,
      color: Colors.red,
      ledOnMs: 1000,
      ledOffMs: 1000,

      channelShowBadge: false,
      // sound: RawResourceAndroidNotificationSound(_sound),
      enableVibration: true,
      vibrationPattern: l,
      visibility: NotificationVisibility.Public,
      //  timeoutAfter: 1000,
      enableLights: true,

      styleInformation: BigTextStyleInformation('',
          htmlFormatTitle: true,
          htmlFormatBigText: true,
          htmlFormatSummaryText: true,
          htmlFormatContent: true,
          htmlFormatContentTitle: true),
    );

    var iosChannelSpecifies = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifies, iosChannelSpecifies);
    print(platformChannelSpecifics);
    currentid++;
    await flutterLocalNotificationsPlugin.show(
        currentid,
        ' $currentid ${DateTime.now()}<br>  $func ',
        '<b>Text</b> BodyText BodyText BodyText <br> <hr>BodyText BodyText BodyText<br> BodyText BodyText BodyText BodyText Body  ',
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> scheduleNotification(String textTitle, String textBody,
      DateTime dateTime, TimeRange timeRange) async {
    Map map = {
      'date': {
        'year': dateTime.year,
        'month': dateTime.month,
        'day': dateTime.day
      },
      'schedule': {
        'time': {
          'hour': dateTime.hour,
          'minute': dateTime.minute,
        },
        'task': textTitle,
        'description': textBody
      }
    };
    int days = 0;
    for (int f = 1; f < dateTime.month; f++) {
      switch (f) {
        case 1:
          {
            days += 31;
            break;
          }
        case 2:
          {
            if (dateTime.year % 4 == 0) {
              days += 29;
            } else {
              days += 28;
            }
            break;
          }
        case 3:
          {
            days += 31;
            break;
          }
        case 4:
          {
            days += 30;
            break;
          }
        case 5:
          {
            days += 31;
            break;
          }
        case 6:
          {
            days += 30;
            break;
          }
        case 7:
          {
            days += 31;
            break;
          }
        case 8:
          {
            days += 31;
            break;
          }
        case 9:
          {
            days += 30;
            break;
          }
        case 10:
          {
            days += 31;
            break;
          }
        case 11:
          {
            days += 30;
            break;
          }

        default:
      }
    }
    days += dateTime.day;
    int id = int.parse("2$days${dateTime.hour}${dateTime.minute}");
    int smin = timeRange.startTime.minute;
    int emin = timeRange.endTime.minute;
    String title =
        "$textTitle <br> ${(timeRange.startTime.hour > 12) ? timeRange.startTime.hour - 12 : timeRange.startTime.hour}:${(timeRange.startTime.minute < 10) ? "0$smin" : timeRange.startTime.minute} ${(timeRange.startTime.hour > 12) ? "pm" : "am"} || ${(timeRange.endTime.hour > 12) ? timeRange.endTime.hour - 12 : timeRange.endTime.hour}:${(timeRange.endTime.minute < 10) ? "0$emin" : timeRange.endTime.minute} ${(timeRange.endTime.hour > 12) ? "pm" : "am"} ";
    var androidChannelSpecifies = AndroidNotificationDetails(
      'CHANNEL_ID 1', 'CHANNEL_NAME 1', "CHANNEL_DESCRIPTION 1",
      icon: 'app_notf_icon',
      //  sound: RawResourceAndroidNotificationSound("my_sound"),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker',
      enableLights: true,
      color: Color.fromARGB(255, 255, 0, 0),
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      vibrationPattern: l,
      ledOffMs: 500,
      enableVibration: true,

      playSound: true,

      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifies = IOSNotificationDetails(
        // sound: 'my_sound.aiff',

        );

    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifies, iosChannelSpecifies);

    await flutterLocalNotificationsPlugin.schedule(
        id, title, textBody, dateTime, platformChannelSpecifics,
        payload: json.encode(map));
  }

  Future<void> showNotificationWithAttachment() async {
    var attachmentPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/800x200', 'attachment_img.jpg');
    var iOSPlatformSpecifics = IOSNotificationDetails(
      attachments: [
        IOSNotificationAttachment(attachmentPicturePath),
      ],
    );
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(attachmentPicturePath),
      contentTitle: '<b>Attached Image</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Text Image',
      htmlFormatSummaryText: true,
    );
    var androidChannelSpecifics = AndroidNotificationDetails(
      "CHANNEL_ID 2",
      "CHANNEL_NAME 2",
      'CHANNEL_DESCRIPTION 2 ',
      importance: Importance.High,
      priority: Priority.High,
      styleInformation: bigPictureStyleInformation,
    );
    var notificationDetails =
        NotificationDetails(androidChannelSpecifics, iOSPlatformSpecifics);

    await flutterLocalNotificationsPlugin.show(0, "Title with attachment",
        'Body with attachment', notificationDetails);
  }

  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> repeatNotification() async {
    var androidChannelSpecifies = AndroidNotificationDetails(
      'CHANNEL_ID 3',
      'CHANNEL_NAME 3',
      "CHANNEL_DESCRIPTION 3",
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      playSound: true,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifies = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifies, iosChannelSpecifies);
    print(platformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(
        1,
        'Repeat  Text <b>title<b>',
        'Repeat Text Body',
        RepeatInterval.EveryMinute,
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> showDailyAtTime() async {
    var time = Time(17, 30, 0);
    var androidChannelSpecifies = AndroidNotificationDetails(
      'CHANNEL_ID 4',
      'CHANNEL_NAME 4',
      "CHANNEL_DESCRIPTION 4",
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifies = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifies, iosChannelSpecifies);
    print(platformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0, 'Text $time', 'Text Body', time, platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> showWeeklyAtDayTime(String textTitle, String textBody, Day day,
      Time time, TimeRange timeRange) async {
    List li = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thusday",
      "Friday",
      "Saturday"
    ];
    Map map = {
      'day': li.elementAt(day.value - 1),
      "schedule": {
        'time': {"hour": time.hour, "minute": time.minute},
        "task": textTitle,
        "description": textBody
      }
    };
    int id = int.parse("1${day.value}${time.hour}${time.minute}");
    int smin = timeRange.startTime.minute;
    int emin = timeRange.endTime.minute;
    String title =
        "$textTitle <br> ${(timeRange.startTime.hour > 12) ? timeRange.startTime.hour - 12 : timeRange.startTime.hour}:${(timeRange.startTime.minute < 10) ? "0$smin" : timeRange.startTime.minute} ${(timeRange.startTime.hour > 12) ? "pm" : "am"} || ${(timeRange.endTime.hour > 12) ? timeRange.endTime.hour - 12 : timeRange.endTime.hour}:${(timeRange.endTime.minute < 10) ? "0$emin" : timeRange.endTime.minute} ${(timeRange.endTime.hour > 12) ? "pm" : "am"} ";
    var androidChannelSpecifies = AndroidNotificationDetails(
      'CHANNEL_ID 5',
      'CHANNEL_NAME 5',
      "CHANNEL_DESCRIPTION 5",
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      playSound: true,
      vibrationPattern: l,
      enableVibration: true,
      visibility: NotificationVisibility.Public,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifies = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifies, iosChannelSpecifies);
    print(platformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        id, title, textBody, day, time, platformChannelSpecifics,
        payload: json.encode(map));
  }

  Future<List<PendingNotificationRequest>> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p;
  }

  Future<void> cancelNotificationWeekly(Day day, Time time) async {
    int id = int.parse("1${day.value}${time.hour}${time.minute}");
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationSchedule(DateTime dateTime) async {
    int days = 0;
    for (int f = 1; f < dateTime.month; f++) {
      switch (f) {
        case 1:
          {
            days += 31;
            break;
          }
        case 2:
          {
            if (dateTime.year % 4 == 0) {
              days += 29;
            } else {
              days += 28;
            }
            break;
          }
        case 3:
          {
            days += 31;
            break;
          }
        case 4:
          {
            days += 30;
            break;
          }
        case 5:
          {
            days += 31;
            break;
          }
        case 6:
          {
            days += 30;
            break;
          }
        case 7:
          {
            days += 31;
            break;
          }
        case 8:
          {
            days += 31;
            break;
          }
        case 9:
          {
            days += 30;
            break;
          }
        case 10:
          {
            days += 31;
            break;
          }
        case 11:
          {
            days += 30;
            break;
          }

        default:
      }
    }
    days += dateTime.day;
    int id = int.parse("2$days${dateTime.hour}${dateTime.minute}");

    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  }) {}
}
