import 'package:Dorganize/auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

class Drawerr extends StatefulWidget {
  @override
  _DrawerrState createState() => _DrawerrState();
}

class _DrawerrState extends State<Drawerr> with AutomaticKeepAliveClientMixin {
  bool loading = true;
  AuthService _auth = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_auth.email);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.teal,
              child: Column(
                children: [
                  Expanded(
                      flex: 2,
                      child: Icon(
                        Icons.person_pin,
                        size: 80,
                        color: Colors.white,
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          '${_auth.email.email} ',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                          overflow: TextOverflow.fade,
                        ),
                      )),
                ],
              )),
        
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/stack');
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text(
                  'My Stack  ',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.teal,
                      fontWeight: FontWeight.w800),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/important');
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text(
                  'Important Input',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.teal,
                      fontWeight: FontWeight.w800),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/iset');
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text(
                  'I Set  ',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.teal,
                      fontWeight: FontWeight.w800),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text(
                  'Logout ',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.teal,
                      fontWeight: FontWeight.w800),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/appInfo');
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text(
                  'App Info  ',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.teal,
                      fontWeight: FontWeight.w800),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
