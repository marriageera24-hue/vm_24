import 'package:flutter/material.dart';
import 'package:vadar_marriage_era/widgets/formfields.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, required this.title});
  final String title;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignupState();
  }
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(36.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //SizedBox(height: height * .2),

                    SizedBox(height: 45.0),
                    Image.asset(
                      "assets/images/Vadar Matri.png",
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    formFieldTextLogin("First Name", "first_name"),
                    SizedBox(
                      height: 20,
                    ),
                    formFieldTextLogin("Last Name", "last_name"),
                    SizedBox(
                      height: 20,
                    ),
                    formFieldTextLogin("Mobile", "phone"),
                    SizedBox(
                      height: 20,
                    ),
                    formFieldTextLogin("Email", "email"),
                    SizedBox(
                      height: 20,
                    ),
                    formFieldTextLogin("Password", "password",
                        isPassword: true),
                    SizedBox(
                      height: 20,
                    ),
                    submitButton(context, "Signup"),
                    SizedBox(height: height * .14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
