// lib/services/admin_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/enums.dart';

class AdminService {
  final DioClient _dioClient;

  AdminService(this._dioClient);

  // Get dashboard statistics
  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _dioClient.get('/api/Admin/dashboard');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get all users with pagination and search
  Future<ApiResponse<List<dynamic>>> getUsers({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dioClient.get(
        '/api/Admin/users',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Toggle user status (activate/deactivate)
  Future<ApiResponse<void>> toggleUserStatus(int userId) async {
    try {
      await _dioClient.put('/api/Admin/users/$userId/toggle-status');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get all products (admin view)
  Future<ApiResponse<List<Product>>> getProducts({
    ProductType? type,
    bool? isApproved,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

      if (type != null) {
        queryParams['type'] = type.toString().split('.').last;
      }
      if (isApproved != null) {
        queryParams['isApproved'] = isApproved;
      }

      final response = await _dioClient.get(
        '/api/Admin/products',
        queryParameters: queryParams,
      );

      final products = (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();

      return ApiResponse.success(products);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Delete product (admin)
  Future<ApiResponse<void>> deleteProduct(int productId) async {
    try {
      await _dioClient.delete('/api/Admin/products/$productId');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get all orders (admin view)
  Future<ApiResponse<List<Order>>> getOrders({
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dioClient.get(
        '/api/Admin/orders',
        queryParameters: queryParams,
      );

      final orders = (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();

      return ApiResponse.success(orders);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Update order status
  Future<ApiResponse<void>> updateOrderStatus(
    int orderId,
    OrderStatus status,
  ) async {
    try {
      await _dioClient.put(
        '/api/Admin/orders/$orderId/update-status',
        data: {'status': status.toString().split('.').last},
      );
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Update delivery status
  Future<ApiResponse<void>> updateDeliveryStatus(
    int deliveryId,
    String status, {
    String? courierName,
    String? courierPhone,
    String? deliveryNotes,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};

      if (courierName != null) data['courierName'] = courierName;
      if (courierPhone != null) data['courierPhone'] = courierPhone;
      if (deliveryNotes != null) data['deliveryNotes'] = deliveryNotes;

      await _dioClient.put(
        '/api/Admin/deliveries/$deliveryId/update-status',
        data: data,
      );
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Search users
  Future<ApiResponse<List<dynamic>>> searchUsers(String query) async {
    return getUsers(search: query);
  }

  // Get pending products
  Future<ApiResponse<List<Product>>> getPendingProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(isApproved: false, page: page, pageSize: pageSize);
  }

  // Get approved products
  Future<ApiResponse<List<Product>>> getApprovedProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(isApproved: true, page: page, pageSize: pageSize);
  }

  // Get pending orders
  Future<ApiResponse<List<Order>>> getPendingOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getOrders(
      status: OrderStatus.Pending,
      page: page,
      pageSize: pageSize,
    );
  }

  // Get confirmed orders
  Future<ApiResponse<List<Order>>> getConfirmedOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getOrders(
      status: OrderStatus.Confirmed,
      page: page,
      pageSize: pageSize,
    );
  }

  // Get delivered orders
  Future<ApiResponse<List<Order>>> getDeliveredOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getOrders(
      status: OrderStatus.Delivered,
      page: page,
      pageSize: pageSize,
    );
  }

  // Activate user
  Future<ApiResponse<void>> activateUser(int userId) async {
    return toggleUserStatus(userId);
  }

  // Deactivate user
  Future<ApiResponse<void>> deactivateUser(int userId) async {
    return toggleUserStatus(userId);
  }
}
