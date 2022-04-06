import 'package:chatify/HomeUi.dart';
import 'package:chatify/services/database.dart';
import 'package:chatify/services/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatify/Model/user.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class AuthMethods {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   UserModel? _userFromFirebase(User user) {
//     return UserModel(userId: user.uid);
//   }

//   Future signInWithEmail(String email, String password) async {
//     try {
//       UserCredential result = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       User? firebaseUser = result.user;
//       return _userFromFirebase(firebaseUser!);
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future signUpWithEmail(String email, String password) async {
//     try {
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       User? firebaseUser = result.user;
//       return _userFromFirebase(firebaseUser!);
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future resetPass(String email, String password) async {
//     try {
//       return await _auth.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future signOut() async {
//     try {
//       return await _auth.signOut();
//     } catch (e) {
//       print(e);
//     }
//   }
// }

class AuthMethods {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentuser() async {
    return await auth.currentUser;
  }

  signInWithgoogle(context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication!.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    if (result != null) {
      final SharedPreferences prefs = await _prefs;

      prefs.setString('USERKEY', userDetails!.uid);
      prefs.setString(
          'USERNAMEKEY', userDetails.email!.replaceAll("@gmail.com", ""));
      prefs.setString('USERDISPLAYNAMEKEY', userDetails.displayName!);
      prefs.setString('USEREMAILKEY', userDetails.email!);
      prefs.setString('USERPROFILEKEY', userDetails.photoURL!);

      UserName.userEmail = userDetails.email!;
      UserName.userDisplayName = userDetails.displayName!;
      UserName.userName = userDetails.email!.replaceAll("@gmail.com", "");
      UserName.userId = userDetails.uid;
      UserName.userProfilePic = userDetails.photoURL!;

      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email!.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL
      };

      databaseMethods
          .addUserInfoToDB(
              userDetails.email!.replaceAll("@gmail.com", ""), userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoomUi()));
      });
    }
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}
