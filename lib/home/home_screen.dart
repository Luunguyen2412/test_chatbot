import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Flutter & Python"),
      ),
      body: Stack(
        children: [
          AnimatedList(
              key: _listKey,
              initialItemCount: _data.length,
              itemBuilder: (BuildContext context, int index,
                  Animation<double> animation) {
                return _buildItem(_data[index], animation, index);
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: ColorFiltered(
              colorFilter: ColorFilter.linearToSrgbGamma(),
              child: Container(
                color: Colors.white.withOpacity(.7),
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.message,
                        color: Colors.orange,
                      ),
                      hintText: "Hello",
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
          )
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
        // client.post(
        //   await Uri.parse("https://uitcovidchatbot.herokuapp.com/"),
        //   body: {"sentence": _controller.text},
        // )..then((response) {
        //     print("tôi là bot đây: " + response.body);
        //     Map<String, dynamic> data = jsonDecode(response.body);
        //     _insertSingleItem(data['response'] + "<bot>");
        //   }); 
        // // cách 1: fetch api theo giống trên mạng
        fetchMessage();  //cách 2: dùng future để fetch apt của thuận bày
      } catch (e) {
        print("Failed -> $e");
      } finally {
        client.close();
        _controller.clear();
      }
    }
  }

  Future fetchMessage() async {
    var client = _getClient();
    final response = await client.post(
      Uri.parse("https://uitcovidchatbot.herokuapp.com/"),
      body: {"sentence": _controller.text},
    );
    if (response.statusCode == 200) {
      print("tôi là bot đây: " + response.body);
      Map<String, dynamic> data = jsonDecode(response.body);
      _insertSingleItem(data['response'] + "<bot>");
    } else {
      throw Exception('Failed to load Message');
    }
  }

  void _insertSingleItem(String message) {
    _data.add(message);
    _listKey.currentState!.insertItem(_data.length - 1);
  }

  Widget _buildItem(String item, Animation<double> animation, int index) {
    bool mine = item.endsWith("<bot>");
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          alignment: mine ? Alignment.topLeft : Alignment.topRight,
          child: Bubble(
            child: Text(item.replaceAll("<bot>", "")),
            color: mine ? Colors.deepOrangeAccent : Colors.white,
            padding: BubbleEdges.all(10),
          ),
        ),
      ),
    );
  }
}
