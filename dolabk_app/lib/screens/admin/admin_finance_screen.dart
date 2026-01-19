// lib/screens/admin/admin_finance_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/admin_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({Key? key}) : super(key: key);

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  final _adminService = getIt<AdminService>();

  bool _isLoading = true;
  dynamic _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);

    try {
      final response = await _adminService.getDashboard();
      if (response.success) {
        setState(() {
          _dashboardData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinancialData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading financial data...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: AppTheme.primaryGreen,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '\${(_dashboardData?.totalRevenue ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Total Revenue',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: AppTheme.orange,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '\${(_dashboardData?.totalCommission ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Commission',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Transaction History
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.softGray,
                            child: Icon(
                              index % 2 == 0
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: index % 2 == 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text('Transaction #${1000 + index}'),
                          subtitle: Text('${index + 1} days ago'),
                          trailing: Text(
                            '${index % 2 == 0 ? '+' : '-'}\${(100 + index * 10).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: index % 2 == 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
