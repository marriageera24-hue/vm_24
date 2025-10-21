import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vm_24/firebase_msg.dart';
import 'package:vm_24/view/desired_partner.dart';
import 'package:vm_24/view/forgot_pass.dart';
import 'package:vm_24/view/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vm_24/app_config.dart';
import 'package:vm_24/view/profile.dart';
import 'package:vm_24/view/profile_view.dart';
import 'package:vm_24/view/signup.dart';
import 'package:vm_24/widgets/dialog.dart';
import 'package:vm_24/services/phone_verification_service.dart';

final GlobalKey<State> _keyLoader = GlobalKey<State>();
bool _isAccepted = false;
// 🔑 NEW: Global state for phone verification
bool _isPhoneVerified = false; 
final PhoneVerificationService _verificationService = PhoneVerificationService();
String? _verifiedPhoneNumber;

Map<String, TextEditingController> _fieldController = {
  'first_name': TextEditingController(text: ''),
  'middle_name': TextEditingController(text: ''),
  'last_name': TextEditingController(text: ''),
  'phone': TextEditingController(text: ''),
  'email': TextEditingController(text: ''),
  'password': TextEditingController(text: ''),
  'username': TextEditingController(text: ''),
  'address_1': TextEditingController(text: ''),
  'city': TextEditingController(text: ''),
  'region_code': TextEditingController(text: ''),
  'district': TextEditingController(text: ''),
  'postal_code': TextEditingController(text: ''),
  'height': TextEditingController(text: ''),
  'weight': TextEditingController(text: ''),
  'income': TextEditingController(text: ''),
  'service': TextEditingController(text: ''),
  'alternateContact': TextEditingController(text: ''),
  'otp_code': TextEditingController(text: ''),
};

Map<String, String> rbValues = {
  'gender': '0',
  'physicallyChallenged': '0',
  'drinking': '0',
  'smoking': '0',
  'food': '0',
  'partnerGender': '0',
};

Map resList={};
var date;
var time;
var bod;

// Country _selected;
//class _FormFieldsState extends State<FormFields> {
Widget _title(BuildContext context) {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      text: 'Vadar Matrimony',
      style: GoogleFonts.portLligatSans(
        textStyle: Theme.of(context).textTheme.displayLarge,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: const Color(0xffe46b10),
      ),
    ),
  );
}

Widget subtitle(BuildContext context) {
  return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        text: 'Supported By Vijay Chougule',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ));
}

Widget formFieldTextLogin(String title, String field,
    {bool isPassword = false, int lines = 1}) {
  //_fieldController[field].text = value;
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          obscureText: isPassword,
          maxLines: lines,
          decoration: const InputDecoration(
            border: InputBorder.none,
            fillColor: Color(0xfff3f3f4),
            filled: true,
          ),
          keyboardType:
              title == "Mobile" ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            title == "Mobile"
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.deny(RegExp(r'[/\\]')),
            title == "Mobile"
                ? LengthLimitingTextInputFormatter(10)
                : LengthLimitingTextInputFormatter(-1),
          ], // Only numbers can be entered
          controller: _fieldController[field],
          validator: (value) {
            if (title == "Email" &&
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(title)) {
              return 'This is not a valid email';
            }
            if (title == "Mobile" && !RegExp(r"[0-9]{10}").hasMatch(title)) {
              return 'This is not a valid phone number';
            }
            return title;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {},
        )
      ],
    ),
  );
}

