import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:TimeliNUS/widgets/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterGroup extends StatefulWidget {
  final authenticationActionFunction;
  const RegisterGroup(this.authenticationActionFunction);
  @override
  State<StatefulWidget> createState() {
    return _RegisterGroupState();
  }
}

class _RegisterGroupState extends State<RegisterGroup> {
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
          Text("Sign up now to start using TimeliNUS",
              style: TextStyle(color: Colors.white)),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          Image(
            image: AssetImage("assets/images/loginScreen/register.png"),
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
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
            Text("Remember me", style: ThemeTextStyle.defaultText)
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
                            onPressed: () => FirebaseService.register(
                                _emailController.text,
                                _passwordController.text),
                            child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Text("Sign Up")))))
              ]),
          // Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Have an account?",
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
              new InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, "YourRoute");
                  widget.authenticationActionFunction();
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
        ],
      ),
    );
  }
}
