import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  Future<bool> isInternetAvailable(context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult[0] == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult[0] == ConnectivityResult.wifi) {
      return true;
    } else {
      showAlertDialog(
        context: context,
        title: 'Internet',
        contentText: 'Please check your internet connection',
        contentWidget: Container(
          color: Colors.red,
          child: Text(
            'Please check your internet connection',
            style: TextStyle(color: Colors.white),
          ),
          padding: EdgeInsets.all(20),
        ),
        yesButtonText: 'Ok',
        noButtonText: 'Cancel',
      );
      return false;
    }
  }

  void showAlertDialog({
    required context,
    title,
    titleWidget,
    contentText,
    contentWidget,
    yesButtonText,
    noButtonText,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: titleWidget ?? Text(title),
          content: contentWidget ?? Text(contentText),
          actions: [
            yesButtonText != null
                ? TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(yesButtonText),
            )
                : Container(),
            noButtonText != null
                ? TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(noButtonText),
            )
                : Container(),
          ],
        );
      },
    );
  }
}
