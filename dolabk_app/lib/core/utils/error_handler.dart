// lib/core/utils/error_handler.dart
import 'package:dio/dio.dart';
import 'package:dolabk_app/core/network/api_exceptions.dart';

class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';

        case DioExceptionType.badResponse:
          return _handleResponseError(error.response);

        case DioExceptionType.cancel:
          return 'Request cancelled';

        case DioExceptionType.connectionError:
          return 'No internet connection';

        default:
          return 'Something went wrong';
      }
    } else if (error is ApiException) {
      return error.message;
    } else {
      return error.toString();
    }
  }

  static String _handleResponseError(Response? response) {
    if (response == null) return 'Unknown error occurred';

    switch (response.statusCode) {
      case 400:
        return response.data['message'] ?? 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Error: ${response.statusCode}';
    }
  }
}
