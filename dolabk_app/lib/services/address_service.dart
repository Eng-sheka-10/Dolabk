// lib/services/address_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/address_model.dart';
import '../models/create_address_dto.dart';
import '../models/update_address_dto.dart';

class AddressService {
  final DioClient _dioClient;

  AddressService(this._dioClient);

  // Get all addresses
  Future<ApiResponse<List<Address>>> getAddresses() async {
    try {
      final response = await _dioClient.get('/api/Addresses');

      final addresses = (response.data as List)
          .map((json) => Address.fromJson(json))
          .toList();

      return ApiResponse.success(addresses);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get address by ID
  Future<ApiResponse<Address>> getAddressById(int id) async {
    try {
      final response = await _dioClient.get('/api/Addresses/$id');
      final address = Address.fromJson(response.data);
      return ApiResponse.success(address);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Create new address
  Future<ApiResponse<Address>> createAddress(
    CreateAddressDto addressDto,
  ) async {
    try {
      final response = await _dioClient.post(
        '/api/Addresses',
        data: addressDto.toJson(),
      );

      final address = Address.fromJson(response.data);
      return ApiResponse.success(address);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Update address
  Future<ApiResponse<void>> updateAddress(
    int id,
    UpdateAddressDto addressDto,
  ) async {
    try {
      await _dioClient.put('/api/Addresses/$id', data: addressDto.toJson());
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Delete address
  Future<ApiResponse<void>> deleteAddress(int id) async {
    try {
      await _dioClient.delete('/api/Addresses/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Set default address
  Future<ApiResponse<void>> setDefaultAddress(int id) async {
    try {
      await _dioClient.put('/api/Addresses/$id/set-default');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get default address
  Future<ApiResponse<Address?>> getDefaultAddress() async {
    try {
      final response = await getAddresses();
      if (response.success && response.data != null) {
        final defaultAddress = response.data!.firstWhere(
          (address) => address.isDefault,
          orElse: () => response.data!.first,
        );
        return ApiResponse.success(defaultAddress);
      }
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }
}
