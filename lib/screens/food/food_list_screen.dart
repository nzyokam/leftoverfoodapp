import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/food_card.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'Recent';

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Meat',
    'Dairy',
    'Grains',
    'Prepared Food',
    'Beverages',
  ];

  final List<String> _sortOptions = [
    'Recent',
    'Distance',
    'Expiry Date',
    'Alphabetical',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Food'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go('/home'), // or Navigator.of(context).pop()
  ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for food items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Implement search functionality
                setState(() {});
              },
            ),
          ),
          
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.green.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.green : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Sort Options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by: $_sortBy',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: _showSortBottomSheet,
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          
          // Food List
          Expanded(
            child: Consumer<FoodProvider>(
              builder: (context, foodProvider, child) {
                final foods = _getFilteredFoods(foodProvider.foodItems);
                
                if (foods.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No food items found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await foodProvider.refreshFoods();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FoodCard(
                          foodItem: food,
                          onTap: () => context.go('/food-detail/${food.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-food'),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<dynamic> _getFilteredFoods(List<dynamic> foods) {
    var filtered = foods;
    
    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((food) {
        return food.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               food.description.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((food) {
        return food.category == _selectedCategory;
      }).toList();
    }
    
    // Sort foods
    switch (_sortBy) {
      case 'Recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Distance':
        // Implement distance sorting
        break;
      case 'Expiry Date':
        filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Options',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Distance Filter
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Within 5 km'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Implement distance filter
                  },
                ),
              ),
              
              // Availability Filter
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Available now'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Implement availability filter
                  },
                ),
              ),
              
              // Free Food Filter
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Free only'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Implement free food filter
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Clear filters
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._sortOptions.map((option) {
                return ListTile(
                  title: Text(option),
                  trailing: _sortBy == option ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() {
                      _sortBy = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}