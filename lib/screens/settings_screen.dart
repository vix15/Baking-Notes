import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final String userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Apariencia
          const Text(
            'Apariencia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Selector de tema
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tema',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Opción de tema claro
                  _buildThemeOption(
                    context,
                    title: 'Tema Claro',
                    icon: Icons.light_mode,
                    isSelected: !themeProvider.isDarkMode,
                    onTap: () {
                      // Use toggleTheme if setTheme is not available
                      if (themeProvider.isDarkMode) {
                        themeProvider.toggleTheme();
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Opción de tema oscuro
                  _buildThemeOption(
                    context,
                    title: 'Tema Oscuro (Dark Coquette)',
                    icon: Icons.dark_mode,
                    isSelected: themeProvider.isDarkMode,
                    onTap: () {
                      // Use toggleTheme if setTheme is not available
                      if (!themeProvider.isDarkMode) {
                        themeProvider.toggleTheme();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sección de Notificaciones
          const Text(
            'Notificaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Configuración de notificaciones
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Notificaciones de temporizador'),
              subtitle: const Text(
                'Recibir notificaciones cuando el temporizador termine',
              ),
              value: true, // Aquí deberías usar un valor real de configuración
              onChanged: (value) {
                // Implementar cambio de configuración
              },
              secondary: const Icon(Icons.notifications),
            ),
          ),
          const SizedBox(height: 24),
          // Sección de Datos
          const Text(
            'Datos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Opciones de datos
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Hacer copia de seguridad'),
                  subtitle: const Text('Guardar tus recetas y configuración'),
                  onTap: () {
                    // Implementar copia de seguridad
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restaurar datos'),
                  subtitle: const Text('Recuperar tus recetas y configuración'),
                  onTap: () {
                    // Implementar restauración
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Borrar todos los datos'),
                  subtitle: const Text(
                    'Eliminar todas tus recetas y configuración',
                  ),
                  onTap: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sección de Acerca de
          const Text(
            'Acerca de',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Información de la aplicación
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas de Repostería',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('Versión 1.0.0'),
                  const SizedBox(height: 16),
                  const Text(
                    'Desarrollado con ❤️ para ayudarte a organizar tus recetas de repostería.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Borrar todos los datos?'),
            content: const Text(
              'Esta acción eliminará todas tus recetas, listas de compras e inventario. Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Implementar borrado de datos
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los datos han sido eliminados'),
                    ),
                  );
                },
                child: const Text(
                  'Borrar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
