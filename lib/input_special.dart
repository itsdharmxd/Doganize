import 'package:Dorganize/NotificationPlugin.dart';
import 'NotificationScreen.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'Storage.dart';
import 'dart:convert';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'loading.dart';

class InputSpecial extends StatefulWidget {
  final Storage _thisStorage;

  InputSpecial(this._thisStorage) : super();

  @override
  _InputSpecialState createState() => _InputSpecialState();
}

class _InputSpecialState extends State<InputSpecial>
    with AutomaticKeepAliveClientMixin {
  //speech
  SpeechRecognition _speechRecognition;
  bool _isavailable = false;
  bool _islistening = false;
  String resulttext = '';

  bool loading = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  //speech
  var _validate;
  List<DateTime> _dateTimeList = [];

  Map currentData;
  DateTimeRange _dateTimeRange;
  TimeOfDay _time;
  var timeminute, timeendminute, timestartminute;
  TimeRange _timeRange;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _taskController = TextEditingController();

  @override
  // TODO: implement wantKeepAlive
//  bool get wantKeepAlive => true;

  file() async {
    String data = await widget._thisStorage.readData();

    setState(() {
      currentData = json.decode(data);
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _validate = null;
    _descriptionController.text = "No Description";
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
      "iset": [],
    };

    // TODO: implement initState
    file();
    initspeechrecognition();
    _dateTimeRange = DateTimeRange(
        start: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        end: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(Duration(days: 1)));
    _time = TimeOfDay.now();
    timeminute = _time.minute;
    _timeRange = TimeRange(startTime: _time, endTime: _time);
    timestartminute = _timeRange.startTime.minute;
    timeendminute = _timeRange.endTime.minute;
    _dateTimeList.add(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));
    _dateTimeList.add(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(Duration(days: 1)));
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
    _speechRecognition.setCurrentLocaleHandler((text) {
      print("----------------------------$text");
    });
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

    return loading
        ? Loading()
        : ListView(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(28, 2, 28, 2),
                child: RaisedButton(
                    color: Colors.redAccent,
                    onPressed: () async {
                      final List<DateTime> picked =
                          await DateRagePicker.showDatePicker(
                              context: context,
                              initialFirstDate: DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day),
                              initialLastDate: DateTime(DateTime.now().year,
                                      DateTime.now().month, DateTime.now().day)
                                  .add(Duration(days: 1)),
                              firstDate: DateTime(DateTime.now().year),
                              lastDate: DateTime(DateTime.now().year)
                                  .add(Duration(days: 700)));

                      if (picked != null) {
                        setState(() {
                          _dateTimeRange = DateTimeRange(
                              start: DateTime(picked[0].year, picked[0].month,
                                  picked[0].day),
                              end: DateTime(picked[1].year, picked[1].month,
                                  picked[1].day));
                          List<DateTime> li = [];
                          for (int i = 0;
                              i <= _dateTimeRange.duration.inDays;
                              i++) {
                            li.add(_dateTimeRange.start.add(Duration(days: i)));
                          }
                          _dateTimeList = li;
                          print(_dateTimeList);
                        });
                      }
                    },
                    child: Text(
                      "Pick Date Range",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              ),
              Card(
                shadowColor: Colors.red,
                elevation: 3,
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      '${_dateTimeRange.start.day}-${_dateTimeRange.start.month}-${_dateTimeRange.start.year} || ${_dateTimeRange.end.day}-${_dateTimeRange.end.month}-${_dateTimeRange.end.year}',
                      style: TextStyle(
                          shadows: [Shadow(offset: Offset.fromDirection(10))],
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.brown[300]),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28.0, 15, 28.0, 10),
                child: Divider(
                  color: Colors.black87,
                  height: 3,
                ),
              ),
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
                padding: const EdgeInsets.fromLTRB(28.0, 10, 28.0, 10),
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
                            shadows: [Shadow(offset: Offset.fromDirection(10))],
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
                            shadows: [Shadow(offset: Offset.fromDirection(10))],
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
                FloatingActionButton(
                  child: Icon(Icons.mic),
                  mini: true,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  onPressed: () {
                    print('$_isavailable $_islistening');
                    if (_isavailable || _islistening) {
                      _speechRecognition.listen(locale: 'en_US').then((value) {
                        print(value);
                      });
                    }
                    _islistening = false;
                  },
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
                  print(
                      "$_time $_timeRange ${_dateTimeRange.start} ${_dateTimeRange.end} $_dateTimeList ${_taskController.text} ${_descriptionController.text} ");

                  List currentDateList = currentData['dates'];

                  int dateTimeLength = _dateTimeList.length;
                  print(dateTimeLength);
                  int currentDateLength = currentDateList.length;
                  int dateTimeLengthIndex = 0;
                  print(_dateTimeList);
                  print(currentDateList);
                  try {
                    for (int i = 0;
                        (i < currentDateLength) &&
                            (dateTimeLengthIndex < dateTimeLength);
                        i++) {
                      print('run $i $dateTimeLengthIndex');
                      //  print(_dateTimeList[dateTimeLengthIndex].year);
                      var object = currentDateList[i];
                      var bo = DateTime(object['date']['year'],
                              object['date']['month'], object['date']['day'])
                          .compareTo(DateTime(
                              _dateTimeList[dateTimeLengthIndex].year,
                              _dateTimeList[dateTimeLengthIndex].month,
                              _dateTimeList[dateTimeLengthIndex].day));
                      if (bo == 0) {
                        print('if');
                        await currentDateList[i]["schedule"]
                            .add(setAlarmObject);
                        await notificationPlugin.scheduleNotification(
                            _taskController.text,
                            _descriptionController.text,
                            DateTime(
                                _dateTimeList[dateTimeLengthIndex].year,
                                _dateTimeList[dateTimeLengthIndex].month,
                                _dateTimeList[dateTimeLengthIndex].day,
                                _time.hour,
                                _time.minute),TimeRange(startTime: TimeOfDay(hour: _timeRange.startTime.hour,minute:_timeRange.startTime.minute), endTime: TimeOfDay(hour: _timeRange.endTime.hour, minute:_timeRange.endTime.minute ) ));
                        dateTimeLengthIndex++;
                      } else if (bo == 1) {
                        print('else if');
                        currentDateList.add({
                          "date": {
                            "year": _dateTimeList[dateTimeLengthIndex].year,
                            "month": _dateTimeList[dateTimeLengthIndex].month,
                            "day": _dateTimeList[dateTimeLengthIndex].day
                          },
                          "schedule": [setAlarmObject]
                        });
                        await notificationPlugin.scheduleNotification(
                            _taskController.text,
                            _descriptionController.text,
                            DateTime(
                                _dateTimeList[dateTimeLengthIndex].year,
                                _dateTimeList[dateTimeLengthIndex].month,
                                _dateTimeList[dateTimeLengthIndex].day,
                                _time.hour,
                                _time.minute),TimeRange(startTime: TimeOfDay(hour: _timeRange.startTime.hour,minute:_timeRange.startTime.minute), endTime: TimeOfDay(hour: _timeRange.endTime.hour, minute:_timeRange.endTime.minute ) ));

                        dateTimeLengthIndex++;
                      } else {
                        print('else');
                      }
                    }
                    for (int i = dateTimeLengthIndex; i < dateTimeLength; i++) {
                      currentDateList.add({
                        "date": {
                          "year": _dateTimeList[dateTimeLengthIndex].year,
                          "month": _dateTimeList[dateTimeLengthIndex].month,
                          "day": _dateTimeList[dateTimeLengthIndex].day
                        },
                        "schedule": [setAlarmObject]
                      });
                      await notificationPlugin.scheduleNotification(
                          _taskController.text,
                          _descriptionController.text,
                          DateTime(
                              _dateTimeList[dateTimeLengthIndex].year,
                              _dateTimeList[dateTimeLengthIndex].month,
                              _dateTimeList[dateTimeLengthIndex].day,
                              _time.hour,
                              _time.minute),TimeRange(startTime: TimeOfDay(hour: _timeRange.startTime.hour,minute:_timeRange.startTime.minute), endTime: TimeOfDay(hour: _timeRange.endTime.hour, minute:_timeRange.endTime.minute ) ));
                      dateTimeLengthIndex++;
                    }

                    currentDateList.sort((a, b) => DateTime(a['date']['year'],
                            a['date']['month'], a['date']['day'])
                        .compareTo(DateTime(b['date']['year'],
                            b['date']['month'], b['date']['day'])));
                    print(currentDateList);

                    setState(() {
                      _taskController.text = "";
                      _descriptionController.text = "No Description";
                      currentData['dates'] = currentDateList;
                      widget._thisStorage.writedata(json.encode(currentData));
                    });

                    Flushbar(
                      title: "Added",
                      message:
                          "Task:${_taskController.text} Time:${_time.hour}:${_time.minute}  ",
                      duration: Duration(seconds: 3),
                    )..show(context);
                  } catch (e) {
                    print(e);
                    for (int i = dateTimeLengthIndex; i < dateTimeLength; i++) {
                      currentDateList.add({
                        "date": {
                          "year": _dateTimeList[dateTimeLengthIndex].year,
                          "month": _dateTimeList[dateTimeLengthIndex].month,
                          "day": _dateTimeList[dateTimeLengthIndex].day
                        },
                        "schedule": [setAlarmObject]
                      });
                      await notificationPlugin.scheduleNotification(
                          _taskController.text,
                          _descriptionController.text,
                          DateTime(
                              _dateTimeList[dateTimeLengthIndex].year,
                              _dateTimeList[dateTimeLengthIndex].month,
                              _dateTimeList[dateTimeLengthIndex].day,
                              _time.hour,
                              _time.minute),TimeRange(startTime: TimeOfDay(hour: _timeRange.startTime.hour,minute:_timeRange.startTime.minute), endTime: TimeOfDay(hour: _timeRange.endTime.hour, minute:_timeRange.endTime.minute ) ));
                      dateTimeLengthIndex++;
                    }

                    currentDateList.sort((a, b) => DateTime(a['date']['year'],
                            a['date']['month'], a['date']['day'])
                        .compareTo(DateTime(b['date']['year'],
                            b['date']['month'], b['date']['day'])));
                    print(currentDateList);

                    setState(() {
                      _taskController.text = '';
                      _descriptionController.text = "No Description";

                      currentData['dates'] = currentDateList;
                      widget._thisStorage.writedata(json.encode(currentData));
                    });
                  }
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
                padding: const EdgeInsets.fromLTRB(28.0, 10, 28.0, 10),
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
                  'Schedule on Dates',
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
                  itemCount: currentData['dates'].length,
                  itemBuilder: (context, i) {
                    return Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.teal)),
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          GestureDetector(
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
                                        image: Image.asset(
                                            'image/dharmesh_bg.png'),
                                        title: Text(
                                          ' ${currentData['dates'][i]['date']['day']}:${currentData['dates'][i]['date']['month']}:${currentData['dates'][i]['date']['year']}',
                                          style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        description: Text(
                                          'Manage Date',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(),
                                        ),
                                        entryAnimation: EntryAnimation.BOTTOM,
                                        onOkButtonPressed: () async {
                                          Navigator.pop(context);
                                          Flushbar(
                                            title: "Deleted",
                                            message:
                                                "Task:${_taskController.text} Date:${currentData['dates'][i]['date']['day']}/${currentData['dates'][i]['date']['month']}/${currentData['dates'][i]['date']['year']}   ",
                                            duration: Duration(seconds: 3),
                                          )..show(context);
                                          try {
                                            List d = currentData['dates'][i]
                                                ['schedule'];

                                            for (int j = 0; j < d.length; j++) {
                                              await notificationPlugin
                                                  .cancelNotificationSchedule(
                                                      DateTime(
                                                          currentData['dates'][i]
                                                              ['date']['year'],
                                                          currentData['dates'][i]
                                                              ['date']['month'],
                                                          currentData['dates'][i]
                                                              ['date']['day'],
                                                          currentData['dates']
                                                                      [i]
                                                                  ['schedule'][j]
                                                              ['time']['hour'],
                                                          currentData['dates']
                                                                          [i]
                                                                      ['schedule']
                                                                  [j]['time']
                                                              ['minute']));
                                            }
                                          } catch (e) {}

                                          await currentData['dates']
                                              .removeAt(i);
                                          Navigator.pop(context);
                                          setState(() {
                                            widget._thisStorage.writedata(
                                                json.encode(currentData));
                                          });
                                        },
                                      ));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: 50,
                                decoration: BoxDecoration(color: Colors.teal),
                                alignment: Alignment.center,
                                child: Text(
                                  '${currentData['dates'][i]['date']['day']}:${currentData['dates'][i]['date']['month']}:${currentData['dates'][i]['date']['year']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                          ),
                          Container(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    currentData['dates'][i]['schedule'].length,
                                itemBuilder: (context, j) {
                                  int min = currentData['dates'][i]['schedule']
                                      [j]['time']['minute'];
                                  int smin = currentData['dates'][i]['schedule']
                                      [j]['range']['start']['minute'];
                                  int emin = currentData['dates'][i]['schedule']
                                      [j]['range']['end']['minute'];

                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AssetGiffyDialog(
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
                                                  '  ${currentData['dates'][i]['schedule'][j]['task']} at \n Time: ${(currentData['dates'][i]['schedule'][j]['time']['hour']>12)?currentData['dates'][i]['schedule'][j]['time']['hour']-12:currentData['dates'][i]['schedule'][j]['time']['hour']}:${(currentData['dates'][i]['schedule'][j]['time']['minute']<10)?"0$min":currentData['dates'][i]['schedule'][j]['time']['minute']} ${(currentData['dates'][i]['schedule'][j]['time']['hour']>12)?"pm":"am"} \n ${(currentData['dates'][i]['schedule'][j]['range']['start']['hour']>12)?currentData['dates'][i]['schedule'][j]['range']['start']['hour']-12:currentData['dates'][i]['schedule'][j]['range']['start']['hour']}:${(currentData['dates'][i]['schedule'][j]['range']['start']['minute']<10)?"0$smin":currentData['dates'][i]['schedule'][j]['range']['start']['minute']} ${(currentData['dates'][i]['schedule'][j]['range']['start']['hour']>12)?"pm":"am"} || ${(currentData['dates'][i]['schedule'][j]['range']['end']['hour']>12)?currentData['dates'][i]['schedule'][j]['range']['end']['hour']-12:currentData['dates'][i]['schedule'][j]['range']['end']['hour']}:${(currentData['dates'][i]['schedule'][j]['range']['end']['minute']<10)?"0$emin":currentData['dates'][i]['schedule'][j]['range']['end']['minute']} ${(currentData['dates'][i]['schedule'][j]['range']['end']['hour']>12)?"pm":"am"} ',
                                                  style: TextStyle(
                                                      fontSize: 22.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                description: Text(
                                                  '${currentData['dates'][i]['schedule'][j]['description']}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(),
                                                ),
                                                entryAnimation:
                                                    EntryAnimation.BOTTOM,
                                                onOkButtonPressed: () async {
                                                  Navigator.pop(context);

                                                  Flushbar(
                                                    title: "Deleted",
                                                    message:
                                                        "Task:${_taskController.text} Time:${_time.hour}:${_time.minute}  ",
                                                    duration:
                                                        Duration(seconds: 3),
                                                  )..show(context);
                                                  try {
                                                    await notificationPlugin
                                                        .cancelNotificationSchedule(DateTime(
                                                            currentData['dates']
                                                                    [i]['date']
                                                                ['year'],
                                                            currentData['dates']
                                                                    [i]['date']
                                                                ['month'],
                                                            currentData['dates'][i]
                                                                ['date']['day'],
                                                            currentData['dates'][i]
                                                                        ['schedule']
                                                                    [j]['time']
                                                                ['hour'],
                                                            currentData['dates'][i]
                                                                        ['schedule']
                                                                    [j]['time']
                                                                ['minute']));
                                                  } catch (e) {}
                                                  await currentData['dates'][i]
                                                          ['schedule']
                                                      .removeAt(j);
                                                  setState(() {
                                                    widget._thisStorage
                                                        .writedata(json.encode(
                                                            currentData));
                                                  });
                                                },
                                              ));
                                    },
                                    child: Card(
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(2, 0, 2, 0),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                  "${currentData['dates'][i]['schedule'][j]['task']}",  style: TextStyle(fontSize:16 )),
                                              Text(
                                                "${(currentData['dates'][i]['schedule'][j]['time']['hour'] > 12) ? currentData['dates'][i]['schedule'][j]['time']['hour'] - 12 : currentData['dates'][i]['schedule'][j]['time']['hour']}:${currentData['dates'][i]['schedule'][j]['time']['minute']} ${(currentData['dates'][i]['schedule'][j]['time']['hour'] > 12) ? 'pm' : 'am'}",  style: TextStyle(fontSize:12 )
                                              )
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
                    );
                  })
            ],
          );
  }
}
