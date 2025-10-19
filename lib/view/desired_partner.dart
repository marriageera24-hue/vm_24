import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vm_24/view/profile.dart';
import 'package:vm_24/view/profile_view.dart';
import 'package:vm_24/view/payment.dart';
import 'package:vm_24/view/shortlisted.dart';
import 'package:vm_24/view/notification.dart';
import 'package:vm_24/widgets/formfields.dart';
import 'package:vm_24/widgets/modelActions.dart';
import 'dart:convert';
import 'package:vm_24/view/constants.dart';
import 'package:vm_24/widgets/image_dialog.dart';
import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vm_24/app_config.dart';
import 'package:vm_24/view/call_us.dart';

class PartnerView extends StatefulWidget {
  PartnerView({super.key, this.title = ''});
  final String title;
  static String userInterest = '';
  static Map partnerList = {};
  static int selectedIndex = 0;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PartnerViewState();
  }
}

class PartnerViewState extends State<PartnerView> {
  @override
  bool _hasMore = true;
  int _pageNumber = 1;
  bool _error = false;
  bool _loading = true;
  bool _isSubCasteExpanded = false;
  bool _isEducationExpanded = false;
  bool _isMaritalStatusExpanded = false;
  bool _isAgeExpanded = false;
  
  final int _defaultMatchesPerPageCount = 10;
  final int _nextPageThreshold = 2;
  List userList = [];
  void initState() {
    PartnerView.userInterest = '';
    PartnerView.partnerList = {};
    PartnerView.selectedIndex = 3;
    // TODO: implement initState
    super.initState();
    // _hasMore = true;
    // _pageNumber = 1;
    // _error = false;
    // _loading = true;
    convertListData();
  }

  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
      // Widget widget = Container(); // default
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

