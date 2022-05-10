import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_chatbot/models/tiki_items_model.dart';

List<TikiQuickItem> parseQuickItem(String responsebody) {
  final parsed = json.decode(responsebody).cast<Map<String, dynamic>>();
  return parsed
      .map<TikiQuickItem>((json) => TikiQuickItem.fromMap(json))
      .toList();
}

Future<List<TikiQuickItem>> fetchQuickItem() async {
  final response =
      await http.get(Uri.parse('https://api.tiki.vn/v2/home/banners/v2'));
  if (response.statusCode == 200) {
    return parseQuickItem(response.body);
  } else {
    throw Exception('Unable to fetch products from the REST API');
  }
}

class HomeTikiScreen extends StatelessWidget {
  final String title;
  final Future<List<TikiQuickItem>> tikiQuickItems;
  const HomeTikiScreen(
      {Key? key, required this.title, required this.tikiQuickItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Tiki Navigation")),
      body: Center(
        child: FutureBuilder<List<TikiQuickItem>>(
          future: tikiQuickItems,
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? TikiItemList(items: snapshot.data)
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
    );
  }
}

class TikiItemList extends StatelessWidget {
  final List<TikiQuickItem>? items;
  const TikiItemList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items?.length,
      itemBuilder: (context, index) {
        return Ink(
          child: TikiItem(item: items![index]),
        );
      },
    );
  }
}

class TikiItem extends StatelessWidget {
  final TikiQuickItem item;
  const TikiItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                this.item.image_url,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(this.item.title),
        ],
      ),
    );
  }
}