Widget formFieldText(String title, String field,
    {String multiIndex = "", bool isPassword = false, int lines = 1}) {
  if (multiIndex.isEmpty) {
    _fieldController[field] =
        TextEditingController(text: Profile.resList[field].toString());
  } else if (Profile.resList[multiIndex] != null) {
    _fieldController[field] = TextEditingController(
        text: Profile.resList[multiIndex][field].toString());
  }
  //_fieldController[field].text = value;
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          obscureText: isPassword,
          maxLines: lines,
          decoration: const InputDecoration(
            border: InputBorder.none,
            fillColor: Color(0xfff3f3f4),
            filled: true,
          ),
          keyboardType:
              (title == "Contact Number" || title == "Alternate Contact Number")
                  ? TextInputType.number
                  : TextInputType.text,
          inputFormatters: [
            (title == "Contact Number" || title == "Alternate Contact Number")
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.deny(RegExp(r'[/\\]')),
            (title == "Contact Number" || title == "Alternate Contact Number")
                ? LengthLimitingTextInputFormatter(10)
                : LengthLimitingTextInputFormatter(-1),
          ], // Only numbers can be entered
          controller: _fieldController[field],
          // validator: (String value) {
          //   if (title == "Email" &&
          //       !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
          //           .hasMatch(value)) {
          //     return 'This is not a valid email';
          //   } else if (value.isEmpty) {
          //     return "Please enter$title";
          //   }
          //   return value;
          // },
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            if (multiIndex.isEmpty) {
              Profile.resList[field] = _fieldController[field]?.text;
            } else {
              Profile.resList[multiIndex][field] = _fieldController[field]?.text;
            }
          },
          onFieldSubmitted: (value) {
            if (multiIndex.isEmpty) {
              Profile.resList[field] = _fieldController[field]?.text;
            } else {
              Profile.resList[multiIndex][field] = _fieldController[field]?.text;
            }
          },
        )
      ],
    ),
  );
}

Widget profileDateTime(String title,
    {String format = "dd-MM-yyyy", bool isDate = true}) {
  DateTime dateValue = DateTime.parse('2000-12-30 11:33');
  bod = dateValue;
  time = dateValue;
  if (Profile.resList['date_of_birth'] != "" &&
      Profile.resList['other_info'] != null) {
    bod = Profile.resList['date_of_birth'].toString();
    String dateWithT = '';
    if (Profile.resList['other_info']['bot'] != "null") {
      time = Profile.resList['other_info']['bot'].toString();
      dateWithT = '${bod.toString().substring(0, 10)}T${time.substring(11, 16)}';
    } else {
      dateWithT = '${bod.toString().substring(0, 10)}T${bod.toString().substring(11, 16)}';
    }
    dateValue = DateTime.parse(dateWithT);
  }
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(
          height: 10,
        ),
        DateTimeField(
          format: DateFormat(format),
          obscureText: false,
          initialValue: dateValue,
          decoration: const InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true),
          onShowPicker: (context, dateValue) async {
            if (isDate) {
              date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: dateValue ?? DateTime.now(),
                  lastDate: (DateTime.now()));
              return date;
            } else {
              time = await showTimePicker(
                context: context,
                initialTime:
                    TimeOfDay.fromDateTime(dateValue ?? DateTime.now()),
              );
              time = DateTimeField.convert(time);
              return time;
            }
          },
          onChanged: (value) {
            if (isDate) {
              Profile.resList['date_of_birth'] = value;
              bod = value;
            } else {
              Profile.resList['other_info']['bot'] = value;
              time = value;
            }
          },
        )
      ],
    ),
  );
}

Widget profileRadioButtons(String title, String index,
    {String r1 = "Yes", String r2 = "No", String multiIndex = ''}) {
  //final ValueChanged _onChanged = (val) => rbValues[index];
  String selected = '1';
  if (multiIndex.isEmpty) {
    selected = Profile.resList[index];
  } else if (Profile.resList.isNotEmpty &&
      Profile.resList[multiIndex] != null) {
    selected = Profile.resList[multiIndex][index];
  }
  if (selected == 'null' || selected.isEmpty) {
    selected = "1";
  }
  if (index == "partnerGender" && Profile.resList['gender'] == 1) {
    selected = "0";
  }
  rbValues[index] = selected;
  // Default Radio Button Selected Item When App Starts.
  //String radioButtonItem = r1;

  // Group Value for Radio Button.
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(
          height: 10,
        ),
        
        FormBuilderRadioGroup(
          //attribute: 'radio_group',
          initialValue: selected.toString(),
          //decoration: const InputDecoration(labelText: 'Radio Group'),
          onChanged: (value) {
            rbValues[index] = value.toString();
            if (multiIndex.isEmpty) {
              Profile.resList[index] = value.toString();
            } else {
              Profile.resList[multiIndex][index] = value.toString();
            }
          },
          options: [
            FormBuilderFieldOption(value: "0", child: Text(r1)),
            FormBuilderFieldOption(value: "1", child: Text(r2)),
          ], name: '',
        ),
      ],
    ),
  );
}

