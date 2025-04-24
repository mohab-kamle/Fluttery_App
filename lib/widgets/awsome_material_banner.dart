import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

ScaffoldMessengerState awesomeMaterialBanner({
  required BuildContext context,
  required String title,
  required String message,
  required ContentType contentType,
}) {
  final snackBar = MaterialBanner(
                  
                  elevation: 0,
                  // behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
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
                    title: title,
                    message: message,

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: contentType,
                  ),actions: const [SizedBox.shrink()],
                );

                return ScaffoldMessenger.of(context)
                  ..hideCurrentMaterialBanner()
                  ..showMaterialBanner(snackBar);
}