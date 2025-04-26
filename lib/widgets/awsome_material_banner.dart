import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

ScaffoldMessengerState awesomeMaterialBanner({
  required BuildContext context,
  required String title,
  required String message,
  required ContentType contentType,
}) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      messageTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w500,
      ),
    ),
    duration: const Duration(seconds: 4),
  );

  return ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
