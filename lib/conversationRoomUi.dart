import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/detailsUi.dart';
import 'package:chatify/services/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatify/services/database.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class CoversationRoomUi extends StatefulWidget {
  final String chatRoomId;
  final String chatWith;
  final String image;
  final String type;
  final userDetails;
  CoversationRoomUi(
    this.chatRoomId,
    this.chatWith,
    this.image,
    this.type,
    this.userDetails,
  );

  @override
  _CoversationRoomUiState createState() => _CoversationRoomUiState();
}

class _CoversationRoomUiState extends State<CoversationRoomUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();

  Stream? chatMessageStream;

  Widget ChatMessageList() {
    return StreamBuilder<dynamic>(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 10),
                physics: BouncingScrollPhysics(),
                reverse: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index].data()["sendBy"],
                    widget.type,
                    widget.userDetails,
                    // snapshot.data.docs[index].data()["time"],
                  );
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      List users = [
        UserName.userName,
        widget.chatRoomId
            .replaceAll(UserName.userName, '')
            .replaceAll('#_#', '')
      ];
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": UserName.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        'users': users,
      };

      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
      databaseMethods.setLastMessage(widget.chatRoomId, messageController.text);
      messageController.text = "";
    }
  }

  void handleClick(String item) {
    switch (item) {
      case '0':
        // DatabaseMethods().clearAllChats(widget.chatRoomId);
        break;
      case '1':
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => DetailsUi(
                      image: widget.image,
                      name: widget.chatWith,
                      chatRoomId: widget.chatRoomId,
                      type: widget.type,
                    )));
        break;
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1f1f1f),
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsUi(
                              image: widget.image,
                              name: widget.chatWith,
                              chatRoomId: widget.chatRoomId,
                              type: widget.type,
                            )));
              },
              child: Hero(
                tag: widget.image,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade700,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: widget.type == 'Group'
                        ? Image.asset(widget.image)
                        : CachedNetworkImage(
                            imageUrl: widget.image,
                            fit: BoxFit.cover,
                          ),
                  ),
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
                  widget.chatWith,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Id : ' + widget.type == 'Group'
                      ? widget.chatRoomId
                      : widget.chatRoomId
                          .replaceAll(UserName.userName, '')
                          .replaceAll('#_#', ''),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onSelected: (item) => handleClick(item.toString()),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text('Clear all Chats'),
              ),
              PopupMenuItem(
                value: 1,
                child: Text('Details'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            ChatMessageList(),
            Container(
              // color: Colors.black,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: messageController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          autofocus: false,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                            hintText: "Message...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.teal.shade800,
                      child: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
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

class MessageTile extends StatelessWidget {
  final String message;
  final String sendBy;
  final String type;
  final userDetails;
  // var time;
  MessageTile(
    this.message,
    this.sendBy,
    this.type,
    this.userDetails,
    // this.time,
  );

  @override
  Widget build(BuildContext context) {
    bool sendByMe = sendBy == UserName.userName;
    // var format = new DateFormat("yMd");
    // var dateString = format.format(time);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: (sendByMe) ? Alignment.topRight : Alignment.topLeft,
          width: double.infinity,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: (sendByMe) ? Colors.white : Colors.teal.shade100,
              borderRadius: (sendByMe)
                  ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
            ),
            child: Column(
              crossAxisAlignment:
                  sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                SelectableLinkify(
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  text: message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'dateString.toString()',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        type == 'Group'
            ? sendBy == UserName.userName
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: userDetails[sendBy]['dp'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          userDetails[sendBy]['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
            : Container(),
      ],
    );
  }
}
