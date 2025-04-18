import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 5)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  double quantity;
  
  @HiveField(4)
  String unit;
  
  @HiveField(5)
  bool isChecked;
  
  @HiveField(6)
  final DateTime addedDate;
  
  @HiveField(7)
  String? recipeId;
  
  @HiveField(8)
  String category;
  
  @HiveField(9)
  DateTime createdAt;
  
  ShoppingItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
    required this.addedDate,
    this.recipeId,
    this.category = 'General',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}