import 'package:Dorganize/Iset.dart';
import 'package:Dorganize/LocalNotificationScreen.dart';
import 'package:Dorganize/Register.dart';
import 'package:Dorganize/about.dart';
import 'package:Dorganize/logout.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'loading.dart';
import 'auth.dart';
import 'constants.dart';
import 'Home.dart';
import 'Storage.dart';

import 'dart:convert';
import 'dart:async';
import 'Stackk.dart';
import 'Important.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  print('headlessssssssssssssssss');
  await printHello();
  await refresh();
  

  BackgroundFetch.finish(taskId);
}
void backgroundFetchHeadlessTasks()  async {
  print(' Alarm  headlessssssssssssssssss');
  await printHello();
  await refresh();
  

 }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp _initialization = await Firebase.initializeApp();

  runApp(MyApp());
  final int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.cancel(0);
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), helloAlarmID, backgroundFetchHeadlessTasks);

  await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  final Storage indexStorage = Storage(file: 'index.json');
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  String currentEmail, currentPassword;
  bool signIn = false;
  bool loading = true;
  var login;
  se() async {
    setState(() {
      loading = true;
    });
    String data = await widget.indexStorage.readData();
    //  print(data);
    Map readindex = await json.decode(data);

    setState(() {
      currentEmail = readindex['current']['email'];
      currentPassword = readindex['current']['password'];
      login = readindex['login'];
      loading = false;
    });
  }

  see() async {
    print(signIn);
    print(login);
    setState(() {
      signIn = !signIn;
    });
  }

  Future<void> todo() async {
    try {
      String data = await widget.indexStorage.readData();
      Map readindex = await json.decode(data);

      setState(() {
        currentEmail = readindex['current']['email'];
        currentPassword = readindex['current']['password'];
        login = readindex['login'];
        loading = false;
      });
    } catch (e) {
      Map map = {
        "login": 0,
        "current": {"email": '', "password": 0},
        "members": [],
      };
      await widget.indexStorage.writedata(json.encode(map));

      setState(() {
        login = 0;
        loading = false;
      });
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();

    todo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.teal,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/index',
        routes: {
          '/index': (BuildContext context) {
            print(currentEmail);
            print(currentPassword);

            return loading
                ? Loading()
                : ((login == 0)
                    ? (signIn
                        ? Register(widget.indexStorage, see, se)
                        : Login(widget.indexStorage, see, se))
                    : Home(
                        Storage(file: '$currentEmail$currentPassword.json')));
          },
          '/stack': (BuildContext context) {
            return Stackk(Storage(file: '$currentEmail$currentPassword.json'));
          },
          '/important': (BuildContext context) {
            return Important(
                Storage(file: '$currentEmail$currentPassword.json'));
          },
          '/iset': (BuildContext context) {
            return Iset(Storage(file: '$currentEmail$currentPassword.json'));
          },
          '/appInfo': (BuildContext context) {
            return About();
          },
          '/logout': (BuildContext context) {
            return Logout(widget.indexStorage);
          }
        });
  }
}