// Widget countryList(String title) {
//   return Container(
//     margin: EdgeInsets.symmetric(vertical: 10),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           title,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//         ),
//         Container(
//           padding: EdgeInsets.all(10),
//           child: CountryPicker(
//             showDialingCode: true,
//             onChanged: (Country country) {
//               //setState(() {
//               _selected = country;
//               //});
//             },
//             selectedCountry: _selected,
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget submitButton(BuildContext context, String title) {
  return InkWell(
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)])),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
    onTap: () {
      if (title == "Signup" || title == "Update Profile" || title == "Update Password") {
        final phone = "+91${_fieldController['phone']?.text.trim()}";
        // if (!_isPhoneVerified) {
          // If NOT verified, initiate the verification process (sends OTP)
          _handlePhoneVerification(context, title);
        // } else {
          // 🔑 2. If already verified, proceed with the custom registration API call
        //   Dialogs.showLoadingDialog(context, _keyLoader);
        //   _performAction(context, title); // This is your existing registration call
        // }
      } else {
         Dialogs.showLoadingDialog(context, _keyLoader);
        _performAction(context, title);
      }
    },
  );
}

Widget formLabel1(BuildContext context, String action) {
  String label1 = 'Don\'t have an account ?';
  String label2 = 'Register';
  var actionClass = const Signup(key:null, title: '');
  return InkWell(
    onTap: () {
      _isAccepted = false;
      _showTermsAndConditions(context);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              label1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Center(
            child: Text(
              label2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xfff79c4f),
                  decorationThickness: 1.5),
            ),
          )
        ],
      ),
    ),
  );
}

Widget formLabel2(BuildContext context, String action) {
  String label = 'Forgot Password';
  var actionClass = const ForgotPass(key: null, title: '',);

  return InkWell(
    onTap: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => actionClass));
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xfff79c4f),
                  decorationThickness: 1.5),
            ),
          )
        ],
      ),
    ),
  );
}

