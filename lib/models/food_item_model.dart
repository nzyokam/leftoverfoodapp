class FoodItemModel {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final String category;
  final int quantity;
  final String unit;
  final List<String> images;
  final DateTime expiryDate;
  final DateTime pickupFrom;
  final DateTime pickupUntil;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> allergens;
  final String status;
  final String? claimedBy;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  
  FoodItemModel({
    required this.id,
    required this.donorId,
    required this.title,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.images,
    required this.expiryDate,
    required this.pickupFrom,
    required this.pickupUntil,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.allergens,
    required this.status,
    this.claimedBy,
    this.claimedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });
  
  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'],
      donorId: json['donor_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
      images: List<String>.from(json['images']),
      expiryDate: DateTime.parse(json['expiry_date']),
      pickupFrom: DateTime.parse(json['pickup_from']),
      pickupUntil: DateTime.parse(json['pickup_until']),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      allergens: List<String>.from(json['allergens']),
      status: json['status'],
      claimedBy: json['claimed_by'],
      claimedAt: json['claimed_at'] != null ? DateTime.parse(json['claimed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      metadata: json['metadata'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'title': title,
      'description': description,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'images': images,
      'expiry_date': expiryDate.toIso8601String(),
      'pickup_from': pickupFrom.toIso8601String(),
      'pickup_until': pickupUntil.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'allergens': allergens,
      'status': status,
      'claimed_by': claimedBy,
      'claimed_at': claimedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}