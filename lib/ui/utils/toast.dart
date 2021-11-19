import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

  void toastMsg(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      // gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      // backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }