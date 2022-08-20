import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/colors.dart';
import 'package:chatify/conversationRoomUi.dart';
import 'package:chatify/services/database.dart';
import 'package:chatify/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchUi extends StatefulWidget {
  const SearchUi({Key? key}) : super(key: key);

  @override
  _SearchUiState createState() => _SearchUiState();
}

class _SearchUiState extends State<SearchUi> {
  TextEditingController searchController = new TextEditingController();
  QuerySnapshot<Map<String, dynamic>>? searchSnapshot;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  String selectedType = "Personal";
  bool isSearching = false;

  initiateSearch() {
    if (selectedType == "Group") {
      databaseMethods.searchGroupName(searchController.text).then((value) {
        setState(() {
          searchSnapshot = value;

          if (searchSnapshot!.docs.length > 0) {
            print("here group");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1, milliseconds: 300),
                content: Row(
                  children: [
                    Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    Text(
                      "Group Found",
                      style: GoogleFonts.openSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.teal.shade700,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1, milliseconds: 300),
                content: Text(
                  "No Group with such unique name",
                  style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        });
      });
    } else {
      databaseMethods.getuserbyUsername(searchController.text).then((value) {
        setState(() {
          searchSnapshot = value;

          if (searchSnapshot!.docs.length > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1, milliseconds: 300),
                content: Row(
                  children: [
                    Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    Text(
                      "User Found",
                      style: GoogleFonts.openSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.teal.shade700,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1, milliseconds: 300),
                content: Text(
                  "No user with such username",
                  style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        });
      });
    }
  }

  createPersonalChatRoom(
    String friendUserName,
    String friendName,
    String friendDp,
  ) {
    if (friendUserName != UserName.userName) {
      String chatRoomId = getChatRoomId(friendUserName, UserName.userName);
      List<String> users = [friendUserName, UserName.userName];

      Map<String, dynamic> userDetails = {
        UserName.userName: {
          "userName": UserName.userName,
          "name": UserName.userDisplayName,
          "dp": UserName.userProfilePic,
          "status": "Accepted",
        },
        friendUserName: {
          "userName": friendUserName,
          "name": friendName,
          "dp": friendDp,
          "status": "Accepted",
        },
      };

      Map<String, dynamic> chatRoomMap = {
        "type": 'Personal',
        "users": users,
        "chatRoomId": chatRoomId,
        "userDetails": userDetails,
        'lastMessage': '',
      };

      databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CoversationRoomUi(
                    chatRoomId,
                    searchSnapshot!.docs[0].data()["name"],
                    searchSnapshot!.docs[0].data()["imgUrl"],
                    'Personal',
                    searchSnapshot!.docs[0].data()["userDetails"],
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1, milliseconds: 300),
          content: Text(
            "Cannot message yourself",
            style: GoogleFonts.openSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  joinUserInGroup(String chatRoomId, var userDetails, List users) {
    if (!users.contains(UserName.userName)) {
      users.add(UserName.userName);
    }

    userDetails[UserName.userName] = {
      "userName": UserName.userName,
      "name": UserName.userDisplayName,
      "dp": UserName.userProfilePic,
      "status": "Accepted",
    };
    DatabaseMethods().addUserToGroup(chatRoomId, userDetails, users);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CoversationRoomUi(
                  chatRoomId,
                  searchSnapshot!.docs[0].data()["groupName"],
                  'lib/asset/image/noImage.png',
                  'Group',
                  searchSnapshot!.docs[0].data()["userDetails"],
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search",
                    style: GoogleFonts.openSans(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 50,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: searchController,
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    border: InputBorder.none,
                                    hintText: 'Search other users',
                                    hintStyle: GoogleFonts.openSans(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      isSearching = true;
                                    });
                                    if (value.isEmpty) {
                                      setState(() {
                                        isSearching = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              searchController.text.isEmpty
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          searchController.clear();
                                          isSearching = false;
                                        });
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: primaryAccentColor,
                                        radius: 13,
                                        child: Icon(
                                          Icons.close,
                                          size: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(
                        radius: 25,
                        child: IconButton(
                          onPressed: () {
                            initiateSearch();
                          },
                          icon: SvgPicture.asset(
                            'lib/asset/svg/search.svg',
                            color: Colors.white,
                            height: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Search for",
                    style: GoogleFonts.openSans(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: CategorySelectionBtn(
                          press: () {
                            selectedType = "Personal";
                            setState(() {});
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
                            selectedType = "Group";
                            setState(() {});
                          },
                          label: 'Group',
                        ),
                      ),
                    ],
                  ),
                  if (selectedType == 'Personal')
                    if (isSearching == true)
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: FutureBuilder<dynamic>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .where(
                                'name',
                                isLessThanOrEqualTo: searchController.text,
                              )
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 1.6,
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              itemCount: snapshot.data.docs.length,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                try {
                                  DocumentSnapshot ds =
                                      snapshot.data.docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      createPersonalChatRoom(
                                        ds["username"],
                                        ds["name"],
                                        ds["imgUrl"],
                                      );
                                    },
                                    child: ds['email'] == UserName.userEmail
                                        ? Container()
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 15,
                                            ),
                                            child: BuildListTile(ds),
                                          ),
                                  );
                                } catch (e) {
                                  print(e.toString());
                                  return Container();
                                }
                              },
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.teal.shade900,
        child: Icon(
          Icons.arrow_back,
          color: Colors.teal.shade100,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget BuildListTile(DocumentSnapshot<Object?> ds) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Hero(
          tag: ds['imgUrl'],
          child: CachedNetworkImage(
            imageUrl: ds['imgUrl'],
            imageBuilder: (context, image) => CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              backgroundImage: image,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ds['name'],
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '@' + ds['username'],
        style: GoogleFonts.openSans(
          fontSize: 13,
          color: primaryAccentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        // side: BorderSide(
        //   color: primaryAccentColor,
        //   width: 1,
        // ),
      ),
    );
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

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\#_#$a";
  } else {
    return "$a\#_#$b";
  }
}
