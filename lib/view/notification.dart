import 'package:flutter/material.dart';
import 'package:vadar_marriage_era/view/call_us.dart';
import 'package:vadar_marriage_era/view/desired_partner.dart';
import 'package:vadar_marriage_era/view/profile_view.dart';
import 'package:vadar_marriage_era/view/payment.dart';
import 'package:vadar_marriage_era/view/shortlisted.dart';
import 'package:vadar_marriage_era/widgets/modelActions.dart';
import 'dart:convert';

class NotificationView extends StatefulWidget {
  NotificationView({super.key, this.title = ''});
  final String title;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationViewState();
  }
}

class NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  int _selectedIndex = 0;

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
        future: getShortlistedUsers("interested"),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.done) {
            List resList = jsonDecode((data.data));
            Container(
              height: height,
              padding: const EdgeInsets.all(36.0),
            );
            RegExp regExp = RegExp(r'(https://.*?.(png|jpg|jpeg))',
                caseSensitive: false, multiLine: false);
            if (resList.length == 0) {
              return Stack(children: <Widget>[
                Container(
                  height: height,
                  padding: const EdgeInsets.all(36.0),
                  child: const Center(
                    child: Text(
                      "No Notifications yet",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ]);
            } else {
              return Stack(children: <Widget>[
                Container(
                    height: height,
                    //padding: const EdgeInsets.all(36.0),
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 45.0),
                        for (var i = resList.length - 1; i >= 0; i--)
                          Container(
                            decoration: BoxDecoration(
                              //border: new Border.all(color: Colors.grey[500]),
                              color:
                                  i % 2 == 0 ? Colors.white : Colors.grey[200],
                            ),
                            child: Column(children: <Widget>[
                              const SizedBox(height: 20.0),
                              Row(
                                children: [
                                  const SizedBox(width: 30),
                                  Column(children: [
                                    resList[i]['type'] == 'visited'
                                        ? const Text(
                                            "Your Profile has been visited by",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15))
                                        : const Text(
                                            "Your Profile has been shortlisted by",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15)),
                                    GestureDetector(
                                      child: Text(
                                        resList[i]['UserInfo']['first_name'] +
                                            " " +
                                            resList[i]['UserInfo']['last_name'],
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () {
                                        PartnerView.partnerList =
                                            resList[i]['UserInfo'];
                                        PartnerView.userInterest =
                                            resList[i]['type'];
                                        PartnerView.selectedIndex = 0;
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileView()));
                                      },
                                    ),
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                            ]),
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
          }else{
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
