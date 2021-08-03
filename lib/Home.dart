import 'package:Dorganize/Storage.dart';
import 'package:Dorganize/input_regular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Drawer.dart';
import 'main.dart';
import 'loading.dart';
import 'dart:convert';
import 'Storage.dart';
import 'input_special.dart';
import 'NotificationPlugin.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:Dorganize/NotificationPlugin.dart';

class Home extends StatefulWidget {
  final Storage _thisStorage;

  Home(this._thisStorage) : super();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  bool loading = false;

  int _status = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            startOnBoot: true,
            //   forceAlarmManager: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // This is the fetch-event callback.

      print("[BackgroundFetch] Event received in configureeeeeeeeeeee $taskId");

      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading ? Loading() : Home2(widget._thisStorage);
  }
}

class Home2 extends StatefulWidget {
  final Storage _thisStorage;

  Home2(this._thisStorage) : super();
  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with TickerProviderStateMixin {
  Map currentdata;
  TabController _tabController;
  InputRegular inputRegular;
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('home2');
    file();
    inputRegular = InputRegular(widget._thisStorage);

    _tabController = TabController(length: 2, vsync: this);
  }

  file() async {
    try {
      String data = await widget._thisStorage.readData();
      setState(() {
        currentdata = json.decode(data);
        loading = false;
      });
    } catch (e) {
      Map map = {
        "days": {
          "Monday": [],
          "Tuesday": [],
          "Wednesday": [],
          "Thursday": [],
          "Friday": [],
          "Saturday": [],
          "Sunday": []
        },
        "stack": {
          "red": [],
          "orange": [],
          "green": [],
          "important": [],
        },
        "dates": [],
        "iset": [],
      };
      await widget._thisStorage.writedata(json.encode(map));
      setState(() {
        currentdata = map;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //   print('$currentdata');
    return loading
        ? Loading()
        : GestureDetector(
            onTap: () {
              FocusScopeNode _current = FocusScope.of(context);
              if (!_current.hasPrimaryFocus) {
                _current.unfocus();
              }
            },
            child: Scaffold(
              drawer: Drawer(child: Drawerr()),
              appBar: AppBar(
                elevation: 3,
                title: Text('Schedule Input'),
                bottom: TabBar(
                    // onTap: (it) async {
                    //   List c = await notificationPlugin
                    //       .getPendingNotificationCount();
                    //   c.forEach((element) {
                    //     print(element.id);
                    //   });

                    //   //   await notificationPlugin.showNotification();
                    // },
                    controller: _tabController,
                    tabs: [
                      GestureDetector(
                        onTap: () {
                          FocusScopeNode _current = FocusScope.of(context);
                          if (!_current.hasPrimaryFocus) {
                            _current.unfocus();
                          }
                        },
                        child: Tab(
                          icon: Icon(Icons.date_range),
                          child: Text("Regular/Continuous"),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FocusScopeNode _current = FocusScope.of(context);
                          if (!_current.hasPrimaryFocus) {
                            _current.unfocus();
                          }
                        },
                        child: Tab(
                          icon: Icon(Icons.storage),
                          child: Text("Special/perticular"),
                        ),
                      ),
                    ]),
              ),
              body: TabBarView(
                  controller: _tabController,
                  children: [inputRegular, InputSpecial(widget._thisStorage)]),
            ),
          );
  }
}
