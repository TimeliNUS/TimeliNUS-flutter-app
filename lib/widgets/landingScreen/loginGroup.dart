import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/landingScreen/formInput.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/textWithAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginGroup extends StatefulWidget {
  final authenticationActionFunction;
  const LoginGroup(this.authenticationActionFunction);

  @override
  State<StatefulWidget> createState() {
    return LoginGroupState();
  }
}

class LoginGroupState extends State<LoginGroup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isRemembered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 45, right: 45),
      child: Column(
        children: [
          Text("To continue your access",
              style: TextStyle(color: Colors.white)),
          Image(
            image: AssetImage("assets/images/loginScreen/login.png"),
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          getEmailInput(_emailController),
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
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
            InkWell(
                onTap: () => setState(() => isRemembered = !isRemembered),
                child: Text("Remember me", style: ThemeTextStyle.defaultText)),
            Expanded(
                child: Text(
              "Forgot Password?",
              style: ThemeTextStyle.defaultText,
              textAlign: TextAlign.right,
            ))
          ]),
          wideActionButton(
              "Login",
              () => FirebaseService.login(
                  _emailController.text, _passwordController.text)),
          textWithAction("Don't have an account?", "Create here",
              () => widget.authenticationActionFunction())
        ],
      ),
    );
  }
}
