import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vm_24/view/desired_partner.dart';
import 'package:vm_24/view/profile.dart';
import 'package:vm_24/view/profile_view.dart';
import 'package:vm_24/view/shortlisted.dart';
import 'package:vm_24/view/notification.dart';
import 'package:vm_24/widgets/formfields.dart';
import 'package:vm_24/widgets/modelActions.dart';

class PaymentView extends StatefulWidget {
  PaymentView({super.key, this.title = "", this.autoCheckout = false, this.view_id=''});

  final String view_id;
  final String title;
  final bool autoCheckout;
  static String uuid = "";
  static Map partnerList = {};
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PaymentViewState();
  }
}

class PaymentViewState extends State<PaymentView> {
  late Razorpay _razorpay;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // ⭐️ Check the flag and open checkout immediately
    if (widget.autoCheckout) {
      // Use addPostFrameCallback to ensure the widget is fully built 
      // before trying to open the external payment screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openCheckout();
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      if(response.paymentId != null && (widget.view_id).isNotEmpty)  {
        ProfileAction(context, widget.view_id, type: "visited");
        PartnerView.userInterest = 'visited';
        showAlert(context, "Payment Success", ProfileView());
      }
      print("Payment Success: ${response.paymentId}");
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showAlert(context, "Payment Failed", PartnerView());
      
      print("Payment Error: ${response.code} - ${response.message}");
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      print("External Wallet selected: ${response.walletName}");
    });
  }

/// Releases all the resources used by this object.
///
/// Call this method when you are done using this object.
/// This method is idempotent and has no effect if called multiple times.
///
/// The object cannot be used after this method is called.
///
/// This method is automatically called when the object is about to be garbage
/// collected. It is rarely necessary to call this method directly.
///
/// This method is not thread-safe and should not be called from multiple threads at once.
///
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  int _selectedIndex = 2;

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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PaymentView()));
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

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_RO9c0fErkgL1Yh',
      'amount': 100,
      'name': 'Marriage Era',
      'description': 'Recharge Wallet',
      'retry': {'enabled': true, 'max_count': 4},
      'send_sms_hash': true,
      'prefill': {}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var res;
    return Scaffold(
        body:  Center(
          child: CircularProgressIndicator()
        )
      );
    }

   

  // void startPgTransaction() async {
  //   try {
  //     debugPrint("checking debugging");
  //     debugPrint(body);
  //     var response = PhonePePaymentSdk.startTransaction(body, callbackUrl, checksum, "");
  //     response.then((val) async{
  //       print(callbackUrl);
  //       print("======================");
  //       print(jsonDecode(jsonEncode(val)));
  //       setState(() {
  //       if(val != null){
  //           String status = val['status'].toString();
  //           String error = val['status'].toString();
  //           if(status == "SUCCESS"){
  //             result = "Payment Done";
  //             Navigator.push(
  //             context, MaterialPageRoute(builder: (context) => PartnerView()));
  //           }else{
  //             result = "Payment Failed - $status, Error-> $error";
  //           }
  //       }
  //       else{
  //         result = "Flow Incompleted";
  //       }                  
  //       });
  //     });
      
  //   } catch (error) {
  //      handleError(error);
  //   }
      
  // }

  // void handleError(error){
  //   setState(() {
  //     result = {"error": error };
  //   });
  // }
}
