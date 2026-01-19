// lib/services/order_service.dart
import 'package:dolabk_app/models/enums.dart';

import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/order_model.dart';
import '../models/create_order_dto.dart';

class OrderService {
  final DioClient _dioClient;

  OrderService(this._dioClient);

  // Create new order
  Future<ApiResponse<Order>> createOrder(CreateOrderDto orderDto) async {
    try {
      final response = await _dioClient.post(
        '/api/Orders/create',
        data: orderDto.toJson(),
      );

      final order = Order.fromJson(response.data);
      return ApiResponse.success(order);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get order by ID
  Future<ApiResponse<Order>> getOrderById(int id) async {
    try {
      final response = await _dioClient.get('/api/Orders/$id');
      final order = Order.fromJson(response.data);
      return ApiResponse.success(order);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get my orders
  Future<ApiResponse<List<Order>>> getMyOrders({
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
        '/api/Orders/my-orders',
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

  // Cancel order
  Future<ApiResponse<void>> cancelOrder(int id) async {
    try {
      await _dioClient.put('/api/Orders/$id/cancel');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get pending orders
  Future<ApiResponse<List<Order>>> getPendingOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getMyOrders(
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
    return getMyOrders(
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
    return getMyOrders(
      status: OrderStatus.Delivered,
      page: page,
      pageSize: pageSize,
    );
  }
}
