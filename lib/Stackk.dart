import 'dart:async';

import 'package:Dorganize/Storage.dart';
import 'package:Dorganize/loading.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'NotificationPlugin.dart';
import 'NotificationScreen.dart';
import 'package:flutter/rendering.dart';
import 'package:flushbar/flushbar.dart';

class Stackk extends StatefulWidget {
  final Storage _thisStorage;

  Stackk(this._thisStorage) : super();

  @override
  _StackkState createState() => _StackkState();
}

class _StackkState extends State<Stackk> with TickerProviderStateMixin {
  TabController _tabController;
  Key _key = GlobalKey();

  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
    file();
  }

  file() async {
    await printHello();
    await refresh();
    setState(() {
      print('succes');
      loading = false;
    });
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
  onNotificationClick(String payload) {
    Navigator.push(context, MaterialPageRoute(builder: (coontext) {
      return NotificationScreen(
        payload: payload,
      );
    }));
  }

  Future<void> refresh() async {
    print("start refresh ${DateTime.now()}");
    Storage _indexStorage = Storage(file: "index.json");
    String dat = await _indexStorage.readData();
    Map map = json.decode(dat);
    if (map['login'] == 1) {
      String currentName = map['current']['email'];
      String currentPassword = map['current']['password'];
      Storage _thisStorage = Storage(file: "$currentName$currentPassword.json");
      Map currentData = {
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

      String ata = await _thisStorage.readData();
      currentData = await json.decode(ata);
      DateTime _dateTimeNow = DateTime.now();
      int i = 0;

      try {
        List importantList = currentData['stack']['important'];
        while (DateTime(
                importantList[i]['date']['year'],
                importantList[i]['date']['month'],
                importantList[i]['date']['day'],
                importantList[i]['schedule']['time']['hour'],
                importantList[i]['schedule']['time']['minute'])
            .isBefore(_dateTimeNow)) {
          await importantList.removeAt(i);
        }
        currentData['stack']['important'] = importantList;
      } catch (e) {
        print(e);
      }
      try {
        print('red');
        List redList = currentData['stack']['red'];
        print(redList);
        while (DateTime(
                redList[i]['date']['year'],
                redList[i]['date']['month'],
                redList[i]['date']['day'],
                redList[i]['schedule']['time']['hour'],
                redList[i]['schedule']['time']['minute'])
            .isBefore(_dateTimeNow)) {
          print('removed');
          redList.removeAt(i);
        }
        currentData['stack']['red'] = redList;
        print(redList);
      } catch (e) {
        print(e);
      }

      try {
        List isetList = currentData['iset'];

        while (DateTime(
                isetList[i]['date']['year'],
                isetList[i]['date']['month'],
                isetList[i]['date']['day'],
                isetList[i]['schedule']['time']['hour'],
                isetList[i]['schedule']['time']['minute'])
            .isBefore(_dateTimeNow)) {
          await isetList.removeAt(i);
        }
        currentData['iset'] = isetList;
      } catch (e) {
        print(e);
      }

      try {
        List datesList = currentData['dates'];
        while (DateTime(
                datesList[i]['date']['year'],
                datesList[i]['date']['month'],
                datesList[i]['date']['day'],
                23,
                59)
            .isBefore(_dateTimeNow)) {
          await datesList.removeAt(i);
        }
        currentData['dates'] = datesList;
      } catch (e) {
        print(e);
      }

      try {
        List datesListSchedule = currentData['dates'][i]['schedule'];
        while (DateTime(
          _dateTimeNow.year,
          _dateTimeNow.month,
          _dateTimeNow.day,
          datesListSchedule[i]['time']['hour'],
          datesListSchedule[i]['time']['minute'],
        ).isBefore(_dateTimeNow)) {
          await datesListSchedule.removeAt(i);
        }
        currentData['dates'][i]['schedule'] = datesListSchedule;
      } catch (e) {
        print(e);
      }
      await _thisStorage.writedata(json.encode(currentData));
      print("end refresh ${DateTime.now()}");
    }
  }

  Future<void> printHello() async {
    print(" start updates ${DateTime.now()} ");
    Storage _indexStorage = Storage(file: "index.json");
    String dat = await _indexStorage.readData();
    Map map = json.decode(dat);
    if (map['login'] == 1) {
      try {
        String currentName = map['current']['email'];
        String currentPassword = map['current']['password'];
        Storage _thisStorage =
            Storage(file: "$currentName$currentPassword.json");

        Map currentData = {
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
        String ata = await _thisStorage.readData();
        currentData = json.decode(ata);

        List current = [];
        for (int i = 0; i < 3; i++) {
          DateTime _date = DateTime.now().add(Duration(days: i));
          var weekDay = _date.weekday;
          //  print(weekDay);
          bool done = true;
          try {
            for (int j = 0; j < currentData['dates'].length; j++) {
              dynamic data = currentData['dates'][j];
              if (1 ==
                  (DateTime(data['date']['year'], data['date']['month'],
                          data['date']['day'])
                      .compareTo(
                          DateTime(_date.year, _date.month, _date.day)))) {
                break;
              } else if (0 ==
                  (DateTime(data['date']['year'], data['date']['month'],
                          data['date']['day'])
                      .compareTo(
                          DateTime(_date.year, _date.month, _date.day)))) {
                current.add(currentData['dates'][j]);
                done = false;
                break;
              }
            }
            if (done) throw "error";
          } catch (e) {
            if (done) {
              List df = [
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday"
              ];
              current.add({
                "date": {
                  "year": _date.year,
                  "month": _date.month,
                  "day": _date.day
                },
                "schedule": currentData['days'][df[weekDay - 1]],
              });
            }
          }
        }
        List st = [];
        current.forEach((element) {
          //   print(element);
          for (int k = 0; k < element['schedule'].length; k++) {
            st.add({
              "date": {
                "year": element['date']['year'],
                "month": element['date']['month'],
                "day": element['date']['day'],
              },
              "schedule": element['schedule'][k],
            });
          }
        });
        currentData['stack']['red'].clear();
        currentData['stack']['orange'].clear();
        currentData['stack']['green'].clear();
        st.forEach((element) {
          DateTime _dateobj = DateTime(
              element['date']['year'],
              element['date']['month'],
              element['date']['day'],
              element['schedule']['time']['hour'],
              element['schedule']['time']['minute']);
          if ((_dateobj.compareTo(DateTime.now().add(Duration(hours: 12)))) ==
              -1) {
            currentData['stack']['red'].add(element);
          } else if ((_dateobj
                  .compareTo(DateTime.now().add(Duration(hours: 36)))) ==
              -1) {
            currentData['stack']['orange'].add(element);
          } else {
            currentData['stack']['green'].add(element);
          }
        });
        await _thisStorage.writedata(json.encode(currentData));
      } catch (e) {}
      print(" end updates ${DateTime.now()} ");
    }

    // print(
    //     "[$now] Hello, world!  dorganize isolate=$isolateId function='$printHello'");
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            key: _key,
            appBar: AppBar(
              title: Text('My Stack'),
              backgroundColor: Colors.teal,
              bottom:
                  TabBar(controller: _tabController, isScrollable: true, tabs: [
                Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Colors.red,
                        ),
                        Text(
                          'RED',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Colors.orange,
                        ),
                        Text(
                          'ORANGE',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Colors.green,
                        ),
                        Text(
                          'GREEN',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Colors.purple,
                        ),
                        Text(
                          'IMPORTANT',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ],
                    )),
              ]),
            ),
            body: TabBarView(controller: _tabController, children: [
              Container(
                color: Colors.white,
                child: StackRed(widget._thisStorage, Colors.red, 'red', _key),
              ),
              Container(
                color: Colors.white,
                child: StackRed(
                    widget._thisStorage, Colors.orange, 'orange', _key),
              ),
              Container(
                color: Colors.white,
                child:
                    StackRed(widget._thisStorage, Colors.green, 'green', _key),
              ),
              Container(
                color: Colors.white,
                child: StackRed(
                    widget._thisStorage, Colors.purple, 'important', _key),
              ),
            ]),
          );
  }
}

