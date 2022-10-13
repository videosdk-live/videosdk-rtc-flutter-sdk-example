import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';

// Toast
void toastMsg(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    timeInSecForIosWeb: 1,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void showSnackBarMessage(
    {required String message,
    Widget? icon,
    Color messageColor = black900,
    required BuildContext context}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          if (icon != null) icon,
          Text(
            message,
            style: TextStyle(
              color: messageColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      )));
}
