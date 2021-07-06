import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/widgets/landingScreen/carousel.dart';
import 'package:TimeliNUS/widgets/landingScreen/googleSignInButton.dart';
import 'package:TimeliNUS/widgets/landingScreen/landingActionGroup.dart';
import 'package:TimeliNUS/widgets/landingScreen/loginGroup.dart';
import 'package:TimeliNUS/widgets/landingScreen/registerGroup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthenticationAction { no_action, register, login }

class LandingScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: LandingScreen());

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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    return BlocProvider(
        create: (_) => LandingCubit(context.read<AuthenticationRepository>()),
        child: ColoredSafeArea(
            appTheme.accentColor,
            Scaffold(
                body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/loginScreen/background.png"),
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.0275),
                        child: Text(
                          action == AuthenticationAction.login ? 'Login' : 'Welcome',
                          style: Theme.of(context).textTheme.headline6.apply(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                          child: ListView(children: [
                        LandingScreenGroupSwitcher(),
                      ])),
                      // Spacer(),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: Column(children: [
                            Row(children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(child: Divider()),
                                        Padding(
                                            padding: EdgeInsets.all(screenHeight * 0.01),
                                            child: Text("OR", style: TextStyle(color: Colors.black12))),
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
                                        padding: EdgeInsets.only(left: 50.0, right: 20.0), child: GoogleSignInButton()),
                                  ],
                                ),
                              ),
                              new Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 20.0, right: 50.0),
                                      child: new ConstrainedBox(
                                        constraints: BoxConstraints(maxHeight: 45, minHeight: 45, maxWidth: 40),
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
                                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                child: Text(
                                                  "NUS Email",
                                                ))),
                                      )))
                            ]),
                            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 15))
                          ]))
                    ]))))));
  }
}

class LandingScreenGroupSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(builder: (context, state) {
      return Container(
          child: (() {
        switch (state.landingStatus) {
          case LandingStatus.isLoggingIn:
            return LoginGroup();
          case LandingStatus.isSigningUp:
            return RegisterGroup(() => null);
          default:
            return Column(children: [
              CarouselWithIndicatorDemo(),
              Padding(padding: EdgeInsets.only(top: 20)),
              landingActionGroup()
            ]);
        }
      }()));
    });
  }
}
