
import 'Storage.dart';
import 'NotificationPlugin.dart';
import 'dart:convert';

onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
onNotificationClick(String payload) {
  //  Navigator.pushNamed(context,"notificationscreen", arguments: <String,String>{
  //   'payload':payload
  // } );
  // Navigator.push(context, MaterialPageRoute(builder: (context) {
  //   return NotificationScreen(
  //     payload: payload,
  //   );
  // }));
}

printHello() async {
  await notificationPlugin
      .setListenerForLowerVersions(onNotificationInLowerVersions);
  await notificationPlugin.setOnNotificationClick(onNotificationClick);

  print(" start updates ${DateTime.now()} ");
  Storage _indexStorage = Storage(file: "index.json");
  String dat = await _indexStorage.readData();
  Map map = json.decode(dat);
  if (map['login'] == 1) {
    try {
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
                    .compareTo(DateTime(_date.year, _date.month, _date.day)))) {
              break;
            } else if (0 ==
                (DateTime(data['date']['year'], data['date']['month'],
                        data['date']['day'])
                    .compareTo(DateTime(_date.year, _date.month, _date.day)))) {
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

Future refresh() async {
  await notificationPlugin
      .setListenerForLowerVersions(onNotificationInLowerVersions);
  await notificationPlugin.setOnNotificationClick(onNotificationClick);
 

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
    } catch (e) {}
    try {
      List redList = currentData['stack']['red'];
      while (DateTime(
              redList[i]['date']['year'],
              redList[i]['date']['month'],
              redList[i]['date']['day'],
              redList[i]['schedule']['time']['hour'],
              redList[i]['schedule']['time']['minute'])
          .isBefore(_dateTimeNow)) {
        await redList.removeAt(i);
      }
      currentData['stack']['red'] = redList;
    } catch (e) {}
    

    try {
      List isetList = currentData['iset'];

      while (DateTime(
              isetList[i]['date']['year'],
              isetList[i]['date']['month'],
              isetList[i]['date']['day'],
              isetList[i]['schedule']['time']['hour'],
              isetList[i]['schedule']['time']['minute'])
          .isBefore(_dateTimeNow)) {
         isetList.removeAt(i);
      }
      currentData['iset'] = isetList;
    } catch (e) {}

    try {
      List datesList = currentData['dates'];
      while (DateTime(
              datesList[i]['date']['year'],
              datesList[i]['date']['month'],
              datesList[i]['date']['day'],
              23,
              59)
          .isBefore(_dateTimeNow)) {
         datesList.removeAt(i);
      }
      currentData['dates'] = datesList;
    } catch (e) {}

    try {
      List datesListSchedule = currentData['dates'][i]['schedule'];
      while (DateTime(
        _dateTimeNow.year,
        _dateTimeNow.month,
        _dateTimeNow.day,
        datesListSchedule[i]['time']['hour'],
        datesListSchedule[i]['time']['minute'],
      ).isBefore(_dateTimeNow)) {
         datesListSchedule.removeAt(i);
      }
      currentData['dates'][i]['schedule'] = datesListSchedule;
    } catch (e) {}
    await _thisStorage.writedata(json.encode(currentData));
    print("end refresh ${DateTime.now()}");
  }
}
