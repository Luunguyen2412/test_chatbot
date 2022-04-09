import 'package:flutter/material.dart';
import 'package:test_chatbot/home/home_screen.dart';
// ignore: import_of_legacy_library_into_null_safe

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ChatApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(title: 'flutter and python',),
      //home: HomePageDialogFlow(),
    );
  }
}

// class HomePageDialogFlow extends StatefulWidget {
//   const HomePageDialogFlow({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<HomePageDialogFlow> createState() => _HomePageDialogFlowState();
// }

// class _HomePageDialogFlowState extends State<HomePageDialogFlow> {
//   final List<ChatMessage> _messages = <ChatMessage>[];
//   final TextEditingController _textController = new TextEditingController();

//   Widget _buildTextComposer() {
//     return IconTheme(
//         data: new IconThemeData(color: Theme.of(context).cardColor),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Row(
//             children: [
//               Flexible(
//                 child: TextField(
//                   controller: _textController,
//                   onSubmitted: _handleSubmitted,
//                   decoration:
//                       InputDecoration.collapsed(hintText: 'Send a message'),
//                 ),
//               ),
//               Container(
//                 margin: new EdgeInsets.symmetric(horizontal: 4.0),
//                 child: new IconButton(
//                     icon: new Icon(Icons.send),
//                     onPressed: () => _handleSubmitted(_textController.text)),
//               ),
//             ],
//           ),
//         ));
//   }

//   void Response(query) async {
//     _textController.clear();
//     AuthGoogle authGoogle =
//         await AuthGoogle(fileJson: "assets/credentials.json").build();
//     Dialogflow dialogflow =
//         Dialogflow(authGoogle: authGoogle, language: Language.english);
//     AIResponse response = await dialogflow.detectIntent(query);
//     ChatMessage message = ChatMessage(
//       text: response.getMessage() ??
//           CardDialogflow(response.getListMessage()[0]).title,
//       name: 'Bot AI',
//       type: false,
//     );
//     setState(() {
//       _messages.insert(0, message);
//     });
//   }

//   void _handleSubmitted(String text) {
//     _textController.clear();
//     ChatMessage message = ChatMessage(text: text, name: "Viet Luu", type: true);
//     setState(() {
//       _messages.insert(0, message);
//     });
//     Response(text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: new AppBar(
//         centerTitle: true,
//         title: new Text("Flutter ChatApp"),
//       ),
//       body: Column(
//         children: [
//           Flexible(
//             child: ListView.builder(
//               padding: new EdgeInsets.all(8.0),
//               reverse: true,
//               itemBuilder: (_, int index) => _messages[index],
//               itemCount: _messages.length,
//             ),
//           ),
//           Divider(height: 1.0),
//           Container(
//             decoration: BoxDecoration(color: Theme.of(context).cardColor),
//             child: _buildTextComposer(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage extends StatelessWidget {
//   const ChatMessage(
//       {Key? key, required this.text, required this.name, required this.type})
//       : super(key: key);
//   final String text;
//   final String name;
//   final bool type;

//   List<Widget> otherMessage(context) {
//     return <Widget>[
//       Container(
//         margin: EdgeInsets.only(right: 16.0),
//         child: CircleAvatar(child: Text('B')),
//       ),
//       Expanded(
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(this.name, style: TextStyle(fontWeight: FontWeight.bold)),
//           Container(
//             margin: const EdgeInsets.only(top: 5.0),
//             child: Text(text),
//           ),
//         ],
//       )),
//     ];
//   }

//   List<Widget> myMessage(context) {
//     return <Widget>[
//       Expanded(
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             this.name,
//           ),
//           Container(
//             margin: EdgeInsets.only(top: 5.0),
//             child: Text(text),
//           ),
//         ],
//       )),
//       Container(
//         margin: EdgeInsets.only(left: 16.0),
//         child: CircleAvatar(
//           child: Text(
//             this.name[0],
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: this.type ? myMessage(context) : otherMessage(context),
//       ),
//     );
//   }
// }
