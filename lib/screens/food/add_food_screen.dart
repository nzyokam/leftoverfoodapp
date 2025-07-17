import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/food_item_model.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'kg';
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 1));
  DateTime _selectedPickupFrom = DateTime.now();
  DateTime _selectedPickupUntil = DateTime.now().add(const Duration(hours: 24));
  final List<String> _selectedAllergens = [];
  
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Grains',
    'Bakery',
    'Prepared Food',
    'Beverages',
    'Other'
  ];

  final List<String> _units = ['kg', 'g', 'pieces', 'liters', 'ml', 'portions'];
  
  final List<String> _allergenOptions = [
    'Nuts',
    'Dairy',
    'Eggs',
    'Gluten',
    'Soy',
    'Shellfish',
    'Fish'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Get current location for address
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.getCurrentLocation().then((_) {
        if (locationProvider.currentAddress != null) {
          _addressController.text = locationProvider.currentAddress!;
        }
      });
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      if (locationProvider.currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final foodItem = FoodItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        donorId: 'current_user_id', // Replace with actual user ID
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit,
        images: [], // TODO: Add image upload functionality
        expiryDate: _selectedExpiryDate,
        pickupFrom: _selectedPickupFrom,
        pickupUntil: _selectedPickupUntil,
        latitude: locationProvider.currentPosition!.latitude,
        longitude: locationProvider.currentPosition!.longitude,
        address: _addressController.text,
        allergens: _selectedAllergens,
        status: 'available',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await foodProvider.createFoodItem(foodItem);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/food-list');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(foodProvider.error ?? 'Failed to add food item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 30));

    if (type == 'expiry') {
      initialDate = _selectedExpiryDate;
    } else if (type == 'pickup_from') {
      initialDate = _selectedPickupFrom;
    } else if (type == 'pickup_until') {
      initialDate = _selectedPickupUntil;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (type == 'expiry') {
            _selectedExpiryDate = selectedDateTime;
          } else if (type == 'pickup_from') {
            _selectedPickupFrom = selectedDateTime;
          } else if (type == 'pickup_until') {
            _selectedPickupUntil = selectedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/food-list'),
        ),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Food Image Upload Section
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Food Photo',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Food Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Food Title',
                      hintText: 'Enter food title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter food title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity and Unit Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter quantity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: _units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUnit = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter food description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expiry Date
                  ListTile(
                    title: const Text('Expiry Date'),
                    subtitle: Text(_selectedExpiryDate.toString().split('.')[0]),
                    leading: const Icon(Icons.calendar_today),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _selectDate(context, 'expiry'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pickup Time Range
                  ListTile(
                    title: const Text('Pickup From'),
                    subtitle: Text(_selectedPickupFrom.toString().split('.')[0]),
                    leading: const Icon(Icons.access_time),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _selectDate(context, 'pickup_from'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Pickup Until'),
                    subtitle: Text(_selectedPickupUntil.toString().split('.')[0]),
                    leading: const Icon(Icons.access_time_filled),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _selectDate(context, 'pickup_until'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Address',
                      hintText: 'Enter pickup address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Allergens
                  const Text(
                    'Allergens (if any):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allergenOptions.map((allergen) {
                      return FilterChip(
                        label: Text(allergen),
                        selected: _selectedAllergens.contains(allergen),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAllergens.add(allergen);
                            } else {
                              _selectedAllergens.remove(allergen);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: foodProvider.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: foodProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Add Food Item',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}