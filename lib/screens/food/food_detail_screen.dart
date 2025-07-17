import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../models/food_item_model.dart';
import '../../widgets/custom_button.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;

  const FoodDetailScreen({Key? key, required this.foodId}) : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        FoodItemModel? food;
        try {
          food = foodProvider.foodItems.firstWhere(
            (f) => f.id == widget.foodId,
          );
        } catch (e) {
          food = null;
        }

        if (food == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Food Details')),
            body: const Center(child: Text('Food item not found')),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(food.title),
                    background: food.images.isNotEmpty
                        ? Image.network(food.images.first, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Implement share functionality
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                food.address,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.date_range, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Pickup: ${food.pickupFrom} - ${food.pickupUntil}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.hourglass_bottom,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expires: ${food.expiryDate}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Claim This Food',
                          isLoading: _isRequesting,
                          onPressed: _isRequesting
                              ? null
                              : () async {
                                  setState(() => _isRequesting = true);
                                  final success = await foodProvider
                                      .claimFoodItem(food?.id ?? '');
                                  setState(() => _isRequesting = false);

                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Food claimed successfully!',
                                        ),
                                      ),
                                    );
                                    context.go('/home');
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to claim food.'),
                                      ),
                                    );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