  Widget _editButton() {
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
            const Text('Edit Profile',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent))
          ],
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Map<String, dynamic> selectedFilter = {};

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar( // 👈 ADD THIS AppBar
        title: Text(widget.title),
        actions: <Widget>[ // 👈 ADD THE ICON BUTTON HERE
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blue), // Use an appropriate color
            onPressed: () {
              // You might need a delay or check if the context is valid if it fails
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
          child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Expanded(
            child: ListView(
          children: <Widget>[
            ExpansionTile(
              key: const Key('subcaste'),
              // 1. Manage the color state and immediately collapse the tile.
              onExpansionChanged: (bool isExpanded) {
                setState(() {
                  // Toggle the color state based on the click
                  _isSubCasteExpanded = isExpanded; 
                });   
              }, 
              // 2. Conditionally set the title color based on the state variable
              title: Text(
                "Sub-Caste",
                style: TextStyle(
                  color: _isSubCasteExpanded ? Colors.blue : Colors.black, // Change color
                ),
              ),
              
              children: <Widget>[
                SimpleGroupedCheckbox<dynamic>(
                  //groupTitle:"Basic",
                  onItemSelected: (data) {
                    selectedFilter['subcaste'] = data;
                  },
                  controller: GroupController(
                    isMultipleSelection: true,
                    initSelectedItem: selectedFilter.containsKey('subcaste')
                        ? selectedFilter['subcaste']
                        : [],
                  ),
                  isLeading: true,
                  itemsTitle: List.from(subCaste),
                  values: List.generate(subCaste.length, (index) => "$index"),
                  groupStyle: GroupStyle(activeColor: Colors.green), // Fixed error for checkbox color
                  // checkFirstElement: false,
                  // isCirculaire: false,
                ),
              ],
            ),
            ExpansionTile(
              key: const Key('education'),
              // 1. Manage the color state and immediately collapse the tile.
              onExpansionChanged: (bool isExpanded) {
                setState(() {
                  // Toggle the color state based on the click
                  _isEducationExpanded = isExpanded; 
                });   
              }, 
              // 2. Conditionally set the title color based on the state variable
              title: Text( // ⬅️ The 'const' keyword must be removed here
                  "Education",
                  style: TextStyle(
                      // This entire line is now valid because the Text widget is no longer const
                      color: _isEducationExpanded ? Colors.blue : Colors.black,
                  ),
              ),
              children: <Widget>[
                SimpleGroupedCheckbox<dynamic>(
                  //groupTitle:"Basic",
                  onItemSelected: (data) {
                    selectedFilter['education'] = data;
                  },
                  controller: GroupController(
                    isMultipleSelection: true,
                    initSelectedItem: selectedFilter.containsKey('education')
                        ? selectedFilter['education']
                        : [],
                  ),
                  isLeading: true,
                  itemsTitle: List.from(education),
                  values: List.generate(education.length, (index) => "$index"),
                  groupStyle: GroupStyle(activeColor: Colors.green), 
                  // activeColor: Colors.green,
                  // checkFirstElement: false,
                  // isCirculaire: false,
                ),
              ],
            ),
            ExpansionTile(
              key: const Key('matialstatus'),
              onExpansionChanged: (bool isExpanded) {
                setState(() {
                  // Toggle the color state based on the click
                  _isMaritalStatusExpanded = isExpanded; 
                });   
              }, 
              title:  Text(
                "Marital Status",
                style: TextStyle(
                  color: _isMaritalStatusExpanded ? Colors.blue : Colors.black,
                )),
              children: <Widget>[
                SimpleGroupedCheckbox<dynamic>(
                  //groupTitle:"Basic",
                  onItemSelected: (data) {
                    selectedFilter['matialstatus'] = data;
                  },
                  controller: GroupController(
                    isMultipleSelection: true,
                    initSelectedItem: selectedFilter.containsKey('matialstatus')
                        ? selectedFilter['matialstatus']
                        : [],
                  ),
                  isLeading: true,
                  itemsTitle: List.from(maritalStatus),
                  values:
                      List.generate(maritalStatus.length, (index) => "$index"),
                      groupStyle: GroupStyle(activeColor: Colors.green),
                  // activeColor: Colors.green,
                  // checkFirstElement: false,
                  // isCirculaire: false,
                ),
              ],
            ),
            ExpansionTile(
              key: const Key('age'),
              onExpansionChanged: (bool isExpanded) {
                setState(() {
                  // Toggle the color state based on the click
                  _isAgeExpanded = isExpanded; 
                });
              },
              title: Text(
                "Age",
                style: TextStyle(
                  color: _isAgeExpanded ? Colors.blue : Colors.black
                )),
              children: <Widget>[
                SimpleGroupedCheckbox<dynamic>(
                  //groupTitle:"Basic",
                  onItemSelected: (data) {
                    selectedFilter['age'] = data;
                  },
                  controller: GroupController(
                    isMultipleSelection: true,
                    initSelectedItem: selectedFilter.containsKey('age')
                        ? selectedFilter['age']
                        : [],
                  ),
                  isLeading: true,
                  itemsTitle: List.from(age),
                  values: List.generate(age.length, (index) => "$index"),
                  groupStyle: GroupStyle(activeColor: Colors.green),
                  // activeColor: Colors.green,
                  // checkFirstElement: false,
                  // isCirculaire: false,
                ),
              ],
            ),
          ],
        )),
        Container(
          padding: const EdgeInsets.all(36.0),
          width: 500,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
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
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PartnerView()));
                },
              )),
        )
      ])),
      body: createListView(),
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

  Widget createListView() {
    RegExp regExp = RegExp(r'(https://.*?.(png|jpg|jpeg))',
        caseSensitive: false, multiLine: false);
    if (userList.isEmpty) {
      if (_loading) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ));
      } else if (_error) {
        return Center(
            child: InkWell(
          onTap: () {
            setState(() {
              _loading = false;
              _error = false;
              convertListData();
            });
          },
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Error while loading List, tap to try agin"),
          ),
        ));
      }
    } else if (userList.contains("no data")) {
      return Stack(children: <Widget>[
        Container(
            child: const Column(children: <Widget>[
          Text('No more profiles...',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 50,
          )
        ])),
      ]);
    } else {
      return Stack(children: <Widget>[
        Container(
            margin:const EdgeInsets.only(top: 30),
            child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, int index) {
                  if (index == userList.length - _nextPageThreshold &&
                      userList.toString() != 'no data') {
                    convertListData();
                  }
                  if (index == userList.length &&
                      userList.toString() != 'no data') {
                    if (_error) {
                      return Center(
                          child: InkWell(
                        onTap: () {
                          setState(() {
                            _loading = true;
                            _error = false;
                            convertListData();
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                              "Error while loading photos, tap to try agin"),
                        ),
                      ));
                    }
                  }
                  final values = userList[index];
                  return Column(children: <Widget>[
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
                                      borderRadius: BorderRadius.circular(50)),
                                  width: 100,
                                  height: 100,
                                  child: GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (_) => ImageDialog(
                                                  imgUrl: regExp.hasMatch(
                                                          values['user_media']
                                                              .toString())
                                                      ? regExp.stringMatch(
                                                          values['user_media']
                                                              .toString())
                                                      : '',
                                                  isCachedImage: true,
                                                ));
                                      },
                                      child: loadImage(
                                          values['user_media'].toString()))),
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
                            Text(values['first_name'] +
                                " " +
                                values['last_name']),
                            //Text(values['phone']),
                            Text(
                              ((DateTime.now()
                                              .difference(DateTime(
                                                  int.parse(
                                                      values['date_of_birth']
                                                          .toString()
                                                          .substring(0, 4)),
                                                  int.parse(
                                                      values['date_of_birth']
                                                          .toString()
                                                          .substring(6, 7)),
                                                  int.parse(
                                                      values['date_of_birth']
                                                          .toString()
                                                          .substring(9, 10))))
                                              .inDays) /
                                          365)
                                      .toString()
                                      .substring(0, 2) +
                                  " years",
                            ),
                            Text(subCaste[int.parse(values['sub_caste'])]),
                            Text(education[int.parse(
                                values['educationl_info']['education'])]),
                            Text(values['other_info']['district']),
                            GestureDetector(
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                PartnerView.partnerList = values;
                                if(!values.containsKey('interest_details')  || values['interest_details']['type'] == null || values['interest_details']['type'] == ''){
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => PaymentView(
                                        title: "Recharge for Profile View",
                                        autoCheckout: true,
                                        view_id: values['uuid'] // ⭐️ This is the key change
                                      )
                                    )
                                  );

                                }else{
                                  values['interest_details']['type'] != 'interested'
                                          ? ProfileAction(context, values['uuid'],
                                              type: "visited")
                                          : '';
                                  PartnerView.userInterest = values['interest_details']['type'];
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfileView()));
                                } 
                              }
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]);
                }))
      ]);
    }
    return const SizedBox();
  }

  Widget convertListData() {
    Future list = getPartnerData(selectedFilter);
    list.then((value) => userList.addAll((jsonDecode(value))));
    return const SizedBox();
  }

  Future<dynamic> getPartnerData(Map filterOptions) async {
    final config = await AppConfig.forEnvironment("dev");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map data;
    String url;
    String token = prefs.get("token").toString();
    HttpClient client = HttpClient();
    HttpClientRequest request;
    HttpClientResponse response;
    var fromAge;
    var toAge;
    if (Profile.resList['family_info'] != null) {
      if (filterOptions.containsKey('age') && filterOptions['age'] != null) {
        List ageData = filterOptions['age'];
        if (ageData.length > 0) {
          ageData.sort();
          fromAge = age[int.parse(ageData[0])].toString().substring(0, 2);
          toAge = age[int.parse(ageData[ageData.length - 1])]
              .toString()
              .substring(3, 5);
          fromAge = int.parse(fromAge);
          toAge = int.parse(toAge);
        }
      }
      data = {
        "is_verified": 1,
        "gender": Profile.resList['family_info']['partnerGender'],
        "sub_castes": filterOptions['subcaste'],
        "educations": filterOptions['education'],
        "marital_statuses": filterOptions['matialstatus'],
        "from_age": fromAge,
        "to_age": toAge,
        "page": _pageNumber,
        "order by": "id",
        "order": "DESC"
      };
      url = "${config.apiUrl}/users/search";
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      request = await client.postUrl(Uri.parse(url));

      request.headers.set('content-type', 'application/json');
      request.headers.set('Accept-Language', 'en-US,en;q=0.9');
      request.headers.set('Authorization', 'Bearer $token');
      request.add(utf8.encode(json.encode(data)));

      response = await request.close();

      if (response.contentLength == -1) {
        var result = StringBuffer();
        final completer = Completer<String>();
        response.transform(utf8.decoder).listen((searchData) {
          result.write(searchData);
        }, onDone: () {
          completer.complete(result.toString());
          setState(() {
            _loading = false;
            _error = false;
            _pageNumber = _pageNumber + 1;
            _hasMore = userList.length == _defaultMatchesPerPageCount;
          });
        });

        return completer.future;
      } else {
        setState(() {
          _loading = false;
          _error = false;
          _hasMore = false;
        });
        return 'no data';
      }
    }else{
      return const SizedBox();
    }
  }
}
