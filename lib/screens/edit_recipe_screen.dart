import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/recipe.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  final String userId;
  
  const EditRecipeScreen({
    super.key,
    required this.recipeId,
    required this.userId,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  
  String _selectedCategory = 'Tartas';
  final List<String> _categories = [
    'Tartas',
    'Galletas',
    'Cupcakes',
    'Panes',
    'Otros'
  ];
  
  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _stepControllers = [];
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _imagePath;
  
  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }
  
  Future<void> _loadRecipe() async {
    final recipeBox = Hive.box<Recipe>('recipes');
    final recipe = recipeBox.values.firstWhere(
      (recipe) => recipe.id == widget.recipeId,
    );
    
    _nameController = TextEditingController(text: recipe.name);
    _descriptionController = TextEditingController(text: recipe.description);
    _prepTimeController = TextEditingController(text: recipe.prepTime.toString());
    _cookTimeController = TextEditingController(text: recipe.cookTime.toString());
    _servingsController = TextEditingController(text: recipe.servings.toString());
    _selectedCategory = recipe.category;
    _imagePath = recipe.imageUrl;
    
    _ingredientControllers = recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();
    
    _stepControllers = recipe.steps
        .map((step) => TextEditingController(text: step))
        .toList();
    
    setState(() {
      _isInitialized = true;
    });
  }
  
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
  
  Future<void> _updateRecipe() async {
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
        
        final recipeBox = Hive.box<Recipe>('recipes');
        final recipeToUpdate = recipeBox.values.firstWhere(
          (recipe) => recipe.id == widget.recipeId,
        );
        
        recipeToUpdate.name = _nameController.text.trim();
        recipeToUpdate.description = _descriptionController.text.trim();
        recipeToUpdate.ingredients = ingredients;
        recipeToUpdate.steps = steps;
        recipeToUpdate.prepTime = int.parse(_prepTimeController.text);
        recipeToUpdate.cookTime = int.parse(_cookTimeController.text);
        recipeToUpdate.servings = int.parse(_servingsController.text);
        recipeToUpdate.category = _selectedCategory;
        
        if (_imagePath != null) {
          recipeToUpdate.imageUrl = _imagePath;
        }
        
        await recipeToUpdate.save();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Receta actualizada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _pickImage() async {
    // Aquí deberías implementar la lógica para seleccionar una imagen
    // Puedes usar image_picker o cualquier otro paquete que prefieras
    // Por ahora, esto es solo un marcador de posición
    /*
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
    */
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Receta'),
          backgroundColor: const Color(0xFFF8BBD0),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF8BBD0),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Receta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF8BBD0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Imagen de la receta
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  image: _imagePath != null && File(_imagePath!).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(_imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/default_recipe.jpg'),
                          fit: BoxFit.cover,
                        ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      Text(
                        _imagePath == null ? 'Agregar imagen' : 'Cambiar imagen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Resto del formulario (igual que antes)
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
            
            Row(
              children: [
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
              icon: const Icon(Icons.add, color: Color(0xFFF8BBD0)),
              label: const Text(
                'Agregar Ingrediente',
                style: TextStyle(color: Color(0xFFF8BBD0)),
              ),
            ),
            const SizedBox(height: 24),
            
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8BBD0),
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
              icon: const Icon(Icons.add, color: Color(0xFFF8BBD0)),
              label: const Text(
                'Agregar Paso',
                style: TextStyle(color: Color(0xFFF8BBD0)),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8BBD0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Actualizar Receta',
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