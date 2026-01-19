// lib/services/user_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/user_model.dart';
import '../models/update_profile_dto.dart';
import '../models/product_model.dart';

class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  // Get user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _dioClient.get('/api/User/profile');
      final user = User.fromJson(response.data);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Update user profile
  Future<ApiResponse<void>> updateProfile(UpdateProfileDto profileDto) async {
    try {
      await _dioClient.put('/api/User/profile', data: profileDto.toJson());
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Update profile with image
  Future<ApiResponse<void>> updateProfileWithImage(
    UpdateProfileDto profileDto,
    String imagePath,
  ) async {
    try {
      // First upload the image
      final uploadResponse = await _uploadProfileImage(imagePath);

      if (uploadResponse.success && uploadResponse.data != null) {
        // Then update profile with the image URL
        final updatedDto = UpdateProfileDto(
          fullName: profileDto.fullName,
          phoneNumber: profileDto.phoneNumber,
          profileImageUrl: uploadResponse.data,
        );

        return await updateProfile(updatedDto);
      }

      return ApiResponse.error('Failed to upload profile image');
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Upload profile image
  Future<ApiResponse<String>> _uploadProfileImage(String imagePath) async {
    try {
      final response = await _dioClient.uploadFile(
        '/api/Upload/profile-image', // You may need to create this endpoint
        imagePath,
        'file',
      );

      final imageUrl = response.data['url'] ?? response.data['imageUrl'];
      return ApiResponse.success(imageUrl);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get user by ID
  Future<ApiResponse<User>> getUserById(int id) async {
    try {
      final response = await _dioClient.get('/api/User/$id');
      final user = User.fromJson(response.data);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get user products
  Future<ApiResponse<List<Product>>> getUserProducts(int id) async {
    try {
      final response = await _dioClient.get('/api/User/$id/products');

      final products = (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();

      return ApiResponse.success(products);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get user wallet balance
  Future<ApiResponse<double>> getWalletBalance() async {
    try {
      final response = await _dioClient.get('/api/User/wallet');
      final balance = (response.data['balance'] ?? 0.0).toDouble();
      return ApiResponse.success(balance);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Quick update profile
  Future<ApiResponse<void>> quickUpdateProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    final profileDto = UpdateProfileDto(
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    return updateProfile(profileDto);
  }
}
