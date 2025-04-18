import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:uuid/uuid.dart';
import 'package:baking_notes/widgets/image_picker_widget.dart';
class AddRecipeScreen extends StatefulWidget {
  final String userId;
  
  const AddRecipeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  
  String _selectedCategory = 'Tartas';
  final List<String> _categories = [
    'Tartas',
    'Galletas',
    'Cupcakes',
    'Panes',
    'Otros'
  ];
  
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];
  
  String? _imageUrl;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
  
  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }
  
  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }
  
  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }
  
  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }
  
  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final ingredients = _ingredientControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
            
        final steps = _stepControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
        
        if (ingredients.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor agrega al menos un ingrediente'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        if (steps.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor agrega al menos un paso'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        final newRecipe = Recipe(
          id: 'user_${widget.userId}_${const Uuid().v4()}',
          userId: widget.userId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: ingredients,
          steps: steps,
          prepTime: int.parse(_prepTimeController.text),
          cookTime: int.parse(_cookTimeController.text),
          servings: int.parse(_servingsController.text),
          category: _selectedCategory,
          isFavorite: false,
          createdAt: DateTime.now(),
          imageUrl: _imageUrl,
        );
        
        final recipeBox = Hive.box<Recipe>('recipes');
        await recipeBox.add(newRecipe);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Receta guardada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la receta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva Receta',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Imagen de la receta
            ImagePickerWidget(
              onImageSelected: (path) {
                setState(() {
                  _imageUrl = path;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Nombre de la receta
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Receta',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre para la receta';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Descripción de la receta
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Fila de detalles de la receta
            Row(
              children: [
                // Tiempo de preparación
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo de Prep. (min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingresa un número';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Tiempo de cocción
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo de Cocción (min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingresa un número';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Porciones
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Porciones',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingresa un número';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Categoría
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 24),
            
            // Ingredientes
            const Text(
              'Ingredientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            
            ...List.generate(_ingredientControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Ingrediente ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (index == 0 && (value == null || value.isEmpty)) {
                            return 'Por favor ingresa al menos un ingrediente';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => _removeIngredientField(index),
                    ),
                  ],
                ),
              );
            }),
            
            TextButton.icon(
              onPressed: _addIngredientField,
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
              label: Text(
                'Agregar Ingrediente',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pasos
            const Text(
              'Pasos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            
            ...List.generate(_stepControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 12, right: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _stepControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Paso ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (index == 0 && (value == null || value.isEmpty)) {
                            return 'Por favor ingresa al menos un paso';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => _removeStepField(index),
                    ),
                  ],
                ),
              );
            }),
            
            TextButton.icon(
              onPressed: _addStepField,
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
              label: Text(
                'Agregar Paso',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            
            // Botón de guardar
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRecipe,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Receta',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
