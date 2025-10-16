import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall() async {
  String phoneNumber = '8446226497';

  //code to redirect to dialer page
  final Uri launchUri = Uri(
        scheme: 'tel',
        path: '+91 8446226497',
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }

  //code to call directly
  // bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  //   if (res == null || res == false) {
  //     // If direct call fails, fall back to opening the dialer
  //     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  //     if (await canLaunchUrl(launchUri)) {
  //       await launchUrl(launchUri);
  //     } else {
  //       throw 'Could not launch $launchUri';
  //     }
  //   }
  }
  
