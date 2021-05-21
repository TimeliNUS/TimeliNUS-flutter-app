import 'package:TimeliNUS/widgets/carousel.dart';
import 'package:TimeliNUS/widgets/googleSignInButton.dart';
import 'package:TimeliNUS/widgets/landingActionGroup.dart';
import 'package:TimeliNUS/widgets/loginGroup.dart';
import 'package:TimeliNUS/widgets/registerGroup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AuthenticationAction { no_action, register, login }

class LandingScreen extends StatefulWidget {
  LandingScreen();

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthenticationAction action;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    action = AuthenticationAction.no_action;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   // Here we take the value from the MyHomePage object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   title: Text('Register'),
        // ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/loginScreen/background.png"),
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
                // width: MediaQueryData.size.width,
              ),
            ),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      action == AuthenticationAction.login
                          ? 'Login'
                          : 'Welcome',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                          fontFamily: "DMSans",
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  action == AuthenticationAction.login
                      ? LoginGroup(() => setState(
                          () => action = AuthenticationAction.register))
                      : action == AuthenticationAction.register
                          ? RegisterGroup(() => setState(
                              () => action = AuthenticationAction.login))
                          : Column(children: [
                              CarouselWithIndicatorDemo(),
                              Padding(padding: EdgeInsets.only(top: 20)),
                              landingActionGroup(
                                  () => setState(() =>
                                      action = AuthenticationAction.login),
                                  () => setState(() =>
                                      action = AuthenticationAction.register)),
                            ]),
                  Row(children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Divider()),
                              Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text("OR",
                                      style: TextStyle(color: Colors.black12))),
                              Expanded(child: Divider()),
                            ],
                          )),
                    )
                  ]),
                  Row(children: <Widget>[
                    new Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 50.0, right: 20.0),
                              child: GoogleSignInButton()),
                        ],
                      ),
                    ),
                    new Expanded(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 50.0),
                            child: new ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight: 45, minHeight: 45, maxWidth: 40),
                              // height: 40.0,
                              // width: 80.0,
                              child: OutlinedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      child: Text(
                                        "NUS Email",
                                      ))),
                            )))
                  ]),
                ]))));
  }
}
