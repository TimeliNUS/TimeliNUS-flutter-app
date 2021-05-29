import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/textWithAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget landingActionGroup(Function() login, Function() register) {
  return BlocBuilder<LandingCubit, LandingState>(builder: (context, state) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        children: [
          textWithAction(
              "Have an account?",
              "Sign in here",
              () => context
                  .read<LandingCubit>()
                  .changeLandingState(LandingStatus.isLoggingIn)),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          wideActionButton(
              "Continue with Email",
              () => context
                  .read<LandingCubit>()
                  .changeLandingState(LandingStatus.isSigningUp))
        ],
      ),
    );
  });
}
