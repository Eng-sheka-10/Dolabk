// lib/screens/exchange/exchange_offers_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/exchange_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/app_theme.dart';

class ExchangeOffersScreen extends StatefulWidget {
  const ExchangeOffersScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeOffersScreen> createState() => _ExchangeOffersScreenState();
}

class _ExchangeOffersScreenState extends State<ExchangeOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _exchangeService = getIt<ExchangeService>();

  bool _isLoading = true;
  String? _error;
  List<dynamic> _receivedOffers = [];
  List<dynamic> _sentOffers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final receivedResponse = await _exchangeService.getReceivedOffers();
      final sentResponse = await _exchangeService.getSentOffers();

      if (receivedResponse.success && sentResponse.success) {
        setState(() {
          _receivedOffers = receivedResponse.data ?? [];
          _sentOffers = sentResponse.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load offers';
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

  Future<void> _acceptOffer(String offerId) async {
    try {
      final response = await _exchangeService.acceptOffer(int.parse(offerId));
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer accepted'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadOffers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    try {
      final response = await _exchangeService.rejectOffer(int.parse(offerId));
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer rejected'),
            backgroundColor: Colors.grey,
          ),
        );
        _loadOffers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _completeOffer(String offerId) async {
    try {
      final response = await _exchangeService.completeOffer(int.parse(offerId));
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exchange completed'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadOffers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildOfferCard(dynamic offer, bool isReceived) {
    final status = offer.status ?? 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isReceived ? 'Received Offer' : 'Sent Offer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(type: status),
              ],
            ),
            const Divider(height: 24),

            // Products
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requested',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.requestedProduct?.name ?? 'Product',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offered',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.offeredProduct?.name ?? 'Product',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (offer.message != null && offer.message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offer.message!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            if (isReceived && status == 'Pending') ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Accept',
                      onPressed: () => _acceptOffer(offer.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Reject',
                      onPressed: () => _rejectOffer(offer.id),
                      isOutlined: true,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],

            if (status == 'Accepted') ...[
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Mark as Completed',
                  onPressed: () => _completeOffer(offer.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Offers'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading offers...')
          : _error != null
          ? ErrorState(message: _error!, onRetry: _loadOffers)
          : TabBarView(
              controller: _tabController,
              children: [
                // Received Offers
                _receivedOffers.isEmpty
                    ? const EmptyState(
                        message: 'No received offers',
                        icon: Icons.inbox_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOffers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _receivedOffers.length,
                          itemBuilder: (context, index) {
                            return _buildOfferCard(
                              _receivedOffers[index],
                              true,
                            );
                          },
                        ),
                      ),

                // Sent Offers
                _sentOffers.isEmpty
                    ? const EmptyState(
                        message: 'No sent offers',
                        icon: Icons.send_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOffers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _sentOffers.length,
                          itemBuilder: (context, index) {
                            return _buildOfferCard(_sentOffers[index], false);
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
