import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatify/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:chatify/services/auth.dart';
import 'package:chatify/services/database.dart';
import 'package:chatify/services/helperFunction.dart';
import 'package:chatify/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'HomeUi.dart';

class SignInUi extends StatefulWidget {
  const SignInUi({Key? key}) : super(key: key);

  @override
  _SignInUiState createState() => _SignInUiState();
}

class _SignInUiState extends State<SignInUi> {
  final formKey = GlobalKey<FormState>();

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();

  bool isLoading = false;
  QuerySnapshot<Map<String, dynamic>>? snapshotUserInfo;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      // appBar: customAppBar("Sign In", context),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              )
            : Stack(
                children: [
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chat - ify',
                          style: GoogleFonts.bubblegumSans(
                            color: primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 50,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Chat',
                              cursor: '_',
                              textStyle: GoogleFonts.kumbhSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            TypewriterAnimatedText(
                              'Meet',
                              cursor: '_',
                              textStyle: GoogleFonts.kumbhSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            TypewriterAnimatedText(
                              'Make Groups',
                              cursor: '_',
                              textStyle: GoogleFonts.kumbhSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          totalRepeatCount: 100,
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: 20,
                        left: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              "continue with",
                              style: GoogleFonts.kumbhSans(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              AuthMethods().signInWithgoogle(context);
                            },
                            color: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            child: Text(
                              'Google',
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
