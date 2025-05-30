import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/models/user.dart';
import 'package:baking_notes/models/auth_state.dart';
import 'package:baking_notes/models/shopping_item.dart';
import 'package:baking_notes/models/inventory_item.dart';
import 'package:baking_notes/models/inventory_usage.dart';
import 'package:baking_notes/screens/login_screen.dart';
import 'package:baking_notes/screens/home_screen.dart';
import 'package:baking_notes/screens/splash_screen.dart';
import 'package:baking_notes/theme/theme_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Hive.initFlutter();

  // Registrar adaptadores
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AuthStateAdapter());
  Hive.registerAdapter(InventoryUsageAdapter());
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(ShoppingItemAdapter());

  // Abrir cajas
  await Hive.openBox<Recipe>('recipes');
  await Hive.openBox<User>('users');
  await Hive.openBox<AuthState>('auth');
  await Hive.openBox<ShoppingItem>('shopping');
  await Hive.openBox<InventoryItem>('inventory');
  await Hive.openBox('settings');

  // Verificar si hay recetas por defecto
  final recipeBox = Hive.box<Recipe>('recipes');
  if (recipeBox.isEmpty) {
    await _addSampleRecipes();
  }

  // Verificar si hay una sesión activa
  final authBox = Hive.box<AuthState>('auth');
  final authState = authBox.get('currentUser');

  Widget nextScreen;

  if (authState != null) {
    // Verificar si la sesión no ha expirado (opcional, para seguridad)
    final now = DateTime.now();
    final difference = now.difference(authState.lastLogin);

    if (difference.inDays < 30) {
      // Sesión válida
      nextScreen = HomeScreen(userId: authState.userId);
    } else {
      // Sesión expirada
      nextScreen = const LoginScreen();
    }
  } else {
    // No hay sesión
    nextScreen = const LoginScreen();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: BakingNotesApp(nextScreen: nextScreen),
    ),
  );
}

class BakingNotesApp extends StatelessWidget {
  final Widget nextScreen;

  const BakingNotesApp({super.key, required this.nextScreen});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Notas de Repostería',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      // Siempre iniciamos con SplashScreen que luego navegará a nextScreen
      home: SplashScreen(nextScreen: nextScreen),
    );
  }
}

