import 'package:Dorganize/Storage.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'dart:convert';
import 'dart:ui';
import 'NotificationPlugin.dart';
import 'NotificationScreen.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flushbar/flushbar.dart';

class Iset extends StatefulWidget {
  final Storage _thisStorage;
  Iset(this._thisStorage) : super();

  @override
  _IsetState createState() => _IsetState();
}

class _IsetState extends State<Iset> with AutomaticKeepAliveClientMixin {
  Map currentData;
  //speech
  SpeechRecognition _speechRecognition;
  bool _isavailable = false;
  bool _islistening = false;
  String resulttext = '';

  //speech
  var _validate;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _taskController = TextEditingController();
  file() async {
    String data = await widget._thisStorage.readData();

    setState(() {
      currentData = json.decode(data);
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _validate = null;
    _descriptionController.text = 'No Description';
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
    file();
    initspeechrecognition();
    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
  onNotificationClick(String payload) {
    //   Navigator.pushNamed(context,"notificationscreen", arguments: <String,String>{
    //   'payload':payload
    // } );

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NotificationScreen(
        payload: payload,
      );
    }));
  }

  void initspeechrecognition() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler((result) {
      setState(() {
        _isavailable = result;
      });
    });
    _speechRecognition.setRecognitionStartedHandler(() {
      setState(() {
        _islistening = true;
      });
    });
    _speechRecognition.setRecognitionResultHandler((text) {
      setState(() {
        _descriptionController.text = text;
        resulttext = text;
      });
    });
     void _sd(String d ){
setState(() {
        _islistening = false;
      });
    }
    _speechRecognition.setRecognitionCompleteHandler(_sd);
    _speechRecognition.setCurrentLocaleHandler((text) {});
    _speechRecognition.activate().then((value) {
      setState(() {
        _isavailable = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode _current = FocusScope.of(context);
          if (!_current.hasPrimaryFocus) {
            _current.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text('Iset')),
          body: ListView(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Thing to study :",
                  style: TextStyle(
                      color: Colors.brown,
                      height: 1,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                )
              ]),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: TextField(
                  controller: _taskController,
                  style: TextStyle(
                      color: Colors.brown,
                      height: 1,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  minLines: 1,
                  maxLines: 8,
                  decoration: InputDecoration(
                      errorText: _validate,
                      hintText: "One word Recognition of topic to study"),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Describe your Subject :",
                  style: TextStyle(
                      color: Colors.brown,
                      height: 1,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                GestureDetector(
                  onTap: () {
                    if (_isavailable || _islistening) {
                      _speechRecognition
                          .listen(locale: 'en_US')
                          .then((value) {});
                    }
                    _islistening = false;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                  onTap: () {
                    if (_islistening) {
                      _speechRecognition.stop().then((value) {
                        setState(() {
                          _islistening = value;
                        });
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.stop,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                GestureDetector(
                  onTap: () {
                    _speechRecognition.cancel().then((value) {
                      setState(() {
                        _islistening = value;
                        _descriptionController.text = '';
                        resulttext = '';
                      });
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: TextField(
                  controller: _descriptionController,
                  style: TextStyle(
                      color: Colors.brown,
                      height: 1,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  minLines: 1,
                  maxLines: 8,
                  decoration: InputDecoration(
                      errorText: null,
                      hintText: "Describe your thing to study"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 10, 28.0, 10),
                child: Divider(
                  color: Colors.black87,
                  height: 3,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_taskController.text.isEmpty) {
                    setState(() {
                      _validate = "Please enter thing to study";
                    });

                    return 0;
                  } else {
                    setState(() {
                      _validate = null;
                    });
                  }
                  DateTime _oneDate = DateTime.now().add(Duration(days: 1));

                  DateTime _weekDate = DateTime.now().add(Duration(days: 7));
                  DateTime _monthDate = DateTime.now().add(Duration(days: 30));
                  DateTime _tmonthDate = DateTime.now().add(Duration(days: 90));
                  int _hour = TimeOfDay.now().hour;
                  int _minute = TimeOfDay.now().minute;
               
                  TimeRange _timeRange = TimeRange(
                      startTime: TimeOfDay(
                          hour: TimeOfDay.now().hour,
                          minute: TimeOfDay.now().minute),
                      endTime:TimeOfDay(
                          hour: DateTime.now().add(Duration(hours: 3)).hour ,
                          minute: TimeOfDay.now().minute) );
                  var setAlarmObject = {
                    "time": {"hour": _hour, "minute": _minute},
                    "range": {
                      "start": {
                        "hour": TimeOfDay.now().hour,
                        "minute": TimeOfDay.now().minute
                      },
                      "end": {
                        "hour": DateTime.now().add(Duration(hours: 3)).hour,
                        "minute": TimeOfDay.now().minute
                      }
                    },
                    "task": _taskController.text,
                    "description": _descriptionController.text
                  };
                  await currentData['iset'].add({
                    'date': {
                      "year": _oneDate.year,
                      "month": _oneDate.month,
                      "day": _oneDate.day
                    },
                    'schedule': setAlarmObject
                  });
                  await notificationPlugin.scheduleNotification(
                      _taskController.text,
                      _descriptionController.text,
                      DateTime(_oneDate.year, _oneDate.month, _oneDate.day,
                          _hour, _minute),_timeRange);
                  await currentData['iset'].add({
                    'date': {
                      "year": _weekDate.year,
                      "month": _weekDate.month,
                      "day": _weekDate.day
                    },
                    'schedule': setAlarmObject
                  });
                  await notificationPlugin.scheduleNotification(
                      _taskController.text,
                      _descriptionController.text,
                      DateTime(_weekDate.year, _weekDate.month, _weekDate.day,
                          _hour, _minute),_timeRange);
                  await currentData['iset'].add({
                    'date': {
                      "year": _monthDate.year,
                      "month": _monthDate.month,
                      "day": _monthDate.day
                    },
                    'schedule': setAlarmObject
                  });
                  await notificationPlugin.scheduleNotification(
                      _taskController.text,
                      _descriptionController.text,
                      DateTime(_monthDate.year, _monthDate.month,
                          _monthDate.day, _hour, _minute),_timeRange);

                  await currentData['iset'].add({
                    'date': {
                      "year": _tmonthDate.year,
                      "month": _tmonthDate.month,
                      "day": _tmonthDate.day
                    },
                    'schedule': setAlarmObject
                  });
                  await notificationPlugin.scheduleNotification(
                      _taskController.text,
                      _descriptionController.text,
                      DateTime(_tmonthDate.year, _tmonthDate.month,
                          _tmonthDate.day, _hour, _minute),_timeRange);
                  await currentData['iset'].sort((a, b) => DateTime(
                          a['date']['year'],
                          a['date']['month'],
                          a['date']['day'],
                          a['schedule']['time']['hour'],
                          a['schedule']['time']['minute'])
                      .compareTo(DateTime(
                          b['date']['year'],
                          b['date']['month'],
                          b['date']['day'],
                          b['schedule']['time']['hour'],
                          b['schedule']['time']['minute'])));
                  await widget._thisStorage.writedata(json.encode(currentData));

                  setState(() {
                    _taskController.text = '';
                    _descriptionController.text = '';
                  });
                  Flushbar(
                    title: "Added",
                    message:
                        "Study:${_taskController.text} ,Description:${_descriptionController.text}  ",
                    duration: Duration(seconds: 3),
                  )..show(context);
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(50, 0, 50, 5),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.red),
                  child: Center(
                      child: Text(
                    'Submit Schedule',
                    style: TextStyle(
                      letterSpacing: 3,
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 20, 28.0, 20),
                child: Divider(
                  color: Colors.black87,
                  height: 3,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                decoration: BoxDecoration(color: Colors.teal),
                child: Center(
                    child: Text(
                  'Current Study Schedule',
                  style: TextStyle(
                    letterSpacing: 3,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ),
              ListView.builder(
                  controller: ScrollController(keepScrollOffset: false),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: currentData['iset'].length,
                  itemBuilder: (context, i) {
                    int min =
                        currentData['iset'][i]["schedule"]["time"]["minute"];

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AssetGiffyDialog(
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
                                    '${currentData['iset'][i]["schedule"]['task']} ',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  description: Text(
                                    '${currentData['iset'][i]["schedule"]['description']}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(),
                                  ),
                                  entryAnimation: EntryAnimation.BOTTOM,
                                  onOkButtonPressed: () async {
                                    try {
                                      await notificationPlugin
                                          .cancelNotificationSchedule(DateTime(
                                              currentData['iset'][i]['date']
                                                  ['year'],
                                              currentData['iset'][i]['date']
                                                  ['month'],
                                              currentData['iset'][i]['date']
                                                  ['day'],
                                              currentData['iset'][i]['schedule']
                                                  ['time']['hour'],
                                              currentData['iset'][i]['schedule']
                                                  ['time']['minute']));
                                    } catch (e) {}
                                    await currentData['iset'].removeAt(i);
                                    setState(() {
                                      widget._thisStorage
                                          .writedata(json.encode(currentData));
                                    });
                                    Navigator.pop(context);
                                    Flushbar(
                                      title: "Deleted",
                                      message:
                                          "Study:${_taskController.text} ,Description:${_descriptionController.text}  ",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                  },
                                ));
                      },
                      child: Card(
                        shadowColor: Colors.blueGrey,
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
                                  color: Colors.blueGrey,
                                  height: 80,
                                  width: 25,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${currentData['iset'][i]['date']['day']}:${currentData['iset'][i]['date']['month']}:${currentData['iset'][i]['date']['year']}",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            "${(currentData['iset'][i]["schedule"]["time"]["hour"] > 12) ? currentData['iset'][i]["schedule"]["time"]["hour"] - 12 : currentData['iset'][i]["schedule"]["time"]["hour"]}:${(currentData['iset'][i]["schedule"]["time"]["minute"] < 10) ? "0$min" : currentData['iset'][i]["schedule"]["time"]["minute"]} ${(currentData['iset'][i]["schedule"]["time"]["hour"] > 12) ? "pm" : "am"} ",
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
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.5),
                                              child: Text(
                                                  "${currentData['iset'][i]["schedule"]["task"]}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 20)),
                                            ),
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.5),
                                              child: Text(
                                                  "${currentData['iset'][i]["schedule"]["description"]}"),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                              ],
                            )),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
