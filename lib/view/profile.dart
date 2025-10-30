import 'package:flutter/material.dart';
import 'package:vadar_marriage_era/view/payment.dart';
import 'package:vadar_marriage_era/widgets/formfields.dart';
import 'package:vadar_marriage_era/widgets/modelActions.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:vadar_marriage_era/widgets/image_dialog.dart';

class 
Profile extends StatefulWidget {
  Profile({super.key, this.title = ''});
  final String title;
  static Map<String, String> myActivity = {};
  static Map resList = {};
  static bool status = false;
  static String imgPath = "";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileState();
  }
}

 Future userData = Future.value();

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Profile.myActivity = {
      'marital_status': '',
      'partnerStatus': '',
      'sub_caste': '',
      'partnerSubcast': '',
      'gotra': '',
      'education': '',
      'partnerEducation': '',
      'profession': '',
      'complexion': '',
      'bg': '',
      'country': '',
      'age': ''
    };
    userData = getProfileData();
    Profile.resList = {};
    Profile.imgPath = '';
  }

  dynamic _image;
  late Directory _appDocsDir;
  final ImagePicker _picker = ImagePicker();
  _imgFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    // _cropImage(image.path);
    Profile.imgPath = image!.path;
    setState(() {
      _image = File(image.path);
    });
  }

  _imgFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    Profile.imgPath = image!.path;
    //_cropImage(image.path);
    setState(() {
      _image = File(image.path);
    });
  }

  /// Crop Image
  // _cropImage(filePath) async {
  //   File croppedImage = await ImageCropper.cropImage(
  //     sourcePath: filePath,
  //   );
  //   setState(() {
  //     _image = croppedImage;
  //   });
  //   }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  File fileFromDocsDir(String filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  Widget profileDropdownList(String activityIndex, String title, List<DropdownMenuItem<String>> itemList,
      {String multiIndex = ''}) {
    if (multiIndex.isEmpty) {
      Profile.myActivity[activityIndex] = Profile.resList[activityIndex];
    } else if (Profile.resList[multiIndex] != null) {
      Profile.myActivity[activityIndex] =
          Profile.resList[multiIndex][activityIndex];
    }
    if (Profile.myActivity[activityIndex] == 'null' ||
        Profile.myActivity[activityIndex]!.isEmpty) {
      Profile.myActivity[activityIndex] = "0";
      if (activityIndex == "country") {
        Profile.myActivity[activityIndex] = "IN";
      }
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
          Container(
            padding: const EdgeInsets.all(10),
            child: DropdownButtonFormField(
              hint: const Text('Select'),
              value: Profile.myActivity[activityIndex],
              validator: (value) {
                if (value == null) {
                  return "Select $activityIndex";
                }
                return value;
              },
              onSaved: (value) {
                //setState(() {
                if (multiIndex.isEmpty) {
                  Profile.resList[activityIndex] = value;
                } else if (Profile.resList[multiIndex] != null) {
                  Profile.resList[multiIndex][activityIndex] = value;
                } else {
                  Profile.myActivity[activityIndex] = value!;
                }

                //});
              },
              onChanged: (value) {
                setState(() {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (multiIndex.isEmpty) {
                    Profile.resList[activityIndex] = value;
                  } else if (Profile.resList[multiIndex] != null) {
                    Profile.resList[multiIndex][activityIndex] = value;
                  } else {
                    Profile.myActivity[activityIndex] = value!;
                  }
                });
              },
              items: itemList,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder<dynamic>(
        future: userData,
        builder: (context, data) {
          if (data.connectionState == ConnectionState.done) {
            if (Profile.resList.isEmpty) {
              Profile.resList = jsonDecode(data.data);
            }
            Profile.status = false;
            if (Profile.resList['profile_created_by'] == "true") {
              Profile.status = true;
            }
            RegExp regExp = RegExp(r'(https://.*?.(png|jpg|jpeg))',
                caseSensitive: false, multiLine: false);
            return Stack(
              children: <Widget>[
                //Positioned(top: 40, left: 0, child: _backButton()),
                Container(
                  height: height,
                  padding: const EdgeInsets.all(36.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //SizedBox(height: height * .2),

                        const SizedBox(height: 45.0),
                        Image.asset(
                          "assets/images/Vadar Matri.png",
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 50,
                            ),
                            const Text(
                              "Self Registered",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.grey),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Switch(
                              activeColor: Colors.blueAccent,
                              value: Profile.status,
                              onChanged: (value) {
                                setState(() {
                                  Profile.status = value;
                                  Profile.resList['profile_created_by'] =
                                      value.toString();
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 25,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _showPicker(context);
                            },
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(
                                        _image,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      width: 100,
                                      height: 100,
                                      child: (regExp.hasMatch(Profile
                                              .resList['user_media']
                                              .toString()))
                                          ? loadImage(
                                              Profile.resList['user_media']
                                                  .toString(),
                                              isCached: false)
                                          : Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey[800],
                                            ),
                                    ),
                            ),
                          ),
                        ),
                        //width: 100,
                        Image.asset(
                          "assets/images/Basic Information.png",
                          //fit: BoxFit.cover,
                          height: 100,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("First Name", "first_name"),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Middle Name", "middle_name"),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Last Name", "last_name"),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDateTime("Birth Date"),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDateTime("Birth Time",
                            format: "HH:mm", isDate: false),
                        const SizedBox(
                          height: 20,
                        ),
                        profileRadioButtons("Gender", "gender",
                            r1: "Male", r2: "Female"),
                        profileDropdownList(
                            "marital_status", "Marital Status", [
                          const DropdownMenuItem(value: "0", child: Text("Never Married")),
                          const DropdownMenuItem(value: "1", child: Text("Divorce in process")),
                          const DropdownMenuItem(value: "2", child: Text("Divorced")),
                          const DropdownMenuItem(value: "3", child: Text("Widowed"))
                        ]),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList("sub_caste", "SubCaste", [
                          const DropdownMenuItem(value: "0", child: Text("Gadi Vadar")),
                          const DropdownMenuItem(value: "1", child: Text("Mati Vadar")),
                          const DropdownMenuItem(value: "2", child: Text("Dagadi Vadar")),
                          const DropdownMenuItem(value: "3", child: Text("Jati Vadar")),
                          const DropdownMenuItem(value: "4", child: Text("Pathrut Vadar")),
                        ]),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList(
                            "gotra",
                            "Gotra",
                            [
                              const DropdownMenuItem(value: "0", child: Text("Aalkuntor")),
                              const DropdownMenuItem(value: "1", child: Text("Bakkalor")),
                              const DropdownMenuItem(value: "2", child: Text("Bathulor")),
                              const DropdownMenuItem(value: "3", child: Text("Dandagolar")),
                              const DropdownMenuItem(value: "4", child: Text("Dyarangalor")),
                              const DropdownMenuItem(value: "5", child: Text("Eragadindalor")),
                              const DropdownMenuItem(value: "6", child: Text("Fallyafor")),
                              const DropdownMenuItem(value: "7", child: Text("Fandipattor")),
                              const DropdownMenuItem(value: "8", child: Text("Faplor")),
                              const DropdownMenuItem(value: "9", child: Text("Finchguttor")),
                              const DropdownMenuItem(value: "10", child: Text("Fitlor")),
                              const DropdownMenuItem(value: "11", child: Text("Godyalor")),
                              const DropdownMenuItem(value: "12", child: Text("Gogalor")),
                              const DropdownMenuItem(value: "13", child: Text("Gunjalor")),
                              const DropdownMenuItem(value: "14", child: Text("Hidagator")),
                              const DropdownMenuItem(value: "15", child: Text("Kunchafor")),
                              const DropdownMenuItem(value: "16", child: Text("Manjalor")),
                              const DropdownMenuItem(value: "17", child: Text("Mudagulor")),
                              const DropdownMenuItem(value: "18", child: Text("Nakkalor")),
                              const DropdownMenuItem(value: "19", child: Text("Ralhor")),
                              const DropdownMenuItem(value: "20", child: Text("Sampangor")),
                              const DropdownMenuItem(value: "21", child: Text("Satlor")),
                              const DropdownMenuItem(value: "22", child: Text("Vallafor")),
                              const DropdownMenuItem(value: "23", child: Text("Yamlor")),
                              const DropdownMenuItem(value: "24", child: Text("Other")),
                            ],
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        Image.asset(
                          "assets/images/Professional Information.png",
                          //fit: BoxFit.cover,
                          height: 100,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList(
                            "education",
                            "Highest Education",
                            [
                              const DropdownMenuItem(value: "0", child: Text("B.E/B.Tech")),
                              const DropdownMenuItem(value: "1", child: Text("M.E/M.Tech")),
                              const DropdownMenuItem(value: "2", child: Text("B.SC")),
                              const DropdownMenuItem(value: "3", child: Text("B.com")),
                              const DropdownMenuItem(value: "4", child: Text("B.A.")),
                              const DropdownMenuItem(value: "5", child: Text("C.A.")),
                              const DropdownMenuItem(value: "6", child: Text("B.C.A.")),
                              const DropdownMenuItem(value: "7", child: Text("M.C.A.")),
                              const DropdownMenuItem(value: "8", child: Text("B.B.A.")),
                              const DropdownMenuItem(value: "9", child: Text("M.B.A.")),
                              const DropdownMenuItem(value: "10", child: Text("M.B.B.S")),
                              const DropdownMenuItem(value: "11", child: Text("B.A.M.S")),
                              const DropdownMenuItem(value: "12", child: Text("M.D")),
                              const DropdownMenuItem(value: "13", child: Text("B.Pharma")),
                              const DropdownMenuItem(value: "14", child: Text("P.HD")),
                              const DropdownMenuItem(value: "15", child: Text("L.L.B.")),
                              const DropdownMenuItem(value: "16", child: Text("Diploma")),
                              const DropdownMenuItem(value: "17", child: Text("B.Ed")),
                              const DropdownMenuItem(value: "18", child: Text("D.Ed")),
                              const DropdownMenuItem(value: "19", child: Text("ITI")),
                              const DropdownMenuItem(value: "20", child: Text("H.S.C.")),
                              const DropdownMenuItem(value: "21", child: Text("S.S.C.")),
                              const DropdownMenuItem(value: "22", child: Text("Below S.S.C.")),
                              const DropdownMenuItem(value: "23", child: Text("Not Educated")),
                              const DropdownMenuItem(value: "24", child: Text("Other")),
                            ],
                            multiIndex: 'educationl_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList(
                            "profession",
                            "Profession",
                            [
                              const DropdownMenuItem(value: "0", child: Text("Business")),
                              const DropdownMenuItem(value: "1", child: Text("Goverment Service")),
                              const DropdownMenuItem(value: "2", child: Text("Private Service")),
                              const DropdownMenuItem(value: "3", child: Text("Not Working")),
                            ],
                            multiIndex: 'educationl_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Monthly Income (Rupees)", "income",
                            multiIndex: 'educationl_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Business/Service Details", "service",
                            isPassword: false,
                            lines: 4,
                            multiIndex: 'educationl_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        Image.asset(
                          "assets/images/Contact Information.png",
                          //fit: BoxFit.cover,
                          height: 100,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Address", "address_1"),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("City/Town", "city"),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("District", "district",
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("State", "State"),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList("country", "Country", [
                          const DropdownMenuItem(value: "IN", child: Text("India")),
                          const DropdownMenuItem(value: "US", child: Text("America")),
                          const DropdownMenuItem(value: "UK", child: Text("England")),
                          const DropdownMenuItem(value: "DE", child: Text("Germany")),
                          const DropdownMenuItem(value: "FR", child: Text("France")),
                          const DropdownMenuItem(value: "RU", child: Text("Russia")),
                          const DropdownMenuItem(value: "AU", child: Text("Austrelia")),
                          const DropdownMenuItem(value: "JP", child: Text("Japan")),
                          const DropdownMenuItem(value: "Other", child: Text("Other")),
                        ]),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Postal Code", "postal_code"),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Contact Number", "phone"),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText(
                            "Alternate Contact Number", "alternateContact",
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Email id", "email"),
                        const SizedBox(
                          height: 20,
                        ),
                        Image.asset(
                          "assets/images/Physical Information.png",
                          //fit: BoxFit.cover,
                          height: 100,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        profileRadioButtons(
                            "Physically Challeged", "physicallyChallenged",
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Height (feet)", 'height',
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        formFieldText("Weight(Kg)", "weight",
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList(
                            "complexion",
                            "Complexion",
                            [
                              const DropdownMenuItem(value: "0", child: Text("Fair")),
                              const DropdownMenuItem(value: "1", child: Text("Wheat")),
                              const DropdownMenuItem(value: "2", child: Text("Wheat Brown")),
                              const DropdownMenuItem(value: "3", child: Text("Dark "))
                            ],
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        profileDropdownList(
                            "bg",
                            "Blood Group",
                            [
                              const DropdownMenuItem(value: "0", child: Text("A+ve")),
                              const DropdownMenuItem(value: "1", child: Text("A-ve")),
                              const DropdownMenuItem(value: "2", child: Text("B+ve")),
                              const DropdownMenuItem(value: "3", child: Text("B-ve ")),
                              const DropdownMenuItem(value: "4", child: Text("AB+ve")),
                              const DropdownMenuItem(value: "5", child: Text("AB-ve")),
                              const DropdownMenuItem(value: "6", child: Text("O+ve")),
                              const DropdownMenuItem(value: "7", child: Text("O-ve ")),
                            ],
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        profileRadioButtons("Drinking", "drinking",
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        profileRadioButtons("Smoking", "smoking",
                            multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        profileRadioButtons("Food", "food",
                            r1: "Veg", r2: "Non-Veg", multiIndex: 'other_info'),
                        const SizedBox(
                          height: 20,
                        ),
                        
                        const SizedBox(
                          height: 20,
                        ),
                        submitButton(context, "Update Profile"),
                        SizedBox(height: height * .14),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (data.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else{
            return const SizedBox();
          }
        },
      ),
    );
  }
}
