import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FireAuthentication {
  static final _fireInstance = FirebaseAuth.instance;
  static final userStream = _fireInstance.userChanges();
  static User? get currentUser => _fireInstance.currentUser;

  /// initialize the firebase auth and subscriping to the userStream; ----------
  static initialize() {
    _fireInstance.userChanges().listen((User? user) {
      if (user == null) {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('User is signed in!');
        }
      }
    });
  }

  /// phone number Authentication; ---------------------------------------------
  static void phoneAuthenticate({
    required String phoneNumber,
    required Future<String> Function() onSMSCodeSent,
    void Function()? onSuccess,
    void Function(FirebaseAuthException error)? onFailed,
  }) async {
    /// function of getting auth credential;------------------------------------
    void verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      await _fireInstance.signInWithCredential(phoneAuthCredential);

      if (currentUser != null) {
        onSuccess?.call();
      }
    }

    /// handling errors; -------------------------------------------------------
    void verificationFailed(FirebaseAuthException error) {
      if (kDebugMode) {
        if (error.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        print(error);
      }
      onFailed?.call(error);
    }

    /// on SMS code sent; ------------------------------------------------------
    void codeSent(String verificationId, int? forceResendingToken) async {
      // Update the UI - wait for the user to enter the SMS code
      String smsCode = await onSMSCodeSent();

      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      await _fireInstance.signInWithCredential(credential);

      if (currentUser != null) {
        onSuccess?.call();
      }
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      /// auto resolved with timeout attribute;
    }

    /// Verifying the phone number; --------------------------------------------
    _fireInstance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// sign out the user; -------------------------------------------------------
  static void signOut() async {
    await _fireInstance.signOut();
  }
}
