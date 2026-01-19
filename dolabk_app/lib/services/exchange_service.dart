// lib/services/exchange_service.dart
import 'package:dolabk_app/models/enums.dart';

import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/exchange_offer_model.dart';
import '../models/create_exchange_offer_dto.dart';

class ExchangeService {
  final DioClient _dioClient;

  ExchangeService(this._dioClient);

  // Create exchange offer
  Future<ApiResponse<ExchangeOffer>> createOffer(
    CreateExchangeOfferDto offerDto,
  ) async {
    try {
      final response = await _dioClient.post(
        '/api/Exchange/create-offer',
        data: offerDto.toJson(),
      );

      final offer = ExchangeOffer.fromJson(response.data);
      return ApiResponse.success(offer);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get exchange offer by ID
  Future<ApiResponse<ExchangeOffer>> getOfferById(int id) async {
    try {
      final response = await _dioClient.get('/api/Exchange/$id');
      final offer = ExchangeOffer.fromJson(response.data);
      return ApiResponse.success(offer);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get received exchange offers
  Future<ApiResponse<List<ExchangeOffer>>> getReceivedOffers({
    ExchangeStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dioClient.get(
        '/api/Exchange/received',
        queryParameters: queryParams,
      );

      final offers = (response.data as List)
          .map((json) => ExchangeOffer.fromJson(json))
          .toList();

      return ApiResponse.success(offers);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get sent exchange offers
  Future<ApiResponse<List<ExchangeOffer>>> getSentOffers({
    ExchangeStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dioClient.get(
        '/api/Exchange/sent',
        queryParameters: queryParams,
      );

      final offers = (response.data as List)
          .map((json) => ExchangeOffer.fromJson(json))
          .toList();

      return ApiResponse.success(offers);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Accept exchange offer
  Future<ApiResponse<void>> acceptOffer(int id) async {
    try {
      await _dioClient.put('/api/Exchange/$id/accept');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Reject exchange offer
  Future<ApiResponse<void>> rejectOffer(int id) async {
    try {
      await _dioClient.put('/api/Exchange/$id/reject');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Complete exchange offer
  Future<ApiResponse<void>> completeOffer(int id) async {
    try {
      await _dioClient.put('/api/Exchange/$id/complete');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get pending received offers
  Future<ApiResponse<List<ExchangeOffer>>> getPendingReceivedOffers() async {
    return getReceivedOffers(status: ExchangeStatus.Pending);
  }

  // Get accepted received offers
  Future<ApiResponse<List<ExchangeOffer>>> getAcceptedReceivedOffers() async {
    return getReceivedOffers(status: ExchangeStatus.Accepted);
  }

  // Get pending sent offers
  Future<ApiResponse<List<ExchangeOffer>>> getPendingSentOffers() async {
    return getSentOffers(status: ExchangeStatus.Pending);
  }

  // Get accepted sent offers
  Future<ApiResponse<List<ExchangeOffer>>> getAcceptedSentOffers() async {
    return getSentOffers(status: ExchangeStatus.Accepted);
  }

  // Get completed offers
  Future<ApiResponse<List<ExchangeOffer>>> getCompletedOffers() async {
    return getSentOffers(status: ExchangeStatus.Completed);
  }
}
