import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

// for actions such as register, continue with email and sign in.
Widget wideActionButton(String buttonText, onPressedAction) {
  return BlocBuilder<LandingCubit, LandingState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Column(children: [
          Text(state.status == FormzStatus.submissionFailure
              ? "Wrong credentials"
              : ""),
          state.status == FormzStatus.submissionInProgress
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.orange),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => onPressedAction(),
                                  child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(buttonText)))))
                    ])
        ]);
      });
}

// class LoginButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LandingCubit, LandingState>(
//       buildWhen: (previous, current) => previous.status != current.status,
//       builder: (context, state) {
//         return state.status == FormzStatus.submissionInProgress
//             ? const CircularProgressIndicator()
//             : ElevatedButton(
//                 key: const Key('loginForm_continue_raisedButton'),
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   primary: const Color(0xFFFFD600),
//                 ),
//                 onPressed:
//                     // state.status.isValidated                    ?
//                     () => context.read<LandingCubit>().logInWithCredentials()
//                 // : null
//                 ,
//                 child: const Text('LOGIN'),
//               );
//       },
//     );
//   }
// }
