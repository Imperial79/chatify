import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/colors.dart';
import 'package:chatify/createGroupUi.dart';
import 'package:chatify/services/user.dart';
import 'package:chatify/signIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:chatify/conversationRoomUi.dart';
import 'package:chatify/searchUi.dart';
import 'package:chatify/services/auth.dart';
import 'package:chatify/services/database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomUi extends StatefulWidget {
  @override
  _ChatRoomUiState createState() => _ChatRoomUiState();
}

class _ChatRoomUiState extends State<ChatRoomUi> {
  String myName = "", myUsername = "", myProfilePic = "", myEmail = "";

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  String selectedType = "Personal";

  Stream? personalChatRoomStream;
  Stream? groupChatRoomStream;
  Stream? lastMessageStream;

  @override
  void initState() {
    getUserInfo();

    super.initState();
  }

  getUserInfo() async {
    if (UserName.userName == '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      UserName.userName = prefs.getString('USERNAMEKEY')!;
      UserName.userEmail = prefs.getString('USEREMAILKEY')!;
      UserName.userId = prefs.getString('USERKEY')!;
      UserName.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
      UserName.userProfilePic = prefs.getString('USERPROFILEKEY')!;
    }

    databaseMethods.getPersonalChatRooms(UserName.userName).then((value) {
      setState(() {
        personalChatRoomStream = value;
      });
    });
    databaseMethods.getGroupChatRooms(UserName.userName).then((value) {
      setState(() {
        groupChatRoomStream = value;
      });
    });
  }

  Widget PersonalchatRoomList() {
    return StreamBuilder<dynamic>(
      stream: personalChatRoomStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        'No Chats',
                        style: GoogleFonts.kumbhSans(
                          fontSize: 50,
                          color: Colors.grey.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return ChatListTile(ds);
                    },
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: Colors.teal.shade400,
                  ),
                ),
              );
      },
    );
  }

  Widget GroupchatRoomList() {
    return StreamBuilder<dynamic>(
      stream: groupChatRoomStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'No Groups',
                            style: GoogleFonts.kumbhSans(
                              fontSize: 50,
                              color: Colors.grey.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Created/Joined',
                            style: GoogleFonts.kumbhSans(
                              fontSize: 25,
                              color: Colors.grey.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ChatListTile(snapshot.data.docs[index].data());
                    },
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: Colors.teal.shade400,
                  ),
                ),
              );
      },
    );
  }

  Widget ChatListTile(var ds) {
    String userName = ds['type'] == 'Group'
        ? ''
        : ds["chatRoomId"]
            .toString()
            .replaceAll("#_#", "")
            .replaceAll(UserName.userName, "");

    String displayName = ds['type'] == "Group"
        ? ds['groupName']
        : ds['userDetails'][userName]['name'];

    String image = ds['type'] == 'Group'
        ? "lib/asset/image/noImage.png"
        : ds['userDetails'][userName]['dp'];

    return MaterialButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoversationRoomUi(
                ds["chatRoomId"],
                displayName,
                image,
                ds['type'],
                ds['userDetails'],
              ),
            )).then((value) {
          setState(() {});
        });
      },
      elevation: 0,
      highlightElevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: ds["type"] == 'Group'
                    ? Image.asset(image)
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(width: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.kumbhSans(
                      color: Colors.grey.shade400,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    ds['lastMessage'],
                    style: GoogleFonts.kumbhSans(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleClick(String item) {
    switch (item) {
      case '0':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateGroupUi()));
        break;
      case '1':
        AuthMethods().signOut();
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => SignInUi()));
        break;
    }
  }

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: UserName.userProfilePic == ""
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.yellow,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: UserName.userProfilePic,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi,',
                              style: GoogleFonts.kumbhSans(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Text(
                              UserName.userDisplayName.split(' ').first,
                              style: GoogleFonts.openSans(
                                fontSize: 20,
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                    ),
                    onSelected: (item) => handleClick(item.toString()),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: primaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Create Group',
                              style: GoogleFonts.kumbhSans(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red.shade700,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Logout',
                              style: GoogleFonts.kumbhSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: CategorySelectionBtn(
                      press: () {
                        setState(() {
                          selectedType = "Personal";
                        });
                      },
                      label: 'Personal',
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CategorySelectionBtn(
                      press: () {
                        setState(() {
                          selectedType = "Group";
                        });
                      },
                      label: 'Group',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            selectedType == 'Personal'
                ? Expanded(
                    child: Column(
                      children: [
                        PersonalchatRoomList(),
                      ],
                    ),
                  )
                : GroupScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          PageRouteTransition.effect = TransitionEffect.rightToLeft;
          PageRouteTransition.push(context, SearchUi());
        },
        extendedPadding: EdgeInsets.all(20),
        backgroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        label: Text(
          'Search',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: SvgPicture.asset(
          'lib/asset/svg/search.svg',
          color: Colors.white,
          height: 15,
        ),
      ),
    );
  }

  Widget GroupScreen() {
    return Expanded(
        child: Column(
      children: [
        GroupchatRoomList(),
      ],
    ));
  }

  Widget CategorySelectionBtn({
    final label,
    final press,
  }) {
    return MaterialButton(
      onPressed: press,
      color: selectedType == label ? primaryColor : Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
        side: BorderSide(
          color: selectedType == label ? Colors.transparent : primaryColor,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Text(
        label,
        style: GoogleFonts.kumbhSans(
          fontSize: 17,
          color: selectedType == label ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
