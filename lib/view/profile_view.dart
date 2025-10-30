import 'package:flutter/material.dart';
import 'package:vadar_marriage_era/view/profile.dart';
import 'package:vadar_marriage_era/widgets/modelActions.dart';
import 'dart:convert';
import 'package:vadar_marriage_era/view/constants.dart';
import 'package:vadar_marriage_era/view/desired_partner.dart';
import 'package:vadar_marriage_era/view/payment.dart';
import 'package:vadar_marriage_era/view/shortlisted.dart';
import 'package:vadar_marriage_era/view/notification.dart';
import 'package:vadar_marriage_era/widgets/image_dialog.dart';
import 'package:vadar_marriage_era/widgets/dialog.dart';
import 'package:vadar_marriage_era/view/call_us.dart';

final GlobalKey<State> _keyLoader = GlobalKey<State>();

class ProfileView extends StatefulWidget {
  ProfileView({super.key, this.title = ''});
  final String title;
  static bool selfView = false;
  static bool isVisited = false;
  static Map <dynamic, dynamic> wallet = {};
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileViewState();
  }
}

class _ProfileViewState extends State<ProfileView> {
  final int _selectedIndex =
      PartnerView.partnerList.isNotEmpty ? PartnerView.selectedIndex : 4;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ProfileView.selfView = true;
    ProfileView.isVisited = false;
    if(PartnerView.userInterest == 'visited') ProfileView.isVisited = true;
    ProfileView.wallet = {};
  }

  void _onItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
      Widget widget = Container(); // default
      switch (index) {
        case 0:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NotificationView()));
          break;

        case 1:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ShortlistedView()));
          break;

        case 2:
          makePhoneCall();
          break;
        case 3:
          // showDialog(
          //     context: context,
          //     builder: (context) => AlertDialog(
          //             //title: Text("Wifi"),
          //             content: Container(
          //                 height: 150,
          //                 child: profileRadioButtons("Gender", "partnerGender",
          //                     r1: "Male",
          //                     r2: "Female",
          //                     multiIndex: 'family_info')),
          //             actions: <Widget>[
          //               FlatButton(
          //                 child: Text("OK"),
          //                 onPressed: () {
          //                   //Put your code here which you want to execute on Yes button click.
          //                   Navigator.push(
          //                       context,
          //                       new MaterialPageRoute(
          //                           builder: (context) => PartnerView()));
          //                 },
          //               ),
          //             ]));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PartnerView()));
          break;
        case 4:
          PartnerView.partnerList = {};
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfileView()));
          break;
      }
    });
  }

  Widget _editButton() {
    var type = 'interested';
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0),
              alignment: Alignment.topRight,
            ),
            Column(
              children: [
                !ProfileView.selfView
                    ? IconButton(
                        icon: Icon(Icons.favorite),
                        iconSize: 35,
                        color: ProfileView.isVisited
                            ? Colors.grey
                            : Colors.red,
                        onPressed: () {
                          setState(() {
                            if(ProfileView.isVisited){
                              ProfileView.isVisited = false;  
                            }
                            else{
                              ProfileView.isVisited = true;
                            }

                            ProfileAction(
                                context, PartnerView.partnerList['uuid'],
                                type: ProfileView.isVisited ? 'visited' : 'interested');
                          });
                        },
                      )
                    : const Text('Edit Profile',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return InkWell(
      onTap: () {
        Dialogs.showDeleteConfirmationDialog(context);
      },
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 0),
            alignment: Alignment.topRight,
          ),
          const Column(
            children: [
              Text('Delete',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent))
            ],
          )
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: () {
        Dialogs.showLoadingDialog(context, _keyLoader);
        logout(context, _keyLoader);
      },
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 0),
            alignment: Alignment.topRight,
          ),
          const Column(
            children: [
              Text('Logout',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent))
            ],
          )
        ],
      ),
    );
  }

  var resList;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    RegExp regExp = RegExp(r'(https://.*?.(png|jpg|jpeg))',
        caseSensitive: false, multiLine: false);

    return Scaffold(
      body: FutureBuilder<dynamic>(
        future: getProfileData(),
        builder: (context, data) {
          ProfileView.selfView =
              PartnerView.partnerList.isNotEmpty ? false : true;
          if (data.connectionState == ConnectionState.done) {
            resList = jsonDecode(data.data);
            Profile.resList = resList;
            
            if (!ProfileView.selfView) {
              resList = PartnerView.partnerList;
              // resList['user_wallet'] = {};
            }else{
              patchDeviceInfo(resList['other_info']);
              // ProfileView.wallet = resList['user_wallet'][0];
            }
            

            if (resList['other_info'] == null) {
              return Stack(children: <Widget>[
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

                          Row(children: [
                            Column(children: <Widget>[
                              _editButton(),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 180,
                                ),
                              ],
                            ),
                            ProfileView.selfView ? 
                            Column(children: <Widget>[
                              _deleteButton(),
                            ]) : 
                            Column(children: <Widget>[]),
                            
                            const Column(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),

                            ProfileView.selfView ? 
                            Column(children: <Widget>[
                              _logoutButton(),
                            ]) : 
                            Column(children: <Widget>[]), 
                          ]),
                          //width: 100,
                          Image.asset(
                            "assets/images/Basic Information.png",
                            //fit: BoxFit.cover,
                            height: 100,
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList["first_name"] +
                                      " " +
                                      resList["last_name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Contact No.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['phone'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Email",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                ),
                              ],
                            ),
                            Flexible(
                                child: Column(
                              children: [
                                Text(
                                  resList['email'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  softWrap: true,
                                ),
                              ],
                            )),
                          ]),
                          const SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            "assets/images/complete_profile_note.png",
                            //fit: BoxFit.cover,
                            height: 100,
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                        ])))
              ]);
            } else {
              return Stack(
                children: <Widget>[
                  //Positioned(top: 40, left: 0, child: _backButton()),
                  Container(
                    // color: Colors.white,
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
                          Row(children: [
                            Column(children: <Widget>[
                              _editButton(),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 130,
                                ),
                              ],
                            ),
                             ProfileView.selfView ? 
                            Column(children: <Widget>[
                              _deleteButton(),
                            ]) : 
                            Column(children: <Widget>[]),
                            
                            const Column(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),

                            ProfileView.selfView ? 
                            Column(children: <Widget>[
                              _logoutButton(),
                            ]) : 
                            Column(children: <Widget>[]), 
                          ]),
                          CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(50)),
                                width: 100,
                                height: 100,
                                child: GestureDetector(
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (_) => ImageDialog(
                                                imgUrl: regExp.hasMatch(
                                                        resList['user_media']
                                                            .toString())
                                                    ? regExp.stringMatch(
                                                        resList['user_media']
                                                            .toString())
                                                    : '',
                                                isCachedImage:
                                                    ProfileView.selfView
                                                        ? false
                                                        : true,
                                              ));
                                    },
                                    child: (regExp.hasMatch(
                                            resList['user_media'].toString()))
                                        ? loadImage(
                                            resList['user_media'].toString(),
                                            isCached: ProfileView.selfView
                                                ? false
                                                : true)
                                        : Image.asset(
                                            "assets/images/avatar.png")),
                              )),

                          const SizedBox(
                            height: 25,
                          ),
                          resList['profile_created_by'] == "false"
                              ? const Text("Parent Created Profile",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.grey))
                              : const Text("Self Created Profile",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.grey)),
                          //width: 100,
                          const SizedBox(
                            height: 15,
                          ),
                          Image.asset(
                            "assets/images/Basic Information.png",
                            //fit: BoxFit.cover,
                            height: 100,
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 65,
                                ),
                              ],
                            ),
                            Flexible(
                                child: Column(
                              children: [
                                Text(
                                  resList["first_name"] +
                                      " " +
                                      resList["middle_name"] +
                                      " " +
                                      resList["last_name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  softWrap: true,
                                ),
                              ],
                            )),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "BirthDate",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList["date_of_birth"]
                                      .toString()
                                      .substring(0, 10),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "BirthTime",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['other_info']["bot"]
                                      .toString()
                                      .substring(11, 16),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Gender",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 60,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  gender[int.parse(resList['gender'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Marital Status",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  maritalStatus[
                                      int.parse(resList['marital_status'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Sub-Caste",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  subCaste[int.parse(resList['sub_caste'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Gotra",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  gotra[int.parse(
                                      resList['other_info']['gotra'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          const SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            "assets/images/Professional Information.png",
                            //fit: BoxFit.cover,
                            height: 100,
                          ),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Education",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  education[int.parse(
                                      resList['educationl_info']['education'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Profession",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  profession[int.parse(
                                      resList['educationl_info']
                                          ['profession'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Monthly\nIncome(Rs)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['educationl_info']['income'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Business/\nService Details",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    resList['educationl_info']['service'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            )
                          ]),
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
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Address",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 50,
                                ),
                              ],
                            ),
                            Flexible(
                                child: Column(
                              children: [
                                Text(
                                  resList['address_1'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  softWrap: true,
                                ),
                              ],
                            )),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "City/Town",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['city'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "District",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 55,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['other_info']['district'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "State",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['State'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Country",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 50,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  country[resList['country']],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "PINCode",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 45,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['postal_code'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Contact No.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['phone'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Alternate\nContact No",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['other_info']['alternateContact'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Email",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                ),
                              ],
                            ),
                            Flexible(
                                child: Column(
                              children: [
                                Text(
                                  resList['email'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  softWrap: true,
                                ),
                              ],
                            )),
                          ]),
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
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Physically\nChallegned",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  radioDefault[int.parse(resList['other_info']
                                      ['physicallyChallenged'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Height (feet)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['other_info']['height'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Weight(Kg)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 35,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  resList['other_info']['weight'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Complexion",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  complexion[int.parse(
                                      resList['other_info']['complexion'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Blood Group",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  bg[int.parse(resList['other_info']['bg'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Drinking",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 55,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  radioDefault[int.parse(
                                      resList['other_info']['drinking'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Smoking",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 50,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  radioDefault[int.parse(
                                      resList['other_info']['smoking'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          Row(children: [
                            const Column(children: [
                              Text(
                                "Food Type",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]),
                            const Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  food[
                                      int.parse(resList['other_info']['food'])],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          } else if (data.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else{
            return const SizedBox();
          }
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Color.fromARGB(255, 239, 191, 4),
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.white,
            textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: const TextStyle(
                    color: Colors
                        .white))), // sets the inactive color of the `BottomNavigationBar`
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color:Color.fromARGB(255,46,111,64), size:30.0),
              label: "Notification",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color:Color.fromARGB(255, 204, 46, 46), size:30.0),
              label: "Shortlisted",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call, color:Colors.blue, size:30.0),
              label: "Call us",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervisor_account, color:Colors.white, size:30.0),
              label: "Matches",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, color:Colors.black, size:30.0),
              label: "My Profile",
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
