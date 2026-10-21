import 'package:flutter/material.dart';

class NotificationBanner extends StatelessWidget {
  final String message;
  final bool visible;

  const NotificationBanner({
    super.key,
    required this.message,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        width: double.infinity,
        color: Colors.green[400],
        padding: const EdgeInsets.all(10),
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
