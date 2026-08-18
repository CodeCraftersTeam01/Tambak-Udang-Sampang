import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  /// Displays a success toast notification at the top of the screen.
  static void showSuccess(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF1E1E2E),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays an error toast notification at the top of the screen.
  static void showError(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFE53E3E), // Red error background
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
