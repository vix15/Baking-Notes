import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  List<String> ingredients;
  
  @HiveField(5)
  List<String> steps;
  
  @HiveField(6)
  int prepTime;
  
  @HiveField(7)
  int cookTime;
  
  @HiveField(8)
  int servings;
  
  @HiveField(9)
  String category;
  
  @HiveField(10)
  bool isFavorite;
  
  @HiveField(11)
  DateTime createdAt;
  
  @HiveField(12)
  DateTime? lastCooked;
  
  @HiveField(13)
  String? imageUrl;
  
  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.category,
    this.isFavorite = false,
    DateTime? createdAt,
    this.lastCooked,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();
}