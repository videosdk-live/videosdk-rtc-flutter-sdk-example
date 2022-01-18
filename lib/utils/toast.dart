import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
