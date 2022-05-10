import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> _data = [];
  //static const String BOT_URL = "https://supercodebot.herokuapp.com";
  TextEditingController _controller = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? displayName = "";

  @override 
  // ignore: must_call_super
  void initState() {
    getData();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = prefs.getString('displayName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Flutter & Python"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 60),
            child: AnimatedList(
                key: _listKey,
                initialItemCount: _data.length,
                itemBuilder: (BuildContext context, int index,
                    Animation<double> animation) {
                  return _buildItem(_data[index], animation, index);
                }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.message,
                      color: Colors.orange,
                    ),
                    hintText: "Say something with me?",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    fillColor: Colors.white12,
                  ),
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    this._getResponse();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  http.Client _getClient() {
    return http.Client();
  }

  void _getResponse() async {
    if (_controller.text.length > 0) {
      this._insertSingleItem(_controller.text);
      var client = _getClient();
      try {
        client.post(
          await Uri.parse("https://uitcovidchatbot.herokuapp.com/"),
          body: {"sentence": _controller.text},
        )..then((response) {
            print("tôi là bot đây: " + response.body);
            var data = jsonEncode(response.body);
            _insertSingleItem(
                jsonDecode(data) + "<bot>"); // sửa lại format của data trả về
          });
        // cách 1: fetch api theo giống trên mạng
      } catch (e) {
        print("Failed -> $e");
      } finally {
        client.close();
        _controller.clear();
      }
    }
  }

  void _insertSingleItem(String message) {
    _data.add(message);
    _listKey.currentState!.insertItem(_data.length - 1);
    //_data.insert(0, message);
  }

  Widget _buildItem(String item, Animation<double> animation, int index) {
    DateTime date = DateTime.now();

    bool mine = item.endsWith("<bot>");
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
            alignment: mine ? Alignment.topLeft : Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mine
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: RichText(
                          text: TextSpan(
                              text: "Doctor",
                              style: TextStyle(color: Colors.black)),
                        ),
                      )
                    : SizedBox(),
                Bubble(
                  child: Text(item.replaceAll("<bot>", "")),
                  color: mine ? Colors.deepOrangeAccent : Colors.white,
                  padding: BubbleEdges.all(10),
                ),
                mine
                    ? Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: RichText(
                          text: TextSpan(
                              text: "${date.hour}:${date.minute}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500])),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: RichText(
                          text: TextSpan(
                              text: "${date.hour}:${date.minute}",
                              style: TextStyle(color: Colors.grey[500]),
                              children: [
                                TextSpan(
                                    text: " ✓",
                                    style: TextStyle(color: Colors.grey[500]))
                              ]),
                        ),
                      ),
              ],
            )),
      ),
    );
  }
}
