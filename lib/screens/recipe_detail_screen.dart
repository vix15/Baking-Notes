import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/models/user.dart';
import 'package:baking_notes/screens/edit_recipe_screen.dart';
import 'package:baking_notes/widgets/enhanced_timer_widget.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  final String userId;
  
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Recipe>('recipes').listenable(),
      builder: (context, Box<Recipe> recipeBox, _) {
        final recipe = recipeBox.values.firstWhere(
          (recipe) => recipe.id == recipeId,
          orElse: () => Recipe(
            id: '',
            name: '',
            description: '',
            ingredients: [],
            steps: [],
            prepTime: 0,
            cookTime: 0,
            servings: 0,
            category: '',
            createdAt: DateTime.now(),
            userId: userId
          ),
        );
        
        if (recipe.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle de Receta'),
            ),
            body: const Center(
              child: Text('Receta no encontrada'),
            ),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen de la receta con manejo de imagen por defecto
                      recipe.imageUrl != null && File(recipe.imageUrl!).existsSync()
                          ? Image.file(
                              File(recipe.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/default_recipe.jpg',
                              fit: BoxFit.cover,
                            ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                            stops: [0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ValueListenableBuilder(
                    valueListenable: Hive.box<User>('users').listenable(),
                    builder: (context, Box<User> userBox, _) {
                      final user = userBox.values.firstWhere(
                        (user) => user.id == userId,
                      );
                      
                      final isFavorite = user.favoriteRecipeIds.contains(recipe.id);
                      
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            user.favoriteRecipeIds.remove(recipe.id);
                          } else {
                            user.favoriteRecipeIds.add(recipe.id);
                          }
                          user.save();
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecipeScreen(
                            recipeId: recipe.id,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar Receta'),
                          content: const Text('¿Estás seguro de que quieres eliminar esta receta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                recipe.delete();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(
                            context,
                            Icons.timer,
                            'Preparación',
                            '${recipe.prepTime} min',
                          ),
                          _buildInfoItem(
                            context,
                            Icons.whatshot,
                            'Cocción',
                            '${recipe.cookTime} min',
                          ),
                          _buildInfoItem(
                            context,
                            Icons.people,
                            'Porciones',
                            '${recipe.servings}',
                          ),
                          _buildInfoItem(
                            context,
                            Icons.category,
                            'Categoría',
                            recipe.category,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      const Center(
                        child: EnhancedTimerWidget(),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2040),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ...recipe.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Preparación',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2040),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ...List.generate(recipe.steps.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.steps[index],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    if (index < recipe.steps.length - 1)
                                      const Divider(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}