import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock user data - replace with actual user provider
  final UserModel _currentUser = UserModel(
    id: 'user123',
    email: 'user@example.com',
    name: 'John Doe',
    phoneNumber: '+254712345678',
    userType: 'individual',
    profileImageUrl: null,
    organizationName: null,
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/home'), // or Navigator.of(context).pop()
        ),
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: _currentUser.profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            _currentUser.profileImageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.green.shade600,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentUser.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    if (_currentUser.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.white, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentUser.userType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats Row
          Container(
            padding: const EdgeInsets.all(20),
            child: Consumer<FoodProvider>(
              builder: (context, foodProvider, child) {
                final userFoodItems = foodProvider.foodItems
                    .where((item) => item.donorId == _currentUser.id)
                    .toList();

                final donatedCount = userFoodItems.length;
                final claimedCount = userFoodItems
                    .where((item) => item.status == 'claimed')
                    .length;
                final totalSaved = userFoodItems
                    .where((item) => item.status == 'claimed')
                    .fold(0, (sum, item) => sum + item.quantity);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Donated',
                      donatedCount.toString(),
                      Icons.volunteer_activism,
                    ),
                    _buildStatCard(
                      'Claimed',
                      claimedCount.toString(),
                      Icons.done_all,
                    ),
                    _buildStatCard(
                      'Items Saved',
                      totalSaved.toString(),
                      Icons.eco,
                    ),
                  ],
                );
              },
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: const [
              Tab(text: 'My Items'),
              Tab(text: 'Claimed'),
              Tab(text: 'Activity'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyItemsTab(),
                _buildClaimedTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyItemsTab() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        final userFoodItems = foodProvider.foodItems
            .where((item) => item.donorId == _currentUser.id)
            .toList();

        if (userFoodItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No items donated yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start sharing food to help reduce waste!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/add-food'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Food Item'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userFoodItems.length,
          itemBuilder: (context, index) {
            final item = userFoodItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(item.status),
                  child: Icon(_getStatusIcon(item.status), color: Colors.white),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.quantity} ${item.unit} • ${item.category}'),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(item.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(item.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () => context.go('/food-detail/${item.id}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClaimedTab() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        final claimedItems = foodProvider.foodItems
            .where((item) => item.claimedBy == _currentUser.id)
            .toList();

        if (claimedItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No items claimed yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse available food items to claim',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/food-list'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Browse Food'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: claimedItems.length,
          itemBuilder: (context, index) {
            final item = claimedItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.quantity} ${item.unit} • ${item.category}'),
                    const SizedBox(height: 4),
                    Text(
                      'Claimed: ${_formatDate(item.claimedAt!)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/food-detail/${item.id}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        final userActivities = <Map<String, dynamic>>[];

        // Add donated items
        for (final item in foodProvider.foodItems.where(
          (item) => item.donorId == _currentUser.id,
        )) {
          userActivities.add({
            'type': 'donated',
            'item': item,
            'date': item.createdAt,
          });

          if (item.claimedAt != null) {
            userActivities.add({
              'type': 'item_claimed',
              'item': item,
              'date': item.claimedAt,
            });
          }
        }

        // Add claimed items
        for (final item in foodProvider.foodItems.where(
          (item) => item.claimedBy == _currentUser.id,
        )) {
          userActivities.add({
            'type': 'claimed',
            'item': item,
            'date': item.claimedAt,
          });
        }

        // Sort by date
        userActivities.sort((a, b) => b['date'].compareTo(a['date']));

        if (userActivities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No activity yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your food sharing activities will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userActivities.length,
          itemBuilder: (context, index) {
            final activity = userActivities[index];
            final item = activity['item'];
            final type = activity['type'];
            final date = activity['date'];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(type),
                  child: Icon(_getActivityIcon(type), color: Colors.white),
                ),
                title: Text(
                  _getActivityTitle(type),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/food-detail/${item.id}'),
              ),
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to notifications settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to help
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement logout logic
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'claimed':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'claimed':
        return Icons.shopping_bag;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.pending;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'donated':
        return Colors.green;
      case 'claimed':
        return Colors.blue;
      case 'item_claimed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'donated':
        return Icons.volunteer_activism;
      case 'claimed':
        return Icons.shopping_bag;
      case 'item_claimed':
        return Icons.person;
      default:
        return Icons.timeline;
    }
  }

  String _getActivityTitle(String type) {
    switch (type) {
      case 'donated':
        return 'Donated food item';
      case 'claimed':
        return 'Claimed food item';
      case 'item_claimed':
        return 'Your item was claimed';
      default:
        return 'Activity';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
