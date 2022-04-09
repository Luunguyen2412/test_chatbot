import 'package:flutter/material.dart';

class RecommendItem extends StatefulWidget {
  final String name;
  final Function(String) onTap;

  const RecommendItem({Key? key, required this.name, required this.onTap})
      : super(key: key);

  @override
  _RecommendItemState createState() => _RecommendItemState();
}

class _RecommendItemState extends State<RecommendItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
    animation!.addListener(() => setState(() {}));
    _controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(widget.name);
      },
      child: Container(
        height: animation!.value * 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Container(
            alignment: Alignment.center,
            child: Text(
              widget.name,
            )),
      ),
    );
  }
}
