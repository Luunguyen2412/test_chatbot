import 'package:flutter/material.dart';

class MenuRecommend extends StatefulWidget {
  final Function(int, String) onSelected;
  const MenuRecommend({Key? key, required this.onSelected}) : super(key: key);

  @override
  _MenuRecommendState createState() => _MenuRecommendState();
}

class _MenuRecommendState extends State<MenuRecommend> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height - 300,
        bottom: 50,
        left: 10,
        right: 10,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        height: 270,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                widget.onSelected(1, "Về chúng tôi");
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Về chúng tôi",
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.onSelected(2, "Sử dụng giọng nói");
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Sử dụng giọng nói",
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.onSelected(3, "Sức khỏe của bạn");
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Sức khỏe",
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.onSelected(4, "COVID-19");
                Navigator.pop(context);
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "COVID-19",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