Future<void> _addSampleRecipes() async {
  final recipeBox = Hive.box<Recipe>('recipes');
  final defaultUserId = 'default_${const Uuid().v4()}';

  final sampleRecipes = [
    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Tarta de Limón con Merengue',
      description: 'Una tarta de limón fresca y cremosa, coronada con un merengue suave y dorado.',
      ingredients: [
        'Para la masa:',
        '250g harina',
        '125g mantequilla fría',
        '50g azúcar glas',
        '1 huevo',
        '1 pizca sal',
        'Para el relleno:',
        '4 limones (jugo y ralladura)',
        '4 yemas huevo',
        '1 lata leche condensada (400g)',
        'Para el merengue:',
        '4 claras huevo',
        '200g azúcar',
        '1 pizca sal'
      ],
      steps: [
        'MASA:',
        '1. Mezclar harina, azúcar y sal en un bol.',
        '2. Añadir mantequilla en cubos y mezclar con dedos hasta arena.',
        '3. Agregar huevo y formar una bola sin amasar mucho.',
        '4. Envolver en plástico y refrigerar 30 min.',
        '5. Estirar a 3mm y forrar molde de 23cm.',
        '6. Pinchar fondo con tenedor y hornear 15 min a 180°C con peso.',
        '7. Hornear 5 min más sin peso.',
        
        'RELLENO:',
        '1. Mezclar yemas con leche condensada.',
        '2. Añadir jugo (150ml) y ralladura de limón.',
        '3. Verter sobre masa y hornear 15 min a 160°C.',
        
        'MERENGUE:',
        '1. Batir claras con sal hasta espuma.',
        '2. Añadir azúcar poco a poco hasta picos firmes.',
        '3. Cubrir tarta y dorar con soplete.',
        '4. Refrigerar 2 horas antes de servir.'
      ],
      prepTime: 45,
      cookTime: 35,
      servings: 8,
      category: 'Tartas',
      imageUrl: 'assets/images/tarta_limón_merengue.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),

     Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Galletas de Avena y Pasas',
      description: 'Galletas saludables con avena y pasas, perfectas para el desayuno.',
      ingredients: [
        '120g mantequilla',
        '100g azúcar moreno',
        '50g azúcar blanco',
        '1 huevo',
        '1 cdta vainilla',
        '150g harina',
        '120g avena',
        '1/2 cdta canela',
        '1/2 cdta bicarbonato',
        '100g pasas',
        '1 pizca sal'
      ],
      steps: [
        '1. Batir mantequilla con azúcares hasta cremoso.',
        '2. Añadir huevo y vainilla, mezclar bien.',
        '3. Incorporar harina, avena, canela, bicarbonato y sal.',
        '4. Agregar pasas y mezclar uniformemente.',
        '5. Formar bolitas de 3cm y aplanar ligeramente.',
        '6. Hornear 12 min a 180°C hasta bordes dorados.',
        '7. Dejar enfriar 5 min en bandeja antes de mover.'
      ],
      prepTime: 15,
      cookTime: 12,
      servings: 18,
      category: 'Galletas',
      imageUrl: 'assets/images/galletas_avena_pasas.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Tarta de Chocolate y Naranja',
      description:
          'Una tarta con la combinación perfecta entre el sabor amargo del chocolate y la frescura de la naranja. Un lujo para el paladar.',
      ingredients: [
        '200g de chocolate negro de buena calidad',
        '1 taza de crema para batir',
        '2 cucharadas de licor de naranja',
        '1 base de tarta de galletas',
        '1/2 taza de azúcar moreno',
        '1 cucharadita de esencia de vainilla',
      ],
      steps: [
        'Precalienta el horno a 180°C y hornea la base de la tarta durante 10 minutos.',
        'En una cacerola, derrite el chocolate junto con la crema y el licor de naranja a fuego bajo.',
        'Agrega el azúcar y la esencia de vainilla, mezcla bien hasta obtener una crema suave.',
        'Vierte la mezcla sobre la base de la tarta ya horneada y deja enfriar en la nevera durante al menos 2 horas.',
        'Decora con rodajas de naranja y un poco de ralladura para un toque extra de elegancia.',
      ],
      prepTime: 25,
      cookTime: 10,
      servings: 8,
      category: 'Tartas',
      imageUrl: 'assets/images/tarta_chocolate_naranja.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Cupcakes de Vainilla',
      description:
          'Cupcakes suaves y esponjosos de vainilla, cubiertos con una crema de mantequilla suave y dulce, ideales para cualquier ocasión.',
      ingredients: [
        '1 1/2 tazas de harina para todo uso',
        '1 1/2 cucharaditas de polvo para hornear',
        '1/4 cucharadita de sal',
        '1/2 taza de mantequilla sin sal, ablandada',
        '1 taza de azúcar granulada',
        '2 huevos grandes',
        '1 1/2 cucharaditas de extracto de vainilla',
        '1/2 taza de leche',
        '1 taza de azúcar glas para la crema de mantequilla',
        '1/2 taza de mantequilla para la crema de mantequilla',
        '1 cucharadita de esencia de vainilla',
        'Colorante alimentario (opcional)',
      ],
      steps: [
        'Precalentar el horno a 175°C y colocar capacillos en un molde para cupcakes.',
        'En un tazón, mezclar la harina, polvo de hornear y sal.',
        'En otro tazón, batir la mantequilla con el azúcar hasta que esté cremosa. Agregar los huevos, uno a uno, y la esencia de vainilla.',
        'Incorporar gradualmente la mezcla de harina alternando con la leche, batiendo bien.',
        'Rellenar los capacillos con la mezcla hasta 2/3 de su capacidad.',
        'Hornear durante 18-20 minutos o hasta que al insertar un palillo salga limpio.',
        'Dejar enfriar completamente antes de decorar con la crema de mantequilla.',
        'Para la crema, batir la mantequilla con el azúcar glas y la vainilla hasta que esté suave. Añadir colorante si se desea.',
        'Decorar los cupcakes con la crema usando una manga pastelera.',
      ],
      prepTime: 30,
      cookTime: 20,
      servings: 12,
      category: 'Cupcakes',
      imageUrl: 'assets/images/vanilla_cupcakes.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Galletas con Chispas de Chocolate',
      description:
          'Deliciosas galletas con chispas de chocolate que tienen una textura perfecta, crujientes por fuera y suaves por dentro.',
      ingredients: [
        '2 1/4 tazas de harina para todo uso',
        '1 cucharadita de bicarbonato de sodio',
        '1 cucharadita de sal',
        '1 taza de mantequilla sin sal, ablandada',
        '3/4 taza de azúcar granulada',
        '3/4 taza de azúcar morena',
        '2 huevos grandes',
        '2 cucharaditas de extracto de vainilla',
        '2 tazas de chispas de chocolate',
      ],
      steps: [
        'Precalienta el horno a 190°C.',
        'Mezcla la harina, bicarbonato de sodio y sal en un tazón.',
        'En otro tazón, bate la mantequilla con los azúcares hasta que esté cremosa.',
        'Agrega los huevos uno a uno, batiendo bien después de cada adición.',
        'Añade la mezcla de harina, luego las chispas de chocolate.',
        'Forma bolitas de masa y colócalas en una bandeja para hornear.',
        'Hornea de 9-11 minutos hasta que estén doradas en los bordes.',
        'Deja enfriar antes de disfrutar.',
      ],
      prepTime: 15,
      cookTime: 12,
      servings: 24,
      category: 'Galletas',
      imageUrl: 'assets/images/chocolate_chip_cookies.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Tarta de Manzana',
      description:
          'Una tarta clásica y deliciosa de manzana, perfecta para cualquier ocasión. ¡Te llenará de amor y nostalgia!',
      ingredients: [
        '1 masa quebrada para tarta',
        '5 manzanas medianas, peladas y cortadas en rodajas',
        '1/2 taza de azúcar moreno',
        '1 cucharadita de canela',
        '1 cucharada de mantequilla',
        '1 cucharadita de esencia de vainilla',
        '1 huevo batido para pincelar',
      ],
      steps: [
        'Precalienta el horno a 180°C.',
        'Coloca la masa en un molde para tarta.',
        'En un tazón, mezcla las manzanas, azúcar, canela y esencia de vainilla.',
        'Rellena la masa con las manzanas y coloca pedacitos de mantequilla encima.',
        'Cubre la tarta con más masa, haciendo cortes para que respire.',
        'Pincela con huevo batido.',
        'Hornea durante 40 minutos o hasta que la masa esté dorada.',
      ],
      prepTime: 15,
      cookTime: 40,
      servings: 8,
      category: 'Tartas',
      imageUrl: 'assets/images/tarta_manzana.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Brownie de Chocolate',
      description:
          'Un brownie súper chocolateado, denso y delicioso. Ideal para acompañar con un poco de helado de vainilla.',
      ingredients: [
        '1 taza de mantequilla derretida',
        '1 taza de azúcar',
        '1/2 taza de azúcar moreno',
        '4 huevos',
        '1 taza de cacao en polvo',
        '1 taza de harina',
        '1 cucharadita de esencia de vainilla',
        '1/2 cucharadita de sal',
        '1 taza de nueces picadas (opcional)',
      ],
      steps: [
        'Precalienta el horno a 180°C y coloca papel para hornear en un molde cuadrado.',
        'Bate la mantequilla con los azúcares, añade los huevos uno a uno.',
        'Agrega el cacao, la harina, la vainilla y la sal. Mezcla bien.',
        'Incorpora las nueces (si las deseas).',
        'Vierte la mezcla en el molde y hornea durante 25-30 minutos.',
        'Deja enfriar, corta en cuadros y disfruta.',
      ],
      prepTime: 15,
      cookTime: 30,
      servings: 16,
      category: 'Otros',
      imageUrl: 'assets/images/brownie_chocolate.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Tarta de Fresa',
      description:
          'Una tarta refrescante de fresa, con una base crujiente y una crema suave que enamora a cualquiera.',
      ingredients: [
        '1 base de tarta de galletas',
        '2 tazas de fresas frescas, cortadas',
        '1 taza de nata para montar',
        '1/2 taza de azúcar',
        '1 cucharadita de esencia de vainilla',
        '1 cucharada de gelatina sin sabor',
        '1/4 taza de agua',
      ],
      steps: [
        'Precalienta el horno a 180°C y hornea la base de tarta por 10 minutos.',
        'En un tazón, bate la nata con el azúcar y la esencia de vainilla hasta que esté firme.',
        'Disuelve la gelatina en agua caliente y agrega a la mezcla de nata.',
        'Vierte la mezcla sobre la base de la tarta y deja enfriar en la nevera durante 2 horas.',
        'Coloca las fresas encima antes de servir.',
      ],
      prepTime: 20,
      cookTime: 10,
      servings: 8,
      category: 'Tartas',
      imageUrl: 'assets/images/tarta_fresas.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Panna Cotta de Frambuesa',
      description:
          'Un postre italiano delicado y cremoso con un toque de frambuesa fresca, ¡perfecto para enamorar con un bocado!',
      ingredients: [
        '1 taza de nata para montar',
        '1 taza de leche',
        '1/4 taza de azúcar',
        '1 vaina de vainilla',
        '2 cucharaditas de gelatina sin sabor',
        '1/4 taza de agua fría',
        '1 taza de frambuesas frescas',
        '2 cucharadas de azúcar (para las frambuesas)',
      ],
      steps: [
        'Hidrata la gelatina en el agua fría durante 5 minutos.',
        'En una cacerola, calienta la nata, leche y azúcar. Agrega la vaina de vainilla y cocina a fuego bajo.',
        'Añade la gelatina disuelta y mezcla bien.',
        'Vierte en moldes individuales y deja enfriar en la nevera durante 4 horas.',
        'Para la salsa de frambuesa, cocina las frambuesas con el azúcar hasta que se forme una salsa espesa.',
        'Sirve la panna cotta con la salsa de frambuesa por encima.',
      ],
      prepTime: 15,
      cookTime: 5,
      servings: 6,
      category: 'Otros',
      imageUrl: 'assets/images/panna_cotta_frambuesa.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Tiramisú',
      description:
          'Un tiramisú clásico italiano que combina café, cacao y mascarpone en una receta cremosa y llena de sabor.',
      ingredients: [
        '500g de queso mascarpone',
        '3 yemas de huevo',
        '1 taza de azúcar',
        '1 taza de café fuerte',
        '1 paquete de bizcochos de soletilla',
        'Cacao en polvo para decorar',
        '1 cucharadita de esencia de vainilla',
      ],
      steps: [
        'Bate las yemas con el azúcar hasta que se forme una crema espesa.',
        'Agrega el mascarpone y la vainilla, mezclando bien.',
        'Baña los bizcochos en el café y colócalos en el fondo de un molde.',
        'Cubre con una capa de crema de mascarpone, repite las capas y termina con crema.',
        'Deja enfriar en la nevera durante 4 horas.',
        'Decora con cacao en polvo antes de servir.',
      ],
      prepTime: 20,
      cookTime: 0,
      servings: 8,
      category: 'Otros',
      imageUrl: 'assets/images/tiramisu.jpg',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Cheesecake de Frambuesa',
      description:
          'Una cheesecake cremosa con un toque de frambuesas frescas. Suave, dulce y refrescante, ¡será la estrella de tu mesa!',
      ingredients: [
        '200g de galletas Digestive',
        '100g de mantequilla derretida',
        '600g de queso crema',
        '1 taza de azúcar',
        '3 huevos',
        '1 cucharadita de esencia de vainilla',
        '1 taza de frambuesas frescas',
        '1/4 taza de azúcar para las frambuesas',
      ],
      steps: [
        'Precalienta el horno a 160°C.',
        'Muele las galletas y mézclalas con la mantequilla derretida. Coloca la mezcla en un molde y presiona bien.',
        'Bate el queso crema con el azúcar, los huevos y la vainilla hasta que quede suave.',
        'Vierte la mezcla sobre la base de galletas y hornea durante 45 minutos.',
        'Deja enfriar completamente antes de añadir las frambuesas y el azúcar por encima.',
      ],
      prepTime: 15,
      cookTime: 45,
      servings: 8,
      category: 'Tartas',
      imageUrl: 'assets/images/cheescake_frambuesa.png',
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Helado de Mango Casero',
      description: 'Postre frío y cremoso elaborado con mango natural.',
      ingredients: [
        '2 mangos maduros',
        '1 taza de crema para batir',
        '1/2 taza de leche condensada',
        '1 cucharadita de esencia de vainilla',
        'Jugo de medio limón',
      ],
      steps: [
        'Pelar y licuar los mangos junto con el jugo de limón.',
        'Mezclar con la crema, leche condensada y esencia de vainilla.',
        'Verter la mezcla en un recipiente y congelar por 6 horas.',
        'Remover cada 2 horas para obtener una textura cremosa.',
      ],
      prepTime: 10,
      cookTime: 0,
      servings: 6,
      category: 'Otros',
      imageUrl: 'assets/images/helado_mango.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Empanadas de Queso',
      description: 'Empanadas fritas con masa casera y relleno de queso.',
      ingredients: [
        '2 tazas de harina',
        '1/2 taza de mantequilla',
        '1 huevo',
        '1/4 taza de agua',
        '1 pizca de sal',
        '1 taza de queso rallado',
        'Aceite para freír',
      ],
      steps: [
        'Mezclar la harina con la mantequilla, el huevo, el agua y la sal hasta formar una masa.',
        'Estirar la masa y cortar círculos.',
        'Rellenar con queso, sellar y freír hasta dorar.',
      ],
      prepTime: 25,
      cookTime: 10,
      servings: 10,
      category: 'Panes',
      imageUrl: 'assets/images/empanadas_queso.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Panqueques de Avena y Plátano',
      description: 'Panqueques saludables hechos con avena y plátano.',
      ingredients: [
        '1 plátano maduro',
        '1 huevo',
        '1/2 taza de avena',
        '1/4 taza de leche',
        '1 cucharadita de canela',
        '1 pizca de sal',
        'Aceite para cocinar',
      ],
      steps: [
        'Triturar el plátano y mezclar con el huevo.',
        'Agregar avena, leche, canela y sal.',
        'Cocinar en sartén a fuego medio hasta dorar por ambos lados.',
      ],
      prepTime: 10,
      cookTime: 10,
      servings: 4,
      category: 'Otros',
      imageUrl: 'assets/images/panqueques_avena_platano.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Pizza Margarita Casera',
      description:
          'Pizza italiana con salsa de tomate, queso mozzarella y albahaca.',
      ingredients: [
        '1 base de pizza',
        '100g de salsa de tomate',
        '200g de queso mozzarella',
        'Hojas de albahaca',
        'Aceite de oliva',
        'Sal y pimienta al gusto',
      ],
      steps: [
        'Precalentar el horno a 220°C.',
        'Colocar salsa sobre la base, añadir queso y hojas de albahaca.',
        'Rociar con aceite de oliva.',
        'Hornear durante 12 minutos.',
      ],
      prepTime: 10,
      cookTime: 12,
      servings: 4,
      category: 'Otros',
      imageUrl: 'assets/images/pizza_margarita_casera.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Mousse de Chocolate',
      description: 'Postre suave y aireado a base de chocolate negro.',
      ingredients: [
        '200g de chocolate negro',
        '3 huevos',
        '1/2 taza de azúcar',
        '1 taza de nata montada',
        '1 pizca de sal',
      ],
      steps: [
        'Derretir el chocolate y mezclar con las yemas.',
        'Batir las claras con sal y añadir el azúcar.',
        'Incorporar las claras montadas y la nata con movimientos envolventes.',
        'Refrigerar por al menos 2 horas.',
      ],
      prepTime: 15,
      cookTime: 0,
      servings: 6,
      category: 'Otros',
      imageUrl: 'assets/images/mousse_chocolate.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Smoothie de Frutilla',
      description: 'Bebida fría y nutritiva elaborada con frutilla y plátano.',
      ingredients: [
        '1 taza de frutilla congelada',
        '1/2 plátano',
        '1 taza de leche vegetal',
        '1 cucharada de semillas de chía',
        '1 cucharadita de miel',
        'Hielo al gusto',
      ],
      steps: [
        'Licuar todos los ingredientes hasta obtener una textura homogénea.',
        'Servir frío.',
      ],
      prepTime: 5,
      cookTime: 0,
      servings: 2,
      category: 'Otros',
      imageUrl: 'assets/images/smoothie_frutilla.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),

    Recipe(
      id: 'recipe_${const Uuid().v4()}',
      userId: defaultUserId,
      name: 'Crepas con Nutella',
      description:
          'Postre clásico de crepas finas con relleno de crema de avellanas.',
      ingredients: [
        '1 taza de harina',
        '1 taza de leche',
        '2 huevos',
        '1 cucharada de mantequilla derretida',
        '1 pizca de sal',
        'Nutella al gusto',
        'Frutas para decorar',
      ],
      steps: [
        'Mezclar todos los ingredientes excepto la Nutella y las frutas.',
        'Cocinar las crepas en sartén caliente por ambos lados.',
        'Rellenar con Nutella y decorar con frutas.',
      ],
      prepTime: 10,
      cookTime: 10,
      servings: 4,
      category: 'Otros',
      imageUrl: 'assets/images/crepas_nutella.jpg',
      isFavorite: false,
      createdAt: DateTime.now(),
    ),
  ];

  for (var recipe in sampleRecipes) {
    await recipeBox.add(recipe);
  }
}
