import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/landingScreen/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/textWithAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterGroup extends StatefulWidget {
  final authenticationActionFunction;
  const RegisterGroup(this.authenticationActionFunction);
  @override
  State<StatefulWidget> createState() {
    return RegisterGroupState();
  }
}

class RegisterGroupState extends State<RegisterGroup> {
  bool isRemembered = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return BlocBuilder<LandingCubit, LandingState>(
        buildWhen: (previous, current) =>
            previous.email != current.email ||
            previous.remembered != current.remembered,
        builder: (context, state) {
          return Padding(
            padding:
                EdgeInsets.only(top: screenHeight * 0.01, left: 45, right: 45),
            child: Column(
              children: [
                Text("Sign up now to start using TimeliNUS",
                    style: TextStyle(color: Colors.white)),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Image(
                  image: AssetImage("assets/images/loginScreen/register.png"),
                  height: MediaQuery.of(context).size.height * 0.175,
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                EmailInput(),
                // Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                PasswordInput(),
                Padding(padding: EdgeInsets.only(top: screenHeight * 0.01)),
                Row(
                  children: [
                    Text(
                      "Password should consist of at least 8 characters,\nincluding letters and numbers ",
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
                Row(children: [
                  SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: Checkbox(
                        value: state.remembered,
                        onChanged: (isSetToRemembered) =>
                            context.read<LandingCubit>().toggleRemembered()),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical:
                              MediaQuery.of(context).size.height * 0.025)),
                  InkWell(
                      onTap: () =>
                          context.read<LandingCubit>().toggleRemembered(),
                      child: Text("Remember me",
                          style: ThemeTextStyle.defaultText)),
                ]),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                wideActionButton("Sign Up",
                    () => context.read<LandingCubit>().signUpFormSubmitted()),
                textWithAction(
                    "Have an account?",
                    "Sign in here",
                    () => context
                        .read<LandingCubit>()
                        .changeLandingState(LandingStatus.isLoggingIn)),
              ],
            ),
          );
        });
  }
}
