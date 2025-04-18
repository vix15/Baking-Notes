import 'package:flutter/material.dart';
import 'package:baking_notes/models/inventory_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class InventoryItemWidget extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onUse;
  
  const InventoryItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular días hasta caducidad
    final daysUntilExpiration = item.expirationDate.difference(DateTime.now()).inDays;
    
    // Determinar color basado en la fecha de caducidad
    Color expirationColor;
    if (daysUntilExpiration < 0) {
      expirationColor = Colors.red;
    } else if (daysUntilExpiration < 7) {
      expirationColor = Colors.orange;
    } else {
      expirationColor = Colors.green;
    }
    
    // Calcular porcentaje restante
    final percentRemaining = (item.quantity / item.initialQuantity) * 100;
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).primaryColor,
                        onPressed: onUse,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade300,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Barra de progreso
              LinearProgressIndicator(
                value: item.quantity / item.initialQuantity,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentRemaining > 50
                      ? Colors.green
                      : percentRemaining > 20
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              
              // Fecha de caducidad
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: expirationColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysUntilExpiration < 0
                        ? 'Caducado hace ${-daysUntilExpiration} días'
                        : daysUntilExpiration == 0
                            ? 'Caduca hoy'
                            : 'Caduca en $daysUntilExpiration días',
                    style: TextStyle(
                      fontSize: 12,
                      color: expirationColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}