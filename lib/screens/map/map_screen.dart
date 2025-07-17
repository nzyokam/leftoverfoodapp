import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/food_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/food_item_model.dart';
import '../../services/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedCategory = 'All';
  double _radiusFilter = 5.0; // km

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Grains',
    'Bakery',
    'Prepared Food',
    'Beverages',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);

    locationProvider.getCurrentLocation();
    foodProvider.fetchFoodItems();
  }

  List<FoodItemModel> _getFilteredFoodItems(
    List<FoodItemModel> foodItems,
    Position? currentPosition,
  ) {
    if (currentPosition == null) return foodItems;

    return foodItems.where((item) {
      // Category filter
      bool categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      // Distance filter
      double distance = LocationService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        item.latitude,
        item.longitude,
      );
      bool withinRadius = distance <= _radiusFilter;

      // Only show available items
      bool isAvailable = item.status == 'available';

      return categoryMatch && withinRadius && isAvailable;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Map'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer2<FoodProvider, LocationProvider>(
        builder: (context, foodProvider, locationProvider, child) {
          if (foodProvider.isLoading || locationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (foodProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${foodProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (locationProvider.currentPosition == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Location access required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable location services to view nearby food items',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => locationProvider.getCurrentLocation(),
                    child: const Text('Enable Location'),
                  ),
                ],
              ),
            );
          }

          final filteredFoodItems = _getFilteredFoodItems(
            foodProvider.foodItems,
            locationProvider.currentPosition,
          );

          return Column(
            children: [
              // Map placeholder (since we don't have actual map integration)
              Container(
                height: 300,
                margin: const EdgeInsets.all(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      locationProvider.currentPosition!.latitude,
                      locationProvider.currentPosition!.longitude,
                    ),
                    initialZoom: 13.0,
                    maxZoom: 19.0,
                    minZoom: 3.0,
                    // optional: interactionOptions, etc.
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName:
                          'com.nzyoka.foodshare', // Match from AndroidManifest.xml
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: filteredFoodItems.map((item) {
                        return Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(item.latitude, item.longitude),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 36,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Filter info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withAlpha(75)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Showing $_selectedCategory within ${_radiusFilter.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Food items list
              Expanded(
                child: filteredFoodItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No food items found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or check back later',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredFoodItems.length,
                        itemBuilder: (context, index) {
                          final foodItem = filteredFoodItems[index];
                          final distance = LocationService.calculateDistance(
                            locationProvider.currentPosition!.latitude,
                            locationProvider.currentPosition!.longitude,
                            foodItem.latitude,
                            foodItem.longitude,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text(
                                  foodItem.category
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                foodItem.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${foodItem.quantity} ${foodItem.unit}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${distance.toStringAsFixed(1)} km away',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      foodItem.category,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getTimeUntilExpiry(foodItem.expiryDate),
                                    style: TextStyle(
                                      color: _getExpiryColor(
                                        foodItem.expiryDate,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.go('/food-detail/${foodItem.id}');
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-food'),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Options'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Radius:'),
                  const SizedBox(height: 8),
                  Slider(
                    value: _radiusFilter,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    label: '${_radiusFilter.toStringAsFixed(1)} km',
                    onChanged: (value) {
                      setDialogState(() {
                        _radiusFilter = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Filters are already updated in the dialog
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getTimeUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Expired';
    }
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.inDays > 1) {
      return Colors.green;
    } else if (difference.inHours > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
