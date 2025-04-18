import 'dart:io';
import 'package:flutter/material.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final String userId;
  final VoidCallback onTap;
  
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen con manejo inteligente de rutas
                    _buildRecipeImage(),
                    
                    // Botón de favorito
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ValueListenableBuilder(
                        valueListenable: Hive.box<User>('users').listenable(),
                        builder: (context, Box<User> userBox, _) {
                          final user = userBox.values.firstWhere(
                            (user) => user.id == userId,
                            orElse: () => User(
                              id: '',
                              username: '',
                              password: '',
                              email: '',
                              favoriteRecipeIds: [],
                            ),
                          );
                          
                          final isFavorite = user.favoriteRecipeIds.contains(recipe.id);
                          
                          return GestureDetector(
                            onTap: () {
                              if (isFavorite) {
                                user.favoriteRecipeIds.remove(recipe.id);
                              } else {
                                user.favoriteRecipeIds.add(recipe.id);
                              }
                              user.save();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Categoría
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Información de la receta
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la receta
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Descripción
                    Expanded(
                      child: Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Tiempo de preparación y cocción
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime + recipe.cookTime} min',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecipeImage() {
    if (recipe.imageUrl == null || recipe.imageUrl!.isEmpty) {
      // Si no hay URL de imagen, mostrar imagen por defecto
      return Image.asset(
        'assets/images/default_recipe.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          );
        },
      );
    }
    
    // Verificar si la ruta es un asset o un archivo
    if (recipe.imageUrl!.startsWith('assets/')) {
      // Es un asset
      return Image.asset(
        recipe.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error cargando asset: ${recipe.imageUrl}');
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          );
        },
      );
    } else {
      // Es un archivo local
      final file = File(recipe.imageUrl!);
      return FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && 
              snapshot.hasData && 
              snapshot.data == true) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                );
              },
            );
          } else {
            // Si el archivo no existe, mostrar imagen por defecto
            return Image.asset(
              'assets/images/default_recipe.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              },
            );
          }
        },
      );
    }
  }
}
