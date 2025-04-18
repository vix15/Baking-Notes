/*import 'package:hive/hive.dart';
import 'package:baking_notes/models/recipe.dart';
import 'package:baking_notes/models/user.dart';

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      ingredients: (fields[3] as List).cast<String>(),
      steps: (fields[4] as List).cast<String>(),
      prepTime: fields[5] as int,
      cookTime: fields[6] as int,
      servings: fields[7] as int,
      category: fields[8] as String,
      imageUrl: fields[9] as String,
      isFavorite: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.ingredients);
    writer.writeByte(4);
    writer.write(obj.steps);
    writer.writeByte(5);
    writer.write(obj.prepTime);
    writer.writeByte(6);
    writer.write(obj.cookTime);
    writer.writeByte(7);
    writer.write(obj.servings);
    writer.writeByte(8);
    writer.write(obj.category);
    writer.writeByte(9);
    writer.write(obj.imageUrl);
    writer.writeByte(10);
    writer.write(obj.isFavorite);
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return User(
      id: fields[0] as String,
      username: fields[1] as String,
      password: fields[2] as String,
      email: fields[3] as String,
      favoriteRecipeIds: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.username);
    writer.writeByte(2);
    writer.write(obj.password);
    writer.writeByte(3);
    writer.write(obj.email);
    writer.writeByte(4);
    writer.write(obj.favoriteRecipeIds);
  }
}*/