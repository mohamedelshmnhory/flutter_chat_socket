import 'dart:convert';

import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:scoped_model/scoped_model.dart';

import './Message.dart';
import './User.dart';

class ChatModel extends Model {
  List<User> users = [
    User('IronMan', '111'),
    User('Captain America', '222'),
    User('Antman', '333'),
    User('Hulk', '444'),
    User('Thor', '555'),
  ];

  User currentUser;
  List<User> friendList = [];
  List<Message> messages = [];
  SocketIO socketIO;

  void init() {
    currentUser = users[1];
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    socketIO = SocketIOManager().createSocketIO(
        'https://flutter-chat-socket-smn.herokuapp.com', '/',
        query: 'chatID=${currentUser.chatID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }
}
