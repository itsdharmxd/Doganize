import 'package:Dorganize/Storage.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:convert';
import 'package:Dorganize/NotificationPlugin.dart';
import 'NotificationScreen.dart';
import 'dart:ui';
import 'package:flushbar/flushbar.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'loading.dart';
import 'dart:io';



class InputRegular extends StatefulWidget {
  final Storage _thisStorage;

  InputRegular(
    this._thisStorage,
  ) : super();

  @override
  _InputRegularState createState() => _InputRegularState();
}

class _InputRegularState extends State<InputRegular>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> _weekDays = [
    "Monday",
  ];
  Map currentData;
 

  //speech
  SpeechRecognition _speechRecognition;
  bool _isavailable = false;
  bool _islistening = false;
  String resulttext = '';

  //speech
  var _validate;
  TimeOfDay _time;
  var timeminute, timeendminute, timestartminute;
  TimeRange _timeRange;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _taskController = TextEditingController();
  Future file() async {

     
    print(widget._thisStorage.file);
    String data;
    try {
      data = await widget._thisStorage.readData();
    } catch (e) {
      print(e);
    }
    setState(() {
      currentData = json.decode(data);
      
    });
  }

  // @override
  // TODO: implement wantKeepAlive
  // bool get wantKeepAlive => true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _validate = null;
    print('----------------------------------------');

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
    print('----------------------------------------');
    print(widget._thisStorage.file);
    file();
    print('--------------------------------------- after');
    initspeechrecognition();
    _descriptionController.text = 'No Description';

    _time = TimeOfDay.now();
    timeminute = _time.minute;
    _timeRange = TimeRange(startTime: _time, endTime: _time);
    timestartminute = _timeRange.startTime.minute;
    timeendminute = _timeRange.endTime.minute;

    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
  onNotificationClick(String payload) {
    //  Navigator.pushNamed(context,"notificationscreen", arguments: <String,String>{
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

  void onTimeChanged(TimeOfDay _t) {
    setState(() {
      _time = _t;
      timeminute = _time.minute;
      _timeRange = TimeRange(startTime: _time, endTime: _time);
      timestartminute = _timeRange.startTime.minute;
      timeendminute = _timeRange.endTime.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return  Container(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        color: Colors.teal,
                        elevation: 5,
                        onPressed: () {
                          Navigator.of(context).push(
                            showPicker(
                              okText: "Set",
                              cancelText: "Leave",
                              context: context,
                              value: _time,
                              onChange: onTimeChanged,
                            ),
                          );
                        },
                        child: Text(
                          "Set Time",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        "AT ${(_time.hour > 12) ? _time.hour - 12 : _time.hour}:${(_time.minute < 10) ? '0$timeminute' : _time.minute} ${(_time.hour > 12) ? "pm" : 'am'}",
                        style: TextStyle(
                            shadows: [Shadow(offset: Offset.fromDirection(10))],
                            fontSize: 35,
                            fontWeight: FontWeight.w500,
                            color: Colors.brown[300]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 0, 28.0, 0),
                  child: Divider(
                    color: Colors.black87,
                    height: 3,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    TimeRange result = await showTimeRangePicker(
                      autoAdjustLabels: true,
                      labels: [
                        "12 pm",
                        "3 am",
                        "6 am",
                        "9 am",
                        "12 am",
                        "3 pm",
                        "6 pm",
                        "9 pm"
                      ].asMap().entries.map((e) {
                        return ClockLabel.fromIndex(
                            idx: e.key, length: 8, text: e.value);
                      }).toList(),
                      interval: Duration(minutes: 1),
                      snap: true,
                      context: context,
                      start: _time,
                    );
                    setState(() {
                      _timeRange = result;
                      timestartminute = _timeRange.startTime.minute;
                      timeendminute = _timeRange.endTime.minute;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    // constraints: BoxConstraints(
                    //   maxWidth: 100,
                    //   maxHeight:40

                    // ),
                    decoration: BoxDecoration(color: Colors.teal),
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.85,

                    clipBehavior: Clip.antiAlias,

                    child: Center(
                        child: Text(
                      "Time Range",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("From"),
                        Text(
                          "${(_timeRange.startTime.hour > 12) ? _timeRange.startTime.hour - 12 : _timeRange.startTime.hour}:${(_timeRange.startTime.minute < 10) ? '0$timestartminute' : _timeRange.startTime.minute} ${(_timeRange.startTime.hour > 12) ? "pm" : 'am'}",
                          style: TextStyle(
                              shadows: [
                                Shadow(offset: Offset.fromDirection(10))
                              ],
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.brown[300]),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text("To"),
                        Text(
                          "${(_timeRange.endTime.hour > 12) ? _timeRange.endTime.hour - 12 : _timeRange.endTime.hour}:${(_timeRange.endTime.minute < 10) ? '0$timeendminute' : _timeRange.endTime.minute} ${(_timeRange.endTime.hour > 12) ? "pm" : 'am'}",
                          style: TextStyle(
                              shadows: [
                                Shadow(offset: Offset.fromDirection(10))
                              ],
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.brown[300]),
                        )
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 10, 28.0, 10),
                  child: Divider(
                    color: Colors.black87,
                    height: 3,
                  ),
                ),
                Center(
                    child: Text(
                  'Select Days',
                  style: TextStyle(
                      shadows: [Shadow(offset: Offset.fromDirection(10))],
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown[300]),
                )),
                
                CustomCheckBoxGroup(
                  elevation: 5,
                  buttonTextStyle: ButtonTextStyle(
                    selectedColor: Colors.white,
                    unSelectedColor: Colors.orange,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  unSelectedColor: Theme.of(context).canvasColor,
                  buttonLables: [
                    "Mon",
                    "Tue",
                    "Wed",
                    "Thu",
                    "Fri",
                    "Sat",
                    "Sun",
                  ],
                  buttonValuesList: [
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday",
                    "Sunday",
                  ],
                  checkBoxButtonValues: (values) {
                    _weekDays = values;
                    print(values);
                  },
                  spacing: 0,
                  defaultSelected: ["Monday"],
                  horizontal: false,
                  enableButtonWrap: false,
                  width: 90,
                  absoluteZeroSpacing: false,
                  selectedColor: Colors.teal,
                  padding: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 10, 28.0, 10),
                  child: Divider(
                    color: Colors.black87,
                    height: 3,
                  ),
                ),
                Row(children: [
                  Text(
                    " Task :",
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
                        hintText: "One word Recognition of your task"),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Describe your Task :",
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
                        errorText: null, hintText: "Describe your task"),
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
                        _validate = "Please enter your task";
                      });

                      return 0;
                    } else {
                      setState(() {
                        _validate = null;
                      });
                    }

                    Flushbar(
                      title: "Added",
                      message:
                          "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on ${_weekDays.join(",")}",
                      duration: Duration(seconds: 3),
                    )..show(context);
                    var setAlarmObject = {
                      "time": {"hour": _time.hour, "minute": _time.minute},
                      "range": {
                        "start": {
                          "hour": _timeRange.startTime.hour,
                          "minute": _timeRange.startTime.minute
                        },
                        "end": {
                          "hour": _timeRange.endTime.hour,
                          "minute": _timeRange.endTime.minute
                        }
                      },
                      "task": _taskController.text,
                      "description": _descriptionController.text
                    };
                    Map l = {
                      "Monday": Day.Monday,
                      "Tuesday": Day.Tuesday,
                      "Wednesday": Day.Wednesday,
                      "Thursday": Day.Thursday,
                      "Friday": Day.Friday,
                      "Saturday": Day.Saturday,
                      "Sunday": Day.Sunday,
                    };
                    for (String i in _weekDays) {
                      await notificationPlugin.showWeeklyAtDayTime(
                          _taskController.text,
                          _descriptionController.text,
                          l[i],
                          Time(_time.hour, _time.minute),_timeRange);
                      await currentData['days'][i].add(setAlarmObject);
                    }

                    widget._thisStorage.writedata(json.encode(currentData));

                    setState(() {
                      _taskController.text = '';
                      _descriptionController.text = 'No Description';
                    });
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
                    'Current Schedule',
                    style: TextStyle(
                      letterSpacing: 3,
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Mon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Monday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Monday'][i]['time']
                                  ['minute'];
                              int smin = currentData["days"]['Monday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Monday'][i]
                                  ['range']['end']['minute'];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              '  ${currentData["days"]['Monday'][i]['task']} at \n Time: ${(currentData["days"]['Monday'][i]['time']['hour'] > 12) ? currentData["days"]['Monday'][i]['time']['hour'] - 12 : currentData["days"]['Monday'][i]['time']['hour']}:${(currentData["days"]['Monday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Monday'][i]['time']['minute']} ${(currentData["days"]['Monday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Monday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Monday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Monday'][i]['range']['start']['hour']}:${(currentData["days"]['Monday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Monday'][i]['range']['start']['minute']} ${(currentData["days"]['Monday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Monday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Monday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Monday'][i]['range']['end']['hour']}:${(currentData["days"]['Monday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Monday'][i]['range']['end']['minute']} ${(currentData["days"]['Monday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Monday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Monday,
                                                      Time(
                                                          currentData["days"]
                                                                  ['Monday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"]
                                                                      ['Monday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Monday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });
                                              Navigator.pop(context);

                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Monday",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Monday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Monday'][i]['time']['hour'] > 12 ? currentData["days"]['Monday'][i]['time']['hour'] - 12 : currentData["days"]['Monday'][i]['time']['hour'])}:${(currentData["days"]['Monday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Monday'][i]['time']['minute']} ${(currentData["days"]['Monday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Tue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Tuesday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Tuesday'][i]
                                  ['time']['minute'];
                              int smin = currentData["days"]['Tuesday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Tuesday'][i]
                                  ['range']['end']['minute'];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              '  ${currentData["days"]['Tuesday'][i]['task']} at \n Time: ${(currentData["days"]['Tuesday'][i]['time']['hour'] > 12) ? currentData["days"]['Tuesday'][i]['time']['hour'] - 12 : currentData["days"]['Tuesday'][i]['time']['hour']}:${(currentData["days"]['Tuesday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Tuesday'][i]['time']['minute']} ${(currentData["days"]['Tuesday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Tuesday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Tuesday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Tuesday'][i]['range']['start']['hour']}:${(currentData["days"]['Tuesday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Tuesday'][i]['range']['start']['minute']} ${(currentData["days"]['Tuesday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Tuesday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Tuesday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Tuesday'][i]['range']['end']['hour']}:${(currentData["days"]['Tuesday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Tuesday'][i]['range']['end']['minute']} ${(currentData["days"]['Tuesday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Tuesday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Tuesday,
                                                      Time(
                                                          currentData["days"][
                                                                  'Tuesday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"]
                                                                      [
                                                                      'Tuesday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Tuesday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });

                                              Navigator.pop(context);
                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Tuesday",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Tuesday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Tuesday'][i]['time']['hour'] > 12 ? currentData["days"]['Tuesday'][i]['time']['hour'] - 12 : currentData["days"]['Tuesday'][i]['time']['hour'])}:${(currentData["days"]['Tuesday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Tuesday'][i]['time']['minute']} ${(currentData["days"]['Tuesday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Wed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Wednesday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Wednesday'][i]
                                  ['time']['minute'];
                              int smin = currentData["days"]['Wednesday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Wednesday'][i]
                                  ['range']['end']['minute'];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              '  ${currentData["days"]['Wednesday'][i]['task']} at \n Time: ${(currentData["days"]['Wednesday'][i]['time']['hour'] > 12) ? currentData["days"]['Wednesday'][i]['time']['hour'] - 12 : currentData["days"]['Wednesday'][i]['time']['hour']}:${(currentData["days"]['Wednesday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Wednesday'][i]['time']['minute']} ${(currentData["days"]['Wednesday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Wednesday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Wednesday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Wednesday'][i]['range']['start']['hour']}:${(currentData["days"]['Wednesday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Wednesday'][i]['range']['start']['minute']} ${(currentData["days"]['Wednesday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Wednesday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Wednesday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Wednesday'][i]['range']['end']['hour']}:${(currentData["days"]['Wednesday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Wednesday'][i]['range']['end']['minute']} ${(currentData["days"]['Wednesday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Wednesday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Wednesday,
                                                      Time(
                                                          currentData["days"][
                                                                  'Wednesday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"][
                                                                      'Wednesday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Wednesday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });
                                              Navigator.pop(context);

                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Wednesday",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Wednesday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Wednesday'][i]['time']['hour'] > 12 ? currentData["days"]['Wednesday'][i]['time']['hour'] - 12 : currentData["days"]['Wednesday'][i]['time']['hour'])}:${(currentData["days"]['Wednesday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Wednesday'][i]['time']['minute']} ${(currentData["days"]['Wednesday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Thu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Thursday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Thursday'][i]
                                  ['time']['minute'];
                              int smin = currentData["days"]['Thursday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Thursday'][i]
                                  ['range']['end']['minute'];

                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              '  ${currentData["days"]['Thursday'][i]['task']} at \n Time: ${(currentData["days"]['Thursday'][i]['time']['hour'] > 12) ? currentData["days"]['Thursday'][i]['time']['hour'] - 12 : currentData["days"]['Thursday'][i]['time']['hour']}:${(currentData["days"]['Thursday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Thursday'][i]['time']['minute']} ${(currentData["days"]['Thursday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Thursday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Thursday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Thursday'][i]['range']['start']['hour']}:${(currentData["days"]['Thursday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Thursday'][i]['range']['start']['minute']} ${(currentData["days"]['Thursday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Thursday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Thursday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Thursday'][i]['range']['end']['hour']}:${(currentData["days"]['Thursday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Thursday'][i]['range']['end']['minute']} ${(currentData["days"]['Thursday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Thursday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Thursday,
                                                      Time(
                                                          currentData["days"][
                                                                  'Thursday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"][
                                                                      'Thursday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Thursday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });
                                              Navigator.pop(context);

                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Thursday",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Thursday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Thursday'][i]['time']['hour'] > 12 ? currentData["days"]['Thursday'][i]['time']['hour'] - 12 : currentData["days"]['Thursday'][i]['time']['hour'])}:${(currentData["days"]['Thursday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Thursday'][i]['time']['minute']} ${(currentData["days"]['Thursday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Fri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Friday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Friday'][i]['time']
                                  ['minute'];
                              int smin = currentData["days"]['Friday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Friday'][i]
                                  ['range']['end']['minute'];

                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              ' ${currentData["days"]['Friday'][i]['task']} at \n Time: ${(currentData["days"]['Friday'][i]['time']['hour'] > 12) ? currentData["days"]['Friday'][i]['time']['hour'] - 12 : currentData["days"]['Friday'][i]['time']['hour']}:${(currentData["days"]['Friday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Friday'][i]['time']['minute']} ${(currentData["days"]['Friday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Friday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Friday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Friday'][i]['range']['start']['hour']}:${(currentData["days"]['Friday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Friday'][i]['range']['start']['minute']} ${(currentData["days"]['Friday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Friday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Friday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Friday'][i]['range']['end']['hour']}:${(currentData["days"]['Friday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Friday'][i]['range']['end']['minute']} ${(currentData["days"]['Friday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Friday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Friday,
                                                      Time(
                                                          currentData["days"]
                                                                  ['Friday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"]
                                                                      ['Friday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Friday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });
                                              Navigator.pop(context);
                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Friday ",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Friday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Friday'][i]['time']['hour'] > 12 ? currentData["days"]['Friday'][i]['time']['hour'] - 12 : currentData["days"]['Friday'][i]['time']['hour'])}:${(currentData["days"]['Friday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Friday'][i]['time']['minute']} ${(currentData["days"]['Friday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Sat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Saturday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Saturday'][i]
                                  ['time']['minute'];
                              int smin = currentData["days"]['Saturday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Saturday'][i]
                                  ['range']['end']['minute'];

                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              '  ${currentData["days"]['Saturday'][i]['task']} at \n Time: ${(currentData["days"]['Saturday'][i]['time']['hour'] > 12) ? currentData["days"]['Saturday'][i]['time']['hour'] - 12 : currentData["days"]['Saturday'][i]['time']['hour']}:${(currentData["days"]['Saturday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Saturday'][i]['time']['minute']} ${(currentData["days"]['Saturday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Saturday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Saturday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Saturday'][i]['range']['start']['hour']}:${(currentData["days"]['Saturday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Saturday'][i]['range']['start']['minute']} ${(currentData["days"]['Saturday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Saturday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Saturday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Saturday'][i]['range']['end']['hour']}:${(currentData["days"]['Saturday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Saturday'][i]['range']['end']['minute']} ${(currentData["days"]['Saturday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Saturday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Saturday,
                                                      Time(
                                                          currentData["days"][
                                                                  'Saturday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"][
                                                                      'Saturday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Saturday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });
                                              Navigator.pop(context);

                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Saturday",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Saturday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Saturday'][i]['time']['hour'] > 12 ? currentData["days"]['Saturday'][i]['time']['hour'] - 12 : currentData["days"]['Saturday'][i]['time']['hour'])}:${(currentData["days"]['Saturday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Saturday'][i]['time']['minute']} ${(currentData["days"]['Saturday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.teal)),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.teal),
                          alignment: Alignment.center,
                          child: Text(
                            'Sun',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentData["days"]['Sunday'].length,
                            itemBuilder: (context, i) {
                              int min = currentData["days"]['Sunday'][i]['time']
                                  ['minute'];
                              int smin = currentData["days"]['Sunday'][i]
                                  ['range']['start']['minute'];
                              int emin = currentData["days"]['Sunday'][i]
                                  ['range']['end']['minute'];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AssetGiffyDialog(
                                            buttonCancelText: Text(
                                              'Leave',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonCancelColor: Colors.teal,
                                            buttonOkText: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            buttonOkColor: Colors.redAccent,
                                            image: Image.asset(
                                                'image/dharmesh_bg.png'),
                                            title: Text(
                                              ' ${currentData["days"]['Sunday'][i]['task']} at \n Time: ${(currentData["days"]['Sunday'][i]['time']['hour'] > 12) ? currentData["days"]['Sunday'][i]['time']['hour'] - 12 : currentData["days"]['Sunday'][i]['time']['hour']}:${(currentData["days"]['Sunday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Sunday'][i]['time']['minute']} ${(currentData["days"]['Sunday'][i]['time']['hour'] > 12) ? "pm" : "am"}  \n ${(currentData["days"]['Sunday'][i]['range']['start']['hour'] > 12) ? currentData["days"]['Sunday'][i]['range']['start']['hour'] - 12 : currentData["days"]['Sunday'][i]['range']['start']['hour']}:${(currentData["days"]['Sunday'][i]['range']['start']['minute'] < 10) ? "0$smin" : currentData["days"]['Sunday'][i]['range']['start']['minute']} ${(currentData["days"]['Sunday'][i]['range']['start']['hour'] > 12) ? "pm" : "am"} || ${(currentData["days"]['Sunday'][i]['range']['end']['hour'] > 12) ? currentData["days"]['Sunday'][i]['range']['end']['hour'] - 12 : currentData["days"]['Sunday'][i]['range']['end']['hour']}:${(currentData["days"]['Sunday'][i]['range']['end']['minute'] < 10) ? "0$emin" : currentData["days"]['Sunday'][i]['range']['end']['minute']} ${(currentData["days"]['Sunday'][i]['range']['end']['hour'] > 12) ? "pm" : "am"}',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            description: Text(
                                              '${currentData["days"]['Sunday'][i]['description']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(),
                                            ),
                                            entryAnimation:
                                                EntryAnimation.BOTTOM,
                                            onOkButtonPressed: () async {
                                              await notificationPlugin
                                                  .cancelNotificationWeekly(
                                                      Day.Sunday,
                                                      Time(
                                                          currentData["days"]
                                                                  ['Sunday'][i]
                                                              ['time']['hour'],
                                                          currentData["days"]
                                                                      ['Sunday']
                                                                  [i]['time']
                                                              ['minute']));
                                              await currentData["days"]
                                                      ['Sunday']
                                                  .removeAt(i);
                                              setState(() {
                                                widget._thisStorage.writedata(
                                                    json.encode(currentData));
                                              });
                                              Navigator.pop(context);

                                              Flushbar(
                                                title: "Deleted",
                                                message:
                                                    "Task:${_taskController.text} Time:${_time.hour}:${_time.minute} on Sunday ",
                                                duration: Duration(seconds: 3),
                                              )..show(context);
                                            },
                                          ));
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${currentData["days"]['Sunday'][i]['task']}",
                                              style: TextStyle(fontSize: 16)),
                                          Text(
                                              "${(currentData["days"]['Sunday'][i]['time']['hour'] > 12 ? currentData["days"]['Sunday'][i]['time']['hour'] - 12 : currentData["days"]['Sunday'][i]['time']['hour'])}:${(currentData["days"]['Sunday'][i]['time']['minute'] < 10) ? "0$min" : currentData["days"]['Sunday'][i]['time']['minute']} ${(currentData["days"]['Sunday'][i]['time']['hour'] > 12) ? "pm" : "am"}",
                                              style: TextStyle(fontSize: 12))
                                        ]),
                                  ),
                                  color: Colors.white,
                                  elevation: 2,
                                ),
                              );
                            }),
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.73,
                        color: Colors.grey,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ],
            ),
          );
  }
}
