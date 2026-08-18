import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'toast_helper.dart';

class ErrorHandler {
  static bool isNetworkError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return true;
      }
      if (error.error is SocketException || error.error is TimeoutException) {
        return true;
      }
    }
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('socketexception') ||
        errStr.contains('timeout') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('connection refused') ||
        errStr.contains('500') ||
        errStr.contains('502') ||
        errStr.contains('503') ||
        errStr.contains('504') ||
        errStr.contains('gagal memproses data') ||
        errStr.contains('koneksi internet')) {
      return true;
    }
    return false;
  }

  static void handleError(BuildContext context, dynamic error) {
    if (isNetworkError(error)) {
      showNetworkErrorSnackbar(context);
    } else {
      final message = error.toString().replaceAll('Exception: ', '');
      ToastHelper.showError(message);
    }
  }

  static void showNetworkErrorSnackbar(BuildContext context) {
    ToastHelper.showError('Gagal memproses data. Periksa koneksi internet Anda.');
  }
}
