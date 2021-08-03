import 'package:Dorganize/NotificationScreen.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:Dorganize/NotificationPlugin.dart';
import 'auth.dart';

class LocalNotificationScreen extends StatefulWidget {
  @override
  _LocalNotificationScreenState createState() =>
      _LocalNotificationScreenState();
}

class _LocalNotificationScreenState extends State<LocalNotificationScreen> {
  AuthService _auth = AuthService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Notification'),
      ),
      body: Center(
          child: FlatButton(
        onPressed: () async {
          Navigator.of(context).pop();
          //      _auth.signOut();
          await notificationPlugin.showNotification('lala');
          //await notificationPlugin.cancelAll();
          // await notificationPlugin.repeatNotification();
          // await notificationPlugin.scheduleNotification();
          //  await notificationPlugin.showNotificationWithAttachment();
          //  await notificationPlugin.repeatNotification();
          // await notificationPlugin.showDailyAtTime();
          // await notificationPlugin.showWeeklyAtDayTime();
          // count = await notificationPlugin.getPendingNotificationCount();
          // print(count);
          // await notificationPlugin.cancelNotification();
          // count = await notificationPlugin.getPendingNotificationCount();
          // print(count);
        },
        child: Text("send Notification ${count++}"),
      )),
    );
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
  onNotificationClick(String payload) {
    // Navigator.pushNamed(context,"notificationscreen", arguments: <String,String>{
    //   'payload':payload
    // } );

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NotificationScreen(
        payload: payload,
      );
    }));

    //   Navigator.push(context, MaterialPageRoute(builder: (context) {
    //     return NotificationScreen(
    //       payload: payload,
    //     );
    //   }));
  }
}
