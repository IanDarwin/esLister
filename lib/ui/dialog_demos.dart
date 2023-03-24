import 'package:flutter/material.dart';

alertWidgetChild(BuildContext context, Widget child, { title = "Error", actions}) {
  showDialog<void>(
      context: context,
      barrierDismissible: true, // must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: child,
          actions: actions ?? <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
  );
}

alert(BuildContext context, String message, {title = 'Error', actions}) async {
  alertWidgetChild(context, Text(message), actions: actions, title: title);
}


