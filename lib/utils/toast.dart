import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/constants/colors.dart';

void showSnackBarMessage(
    {required String message,
    Widget? icon,
    Color messageColor = black900,
    required BuildContext context}) {
  print("\n--------------------------------------------------");
  print("🔴 [APP LOG / ERROR SNACKBAR]: $message");
  print("--------------------------------------------------\n");

  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Row(
        children: [
          if (icon != null) icon,
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.fade,
            ),
          )
        ],
      )));
}

// 5.0 room actions are Futures that throw VideoSDKError; surface failures instead of dropping them.
extension ShowErrors on Future<void> {
  void showErrors(BuildContext context) => catchError((Object e) {
        if (!context.mounted) return;
        showSnackBarMessage(
            message: e is VideoSDKError ? "${e.name} :: ${e.message}" : "$e",
            context: context);
      });
}
