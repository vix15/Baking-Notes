import 'package:hive/hive.dart';

part 'inventory_usage.g.dart';

@HiveType(typeId: 3) // Cambiado a 3 para evitar conflicto con InventoryItem
class InventoryUsage extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String inventoryItemId;
  
  @HiveField(2)
  final String recipeId;
  
  @HiveField(3)
  final double quantity;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final String nombre;
  
  @HiveField(6)
  final String unidad;
  
  InventoryUsage({
    required this.id,
    required this.inventoryItemId,
    required this.recipeId,
    required this.quantity,
    required this.date,
    required this.nombre,
    required this.unidad,
  });
}