class StackRed extends StatefulWidget {
  final Storage _storage;
  final Color color;
  final String stack;
  final Key _key;

  StackRed(this._storage, this.color, this.stack, this._key) : super();

  @override
  _StackRedState createState() => _StackRedState();
}

class _StackRedState extends State<StackRed>
    with AutomaticKeepAliveClientMixin {
  Map currentData;
  bool loading = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  // TODO: implement wantKeepAlive

  List list;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list = [];
    currentData = {
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
      "iset": []
    };
    if (mounted) {
      file();
    }
  }

  file() async {
    var data = await widget._storage.readData();
    if (mounted) {
      setState(() {
        currentData = json.decode(data);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return loading
        ? Loading()
        : ListView.builder(
            itemCount: currentData['stack'][widget.stack].length,
            itemBuilder: (context, i) {
              int min = currentData['stack'][widget.stack][i]["schedule"]
                  ["time"]["minute"];

              return GestureDetector(
                onTap: () {
                  String task =
                      currentData['stack'][widget.stack][i]["schedule"]['task'];
                  String description = currentData['stack'][widget.stack][i]
                      ["schedule"]['description'];
                  showDialog(
                      context: context,
                      builder: (context) => AssetGiffyDialog(
                           onlyCancelButton: true,
                            buttonCancelText: Text(
                              'Leave',
                              style: TextStyle(color: Colors.white),
                            ),
                            buttonCancelColor: Colors.teal,
                            buttonOkText: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                            buttonOkColor: Colors.redAccent,
                            image: Image.asset('image/dharmesh_bg.png'),
                            title: Text(
                              '${currentData['stack'][widget.stack][i]["schedule"]['task']} ',
                              style: TextStyle(
                                  fontSize: 22.0, fontWeight: FontWeight.w600),
                            ),
                            description: Text(
                              '${currentData['stack'][widget.stack][i]["schedule"]['description']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(),
                            ),
                            entryAnimation: EntryAnimation.BOTTOM,
                            onOkButtonPressed: () async {
                              if (widget.stack == 'important') {
                                try {
                                  Map m = currentData['stack'][widget.stack][i];
                                  await notificationPlugin
                                      .cancelNotificationSchedule(DateTime(
                                          m['date']['year'],
                                          m['date']['month'],
                                          m['date']['day'],
                                          m['schedule']['time']['hour'],
                                          m['schedule']['time']['minute']));
                                } catch (r) {}

                                await currentData['stack'][widget.stack]
                                    .removeAt(i);
                                setState(() {
                                  widget._storage
                                      .writedata(json.encode(currentData));
                                });
                                Navigator.pop(context);
                                Flushbar(
                                  title: "Deleted",
                                  message:
                                      "Task:$task Description:$description",
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              }
                            },
                          ));
                },
                child: Card(
                  shadowColor: widget.color,
                  elevation: 3,
                  color: Colors.white,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 80,
                      child: Row(
                        children: [
                          Container(
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            color: widget.color,
                            height: 80,
                            width: 25,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${currentData['stack'][widget.stack][i]['date']['day']}:${currentData['stack'][widget.stack][i]['date']['month']}:${currentData['stack'][widget.stack][i]['date']['year']}",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      "${(currentData['stack'][widget.stack][i]["schedule"]["time"]["hour"] > 12) ? currentData['stack'][widget.stack][i]["schedule"]["time"]["hour"] - 12 : currentData['stack'][widget.stack][i]["schedule"]["time"]["hour"]}:${(currentData['stack'][widget.stack][i]["schedule"]["time"]["minute"]<10)?"0$min":currentData['stack'][widget.stack][i]["schedule"]["time"]["minute"]} ${(currentData['stack'][widget.stack][i]["schedule"]["time"]["hour"] > 12) ? "pm" : "am"}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 25),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container( constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.width*0.5 ),
                                        child: Text(
                                            "${currentData['stack'][widget.stack][i]["schedule"]["task"]}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20)),
                                      ),
                                      Container( constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.width*0.5 ),
                                        child: Text(
                                            "${currentData['stack'][widget.stack][i]["schedule"]["description"]}"),
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        ],
                      )),
                ),
              );
            });
  }
}
