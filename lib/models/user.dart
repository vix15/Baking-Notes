import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String username;
  
  @HiveField(2)
  String password;
  
  @HiveField(3)
  String email;
  
  @HiveField(4)
  List<String> favoriteRecipeIds;
  
  @HiveField(5)
  String? profileImagePath;
  
  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.favoriteRecipeIds,
    this.profileImagePath,
  });
  
  void updateProfileImage(String path) {
    profileImagePath = path;
    save();
  }
}