import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:TimeliNUS/widgets/actionButton.dart';
import 'package:TimeliNUS/widgets/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/textWithAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterGroup extends StatefulWidget {
  final authenticationActionFunction;
  const RegisterGroup(this.authenticationActionFunction);
  @override
  State<StatefulWidget> createState() {
    return RegisterGroupState();
  }
}

class RegisterGroupState extends State<RegisterGroup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isRemembered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 45, right: 45),
      child: Column(
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
            InkWell(
                onTap: () => setState(() => isRemembered = !isRemembered),
                child: Text("Remember me", style: ThemeTextStyle.defaultText))
          ]),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          wideActionButton(
              "Sign Up",
              () => FirebaseService.register(
                  _emailController.text, _passwordController.text)),
          textWithAction("Have an account?", "Sign in here",
              () => widget.authenticationActionFunction()),
        ],
      ),
    );
  }
}