void _performAction(BuildContext context, String title) async {
  final config = await AppConfig.forEnvironment("prod");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map data = {};
  String url = "";
  String imgUrl = "";
  String successMessage = "";
  dynamic actionClass = ProfileView();

  switch (title) {
    case "Login":
      successMessage =
          "You logged In Successfully. Please Complete your Profile";

      data = {
        'username': _fieldController['username']?.text,
        'password': _fieldController['password']?.text
      };
      url = "${config.apiUrl}/users/login/password";
      //actionClass = Profile();
      break;

    case "Update Password":
      actionClass = const LoginPage();
      successMessage = "Password has been Updated Successfully.";
      data = {
        'username': _fieldController['username']?.text,
        'password': _fieldController['password']?.text
      };
      url = "${config.apiUrl}/users/reset";
      break;

    case "Signup":
      // 🔑 CRITICAL FIX: Ensure registration only uses the VERIFIED number
      if (_verifiedPhoneNumber == null || _verifiedPhoneNumber!.isEmpty) {
         Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); // Dismiss loading
         showAlert(context, "Verification state lost. Please verify your phone number again.", Signup(key:null, title: ''));
         return; // STOP the registration process
      }
      actionClass = Profile();
      data = {
        'first_name': _fieldController['first_name']?.text,
        'last_name': _fieldController['last_name']?.text,
        'email': _fieldController['email']?.text,
        'phone': _verifiedPhoneNumber!,
        'password': _fieldController['password']?.text
      };
      url = "${config.apiUrl}/users/register";
      successMessage =
          "You have registered Successfully. Please Complete your Profile";
      break;
    case "Update Profile":
      String uuid = prefs.get("uuid").toString();
      Map proInfo = {
        'education': Profile.myActivity['education'],
        'profession': Profile.myActivity['profession'],
        'income': _fieldController['income']?.text,
        'service': _fieldController['service']?.text
      };
      Map partnerInfo = {
        'partnerGender': rbValues['gender'].toString() == "0" ? "1" : "0",
        'age': Profile.myActivity['age'],
        'partnerStatus': Profile.myActivity['partnerStatus'],
        'partnerSubcast': Profile.myActivity['partnerSubcast'],
        'partnerEducation': Profile.myActivity['partnerEducation']
      };
      Map otherInfo = {
        'bot': time.toString(),
        'gotra': Profile.myActivity['gotra'],
        'district': _fieldController['district']?.text,
        'alternateContact': _fieldController['alternateContact']?.text,
        'physicallyChallenged': rbValues['physicallyChallenged'],
        'height': _fieldController['height']?.text,
        'weight': _fieldController['weight']?.text,
        'complexion': Profile.myActivity['complexion'],
        'bg': Profile.myActivity['bg'],
        'drinking': rbValues['drinking'],
        'smoking': rbValues['smoking'],
        'food': rbValues['food'],
        'fcmToken': FirebaseMsg.token
      };
      data = {
        'uuid': uuid,
        'first_name': _fieldController['first_name']?.text,
        'middle_name': _fieldController['middle_name']?.text,
        'last_name': _fieldController['last_name']?.text,
        'email': _fieldController['email']?.text,
        'phone': _fieldController['phone']?.text.trim(),
        'gender': rbValues['gender'].toString(),
        'date_of_birth': bod.toString(),
        'marital_status': Profile.myActivity['marital_status'].toString(),
        'sub_caste': Profile.myActivity['sub_caste'].toString(),
        'job_title': 'test',
        'address_1': _fieldController['address_1']?.text,
        'city': _fieldController['city']?.text,
        'State': _fieldController['State']?.text,
        'country': Profile.myActivity['country'].toString(),
        'postal_code': _fieldController['postal_code']?.text,
        'profile_created_by': Profile.status.toString(),
        'unsubscribed': false,
        'educationl_info': proInfo,
        'family_info': partnerInfo,
        'other_info': otherInfo
      };
      url = "${config.apiUrl}/users/me";
      imgUrl = "${config.apiUrl}/users/media/profile/0/";
      if (Profile.resList.containsKey('user_media')) {
        RegExp regExp = RegExp(r'(uuid:\s+(.*?)\,)',
            caseSensitive: false, multiLine: false);
        if (regExp.hasMatch(Profile.resList['user_media'].toString())) {
          String? userId =
              regExp.stringMatch(Profile.resList['user_media'].toString());
          userId = userId?.replaceFirst("uuid: ", "");
          userId = userId?.replaceFirst(",", "");
          // ignore: prefer_interpolation_to_compose_strings
          imgUrl = config.apiUrl + "/users/media/profile/" + userId.toString();
        }
      }
      successMessage = "Cograst!! Profile is completed Successfully.";

      break;
    default:
  }
  HttpClient client = HttpClient();
  String token = '';
  HttpClientRequest request;

  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);
  if (title == "Update Profile") {
    String userToken = prefs.get("token").toString();

    request = await client.patchUrl(Uri.parse(url));

    request.headers.set('content-type', 'application/json');
    request.headers.set('Accept-Language', 'en-US,en;q=0.9');
    request.headers.set('Authorization', 'Bearer $userToken');
    // if (Profile.imgPath != "") {
    //   var imgrequest = http.MultipartRequest('POST', Uri.parse(imgUrl));
    //   imgrequest.files
    //       .add(await http.MultipartFile.fromPath('pics', Profile.imgPath));
    //   imgrequest.headers.addAll({
    //     'Authorization': 'Bearer $userToken',
    //     'Content-Type': 'multipart/form-data',
    //     'Accept-Language': 'en-US,en;q=0.9'
    //   });

    //   var imgresponse = await imgrequest.send();
    //   imageCache.clear();
    // }
  } else {
    request = await client.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  }

  request.add(utf8.encode(json.encode(data)));

  HttpClientResponse response = await request.close();
  var result = StringBuffer();

  String reply = '';
  // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  if (response.statusCode == 200) {
    await for (var contents in response.transform(const Utf8Decoder())) {
      result.write(contents);
    }
    if (title != "Update Password") {
      Map<String, dynamic> resList = jsonDecode(result.toString());
      if (title != "Update Profile") {
        saveLoginState(resList['user']['uuid']);
        prefs.setString("uuid", resList['user']['uuid']);
        prefs.setString("token", resList["token"]);
      }
    }
    if (title == 'Login') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => actionClass));
    } else {
       showAlert(context, successMessage, actionClass);
    }
  } else {
    if (title == 'Login') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
    reply = await response.transform(utf8.decoder).join();
     showAlert(context, reply, '');
  }
}

void showAlert(BuildContext context, String message, var actionClass) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
              //title: Text("Wifi"),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    if (actionClass != "") {
                      //Put your code here which you want to execute on Yes button click.
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => actionClass));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ]));
}

