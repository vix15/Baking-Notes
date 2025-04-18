import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/inventory_item.dart';
import 'package:baking_notes/models/inventory_usage.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';
import 'package:baking_notes/widgets/inventory_item_widget.dart';

class InventoryTab extends StatefulWidget {
  final String userId;

  const InventoryTab({super.key, required this.userId});

  @override
  _InventoryTabState createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'unidad';
  String _selectedCategory = 'General';
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));

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
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addInventoryItem() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para el artículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;

    final newItem = InventoryItem(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      quantity: quantity,
      unit: _selectedUnit,
      category: _selectedCategory,
      expirationDate: _expirationDate,
      purchaseDate: DateTime.now(),
      initialQuantity: quantity,
      usageHistory: [],
      userId: widget.userId,
      addedDate: DateTime.now(),
    );

    final inventoryBox = Hive.box<InventoryItem>('inventory');
    inventoryBox.add(newItem);

    _nameController.clear();
    _quantityController.clear();
    _selectedUnit = 'unidad';
    _selectedCategory = 'General';
    _expirationDate = DateTime.now().add(const Duration(days: 30));

    Navigator.pop(context);

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newItem.name} añadido al inventario'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteItem(InventoryItem item) {
    final itemName = item.name;
    item.delete();

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName eliminado del inventario'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _editItem(InventoryItem item) {
    _nameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _selectedUnit = item.unit;
    _selectedCategory = item.category;
    _expirationDate = item.expirationDate;

    _showAddItemDialog(isEditing: true, itemToEdit: item);
  }

  // En el método _updateItem, modificar la línea que actualiza initialQuantity

  void _updateItem(InventoryItem item) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para el artículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;

    item.name = _nameController.text.trim();
    item.quantity = quantity;
    item.unit = _selectedUnit;
    item.category = _selectedCategory;
    item.expirationDate = _expirationDate;

    // Eliminar esta línea ya que initialQuantity es final
    // item.initialQuantity = quantity > item.initialQuantity ? quantity : item.initialQuantity;

    item.save();

    _nameController.clear();
    _quantityController.clear();
    _selectedUnit = 'unidad';
    _selectedCategory = 'General';
    _expirationDate = DateTime.now().add(const Duration(days: 30));

    Navigator.pop(context);

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} actualizado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _recordUsage(InventoryItem item) {
    final TextEditingController usageController = TextEditingController();
    String? selectedRecipeId;
    String? selectedRecipeName;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Registrar Uso'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ingrediente: ${item.name}'),
                    const SizedBox(height: 10),
                    Text('Disponible: ${item.quantity} ${item.unit}'),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usageController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad usada (${item.unit})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Selector de receta (opcional)
                    ValueListenableBuilder(
                      valueListenable: Hive.box<Recipe>('recipes').listenable(),
                      builder: (context, Box<Recipe> recipeBox, _) {
                        final recipes = recipeBox.values.toList();

                        return DropdownButtonFormField<String>(
                          value: selectedRecipeId,
                          decoration: const InputDecoration(
                            labelText: 'Receta (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Seleccionar receta'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Ninguna'),
                            ),
                            ...recipes.map((recipe) {
                              return DropdownMenuItem<String>(
                                value: recipe.id,
                                child: Text(recipe.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRecipeId = value;
                              if (value != null) {
                                selectedRecipeName =
                                    recipes
                                        .firstWhere(
                                          (recipe) => recipe.id == value,
                                        )
                                        .name;
                              } else {
                                selectedRecipeName = null;
                              }
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final usageAmount =
                          double.tryParse(usageController.text) ?? 0;

                      if (usageAmount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor ingresa una cantidad válida',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (usageAmount > item.quantity) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'La cantidad usada no puede ser mayor que la disponible',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Registrar el uso
                      final usage = InventoryUsage(
                        id: const Uuid().v4(), // Genera un ID único
                        inventoryItemId: item.id, // ID del item de inventario
                        recipeId:
                            selectedRecipeId ??
                            '', // Si es null, asigna un string vacío
                        quantity: usageAmount, // Cantidad de uso
                        date: DateTime.now(), // Fecha actual
                        nombre: item.name, // Nombre del ítem
                        unidad: item.unit, // Unidad del ítem
                      );

                      item.quantity -=
                          usageAmount; // Actualiza la cantidad del ingrediente
                      item.usageHistory.add(usage); // Registra el uso
                      item.save();

                      Navigator.pop(context);

                      // Mostrar confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Se usaron $usageAmount ${item.unit} de ${item.name}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Registrar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showAddItemDialog({bool isEditing = false, InventoryItem? itemToEdit}) {
    if (!isEditing) {
      _nameController.clear();
      _quantityController.clear();
      _selectedUnit = 'unidad';
      _selectedCategory = 'General';
      _expirationDate = DateTime.now().add(const Duration(days: 30));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final themeProvider = Provider.of<ThemeProvider>(context);
              final isDarkMode = themeProvider.isDarkMode;

              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
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
                      Text(
                        isEditing
                            ? 'Editar Ingrediente'
                            : 'Agregar Ingrediente',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nombre del artículo
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del ingrediente',
                          hintText: 'Ej: Harina',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 15),

                      // Cantidad y unidad
                      Row(
                        children: [
                          // Cantidad
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

                          // Unidad
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unidad',
                              ),
                              items:
                                  _units.map((unit) {
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

                      // Categoría
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                        ),
                        items:
                            _categories.map((category) {
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
                      const SizedBox(height: 15),

                      // Fecha de caducidad
                      Row(
                        children: [
                          const Text('Fecha de caducidad: '),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () async {
                              final DateTime? selectedDate =
                                  await showDatePicker(
                                    context: context,
                                    initialDate: _expirationDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                              if (selectedDate != null &&
                                  selectedDate != _expirationDate) {
                                setState(() {
                                  _expirationDate = selectedDate;
                                });
                              }
                            },
                            child: Text(
                              '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed:
                                isEditing
                                    ? () => _updateItem(itemToEdit!)
                                    : _addInventoryItem,
                            child: Text(isEditing ? 'Actualizar' : 'Agregar'),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Despensa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Implementar ordenamiento
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<InventoryItem>('inventory').listenable(),
        builder: (context, Box<InventoryItem> inventoryBox, _) {
          final inventoryItems =
              inventoryBox.values
                  .where((item) => item.userId == widget.userId)
                  .toList();

          if (inventoryItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu despensa está vacía',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega ingredientes para empezar',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Ingrediente'),
                  ),
                ],
              ),
            );
          }

          // Agrupar por categoría
          final itemsByCategory = <String, List<InventoryItem>>{};
          for (var item in inventoryItems) {
            if (!itemsByCategory.containsKey(item.category)) {
              itemsByCategory[item.category] = [];
            }
            itemsByCategory[item.category]!.add(item);
          }

          return ListView.builder(
            itemCount: itemsByCategory.length,
            itemBuilder: (context, index) {
              final category = itemsByCategory.keys.elementAt(index);
              final items = itemsByCategory[category]!;

              return ExpansionTile(
                title: Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                children:
                    items.map((item) {
                      return InventoryItemWidget(
                        item: item,
                        onDelete: () => _deleteItem(item),
                        onEdit: () => _editItem(item),
                        onUse: () => _recordUsage(item),
                      );
                    }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
