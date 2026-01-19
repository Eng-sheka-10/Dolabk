// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _productService = getIt<ProductService>();
  final _searchController = TextEditingController();

  int _selectedIndex = 0;
  String? _selectedCategory;
  String? _selectedCondition;
  double? _minPrice;
  double? _maxPrice;

  bool _isLoading = true;
  String? _error;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadProducts();
      }
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      dynamic response;

      switch (_tabController.index) {
        case 0: // All
          response = await _productService.getProducts(
            category: _selectedCategory,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            page: 1,
            pageSize: 20,
          );
          break;
        case 1: // For Sale
          response = await _productService.getProductsBySale(
            page: 1,
            pageSize: 20,
          );
          break;
        case 2: // For Rent
          response = await _productService.getProductsByRent(
            page: 1,
            pageSize: 20,
          );
          break;
        case 3: // For Exchange
          response = await _productService.getProductsByExchange(
            page: 1,
            pageSize: 20,
          );
          break;
      }

      if (response.success) {
        setState(() {
          _products = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load products';
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

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      _loadProducts();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _productService.searchProducts(
        query,
        page: 1,
        pageSize: 20,
      );

      if (response.success) {
        setState(() {
          _products = response.data ?? [];
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedCondition = null;
                        _minPrice = null;
                        _maxPrice = null;
                      });
                      Navigator.pop(context);
                      _loadProducts();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    const Text(
                      'Condition',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['New', 'Like New', 'Good', 'Fair', 'Poor'].map(
                        (condition) {
                          return FilterChip(
                            label: Text(condition),
                            selected: _selectedCondition == condition,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCondition = selected
                                    ? condition
                                    : null;
                              });
                            },
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Price Range',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Min Price',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _minPrice = double.tryParse(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Max Price',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _maxPrice = double.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadProducts();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 5;
    } else if (isTablet) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwapMarket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: _showFilterDialog,
                    ),
                  ),
                  onSubmitted: _searchProducts,
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryGreen,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'For Sale'),
                  Tab(text: 'For Rent'),
                  Tab(text: 'For Exchange'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading products...')
          : _error != null
          ? ErrorState(message: _error!, onRetry: _loadProducts)
          : _products.isEmpty
          ? EmptyState(
              message: 'No products found',
              icon: Icons.inventory_2_outlined,
              actionText: 'Add Product',
              onAction: () => Navigator.pushNamed(context, '/add-product'),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    productId: product.id ?? '',
                    name: product.name ?? 'Unknown',
                    price: (product.price ?? 0).toDouble(),
                    imageUrl: product.images?.isNotEmpty == true
                        ? product.images!.first.imageUrl
                        : null,
                    condition: product.condition,
                    type: product.type ?? 'Sale',
                    onTap: () =>
                        Navigator.pushNamed(context, '/product/${product.id}'),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-product'),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/exchange-offers');
              break;
            case 2:
              Navigator.pushNamed(context, '/orders');
              break;
            case 3:
              Navigator.pushNamed(context, '/chat');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Exchange',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
