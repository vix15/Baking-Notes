import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/screens/recipe_detail_screen.dart';
import 'package:baking_notes/widgets/recipe_card.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';
 
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Recipe>('recipes').listenable(),
        builder: (context, Box<Recipe> recipeBox, _) {
          final categoryRecipes = recipeBox.values
              .where((recipe) => recipe.category == category)
              .toList();
          if (categoryRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 80,
                    color: isDarkMode ? Colors.white54 : color.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recetas en esta categoría',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega una nueva receta para empezar',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
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
            itemCount: categoryRecipes.length,
            itemBuilder: (context, index) {
              final recipe = categoryRecipes[index];
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