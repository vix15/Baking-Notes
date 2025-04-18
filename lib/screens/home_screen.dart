import 'package:flutter/material.dart';
import 'package:baking_notes/screens/add_recipe_screen.dart';
import 'package:baking_notes/screens/tabs/recipes_tab.dart';
import 'package:baking_notes/screens/tabs/categories_tab.dart';
import 'package:baking_notes/screens/tabs/inventory_tab.dart' as inventory;
import 'package:baking_notes/screens/tabs/shopping_list_tab.dart' as shopping;
import 'package:baking_notes/screens/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return RecipesTab(userId: widget.userId);
      case 1:
        return CategoriesTab(userId: widget.userId);
      case 2:
        return shopping.ShoppingListTab(userId: widget.userId);
      case 3:
        return inventory.InventoryTab(userId: widget.userId);
      case 4:
        return ProfileTab(userId: widget.userId);
      default:
        return RecipesTab(userId: widget.userId);
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Recetas'),
        BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categorías'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Compras'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventario'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    // Mostrar FAB solo en Recetas y Compras 💅
    if (_currentIndex == 0 ) {
      return FloatingActionButton(
        onPressed: () => _handleFabPressed(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }

  void _handleFabPressed() {
    switch (_currentIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRecipeScreen(userId: widget.userId),
          ),
        );
        break;
    }
  }
}
