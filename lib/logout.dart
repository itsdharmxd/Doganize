import 'package:Dorganize/NotificationPlugin.dart';
import 'package:Dorganize/Storage.dart';
import 'package:Dorganize/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:flutter/services.dart';

class Logout extends StatefulWidget {
  final Storage _indexStorage;

  Logout(this._indexStorage) : super();

  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  final AuthService _authService = AuthService();
  String up = 'upload';
  String error = '';
  String button = 'Logout';
  bool press = true;
  bool upload = false;
  String dat = '';
  _work() async {
    // DocumentSnapshot doc = await DatabaseService(uid:_authService.email.uid).getUserData();
    // print(doc.data()['data']);

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        String data = await widget._indexStorage.readData();
        Map currentdata = json.decode(data);
        currentdata['login'] = 0;

        String currentemail = currentdata['current']['email'];
        String currentpassword = currentdata['current']['password'];
        Storage st = Storage(file: '$currentemail$currentpassword.json');
        String filedata = await st.readData();
        await widget._indexStorage.writedata(json.encode(currentdata));
        await DatabaseService(uid: _authService.email.uid)
            .updateUserData(filedata);
        await notificationPlugin.cancelAll();
        await _authService.signOut();

        SystemNavigator.pop();
        print('connected');
      }
    } on SocketException catch (_) {
      setState(() {
        error = "Please Connect to Internet to Logout";
      });

      print('not connected');
    }
  }

  preess() {
    setState(() {
      press = false;
      button = 'Press Again to Logout';
    });
  }

  func() async {
    try {
      setState(() {
        dat = '';
      });
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        String data = await widget._indexStorage.readData();
        Map currentdata = json.decode(data);

        String currentemail = currentdata['current']['email'];
        String currentpassword = currentdata['current']['password'];
        Storage st = Storage(file: '$currentemail$currentpassword.json');
        String filedata = await st.readData();

        await DatabaseService(uid: _authService.email.uid)
            .updateUserData(filedata);
        setState(() {
          upload = true;
          up = 'Uploaded';
        });

        print('connected');
      }
    } on SocketException catch (_) {
      setState(() {
        dat = "Please Connect to network";
      });

      print('not connected');
    }
  }

  dataLoad() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        DocumentSnapshot doc =
            await DatabaseService(uid: _authService.email.uid).getUserData();
        Map currentData = json.decode(doc.data()['data']);
        notificationPlugin.cancelAll();
        List l = [
          "Monday"
              "Tuesday"
              "Wednesday"
              "Thursday"
              "Friday"
              "Saturday"
              "Sunday"
        ];
        for (int i = 0; i < l.length; i++) {
          try {
            print(l[i]);
            List list = currentData['days'][l[i]];
            for (int j = 0; j < list.length; j++) {
              Map d = list[j];
              print(d['task']);
              print(d['description']);
              print(d['time']['hour']);
              print(d['time']['minute']);
            }
          } catch (e) {}
        }
      }
    } on SocketException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Load your data to servers'),
                  RaisedButton(
                      textColor: Colors.white,
                      color: Colors.pink,
                      onPressed: null,
                      child: Text(
                        "Load your data ",
                        style: TextStyle(fontSize: 30),
                      )),
                  Text('Load Button will be available in future',
                      style: TextStyle(color: Colors.red)),
                  Text(
                    dat,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  Text('Upload your data to servers'),
                  RaisedButton(
                      textColor: Colors.white,
                      color: Colors.pink,
                      onPressed: func,
                      child: Text(
                        up,
                        style: TextStyle(fontSize: 30),
                      )),
                  !upload
                      ? SizedBox()
                      : Icon(
                          Icons.done_all,
                          color: Colors.red,
                          size: 50,
                        ),
                  SizedBox(height: 100),
                  Text('Current User'),
                  SizedBox(height: 12),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(_authService.email.email,
                          style: TextStyle(fontSize: 30))),
                  SizedBox(height: 12),
                  RaisedButton(
                      textColor: Colors.white,
                      color: Colors.pink,
                      onPressed: null, // press ? preess : _work,
                      child: Text(
                        button,
                        style: TextStyle(fontSize: 30),
                      )),
                  SizedBox(height: 12),
                  Text(
                    'Will be available in future',
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red),
                  )
                ]),
          ],
        ),
      ),
    );
  }
}
