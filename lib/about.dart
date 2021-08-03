import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}



class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("About app "),
        ),
        body: Bo());
  }
}

class Bo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Card(
          elevation: 6,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Regular ',
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
                Text('1. Set Time'),
                Text('2. Set Time Range'),
                Text('3. Select WeekDays'),
                Text('4. Write Task'),
                Text('5. Write Description'),
                SizedBox(height: 5),
                Text(
                    'This  section is mainly for your weekly routine , like you have your own routine for respective days in weeks ')
              ])),
      SizedBox(height: 10),
      Card(
          elevation: 6,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Special ',
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
                Text('1. Select Date in Range'),
                Text('2. Set Time'),
                Text('3. Set Time Range'),
                Text('4. Write Task'),
                Text('5. Write Description'),
                SizedBox(height: 5),
                Text(
                    'This  section is  for A range of dates like for 10 days ,15 days .  Like you wear following you weekly schedule but for next 10 to 15 days you have your exam for that you can just select you range of days and set your routine ')
              ])),
              SizedBox(height:10),
               Card(
          elevation: 6,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Iset ',
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
                Text('1. Write thing you studied'),
                Text('2. Write Description'),
             
                SizedBox(height: 5),
                Text(
                    'This  section  automaticaly select days for revision of what you studied today .  ')
              ])),
              SizedBox(height:10),
                  Card(
          elevation: 6,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Stack ',
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
                Text('1. Red'),
                Text('2. Orange'),
                Text('3. Green'),
                Text('4. Important'),
             
                SizedBox(height: 5),
                Text(
                    'This  section  automatic update of what you have to do and for what you have to ready for, you have you own important stack in which you can import your task directly ')
              ])),
              SizedBox(height:10),
                     Card(
          elevation: 6,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Important ',
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
                  Text('1. Select Date in Range'),
                Text('2. Set Time'),
                Text('3. Set Time Range'),
                Text('4. Write Task'),
                Text('5. Write Description'),
             
                SizedBox(height: 5),
                Text(
                    'This  section  automatic Takes your Input and insert in Important Stack ')
              ])),
        
    ]);
  }
}
