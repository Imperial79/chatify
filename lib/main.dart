import 'package:chatify/HomeUi.dart';
import 'package:chatify/services/helperFunction.dart';
import 'package:chatify/signIn.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Color(0xff1f1f1f),
      systemNavigationBarColor: Color(0xff1f1f1f),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;
  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserNameUserPreference().then((value) {
      print(value);

      if (value == null) {
        setState(() {
          userIsLoggedIn = false;
        });
      } else {
        setState(() {
          userIsLoggedIn = value == "" ? false : true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xff1f1f1f),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn == true ? ChatRoomUi() : SignInUi(),
      // home: CoversationRoomUi(),
    );
  }
}
