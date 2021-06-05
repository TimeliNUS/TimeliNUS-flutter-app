import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: _isSigningIn
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : OutlinedButton(
                style: ButtonStyle(
                  // backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isSigningIn = true;
                  });

                  context.read<LandingCubit>().logInWithGoogle();

                  setState(() {
                    _isSigningIn = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage("assets/images/googleIcon.png"),
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Google',
                          ),
                        )
                      ]),
                ),
              ),
      );
    });
  }
}
