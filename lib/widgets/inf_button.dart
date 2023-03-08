import 'package:flutter/material.dart';

/// this is a button that shows a dialog with info
/// it is used in most of the pages
class InfoButton extends StatelessWidget {
  const InfoButton({Key? key, required this.infoText}) : super(key: key);
  final String infoText;

  /// shows a dialog with info
  void showInfo(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Info:"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    infoText,
                  )
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                autofocus: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "info",
      icon: const Icon(Icons.info_outline),
      onPressed: () => showInfo(context),
    );
  }
}
