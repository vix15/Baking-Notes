import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/shopping_item.dart';
import 'package:uuid/uuid.dart';

class ShoppingListTab extends StatefulWidget {
  final String userId;

  const ShoppingListTab({super.key, required this.userId});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'unidad';
  String _selectedCategory = 'General';

  final List<String> _units = [
    'unidad',
    'g',
    'kg',
    'ml',
    'l',
    'cucharada',
    'taza',
  ];
  final List<String> _categories = [
    'General',
    'Lácteos',
    'Frutas',
    'Verduras',
    'Carnes',
    'Panadería',
    'Especias',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addItemFromModal() {
    if (_itemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para el artículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final newItem = ShoppingItem(
      id: const Uuid().v4(),
      userId: widget.userId,
      name: _itemController.text.trim(),
      quantity: quantity,
      unit: _selectedUnit,
      isChecked: false,
      category: _selectedCategory,
      addedDate: DateTime.now(),
    );

    final shoppingBox = Hive.box<ShoppingItem>('shopping');
    shoppingBox.add(newItem);

    _itemController.clear();
    _quantityController.clear();
    _selectedUnit = 'unidad';
    _selectedCategory = 'General';

    Navigator.pop(context);
  }

  void _toggleItemCheck(ShoppingItem item) {
    item.isChecked = !item.isChecked;
    item.save();
  }

  void _deleteItem(ShoppingItem item) {
    item.delete();
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agregar Artículo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del artículo',
                      hintText: 'Ej: Harina',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad',
                            hintText: 'Ej: 500',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unidad',
                          ),
                          items: _units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addItemFromModal,
                        child: const Text('Agregar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pendientes'), Tab(text: 'Completados')],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<ShoppingItem>('shopping').listenable(),
        builder: (context, Box<ShoppingItem> box, _) {
          final allItems = box.values
              .where((item) => item.userId == widget.userId)
              .toList();

          final pendingItems =
              allItems.where((item) => !item.isChecked).toList();
          final completedItems =
              allItems.where((item) => item.isChecked).toList();

          final pendingByCategory = <String, List<ShoppingItem>>{};
          for (var item in pendingItems) {
            if (!pendingByCategory.containsKey(item.category)) {
              pendingByCategory[item.category] = [];
            }
            pendingByCategory[item.category]!.add(item);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              pendingItems.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.shopping_cart_outlined,
                      message: 'Tu lista de compras está vacía',
                    )
                  : ListView.builder(
                      itemCount: pendingByCategory.keys.length,
                      itemBuilder: (context, categoryIndex) {
                        final category =
                            pendingByCategory.keys.elementAt(categoryIndex);
                        final categoryItems = pendingByCategory[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2040),
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categoryItems.length,
                              itemBuilder: (context, itemIndex) {
                                final item = categoryItems[itemIndex];
                                return _buildShoppingItem(item);
                              },
                            ),
                          ],
                        );
                      },
                    ),
              completedItems.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.check_circle_outline,
                      message: 'No hay artículos completados',
                    )
                  : ListView.builder(
                      itemCount: completedItems.length,
                      itemBuilder: (context, index) {
                        final item = completedItems[index];
                        return _buildShoppingItem(item);
                      },
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} eliminado'),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Checkbox(
            value: item.isChecked,
            activeColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) => _toggleItemCheck(item),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Text(
            '${item.quantity} ${item.unit}',
            style: TextStyle(
              color: item.isChecked ? Colors.grey : Colors.black54,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade300,
            onPressed: () => _deleteItem(item),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