void _showTermsAndConditions(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    builder: (BuildContext dialogContext) {
      bool dialogIsAccepted = _isAccepted; // Use a local variable for the dialog's state

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Terms and Conditions'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text(
                    "We are Just helping you to find your desire partner. \n It's your sole resposibilty to validate a profile. \n We are not responsible for any further conconsequences.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: dialogIsAccepted,
                        onChanged: (bool? newValue) {
                          setState(() {
                            dialogIsAccepted = newValue!;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I have read and agree to the Terms and Conditions.',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Decline'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dialogIsAccepted ? Colors.blue : Colors.grey,
                ),
                onPressed: dialogIsAccepted
                    ? () {
                        setState(() {
                          _isAccepted = true;
                        });
                        Navigator.of(dialogContext).pop();
                        // Proceed to the registration form
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup(key:null, title: '')));
                      }
                    : null, // Button is disabled if not accepted
                child: const Text('Accept'),
              ),
            ],
          );
        },
      );
    },
  );
}

// On successful login
Future<void> saveLoginState(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('userId', userId);
}

// 🔑 NEW: Function to show the OTP input dialog
void _showOtpInputDialog(BuildContext context, String phoneNumber, String title) {
  final TextEditingController otpController = TextEditingController();
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Enter OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // 1. Text message
          Text(
            'A code has been sent to $phoneNumber',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),

          // 2. TextFormField with the local controller
          TextFormField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6, // Standard OTP length
            decoration: const InputDecoration(
              labelText: 'OTP Code',
              border: OutlineInputBorder(), // Use a standard border for clarity
              filled: true,
              fillColor: Color(0xfff3f3f4),
              counterText: "", // Hide the default character counter
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allows numbers
            ],
          ),
        ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: const Text('VERIFY'),
            onPressed: () async {
              Dialogs.showLoadingDialog(dialogContext, _keyLoader);
              final smsCode = otpController.text.trim();
              
              // Call the service to verify the code and sign out
              final success = await _verificationService.verifyAndSignOut(
                smsCode: smsCode,
              );
              
              Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); // Dismiss loading dialog
              Navigator.of(dialogContext).pop(); // Dismiss OTP dialog

              if (success) {
                // 🔑 CRITICAL FIX: Store the successfully verified number
                _verifiedPhoneNumber = _fieldController['phone']?.text.trim();
                // Set the global flag to allow registration
                _isPhoneVerified = true;
                //showAlert(context, "Phone number verified! You are now registered.", '');
                 _performAction(context, title);
                // OPTIONAL: Make the phone number field read-only now
                _fieldController['phone']?.text = _verifiedPhoneNumber!;
              } else {
                _isPhoneVerified = false;
                _verifiedPhoneNumber = null;
                showAlert(context, "Invalid OTP. Please try again.", Signup(key:null, title: ''));
              }
            },
          ),
        ],
      );
    },
  );
}

// 🔑 NEW: Function to initiate the OTP process
void _handlePhoneVerification(BuildContext context, String title) async {
  // Ensure the phone number is 10 digits and has a country code prefix (e.g., +91)
  final rawPhone = _fieldController['phone']?.text.trim() ?? '';
  final phoneNumber = "+91$rawPhone"; // Assuming Indian numbers

  if (!RegExp(r"^\+?[0-9]{10,15}$").hasMatch(phoneNumber)) {
    showAlert(context, "Please enter a valid phone number with country code (e.g., +91).", Signup(key:null, title: ''));
    return;
  }
  
  Dialogs.showLoadingDialog(context, _keyLoader);

  await _verificationService.sendOtp(
    phoneNumber: phoneNumber,
    codeSentCallback: (verId, resendToken) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); // Dismiss loading dialog
      if (verId == "AUTO_VERIFIED") {
        // Android auto-verified, proceed directly to registration allowance
        _isPhoneVerified = true;
        showAlert(context, "Phone number automatically verified! You can now register.", Signup(key:null, title: ''));
      } else {
        // Code sent via SMS, show the input dialog
        _showOtpInputDialog(context, phoneNumber, title);
      }
    },
    verificationFailedCallback: (e) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); // Dismiss loading dialog
      showAlert(context, "Verification Failed: ${e.message}", Signup(key:null, title: ''));
    },
  );
}