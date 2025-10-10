import '../../data/local_storage/local_storage_impl.dart';
import '../../data/models/user_model.dart';

class AuthRepositoryImpl {
  final LocalStorageImpl storage;

  AuthRepositoryImpl({required this.storage});

  Future<UserModel> login(String email) async {
    final users = storage.userBox.values.toList();

    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );

    await storage.saveCurrentUser(user);

    return user;
  }

  Future<void> logout() async {
    await storage.clearCurrentUser();
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String role,
    String? department,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final newUser = UserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      department: department,
    );

    await storage.saveUser(newUser);
    await storage.saveCurrentUser(newUser);

    return newUser;
  }

  Future<UserModel?> getCurrentUser() async {
    return await storage.getCurrentUser();
  }
}
