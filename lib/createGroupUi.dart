import 'package:chatify/conversationRoomUi.dart';
import 'package:chatify/services/database.dart';
import 'package:chatify/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateGroupUi extends StatefulWidget {
  const CreateGroupUi({Key? key}) : super(key: key);

  @override
  _CreateGroupUiState createState() => _CreateGroupUiState();
}

class _CreateGroupUiState extends State<CreateGroupUi> {
  TextEditingController uniqueName = new TextEditingController();
  TextEditingController groupName = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot<Map<String, dynamic>>? searchSnapshot;
  final form1 = GlobalKey<FormState>();

  createGroupChatRoom() async {
    String chatRoomId = uniqueName.text;
    await databaseMethods.searchGroupName(chatRoomId).then((value) {
      searchSnapshot = value;
    });
    if (searchSnapshot!.docs.length == 0) {
      List<String> users = [UserName.userName];
      Map<String, dynamic> userDetails = {
        UserName.userName: {
          "userName": UserName.userName,
          "name": UserName.userDisplayName,
          "dp": UserName.userProfilePic,
          "status": "Accepted",
        },
      };

      Map<String, dynamic> chatRoomMap = {
        "type": 'Group',
        "users": users,
        "userDetails": userDetails,
        "groupName": groupName.text,
        "chatRoomId": chatRoomId,
        "description": "description.....",
        'lastMessage': ''
      };

      databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CoversationRoomUi(
                    chatRoomId,
                    groupName.text,
                    "lib/asset/image/noImage.png",
                    'Group',
                    userDetails,
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1, milliseconds: 300),
          content: Text(
            "Already a Group with this Unique name",
            style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1f1f1f),
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          "Create Group",
          style: TextStyle(
            fontSize: 45,
            color: Colors.grey,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: form1,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade800,
                  ),
                  child: TextFormField(
                    controller: uniqueName,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.red.shade200,
                      ),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none,
                      labelText: "Enter Unique Name",
                      labelStyle: TextStyle(
                        color: Colors.teal.shade300,
                        fontSize: 20,
                      ),
                    ),
                    validator: (value) {
                      return (value!.isEmpty)
                          ? "Provide a valid Unique name"
                          : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade800,
                  ),
                  child: TextFormField(
                    controller: groupName,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.red.shade200,
                      ),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none,
                      labelText: "Enter Group Name",
                      labelStyle: TextStyle(
                        color: Colors.teal.shade300,
                        fontSize: 20,
                      ),
                    ),
                    validator: (value) {
                      return (value!.isEmpty)
                          ? "Provide a valid group name"
                          : null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MaterialButton(
        onPressed: () {
          if (form1.currentState!.validate()) {
            createGroupChatRoom();
          }
        },
        color: Colors.teal.shade700,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(70),
        ),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Text(
            "Create",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade100,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
