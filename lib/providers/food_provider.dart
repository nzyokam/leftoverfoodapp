import 'package:flutter/foundation.dart';
import '../models/food_item_model.dart';
import '../services/api_service.dart';

class FoodProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FoodItemModel> _foodItems = [];
  bool _isLoading = false;
  String? _error;

  List<FoodItemModel> get foodItems => _foodItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<FoodItemModel> get recentFoods {
    final items = [..._foodItems];
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> fetchFoodItems({String? category, double? radius}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get('/food-items');

      if (response['success']) {
        _foodItems = (response['data'] as List)
            .map((item) => FoodItemModel.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to fetch food items');
      }
    } catch (e) {
      _setError('Error fetching food items: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createFoodItem(FoodItemModel foodItem) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post('/food-items', foodItem.toJson());

      if (response['success']) {
        _foodItems.add(FoodItemModel.fromJson(response['data']));
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to create food item');
        return false;
      }
    } catch (e) {
      _setError('Error creating food item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> claimFoodItem(String foodItemId) async {
    try {
      final response = await _apiService.post(
        '/food-items/$foodItemId/claim',
        {},
      );

      if (response['success']) {
        final index = _foodItems.indexWhere((item) => item.id == foodItemId);
        if (index != -1) {
          _foodItems[index] = FoodItemModel.fromJson(response['data']);
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to claim food item');
        return false;
      }
    } catch (e) {
      _setError('Error claiming food item: ${e.toString()}');
      return false;
    }
  }

  Future<void> refreshFoods() async {
    await fetchFoodItems();
  }

  void clearFoodItems() {
    _foodItems = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
