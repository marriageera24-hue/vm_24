import 'dart:convert';
import 'dart:io';
// import 'package:flutter_form_builder/l10n/messages_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vm_24/app_config.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vm_24/firebase_msg.dart';
import 'package:vm_24/view/desired_partner.dart';
import 'package:vm_24/view/login.dart';
import 'package:vm_24/widgets/formfields.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:vm_24/push_notifications.dart';

var contents = StringBuffer();
setPartnerToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("partner_token", token);
}

unsetPrefs(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

void logout(BuildContext context, GlobalKey _keyLoader) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.get("token").toString();
  final config = await AppConfig.forEnvironment("prod");
  String url = "${config.apiUrl}/users/me/logout";

  HttpClient client = HttpClient();

  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  HttpClientRequest request = await client.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  request.headers.set('Authorization', 'Bearer $token');
  Map data = {};
  request.add(utf8.encode(json.encode(data)));

  HttpClientResponse response = await request.close();
  if (response.statusCode == 204) {
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    showAlert(context, "Successfully Logged out", const LoginPage());
  }
}

void delete(BuildContext context) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.get("token").toString();
  final config = await AppConfig.forEnvironment("prod");
  String url = "${config.apiUrl}/users/delete";
              HttpClient client = HttpClient();
client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  HttpClientRequest request = await client.postUrl(Uri.parse(url));

    request.headers.set('content-type', 'application/json');
    request.headers.set('Accept-Language', 'en-US,en;q=0.9');
    request.headers.set('Authorization', 'Bearer $token');
    Map data = {};
    request.add(utf8.encode(json.encode(data)));

  HttpClientResponse response = await request.close();
  if (response.statusCode == 200) {
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    showAlert(context, "Successfully deleted profile", const LoginPage());
  }
}
void ProfileAction(BuildContext context, String uuid,
    {String type = "interested"}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.get("token").toString();
  final config = await AppConfig.forEnvironment("prod");
  String url = "${config.apiUrl}/users/me/interest";

  HttpClient client = HttpClient();

  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  HttpClientRequest request = await client.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  request.headers.set('Authorization', 'Bearer $token');
  Map data = {"to_user_uuid": uuid.toString(), "type": type};
  request.add(utf8.encode(json.encode(data)));

  HttpClientResponse response = await request.close();
  if (response.statusCode == 201 &&
      (PartnerView.userInterest == 'interested' || type == 'interested')) {
    showAlert(
        context,
        type == 'visited'
            ? "Profile has been removed from shortlisting"
            : "Profile has been shortlisted",
        '');
    PartnerView.userInterest = type;
  }
}

Future<dynamic> getShortlistedUsers(String type) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final completer = Completer<String>();
  final config = await AppConfig.forEnvironment("prod");
  var contentsData = StringBuffer();
  String url;
  String token = prefs.get("token").toString();
  url = "${config.apiUrl}/users/me/$type";

  HttpClient client = HttpClient();

  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  request.headers.set('Authorization', 'Bearer $token');

  HttpClientResponse response = await request.close();
  response.transform(utf8.decoder).listen((data) {
    contentsData.write(data);
  }, onDone: () => completer.complete(contentsData.toString()));
  return completer.future;
}

void patchDeviceInfo(var otherInfo) async {
  Map<String, dynamic> deviceData;
  //await Firebase.initializeApp();
  // pushFCMtoken();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final config = await AppConfig.forEnvironment("prod");
  //deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
  String userToken = prefs.get("token").toString();
  HttpClient client = new HttpClient();
  HttpClientRequest request;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Map packageData = {
    'appName': packageInfo.appName,
    'packageName': packageInfo.packageName,
    'version': packageInfo.version,
    'buildNumber': packageInfo.buildNumber
  };

  String url = "${config.apiUrl}/users/me";
  // otherInfo['deviceData'] = deviceData;
  otherInfo['fcmToken'] = FirebaseMsg.token;
  otherInfo['packageData'] = packageData;
  Map data = {'other_info': (otherInfo)};
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  request = await client.patchUrl(Uri.parse(url));

  request.headers.set('content-type', 'application/json');
  request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  request.headers.set('Authorization', 'Bearer $userToken');
  request.add(utf8.encode(json.encode(data)));
  HttpClientResponse response = await request.close();
}

Future<String> getProfileData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final completer = Completer<String>();
  final config = await AppConfig.forEnvironment("prod");
  contents = StringBuffer();
  String url;
  String token = prefs.get("token").toString();
  url = "${config.apiUrl}/users/me";
  HttpClient client = HttpClient();

  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  request.headers.set('Authorization', 'Bearer $token');

  HttpClientResponse response = await request.close();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));
  return completer.future;
}

Future<String> getBalance() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final completer = Completer<String>();
  final config = await AppConfig.forEnvironment("prod");
  contents = StringBuffer();
  String url;
  String token = prefs.get("token").toString();
  url = "${config.apiUrl}/users/balance";
  HttpClient client = HttpClient();

  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.headers.set('Accept-Language', 'en-US,en;q=0.9');
  request.headers.set('Authorization', 'Bearer $token');

  HttpClientResponse response = await request.close();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));
  return completer.future;
}
