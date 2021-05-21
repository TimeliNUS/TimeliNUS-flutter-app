import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:TimeliNUS/widgets/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginGroup extends StatefulWidget {
  final authenticationActionFunction;
  const LoginGroup(this.authenticationActionFunction);

  @override
  State<StatefulWidget> createState() {
    return _loginGroupState();
  }
}

class _loginGroupState extends State<LoginGroup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isRemembered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 45, right: 45),
      child: Column(
        // mainAxisSize: MainAxisSize.max,
        children: [
          Text("To continue your access",
              style: TextStyle(color: Colors.white)),
          Image(
            image: AssetImage("assets/images/loginScreen/login.png"),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          getEmailInput(_emailController),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          getPasswordInput(_passwordController),
          Row(mainAxisSize: MainAxisSize.max, children: [
            SizedBox(
              height: 24.0,
              width: 24.0,
              child: Checkbox(
                  value: isRemembered,
                  onChanged: (isSetToRemembered) =>
                      setState(() => isRemembered = isSetToRemembered)),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 30)),
            Text("Remember me", style: ThemeTextStyle.defaultText),
            Expanded(
                child: Text(
              "Forgot Password?",
              style: ThemeTextStyle.defaultText,
              textAlign: TextAlign.right,
            ))
          ]),
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
                            onPressed: () => FirebaseService.login(
                                _emailController.text,
                                _passwordController.text),
                            child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Text("Login")))))
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?",
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
              new InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, "YourRoute");
                  widget.authenticationActionFunction();
                },
                child: new Padding(
                  padding: new EdgeInsets.all(10.0),
                  child: new Text("Create here",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.black54,
                          fontSize: 12)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
