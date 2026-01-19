// lib/services/product_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/product_model.dart';
import '../models/create_product_dto.dart';
import '../models/update_product_dto.dart';
import '../models/enums.dart';

class ProductService {
  final DioClient _dioClient;

  ProductService(this._dioClient);

  // Get all products with filters
  Future<ApiResponse<List<Product>>> getProducts({
    ProductType? type,
    String? category,
    double? minPrice,
    double? maxPrice,
    ProductCondition? condition,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (condition != null)
        queryParams['condition'] = condition.toString().split('.').last;
      if (search != null) queryParams['search'] = search;
      queryParams['page'] = page;
      queryParams['pageSize'] = pageSize;

      final response = await _dioClient.get(
        '/api/Products',
        queryParameters: queryParams,
      );

      // FIX: Handle both paginated and non-paginated responses
      List<Product> products;
      if (response.data is List) {
        // Direct list response
        products = (response.data as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else if (response.data is Map) {
        // Paginated response with 'items' or 'data' key
        final data = response.data as Map<String, dynamic>;
        final items = data['items'] ?? data['data'] ?? data['products'] ?? [];
        products = (items as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        products = [];
      }

      return ApiResponse.success(products);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get product by ID
  Future<ApiResponse<Product>> getProductById(int id) async {
    try {
      final response = await _dioClient.get('/api/Products/$id');
      final product = Product.fromJson(response.data);
      return ApiResponse.success(product);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Create new product
  Future<ApiResponse<Product>> createProduct(
    CreateProductDto productDto,
  ) async {
    try {
      final response = await _dioClient.post(
        '/api/Products',
        data: productDto.toJson(),
      );

      final product = Product.fromJson(response.data);
      return ApiResponse.success(product);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Create product with images
  Future<ApiResponse<Product>> createProductWithImages(
    CreateProductDto productDto,
    List<String> imagePaths,
  ) async {
    try {
      // First, upload images and get URLs
      List<String> imageUrls = [];
      for (String imagePath in imagePaths) {
        final uploadResponse = await _uploadImage(imagePath);
        if (uploadResponse.success && uploadResponse.data != null) {
          imageUrls.add(uploadResponse.data!);
        }
      }

      // Create product with image URLs
      final productWithImages = CreateProductDto(
        name: productDto.name,
        description: productDto.description,
        price: productDto.price,
        rentPricePerDay: productDto.rentPricePerDay,
        type: productDto.type,
        condition: productDto.condition,
        category: productDto.category,
        imageUrls: imageUrls,
      );

      return await createProduct(productWithImages);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Upload single image
  Future<ApiResponse<String>> _uploadImage(String imagePath) async {
    try {
      final response = await _dioClient.uploadFile(
        '/api/Upload/image',
        imagePath,
        'file',
      );

      final imageUrl = response.data['url'] ?? response.data['imageUrl'];
      return ApiResponse.success(imageUrl);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Update product
  Future<ApiResponse<void>> updateProduct(
    int id,
    UpdateProductDto productDto,
  ) async {
    try {
      await _dioClient.put('/api/Products/$id', data: productDto.toJson());
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Delete product
  Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      await _dioClient.delete('/api/Products/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get my products
  Future<ApiResponse<List<Product>>> getMyProducts() async {
    try {
      final response = await _dioClient.get('/api/Products/my-products');

      // FIX: Handle both paginated and non-paginated responses
      List<Product> products;
      if (response.data is List) {
        products = (response.data as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final items = data['items'] ?? data['data'] ?? data['products'] ?? [];
        products = (items as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        products = [];
      }

      return ApiResponse.success(products);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get product categories
  Future<ApiResponse<List<String>>> getCategories() async {
    try {
      final response = await _dioClient.get('/api/Products/categories');
      final categories = (response.data as List).cast<String>();
      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get products by sale type
  Future<ApiResponse<List<Product>>> getProductsBySale({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(type: ProductType.Sale, page: page, pageSize: pageSize);
  }

  // Get products by rent type
  Future<ApiResponse<List<Product>>> getProductsByRent({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(type: ProductType.Rent, page: page, pageSize: pageSize);
  }

  // Get products by exchange type
  Future<ApiResponse<List<Product>>> getProductsByExchange({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(
      type: ProductType.Exchange,
      page: page,
      pageSize: pageSize,
    );
  }

  // Search products
  Future<ApiResponse<List<Product>>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(search: query, page: page, pageSize: pageSize);
  }

  // Filter products by price range
  Future<ApiResponse<List<Product>>> filterByPriceRange(
    double minPrice,
    double maxPrice, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      pageSize: pageSize,
    );
  }

  // Filter products by category
  Future<ApiResponse<List<Product>>> filterByCategory(
    String category, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return getProducts(category: category, page: page, pageSize: pageSize);
  }
}
