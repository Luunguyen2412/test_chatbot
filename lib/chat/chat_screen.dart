import 'dart:async';
import 'package:dialogflow_grpc/dialogflow_auth.dart';
import 'package:dialogflow_grpc/types/v2beta1/input_config.dart';
import 'package:dialogflow_grpc/v2beta1.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:test_chatbot/chat/recommendItem.dart';
import 'package:test_chatbot/services_api.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';

import 'menu_recommed.dart';

late DialogflowGrpcV2Beta1 dialogflow;

List<String> suggestions1 = [
  "COVID-19 là gì?",
  "Khẩn cấp",
  "Thống kê",
];
List<String> suggestions = ["Xin chào!", "COVID-19", "Sức khỏe", "Quy tắt 5K"];
List<String> suggestions2 = [
  "Triệu chứng",
  "Cách lây lan",
  "Phòng ngừa",
  "Quy tắt 5K"
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool _isRecording = false;
  bool _isWaitingBot = false;
  late AnimationController _animationIconMenuController;
  bool isShowingIconMenu = false;

  int funcSelected = 0;

  RecorderStream _recorder = RecorderStream();
  late StreamSubscription _recorderStatus;
  late StreamSubscription<List<int>> _audioStreamSubscription;
  late BehaviorSubject<List<int>> _audioStream;

  bool isRecommend = true;

  @override
  void initState() {
    super.initState();
    initPlugin();
    _animationIconMenuController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    setState(() {
      suggestion = suggestions;
    });
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    _audioStreamSubscription.cancel();
    _animationIconMenuController.dispose();
    super.dispose();
  }

  Future<void> initPlugin() async {
    // _recorderStatus = _recorder.status.listen((status) {
    //   if (mounted)
    //     setState(() {
    //       _isRecording = status == SoundStreamStatus.Playing;
    //     });
    // });
    await Future.wait([_recorder.initialize()]);

    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/credentials.json'))}');
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
  }

  void stopStream() async {
    await _recorder.stop();
    await _audioStreamSubscription.cancel();
    await _audioStream.close();
    setState(() {
      isRecommend = false;
    });
  }

  void handleSubmitted(text) async {
    if (text != "Sức khỏe")
      setState(() {
        _isWaitingBot = true;
      });
    _textController.clear();

    //TODO Dialogflow Code
    ChatMessage message = ChatMessage(
      text: text,
      type: true,
    );

    setState(() {
      _messages.insert(0, message);
    });
    late String fulfillmentText;
    late ChatMessage botMessage;
    switch (text) {
      case "Thống kê":
        var data = await APIServices().getDataCovid19();
        if (data != null) {
          fulfillmentText = "**Thống kê mới nhất ngày ${data["date"]}:\n"
              "- Số ca mắc mới: ${data["cases"]}\n"
              "- Số ca đang điều trị: ${data["treating"]}\n"
              "- Số ca khỏi bệnh: ${data["recovered"]}\n"
              "- Số ca tử vong: ${data["death"]}";
          setState(() {
            _isWaitingBot = false;
            isRecommend = false;
          });
          botMessage = ChatMessage(
            text: fulfillmentText,
            type: false,
          );
          setState(() {
            _messages.insert(0, botMessage);
          });
        }
        break;
      case "Sức khỏe":
        break;
      default:
        DetectIntentResponse data =
            await dialogflow.detectIntent(text, 'vi-VN');
        fulfillmentText = data.queryResult.fulfillmentText;
        setState(() {
          _isWaitingBot = false;
          isRecommend = false;
        });
        botMessage = ChatMessage(
          text: fulfillmentText,
          type: false,
        );
        setState(() {
          _messages.insert(0, botMessage);
        });
        break;
    }
  }

  void handleStream() async {
    _recorder.start();

    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((data) {
      print(data);
      _audioStream.add(data);
    });

    // TODO Create SpeechContexts
    // Create an audio InputConfig
    var biasList = SpeechContextV2Beta1(phrases: [
      'Dialogflow CX',
      'Dialogflow Essentials',
      'Action Builder',
      'HIPAA'
    ], boost: 20.0);

    var config = InputConfigV2beta1(
        encoding: 'AUDIO_ENCODING_LINEAR_16',
        languageCode: 'vi-VN',
        sampleRateHertz: 16000,
        singleUtterance: false,
        speechContexts: [biasList]);

    final responseStream =
        dialogflow.streamingDetectIntent(config, _audioStream);
    responseStream.listen((data) {
      setState(() {
        String transcript = data.recognitionResult.transcript;
        String queryText = data.queryResult.queryText;
        String fulfillmentText = data.queryResult.fulfillmentText;

        if (fulfillmentText.isNotEmpty) {
          ChatMessage message = new ChatMessage(
            text: queryText,
            type: true,
          );

          ChatMessage botMessage = new ChatMessage(
            text: fulfillmentText,
            type: false,
          );

          _messages.insert(0, message);
          _textController.clear();
          _messages.insert(0, botMessage);
        }
        if (transcript.isNotEmpty) {
          _textController.text = transcript;
        }
      });
    }, onError: (e) {}, onDone: () {});
  }

  List<String> suggestion = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F9F9),
        toolbarHeight: 90,
        elevation: 1,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/doctor.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Dr.Cowin",
              ),
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          if (_isWaitingBot)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Dr.Cowin đang trả lời...",
              ),
            ),
          if (isRecommend)
            Container(
              height: suggestion.length * 60,
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: AnimatedList(
                  key: _listKey,
                  initialItemCount: suggestion.length,
                  itemBuilder: (context, index, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: RecommendItem(
                          name: suggestion[index],
                          onTap: (result) {
                            if (result == "Sức khỏe") {
                              suggestion = suggestions2;
                            }
                            handleSubmitted(result);
                          }),
                    );
                  }),
            ),
          Divider(height: 1.0),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: IconTheme(
                data: IconThemeData(color: Theme.of(context).backgroundColor),
                child: Container(
                  height: 70,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: TextField(
                          controller: _textController,
                          onChanged: (value) {
                            if (value.isNotEmpty)
                              setState(() {
                                funcSelected = 5;
                              });
                            else
                              setState(() {
                                funcSelected = 0;
                              });
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) handleSubmitted(value);
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: _isRecording
                                ? "Bạn muốn nói gì?"
                                : "Viết ra câu hỏi của bạn...",
                          ),
                        ),
                      ),
                      if (funcSelected != 2 && funcSelected != 5)
                        GestureDetector(
                          onTap: () async {
                            isShowingIconMenu = !isShowingIconMenu;
                            _animationIconMenuController.forward();
                            await showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: "",
                                barrierColor: Colors.transparent,
                                pageBuilder: (context, _, child) {
                                  return MenuRecommend(
                                    onSelected: (id, name) {
                                      setState(() {
                                        funcSelected = id;
                                      });
                                      if (funcSelected == 2) {
                                        setState(() {
                                          _isRecording = true;
                                        });
                                        handleStream();
                                      }
                                      if (funcSelected == 3) {
                                        setState(() {
                                          isRecommend = true;
                                          suggestion = suggestions2;
                                        });
                                      }
                                      if (funcSelected == 4) {
                                        setState(() {
                                          isRecommend = true;
                                          suggestion = suggestions1;
                                        });
                                      }
                                    },
                                  );
                                });
                            isShowingIconMenu = !isShowingIconMenu;
                            _animationIconMenuController.reverse();
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            child: AnimatedIcon(
                              size: 25,
                              color: Colors.white,
                              icon: AnimatedIcons.menu_close,
                              progress: _animationIconMenuController,
                            ),
                          ),
                        ),
                      if (funcSelected == 2 || funcSelected == 5)
                        Row(
                          children: [
                            GestureDetector(
                              child: Icon(
                                Icons.send,
                                size: 30,
                              ),
                              onTap: () {
                                if (_textController.text.isNotEmpty)
                                  handleSubmitted(_textController.text);
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              child: Icon(
                                _isRecording ? Icons.mic_off : Icons.mic,
                                size: 30,
                              ),
                              onTap: () {
                                setState(() {
                                  _isRecording = !_isRecording;
                                });
                                if (_isRecording)
                                  handleStream();
                                else {
                                  stopStream();
                                  setState(() {
                                    funcSelected = 0;
                                  });
                                }
                              },
                              onLongPress: () {
                                handleStream();
                              },
                              onLongPressUp: () {
                                stopStream();
                              },
                              //onTap: _isRecording ? stopStream : handleStream,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )),
        ]),
      ),
    );
  }
}

// ignore: must_be_immutable
class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.type});

  final String text;
  final bool type;

  DateTime date = DateTime.now();

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  )),
              child: Text(
                text,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: RichText(
                text: TextSpan(
                  text: "${date.hour}:${date.minute}",
                ),
              ),
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  )),
              child: Text(
                text,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: RichText(
                text: TextSpan(
                  text: "${date.hour}:${date.minute}",
                ),
              ),
            )
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 27),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
