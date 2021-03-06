import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading>  {
  @override
  Widget build(BuildContext context) {
    return
          Container(

            child: Container(
          color:Colors.teal[50],
          child: Center(
            child: SpinKitChasingDots(
              color:Colors.teal,
              size: 50,
            ),
          ),
        ),
      );
  }
}