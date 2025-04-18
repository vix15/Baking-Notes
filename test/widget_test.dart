import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baking_notes/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Crear un mock del Box de Hive
    final mockSettingsBox = MockBox<dynamic>();

    // Inyectar el mock si es necesario (esto dependerá de cómo uses Hive dentro de tu ThemeProvider o SplashScreen)

    // Construir el widget con un dummy como pantalla siguiente
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const BakingNotesApp(
          nextScreen: Scaffold(body: Text('Pantalla siguiente')),
        ),
      ),
    );

    // Verificar que se construye correctamente
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
