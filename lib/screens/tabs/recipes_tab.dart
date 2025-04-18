import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/widgets/recipe_card.dart';
import 'package:baking_notes/screens/recipe_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';

class RecipesTab extends StatefulWidget {
  final String userId;
  
  const RecipesTab({
    super.key,
    required this.userId,
  });

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  String _sortBy = 'Recientes';
  
  final List<String> _categories = [
    'Todas',
    'Tartas',
    'Galletas',
    'Cupcakes',
    'Panes',
    'Otros'
  ];
  
  final List<String> _sortOptions = [
    'Recientes',
    'Antiguos',
    'A-Z',
    'Z-A',
    'Tiempo de preparación',
  ];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recetas'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Theme.of(context).primaryColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Categorías horizontales
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : (isDarkMode ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),
          
          // Lista de recetas
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Recipe>('recipes').listenable(),
              builder: (context, Box<Recipe> box, _) {
                // Filtrar recetas
                var recipes = box.values.toList();
                
                // Filtrar por búsqueda
                if (_searchQuery.isNotEmpty) {
                  recipes = recipes.where((recipe) {
                    return recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           recipe.ingredients.any((ingredient) => 
                             ingredient.toLowerCase().contains(_searchQuery.toLowerCase()));
                  }).toList();
                }
                
                // Filtrar por categoría
                if (_selectedCategory != 'Todas') {
                  recipes = recipes.where((recipe) => 
                    recipe.category == _selectedCategory).toList();
                }
                
                // Ordenar recetas
                switch (_sortBy) {
                  case 'Recientes':
                    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    break;
                  case 'Antiguos':
                    recipes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    break;
                  case 'A-Z':
                    recipes.sort((a, b) => a.name.compareTo(b.name));
                    break;
                  case 'Z-A':
                    recipes.sort((a, b) => b.name.compareTo(a.name));
                    break;
                  case 'Tiempo de preparación':
                    recipes.sort((a, b) => (a.prepTime + a.cookTime).compareTo(b.prepTime + b.cookTime));
                    break;
                }
                
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_food,
                          size: 80,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron recetas',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != 'Todas'
                              ? 'Intenta con otros filtros'
                              : 'Agrega tu primera receta',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Usar LayoutBuilder para hacer las tarjetas responsivas
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calcular el número de columnas basado en el ancho disponible
                    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    if (constraints.maxWidth > 900) crossAxisCount = 4;
                    if (constraints.maxWidth < 400) crossAxisCount = 1;
                    
                    // Calcular la relación de aspecto para mantener las tarjetas proporcionales
                    double childAspectRatio = constraints.maxWidth > 600 ? 0.8 : 0.75;
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          userId: widget.userId,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(
                                  recipeId: recipe.id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ordenar por',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _sortOptions.map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: _sortBy == option,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _sortBy = option;
                          });
                          this.setState(() {});
                        }
                      },
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _sortBy == option
                            ? Theme.of(context).primaryColor
                            : (isDarkMode ? Colors.white : Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}