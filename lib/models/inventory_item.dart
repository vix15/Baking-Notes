import 'package:hive/hive.dart';
import 'package:baking_notes/models/inventory_usage.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 4)
class InventoryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String unit;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime expirationDate;

  @HiveField(6)
  DateTime purchaseDate;

  @HiveField(7)
  double initialQuantity; // Cambiado de final a no final

  @HiveField(8)
  List<InventoryUsage> usageHistory;

  @HiveField(9)
  String userId;

  @HiveField(10)
  DateTime addedDate;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.expirationDate,
    required this.purchaseDate,
    required this.initialQuantity,
    required this.usageHistory,
    required this.userId,
    required this.addedDate,
  });
}