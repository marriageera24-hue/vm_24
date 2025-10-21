import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? verificationId;

  // Verifies the code, signs in the user, and immediately signs them out.
  Future<bool> verifyAndSignOut({
    required String smsCode,
  }) async {
    try {
      print("Verifying code: $smsCode");
      print("Verification ID: $verificationId");
      if (verificationId == null) return false;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      // 1. Sign In (Confirms the number)
      await _auth.signInWithCredential(credential);

      // 2. Sign Out (Cleans up the authentication state)
      await _auth.signOut();
      
      // Verification ID is now consumed, reset it.
      verificationId = null;

      return true;

    } on FirebaseAuthException catch (e) {
      print("Verification failed: ${e.code} - ${e.message}");
      return false;
    }
  }

  // Sends the OTP and stores the verificationId.
  Future<bool> sendOtp({
    required String phoneNumber,
    required Function(String, int?) codeSentCallback,
    required Function(FirebaseAuthException) verificationFailedCallback,
  }) async {
    try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval success: complete the flow immediately
            await _auth.signInWithCredential(credential);
            await _auth.signOut();
            codeSentCallback("AUTO_VERIFIED", null);
          },
          verificationFailed: verificationFailedCallback,
          codeSent: (String verId, int? resendToken) {
            this.verificationId = verId;
            codeSentCallback(verId, resendToken);
          },
          codeAutoRetrievalTimeout: (String verId) {
            this.verificationId = verId;
          },
        );
        return true;
    } catch (e) {
        print("Error initiating OTP: $e");
        return false;
    }
  }
}