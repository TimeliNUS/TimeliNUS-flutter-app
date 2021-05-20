import 'package:TimeliNUS/widgets/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignInGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignInGroupState();
  }
}

class _SignInGroupState extends State<SignInGroup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isRemembered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 45, right: 45),
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        children: [
          Image(image: AssetImage("assets/images/loginScreen/login.png")),
          getEmailInput(_emailController),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          getPasswordInput(_passwordController),
          Padding(padding: EdgeInsets.only(top: 20)),
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
                  value: isRemembered,
                  onChanged: (isSetToRemembered) =>
                      setState(() => isRemembered = isSetToRemembered)),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 30)),
            Text("Remember me", style: defaultText())
          ]),
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
                                child: Text("Sign Up")))))
              ])
        ],
      ),
    );
  }
}
