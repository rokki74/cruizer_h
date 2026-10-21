import 'package:flutter/material.dart';

Future<void> showLoadingDialog(
  BuildContext context, {
  String message = "Please wait...",
}) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Loading",
    barrierColor: Colors.black54, // dim background
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: FadeTransition(
          opacity: animation,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Flexible(
                    child: Text(message, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250), // fade speed
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
