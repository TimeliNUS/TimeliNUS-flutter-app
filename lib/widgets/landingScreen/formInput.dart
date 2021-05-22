import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:TimeliNUS/widgets/style.dart';

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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
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

// return Row(
//     children: <Widget>[
//       Expanded(
//         child: Padding(
//           padding: const EdgeInsets.only(right: 0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: ThemeColor.lightGrey,
//               borderRadius: const BorderRadius.all(
//                 Radius.circular(5.0),
//               ),
//             ),
//             child: Padding(
//               padding:
//                   const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
//               child: TextField(
//                 key: Key('Password'),
//                 controller: _passwordController,
//                 obscureText: true,
//                 onChanged: (String txt) {},
//                 style: const TextStyle(
//                   fontSize: 14,
//                 ),
//                 cursorColor: Colors.white,
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   labelText: 'Password',
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
