import 'dart:ui';

import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingState.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget getEmailInput(TextEditingController _emailController) {
  return SizedBox(
    height: 50,
    child: Container(
      decoration: BoxDecoration(
        color: ThemeColor.lightGrey,
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
        child: TextField(
          key: Key("Email"),
          controller: _emailController,
          onChanged: (String txt) {},
          style: const TextStyle(
            fontSize: 12,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Please enter your email',
          ),
        ),
      ),
    ),
  );
}

Widget getPasswordInput(TextEditingController _passwordController) {
  return SizedBox(
    height: 50,
    child: Container(
      decoration: BoxDecoration(
        color: ThemeColor.lightGrey,
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
        child: TextField(
          key: Key('Password'),
          controller: _passwordController,
          obscureText: true,
          onChanged: (String txt) {},
          style: const TextStyle(
            fontSize: 12,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Password',
          ),
        ),
      ),
    ),
  );
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('emailInput_textField'),
          onChanged: (email) =>
              context.read<LandingCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Please enter your email',
            helperText: '',
            errorText: state.email.invalid ? 'Invalid Email' : null,
          ),
        );
      },
    );
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('passwordInput_textField'),
          onChanged: (password) =>
              context.read<LandingCubit>().passwordChanged(password),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: '',
            errorText: state.password.invalid ? 'Invalid Password!' : null,
          ),
        );
      },
    );
  }
}
