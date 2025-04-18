import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/screens/recipe_detail_screen.dart';
import 'package:baking_notes/widgets/recipe_card.dart';
 
class CategoriesTab extends StatelessWidget {
  final String userId;
 
  const CategoriesTab({
    super.key,
    required this.userId,
  });
 
  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Tartas',
        'icon': Icons.cake,
        'color': Colors.pink.shade200,
      },
      {
        'name': 'Galletas',
        'icon': Icons.cookie,
        'color': Colors.amber.shade300,
      },
      {
        'name': 'Cupcakes',
        'icon': Icons.bakery_dining,
        'color': Colors.purple.shade200,
      },
      {
        'name': 'Panes',
        'icon': Icons.breakfast_dining,
        'color': Colors.brown.shade300,
      },
      {
        'name': 'Otros',
        'icon': Icons.restaurant,
        'color': Colors.teal.shade200,
      },
    ];
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Recipe>('recipes').listenable(),
        builder: (context, Box<Recipe> box, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['name'] as String;
              final categoryIcon = category['icon'] as IconData;
              final categoryColor = category['color'] as Color;
             
              // Contar recetas en esta categoría
              final recipeCount = box.values
                  .where((recipe) => recipe.category == categoryName)
                  .length;
             
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailScreen(
                        userId: userId,
                        category: categoryName,
                        color: categoryColor,
                        icon: categoryIcon,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            categoryIcon,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$recipeCount ${recipeCount == 1 ? 'receta' : 'recetas'}',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
 
class CategoryDetailScreen extends StatelessWidget {
  final String userId;
  final String category;
  final Color color;
  final IconData icon;
 
  const CategoryDetailScreen({
    super.key,
    required this.userId,
    required this.category,
    required this.color,
    required this.icon,
  });
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: color,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Recipe>('recipes').listenable(),
        builder: (context, Box<Recipe> box, _) {
          final recipes = box.values
              .where((recipe) => recipe.category == category)
              .toList();
         
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recetas en esta categoría',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
         
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                userId: userId,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipeId: recipe.id,
                        userId: userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}