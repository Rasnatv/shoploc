import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import '../../data/models/statemodel.dart';

class DioErrorHandler {
  static StateModel<T> handle<T>(DioException e) {
    final code = e.response?.statusCode;
    final msg = _extract(e.response?.data);

    switch (code) {
      case 400:
        return StateModel.error(msg ?? 'Bad request. Please try again.');
      case 401:
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