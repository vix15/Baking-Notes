import 'package:hive/hive.dart';

part 'auth_state.g.dart';

@HiveType(typeId: 2)
class AuthState extends HiveObject {
  @HiveField(0)
  String userId;
  
  @HiveField(1)
  DateTime lastLogin;
  
  AuthState({
    required this.userId,
    required this.lastLogin,
  });
}