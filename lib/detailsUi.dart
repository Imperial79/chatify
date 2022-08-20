import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/HomeUi.dart';
import 'package:chatify/services/database.dart';
import 'package:chatify/services/user.dart';
import 'package:flutter/material.dart';

class DetailsUi extends StatefulWidget {
  final String image;
  final String name;
  final String chatRoomId;
  final String type;
  DetailsUi({
    required this.image,
    required this.name,
    required this.chatRoomId,
    required this.type,
  });

  @override
  _DetailsUiState createState() => _DetailsUiState();
}

class _DetailsUiState extends State<DetailsUi> {
  deletePersonalChat() {
    // DatabaseMethods().deleteChatRoom(widget.chatRoomId);
    // Navigator.pushReplacement(
    //     context, (MaterialPageRoute(builder: (context) => ChatRoomUi())));
  }

  LeaveGroup() {
    // DatabaseMethods().deleteChatRoom(widget.chatRoomId);
    // Navigator.pushReplacement(
    //     context, (MaterialPageRoute(builder: (context) => ChatRoomUi())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Hero(
                    tag: widget.image,
                    child: CircleAvatar(
                      radius: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: widget.type == 'Personal'
                            ? CachedNetworkImage(
                                imageUrl: widget.image,
                                fit: BoxFit.cover,
                                height: 500,
                              )
                            : Image.asset(widget.image),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.type == 'Personal'
                      ? '(' +
                          widget.chatRoomId
                              .replaceAll('#_#', '')
                              .replaceAll(UserName.userName, '') +
                          ')'
                      : '(' + widget.chatRoomId + ')',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: MaterialButton(
                        onPressed: () {
                          widget.type == 'Personal'
                              ? deletePersonalChat()
                              : LeaveGroup();
                        },
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.red.shade900,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red.shade100,
                            ),
                            SizedBox(
                              width: 40,
                            ),
                            Text(
                              widget.type == 'Personal'
                                  ? "Delete Chat"
                                  : 'Leave Group',
                              style: TextStyle(
                                color: Colors.red.shade100,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
