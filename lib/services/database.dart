import 'package:chatify/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  getuserbyUsername(String userName) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: userName)
        .get();
  }

  searchGroupName(String uniqueGroupName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where("chatRoomId", isEqualTo: uniqueGroupName)
        .get();
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap);
  }

  addConversationMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap);
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .where('users', arrayContains: UserName.userName)
        .orderBy('time', descending: true)
        .snapshots();
  }

  getPersonalChatRooms(String userName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where("users", arrayContains: userName)
        .where("type", isEqualTo: "Personal")
        .snapshots();
  }

  getGroupChatRooms(String userName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where("users", arrayContains: userName)
        .where("type", isEqualTo: "Group")
        .snapshots();
  }

  setLastMessage(String chatRoomId, lastMessage) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .update({'lastMessage': lastMessage});
  }

  addUserToGroup(String chatRoomId, var userDetails, List users) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .update({'userDetails': userDetails, 'users': users});
  }
}
