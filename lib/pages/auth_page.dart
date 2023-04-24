// import 'package:firebase_auth_email_ii/widget/login_widget';
// import 'package:firebase_auth_email_ii/widget/signup_widget';
import 'package:flutter/material.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/signup_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LogInWidget(onClickedSignUp: toggle)
      : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() {
        isLogin = !isLogin;
      });
}
