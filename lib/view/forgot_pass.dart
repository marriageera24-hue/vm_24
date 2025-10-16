import 'package:flutter/material.dart';
import 'package:vm_24/widgets/formfields.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key, required this.title});
  final String title;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ForgotPassState();
  }
}

class ForgotPassState extends State<ForgotPass> {
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
                  SizedBox(height: 30.0),
                  formFieldTextLogin("Email/Mobile", "username"),
                  SizedBox(height: 25.0),
                  formFieldTextLogin("New Password", "password",
                      isPassword: true),
                  SizedBox(
                    height: 20.0,
                  ),
                  submitButton(context, "Update Password"),
                  SizedBox(height: height * .14),
                ],
              ),
            ),
          ),
        )));
  }
}
