import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedSlider extends StatefulWidget {
  final List<String> tips;
  const AnimatedSlider({super.key, required this.tips});

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<AnimatedSlider> {
  int _index = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _index = (_index + 1) % widget.tips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        color: Colors.teal.shade100,
        child: Container(
          height: 120,
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            widget.tips[_index],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
