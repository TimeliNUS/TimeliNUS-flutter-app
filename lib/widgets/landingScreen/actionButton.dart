import 'package:flutter/material.dart';

// for actions such as register, continue with email and sign in.
Widget wideActionButton(String buttonText, onPressedAction) {
  return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () => onPressedAction(),
                    child: Padding(
                        padding: EdgeInsets.all(15), child: Text(buttonText)))))
      ]);
}
