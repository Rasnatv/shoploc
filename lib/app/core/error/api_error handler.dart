//
// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
//
// class ApiErrorHandler {
//   // Prevents multiple concurrent 401 responses from each pushing
//   // LoginScreen separately (duplicate route entries in the nav stack).
//   static bool _isHandlingUnauthorized = false;
//
//   static Future<String> handleDioError(DioException e) async {
//     final statusCode = e.response?.statusCode;
//     final responseData = e.response?.data;
//     final message = _extractErrorMessage(responseData);
//
//     String errorMsg;
//
//     switch (statusCode) {
//       case 400:
//         errorMsg = message ?? "Bad request. Please try again.";
//         break;
//       case 401:
//         errorMsg = message ?? "Session expired. Please log in again.";
//         await _handleUnauthorized();
//         break;
//       case 403:
//         errorMsg = message ?? "Access denied.";
//         break;
//       case 404:
//         errorMsg = message ?? "Not found.";
//         break;
//       case 422:
//         errorMsg = message ?? "Validation error. Please check your input.";
//         break;
//       case 429:
//         errorMsg = "Too many requests. Please try again.";
//         break;
//       case 500:
//         errorMsg = message ?? "Server error. Try again later.";
//         break;
//       case 508:
//         errorMsg = "Resource limit reached. Please try again later.";
//         break;
//       default:
//         switch (e.type) {
//           case DioExceptionType.connectionTimeout:
//           case DioExceptionType.sendTimeout:
//           case DioExceptionType.receiveTimeout:
//             errorMsg = "Request timed out. Please try again.";
//             break;
//           case DioExceptionType.connectionError:
//             errorMsg = await _connectionErrorMessage();
//             break;
//           case DioExceptionType.cancel:
//             errorMsg = "Request cancelled.";
//             break;
//           case DioExceptionType.unknown:
//           default:
//             errorMsg = _handleException(e.error);
//         }
//     }
//
//     return errorMsg;
//   }
//
//   static String? _extractErrorMessage(dynamic responseData) {
//     try {
//       if (responseData == null) return null;
//
//       if (responseData is Map<String, dynamic>) {
//         if (responseData['message'] != null) return responseData['message'].toString();
//         if (responseData['error'] != null) return responseData['error'].toString();
//
//         if (responseData['errors'] is Map<String, dynamic>) {
//           final errors = responseData['errors'] as Map<String, dynamic>;
//           if (errors.isNotEmpty) {
//             final firstValue = errors.values.first;
//             if (firstValue is List && firstValue.isNotEmpty) return firstValue.first.toString();
//             return firstValue.toString();
//           }
//         }
//       }
//
//       if (responseData is String) {
//         try {
//           final decoded = jsonDecode(responseData);
//           if (decoded is Map<String, dynamic>) {
//             return decoded['message']?.toString() ?? decoded['error']?.toString();
//           }
//           return responseData;
//         } catch (_) {
//           return responseData.isNotEmpty ? responseData : null;
//         }
//       }
//     } catch (_) {}
//
//     return null;
//   }
//
//   static Future<void> _handleUnauthorized() async {
//     if (_isHandlingUnauthorized) return;
//     _isHandlingUnauthorized = true;
//
//     try {
//       final token = await TokenStorage.readToken();
//       if (token != null && token.isNotEmpty) {
//         await TokenStorage.clear();
//         AppRouter.router.go('/login'); // go_router, not pushAndRemoveUntil
//       }
//     } finally {
//       _isHandlingUnauthorized = false;
//     }
//   }
//
//   // Only says "no internet" if the device really can't reach the internet.
//   // If the internet works, the problem is the server / DNS.
//   static Future<String> _connectionErrorMessage() async {
//     try {
//       final result = await InternetAddress.lookup('google.com')
//           .timeout(const Duration(seconds: 60));
//       if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
//         return "Unable to reach the server. Please try again later.";
//       }
//     } catch (_) {}
//     return "No internet connection.";
//   }
//
//   static String _handleException(Object? error) {
//     if (error is SocketException) {
//       return "Unable to reach the server. Please try again later.";
//     }
//     return "Something went wrong. Please try again.";
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import '../../data/models/statemodel.dart';
import '../utils/object_factory.dart';

class DioErrorHandler {
  /// Session is cleared when a request that carried a token gets a 401
  /// (expired / rejected token). A guest's 401 is ignored.
  static void _handleUnauthorized(DioException e) {
    final sent = (e.requestOptions.headers['Authorization'] ?? '').toString();
    if (sent.isEmpty) return;
    final prefs = ObjectFactory().prefs;
    if (prefs.isLoggedIn() != true) return; // already cleared (parallel 401s)
    prefs.clearSession(); // token, user id/name/email, isLoggedIn=false
  }

  static StateModel<T> handle<T>(DioException e) {
    final code = e.response?.statusCode;
    final msg = _extract(e.response?.data);

    switch (code) {
      case 400:
        return StateModel.error(msg ?? 'Bad request. Please try again.');
      case 401:
        _handleUnauthorized(e);
        return StateModel.error(msg ?? 'Unauthorized. Please login again.');
      case 403:
        return StateModel.error(msg ?? 'Access denied.');
      case 404:
        return StateModel.error(msg ?? 'Not found.');
      case 422:
        return StateModel.error(msg ?? 'Validation error. Please check your input.');
      case 429:
        return StateModel.error('Too many requests. Please try again.');
      case 500:
        return StateModel.error(msg ?? 'Server error. Try again later.');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return StateModel.error('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return StateModel.error('No internet connection.');
      case DioExceptionType.cancel:
        return StateModel.error('Request cancelled.');
      default:
        return StateModel.error(e.error is SocketException
            ? 'Unable to reach the server. Please try again later.'
            : 'Something went wrong. Please try again.');
    }
  }

  static String? _extract(dynamic data) {
    try {
      if (data == null) return null;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        if (m['message'] != null) return m['message'].toString();
        if (m['error'] != null) return m['error'].toString();
        if (m['errors'] is Map) {
          final errors = Map<String, dynamic>.from(m['errors']);
          if (errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) return first.first.toString();
            return first.toString();
          }
        }
      }
      if (data is String) {
        try {
          final d = jsonDecode(data);
          if (d is Map) return d['message']?.toString() ?? d['error']?.toString();
        } catch (_) {}
        return data.isNotEmpty ? data : null;
      }
    } catch (_) {}
    return null;
  }
}