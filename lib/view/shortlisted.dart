import 'package:flutter/material.dart';
import 'package:vadar_marriage_era/view/call_us.dart';
import 'dart:convert';
import 'package:vadar_marriage_era/view/desired_partner.dart';
import 'package:vadar_marriage_era/view/profile_view.dart';
import 'package:vadar_marriage_era/view/payment.dart';
import 'package:vadar_marriage_era/view/notification.dart';
import 'package:vadar_marriage_era/widgets/modelActions.dart';
import 'package:vadar_marriage_era/view/constants.dart';
import 'package:vadar_marriage_era/widgets/image_dialog.dart';

class ShortlistedView extends StatefulWidget {
  ShortlistedView({super.key, this.title = ""});
  final String title;
  static String uuid = "";
  static Map partnerList = {};
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShortlistedViewState();
  }
}

class ShortlistedViewState extends State<ShortlistedView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final int _selectedIndex = 1;

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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PartnerView()));
          break;
        case 4:
          PartnerView.partnerList = {};
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfileView()));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: false,
      body: FutureBuilder<dynamic>(
        future: getShortlistedUsers("interests"),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.done) {
            List resList = jsonDecode((data.data));
            resList.removeWhere((item) => item['type'] == 'visited');
            Container(
              height: height,
              padding: const EdgeInsets.all(36.0),
            );
            RegExp regExp = RegExp(r'(https://.*?.(png|jpg|jpeg))',
                caseSensitive: false, multiLine: false);
            if (resList.length == 0) {
              return Stack(children: <Widget>[
                Container(
                  child: const Center(
                    child: Text(
                      "You have not shortlisted any profile yet",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ]);
            } else {
              return Stack(children: <Widget>[
                Container(
                    child: SingleChildScrollView(
                        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 45.0),
                    for (var i = resList.length - 1; i >= 0; i--)
                      Row(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    width: 100,
                                    height: 100,
                                    child: GestureDetector(
                                        onTap: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (_) => ImageDialog(
                                                  imgUrl: regExp.hasMatch(
                                                          resList[i]['UserInfo']
                                                                  ['user_media']
                                                              .toString())
                                                      ? regExp.stringMatch(
                                                          resList[i]['UserInfo']
                                                                  ['user_media']
                                                              .toString())
                                                      : '',
                                                  isCachedImage: true));
                                        },
                                        child: loadImage(resList[i]['UserInfo']
                                                ['user_media']
                                            .toString()))),
                              ),
                            ],
                          ),
                          const Column(
                            children: [
                              SizedBox(
                                width: 50,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(resList[i]['UserInfo']['first_name'] +
                                  " " +
                                  resList[i]['UserInfo']['last_name']),
                              Text(
                                "${((DateTime.now()
                                                .difference(DateTime(
                                                    int.parse(resList[i]
                                                                ['UserInfo']
                                                            ['date_of_birth']
                                                        .toString()
                                                        .substring(0, 4)),
                                                    int.parse(resList[i]
                                                                ['UserInfo']
                                                            ['date_of_birth']
                                                        .toString()
                                                        .substring(6, 7)),
                                                    int.parse(resList[i]
                                                                ['UserInfo']
                                                            ['date_of_birth']
                                                        .toString()
                                                        .substring(9, 10))))
                                                .inDays) /
                                            365)
                                        .toString()
                                        .substring(0, 2)} years",
                              ),
                              Text(subCaste[int.parse(
                                  resList[i]['UserInfo']['sub_caste'])]),
                              Text(
                                education[int.parse(resList[i]['UserInfo']
                                    ['educationl_info']['education'])],
                              ),
                              Text(resList[i]['UserInfo']['other_info']
                                  ['district']),
                              GestureDetector(
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  PartnerView.partnerList =
                                      resList[i]['UserInfo'];
                                  PartnerView.userInterest = resList[i]['type'];
                                  PartnerView.selectedIndex = 1;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfileView()));
                                },
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                )))
              ]);
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
