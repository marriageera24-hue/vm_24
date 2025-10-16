import 'package:flutter/material.dart';
import 'package:vm_24/widgets/formfields.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/Vadar Matri.png",
                    fit: BoxFit.contain,
                  ),
                  //Positioned(top: 40, child: _title()),

                  formLabel1(context, "signup"),
                  formFieldTextLogin("Email/Mobile", "username"),
                  formFieldTextLogin("Password", "password", isPassword: true),
                  submitButton(context, "Login"),
                  formLabel2(context, "forgotPass"),
                  SizedBox(height: height * .14),
                ],
              ),
            ),
          ),
        )));
  }
}
