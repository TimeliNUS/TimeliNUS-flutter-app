import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/landingScreen/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/textWithAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginGroupState();
  }
}

class LoginGroupState extends State<LoginGroup> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
        buildWhen: (previous, current) =>
            previous.email != current.email ||
            previous.remembered != current.remembered,
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(top: 10, left: 45, right: 45),
            child: Column(
              children: [
                Text("To continue your access",
                    style: TextStyle(color: Colors.white)),
                Image(
                  image: AssetImage("assets/images/loginScreen/login.png"),
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                EmailInput(),
                // Padding(padding: EdgeInsets.symmetric(vertical: 40)),
                PasswordInput(),
                Row(mainAxisSize: MainAxisSize.max, children: [
                  SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: Checkbox(
                        value: state.remembered,
                        onChanged: (isSetToRemembered) =>
                            context.read<LandingCubit>().toggleRemembered()),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 30)),
                  InkWell(
                      onTap: () =>
                          context.read<LandingCubit>().toggleRemembered(),
                      child: Text("Remember me",
                          style: ThemeTextStyle.defaultText)),
                  Expanded(
                      child: Text(
                    "Forgot Password?",
                    style: ThemeTextStyle.defaultText,
                    textAlign: TextAlign.right,
                  ))
                ]),
                // LoginButton(),
                wideActionButton("Login",
                    () => context.read<LandingCubit>().logInWithCredentials()),
                // wideActionButton(
                //     "Login",
                //     () => FirebaseService()
                //         .login(_emailController.text, _passwordController.text)),
                textWithAction(
                    "Don't have an account?",
                    "Create here",
                    () => context
                        .read<LandingCubit>()
                        .changeLandingState(LandingStatus.isSigningUp))
              ],
            ),
          );
        });
  }
}
