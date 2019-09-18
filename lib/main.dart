import 'package:flutter/material.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/signalr_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final _url = 'http://10.0.2.2/Chat.SignalR/chatHub';

  HubConnection hubConnection;
  bool _isConnected;
  List<ChatMessage> _chatMessages;
  TextEditingController controller;

  Future<void> openConnection() async {
    if (hubConnection == null) {
      hubConnection = HubConnectionBuilder().withUrl(_url).build();
      hubConnection.onclose((error) {
        print(error);
        _isConnected = false;
      });
      hubConnection.on('ReceivedMessage', handleIncomingMessage);
    }

    if (hubConnection.state != HubConnectionState.Connected) {
      await hubConnection.start();
      _isConnected = true;
      print('connected');
    }
  }

  Future<void> SendMessage(String message) async {
    await openConnection();
    hubConnection.invoke("SendMessage", args: <Object>["user", message]);
  }

  void handleIncomingMessage(List<Object> args){
    print(args);
    setState(() {
      _chatMessages.add(ChatMessage(username: args[0], message: args[1]));
    });
    
  }

  @override
  void initState() {
    super.initState();
    _chatMessages = List<ChatMessage>();
    controller = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print('Size: ${size.height} Width: ${size.width}');
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (_, index){
                  return ListTile(
                    title: Text(_chatMessages[index].username),
                    subtitle: Text(_chatMessages[index].message),
                  );
                },
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                OutlineButton(
                  onPressed: () async {
                    await SendMessage(controller.text);
                    print(controller.text);
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String username;
  final String message;

  ChatMessage({
    this.username,
    this.message,
  });
}
