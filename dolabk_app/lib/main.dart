// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_details_screen.dart';
import 'screens/product/add_product_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/exchange/exchange_offers_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/addresses/addresses_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/reviews/reviews_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_finance_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(getIt())),
        ChangeNotifierProvider(create: (_) => ProductProvider(getIt())),
        ChangeNotifierProvider(create: (_) => OrderProvider(getIt())),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SwapMarket',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/add-product': (context) => const AddProductScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/exchange-offers': (context) => const ExchangeOffersScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/addresses': (context) => const AddressesScreen(),
              '/chat': (context) => const ChatScreen(),
              '/admin/dashboard': (context) => const AdminDashboardScreen(),
              '/admin/users': (context) => const AdminUsersScreen(),
              '/admin/products': (context) => const AdminProductsScreen(),
              '/admin/orders': (context) => const AdminOrdersScreen(),
              '/admin/finance': (context) => const AdminFinanceScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name?.startsWith('/product/') ?? false) {
                final id = settings.name!.split('/').last;
                return MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailsScreen(productId: int.parse(id)),
                );
              }
              if (settings.name?.startsWith('/reviews/') ?? false) {
                final id = settings.name!.split('/').last;
                return MaterialPageRoute(
                  builder: (_) => ReviewsScreen(userId: id),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
