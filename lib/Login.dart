import 'package:Dorganize/Storage.dart';
import 'package:Dorganize/loading.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'auth.dart';

class Login extends StatefulWidget {
  final Storage indexStorage;
  final Function see;
  final Function se;
  Login(this.indexStorage, this.see, this.se);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final _registerKey = GlobalKey<FormState>();
  AuthService _auth = AuthService();
  String error = '';
  bool loading = false;
  AnimationController fanimationController;
  Animation<double> fanimation;
  @override
  void initState() {
    super.initState();
    fanimationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
        animationBehavior: AnimationBehavior.normal);
    fanimation = CurvedAnimation(
        parent: fanimationController, curve: Curves.fastOutSlowIn);
    fanimation.addListener(() => this.setState(() {}));
    fanimationController.forward();
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  _toHomePage() async {
    if (_registerKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      dynamic result = await _auth.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      if (result == null) {
        setState(() {
          error = 'Cound not SignIn !';
          loading = false;
        });
      } else {
        
        String data = await widget.indexStorage.readData();
        var datajson = await json.decode(data);
        print(datajson);

        datajson['current']['email'] = _emailController.text;
        datajson['current']['password'] = _passwordController.text;
        datajson['login'] = 1;
        datajson['members'].add({
          'email': _emailController.text,
          'password': _passwordController.text
        });
        await widget.indexStorage.writedata(json.encode(datajson));

        _emailController.text = '';
        _passwordController.text = '';
        widget.se();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.pink,
                title: Text("Sign In"),
                actions: [
                  FlatButton.icon(
                      onPressed: () {
                        widget.see();
                      },
                      icon: Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Go to Register',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
              body: Container(
                child: Stack(
                  children: <Widget>[
                    Image(
                      fit: BoxFit.cover,
                      image: AssetImage('image/Wallpaper.jpg'),
                      color: Color.fromRGBO(255, 253, 208, 1),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Theme(
                      data: ThemeData(
                          brightness: Brightness.dark,
                          primarySwatch: Colors.teal,
                          inputDecorationTheme: InputDecorationTheme(
                              labelStyle: TextStyle(
                                  fontSize: 20.0, color: Colors.teal))),
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: ListView(
                            children: <Widget>[
                              Container(
                                  height: 150,
                                  child: Center(
                                      child: Image(
                                        width: 150*fanimation.value,
                                        height:  150*fanimation.value,
                                        image:AssetImage('image/dharmesh_bg.png')) 
                                      )
                                      ),
                              SizedBox(height: 18),
                              Form(
                                key: _registerKey,
                                child: Column(children: <Widget>[
                                  TextFormField(
                                    style: TextStyle(color: Colors.pink),
                                    validator: (val) =>
                                        val.isEmpty ? "Enter email" : null,
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: "Email",
                                        hintStyle:
                                            TextStyle(color: Colors.pink),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pink, width: 2.0),
                                        )),
                                    controller: _emailController,
                                  ),
                                  SizedBox(height: 18),
                                  TextFormField(
                                    style: TextStyle(color: Colors.pink),
                                    obscureText: true,
                                    validator: (val) => val.length < 8
                                        ? "Password must be of 8 characters"
                                        : null,
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.pink),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pink, width: 2.0),
                                        )),
                                    controller: _passwordController,
                                  ),
                                  SizedBox(height: 18),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: RaisedButton(
                                      child: Text('Sign In'),
                                      color: Colors.pink,
                                      onPressed: _toHomePage,
                                      textColor: Colors.white,
                                      highlightColor: Colors.orangeAccent[300],
                                      highlightElevation: 3,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(error,
                                      style: TextStyle(color: Colors.white))
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  fit: StackFit.expand,
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    fanimationController.dispose();
    super.dispose();
  }
}
