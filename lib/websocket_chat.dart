import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final String _currentUserId = '9';
  bool _isWriting = false;
  FocusNode keyboardFocus = FocusNode();
  final List<Message> _messages = [];

  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.1.98:8080'),
  );

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((data) {
      setState(() => _messages.insert(0, Message.fromMap(json.decode(data))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rohit',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) =>
                  MessageLayout(msg: _messages[index], uid: _currentUserId),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _msgController,
                    focusNode: keyboardFocus,
                    onTap: () => keyboardFocus.requestFocus(),
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    onChanged: (val) => setState(
                        () => _isWriting = val.isNotEmpty && val.trim() != ''),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                ),
                _isWriting
                    ? Container(
                        decoration: const BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.send,
                              color: Colors.white, size: 25),
                          onPressed: () {
                            if (_msgController.text.isNotEmpty) {
                              _channel.sink.add(
                                json.encode(Message(
                                  uid: _currentUserId,
                                  from: _currentUserId,
                                  msg: _msgController.text.trim(),
                                  dt: DateTime.now(),
                                ).toMap()),
                              );
                            }
                            _msgController.clear();
                          },
                        ),
                      )
                    : Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.camera_alt, size: 28),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.image_rounded, size: 28),
                            onPressed: () {},
                          ),
                        ],
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MessageLayout extends StatelessWidget {
  final Message msg;
  final String uid;
  const MessageLayout({Key? key, required this.msg, required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Radius messageRadius = Radius.circular(16);
    return Align(
      alignment: msg.uid == uid ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(4, 6, 4, 0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: msg.uid == uid
            ? const BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.only(
                  topLeft: messageRadius,
                  topRight: messageRadius,
                  bottomLeft: messageRadius,
                ),
              )
            : const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomRight: messageRadius,
                  topRight: messageRadius,
                  bottomLeft: messageRadius,
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            msg.msg,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class Message {
  final String uid, from, msg;
  final DateTime dt;

  const Message({
    required this.uid,
    required this.from,
    required this.msg,
    required this.dt,
  });

  Map<String, dynamic> toMap() =>
      {'uid': uid, 'from': from, 'msg': msg, 'dt': dt};

  factory Message.fromMap(Map<String, dynamic> map) => Message(
      uid: map['uid'], from: map['from'], msg: map['msg'], dt: map['dt']);
}
