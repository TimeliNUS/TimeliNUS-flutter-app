import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:TimeliNUS/widgets/style.dart';

Widget getEmailInput(TextEditingController _emailController) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColor.lightGrey,
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: TextField(
                key: Key("Email"),
                controller: _emailController,
                onChanged: (String txt) {},
                style: const TextStyle(
                  fontSize: 14,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Please enter your email',
                ),
              ),
            ),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(0, 2),
                blurRadius: 8.0),
          ],
        ),
      ),
    ],
  );
}

Widget getPasswordInput(TextEditingController _passwordController) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColor.lightGrey,
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: TextField(
                key: Key('Password'),
                controller: _passwordController,
                obscureText: true,
                onChanged: (String txt) {},
                style: const TextStyle(
                  fontSize: 14,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Password',
                ),
              ),
            ),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                offset: const Offset(0, 2),
                blurRadius: 8.0),
          ],
        ),
      ),
    ],
  );
}
