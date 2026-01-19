// lib/screens/admin/admin_users_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/admin_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/user_avatar.dart';
import '../../core/theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _adminService = getIt<AdminService>();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _users = [];
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final response = await _adminService.getUsers(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        page: 1,
        pageSize: 50,
      );

      if (response.success) {
        setState(() {
          _users = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      final response = await _adminService.toggleUserStatus(int.parse(userId));
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? 'User deactivated' : 'User activated',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _filterStatus == null
        ? _users
        : _users.where((u) {
            final isActive = u.isActive ?? true;
            return _filterStatus == 'active' ? isActive : !isActive;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _loadUsers(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (selected) {
                    setState(() => _filterStatus = null);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: _filterStatus == 'active',
                  onSelected: (selected) {
                    setState(() => _filterStatus = selected ? 'active' : null);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactive'),
                  selected: _filterStatus == 'inactive',
                  onSelected: (selected) {
                    setState(
                      () => _filterStatus = selected ? 'inactive' : null,
                    );
                  },
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Loading users...')
                : filteredUsers.isEmpty
                ? const EmptyState(
                    message: 'No users found',
                    icon: Icons.people_outline,
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isActive = user.isActive ?? true;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: UserAvatar(
                              imageUrl: user.profilePictureUrl,
                              name: user.fullName,
                            ),
                            title: Text(user.fullName ?? 'User'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email ?? ''),
                                Text(user.phoneNumber ?? ''),
                                Text(
                                  'Joined: ${user.createdAt ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.primaryGreen.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isActive
                                          ? AppTheme.primaryGreen
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: Icon(
                                    isActive ? Icons.block : Icons.check_circle,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _toggleUserStatus(user.id, isActive),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
