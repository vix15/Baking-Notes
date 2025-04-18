import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/models/user.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/models/auth_state.dart';
import 'package:baking_notes/models/shopping_item.dart';
import 'package:baking_notes/models/inventory_item.dart';
import 'package:baking_notes/screens/login_screen.dart';
import 'package:baking_notes/screens/recipe_detail_screen.dart';
import 'package:baking_notes/screens/edit_profile_screen.dart';
import 'package:baking_notes/widgets/recipe_card.dart';

class ProfileTab extends StatelessWidget {
  final String userId;

  const ProfileTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
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

          if (user.id.isEmpty) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 80,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: _buildProfileAvatar(user, context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(userId: userId),
                        ),
                      ).then((_) {
                        // Forzar la actualización del perfil
                        userBox.get(user.key)?.save();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar Sesión'),
                          content: const Text(
                            '¿Estás seguro de que quieres cerrar sesión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                final authBox = Hive.box<AuthState>('auth');
                                authBox.delete('currentUser');
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Cerrar Sesión',
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
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                                title: const Text('Nombre de Usuario'),
                                subtitle: Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                                title: const Text('Correo Electrónico'),
                                subtitle: Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2040),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            Icons.favorite,
                            'Recetas Favoritas',
                            user.favoriteRecipeIds.length.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            context,
                            Icons.shopping_cart,
                            'Artículos en Lista',
                            Hive.box<ShoppingItem>('shopping').values
                                .where((item) => !item.isChecked)
                                .length
                                .toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            Icons.inventory_2,
                            'Ingredientes',
                            Hive.box<InventoryItem>('inventory').values.length.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            context,
                            Icons.restaurant,
                            'Recetas Creadas',
                            Hive.box<Recipe>('recipes').values
                                .where((recipe) => recipe.id.startsWith('user_${user.id}'))
                                .length
                                .toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recetas Favoritas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2040),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: Hive.box<Recipe>('recipes').listenable(),
                builder: (context, Box<Recipe> recipeBox, _) {
                  final favoriteRecipes = recipeBox.values
                      .where((recipe) => user.favoriteRecipeIds.contains(recipe.id))
                      .toList();

                  if (favoriteRecipes.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay recetas favoritas aún',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toca el ícono de corazón en las recetas para agregarlas a tus favoritos',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final recipe = favoriteRecipes[index];
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
                      }, childCount: favoriteRecipes.length),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actividad Reciente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2040),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder(
                        valueListenable: Hive.box<InventoryItem>('inventory').listenable(),
                        builder: (context, Box<InventoryItem> inventoryBox, _) {
                          final allUsages = <Map<String, dynamic>>[];

                          for (var item in inventoryBox.values) {
                            for (var usage in item.usageHistory) {
                              allUsages.add({
                                'itemName': usage.nombre,
                                'amount': usage.quantity,
                                'unit': usage.unidad,
                                'date': usage.date,
                                'recipeId': usage.recipeId,
                              });
                            }
                          }

                          allUsages.sort(
                            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
                          );

                          final recentUsages = allUsages.take(5).toList();

                          if (recentUsages.isEmpty) {
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No hay actividad reciente',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: recentUsages.map((usage) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.restaurant,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    title: Text(
                                      'Usaste ${usage['amount']} ${usage['unit']} de ${usage['itemName']}',
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hace ${_formatTimeAgo(usage['date'])}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(User user, BuildContext context) {
    if (user.profileImagePath != null && File(user.profileImagePath!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(user.profileImagePath!),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(user, context),
        ),
      );
    } else {
      return _buildInitialsAvatar(user, context);
    }
  }

  Widget _buildInitialsAvatar(User user, BuildContext context) {
    return Center(
      child: Text(
        user.username.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 30),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'hace un momento';
    }
  }
}