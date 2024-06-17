import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messageapp/components/chat_bubble.dart';
import 'package:messageapp/components/my_test_field.dart';
// import 'package:flutter/widgets.dart';
import 'package:messageapp/services/chat/chat_service.dart';
//import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget{

  final String receiveUserEmail;
  final String receiveUserID;

  const ChatPage({super.key,
  required this.receiveUserEmail,
  required this.receiveUserID
  });
  
  @override
  State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async{
    //only send the message if there is something to send
    if(_messageController.text.isNotEmpty){
      await _chatService .sendMessage(
        widget.receiveUserID, _messageController.text);
      //clear the text controller after sending the message
      _messageController.clear();
    }

  }

  @override
  Widget build(BuildContext content)
  {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiveUserEmail)),
      body: Column(
        children: [
          //messages
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildMessageInput(),

          const SizedBox(height: 25,)
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList(){
    return StreamBuilder(
    stream: _chatService.getMessages(
      widget.receiveUserID, _firebaseAuth.currentUser!.uid),
    builder: (context , snapshot)
    {
      if(snapshot.hasError)
      {
        return Text('Error${snapshot.error}');
      }
      if(snapshot.connectionState == ConnectionState.waiting){
        return const Text('Loading...');
      }

      return ListView(
       children: snapshot.data!.docs
       .map((document) => _buildMessageItem(document))
       .toList(),
      );
    }
    );
  }


  //build message item
  Widget _buildMessageItem(DocumentSnapshot document)
  {
    Map<String,dynamic> data = document.data() as Map<String,dynamic>;

    //align message left and right

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
    ? Alignment.centerRight
    : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
           ? CrossAxisAlignment.end
           :CrossAxisAlignment.start,
          mainAxisAlignment:
          (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? MainAxisAlignment.end
          :MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 3,),
            ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }


  //build message input
  Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText : 'Enter message',
              obscureText: false,
            ),
            ),
      
            //send button
            IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.arrow_upward,
              size: 40,
            )
            )
        ],
      ),
    );
  }
}