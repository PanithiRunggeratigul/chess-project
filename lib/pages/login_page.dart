import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:project/utils.dart';

class LogInWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LogInWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LogInWidgetState createState() => _LogInWidgetState();
}

class _LogInWidgetState extends State<LogInWidget> {
  final emailController = TextEditingController();
  final passwordContoller = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordContoller.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 4),
            TextField(
              controller: passwordContoller,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              icon: Icon(Icons.lock_open, size: 32),
              label: Text(
                "Sign In",
                style: TextStyle(fontSize: 24),
              ),
              onPressed: signIn,
            ),
            SizedBox(height: 24),
            RichText(
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  text: "no account? ",
                  children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignUp,
                        text: "Sign Up",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary,
                        ))
                  ]),
            )
          ],
        ),
      );

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordContoller.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
