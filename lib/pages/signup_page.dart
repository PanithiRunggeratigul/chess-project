import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:project/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordContoller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordContoller.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: "Email"),
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: passwordContoller,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? "Enter min. 6 characters"
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                icon: Icon(Icons.arrow_forward, size: 32),
                label: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: signUp,
              ),
              SizedBox(height: 24),
              RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    text: "Already have an account? ",
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickedSignIn,
                          text: "Log In",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).colorScheme.secondary,
                          ))
                    ]),
              )
            ],
          ),
        ),
      );

  Future signUp() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordContoller.text.trim(),
      );
      _firestore.collection("users").doc(_auth.currentUser!.uid).set({
        "uid": _auth.currentUser!.uid,
        "email": emailController.text.trim(),
        "status": "Online",
        "challengestatus": false,
      });
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
