import 'package:flutter/material.dart';
import 'package:baking_notes/models/shopping_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ShoppingItemWidget extends StatelessWidget {
  final ShoppingItem item;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  const ShoppingItemWidget({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: item.isChecked,
            activeColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: onToggle,
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked 
                  ? Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey.shade500 
                      : Colors.grey 
                  : null,
            ),
          ),
          subtitle: Text(
            '${item.quantity} ${item.unit}',
            style: TextStyle(
              color: item.isChecked 
                  ? Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey.shade600 
                      : Colors.grey.shade600 
                  : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade300,
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}