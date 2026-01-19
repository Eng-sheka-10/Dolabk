// lib/screens/product/product_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../services/product_service.dart';
import '../../services/user_service.dart';
import '../../services/review_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/app_theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _productService = getIt<ProductService>();
  final _userService = getIt<UserService>();
  final _reviewService = getIt<ReviewService>();

  bool _isLoading = true;
  String? _error;
  dynamic _product;
  dynamic _seller;
  List<dynamic> _reviews = [];
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final productResponse = await _productService.getProductById(
        widget.productId,
      );

      if (productResponse.success && productResponse.data != null) {
        _product = productResponse.data;

        // Load seller info
        if (_product.userId != null) {
          final sellerResponse = await _userService.getUserById(
            _product.userId,
          );
          if (sellerResponse.success) {
            _seller = sellerResponse.data;
          }

          // Load reviews
          final reviewsResponse = await _reviewService.getUserReviews(
            _product.userId,
          );
          if (reviewsResponse.success) {
            _reviews = reviewsResponse.data ?? [];
          }
        }

        setState(() => _isLoading = false);
      } else {
        setState(() {
          _error = productResponse.message ?? 'Product not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addItem(
      CartItem(
        productId: _product.id,
        productName: _product.name,
        price: (_product.price ?? 0).toDouble(),
        imageUrl: _product.images?.isNotEmpty == true
            ? _product.images!.first.imageUrl
            : null,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        backgroundColor: AppTheme.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showRentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rent Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select rental duration:'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of days',
                suffixText: 'days',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Price per day: \$${(_product.rentPricePerDay ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addToCart();
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  void _showExchangeDialog() {
    Navigator.pop(context);
    // TODO: Navigate to exchange offer screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exchange feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingIndicator(message: 'Loading product...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: _error!, onRetry: _loadProductDetails),
      );
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: isDesktop ? 500 : 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _product.images?.isNotEmpty == true
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: _product.images!.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              _product.images![index].imageUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppTheme.softGray,
                                child: const Icon(Icons.image, size: 100),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _product.images!.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppTheme.softGray,
                      child: const Icon(Icons.image, size: 100),
                    ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _product.name ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_product.type != 'Exchange')
                            Text(
                              _product.type == 'Rent'
                                  ? '\$${(_product.rentPricePerDay ?? 0).toStringAsFixed(2)}/day'
                                  : '\$${(_product.price ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          StatusBadge(type: _product.type ?? 'Sale'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Condition
                  if (_product.condition != null)
                    Row(
                      children: [
                        const Text(
                          'Condition: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(_product.condition!),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description ?? 'No description available',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Seller Info
                  const Text(
                    'Seller Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: UserAvatar(
                        imageUrl: _seller?.profilePictureUrl,
                        name: _seller?.fullName,
                        size: 50,
                      ),
                      title: Text(_seller?.fullName ?? 'Unknown Seller'),
                      subtitle: Row(
                        children: [
                          RatingStars(rating: _seller?.rating?.toDouble() ?? 0),
                          const SizedBox(width: 8),
                          Text('${_reviews.length} reviews'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          // TODO: Navigate to chat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat feature coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_product.type == 'Sale') ...[
                Expanded(
                  child: CustomButton(
                    text: 'Add to Cart',
                    onPressed: _addToCart,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Buy Now',
                    onPressed: () {
                      _addToCart();
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              ],
              if (_product.type == 'Rent')
                Expanded(
                  child: CustomButton(
                    text: 'Rent Now',
                    onPressed: _showRentDialog,
                  ),
                ),
              if (_product.type == 'Exchange')
                Expanded(
                  child: CustomButton(
                    text: 'Propose Exchange',
                    onPressed: _showExchangeDialog,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
