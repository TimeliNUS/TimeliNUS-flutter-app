import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget landingActionGroup(Function() trigger) {
  return Padding(
    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
    child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Have an account?",
                style: TextStyle(color: Colors.black54, fontSize: 12)),
            new InkWell(
              onTap: () {
                // Navigator.pushNamed(context, "YourRoute");
                trigger();
              },
              child: new Padding(
                padding: new EdgeInsets.all(10.0),
                child: new Text("Sign in here",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black54,
                        fontSize: 12)),
              ),
            )
          ],
        ),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.orange),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () => {},
                          child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Text("Continue with Email")))))
            ])
      ],
    ),
  );
}
