import 'package:dio/dio.dart';

import '../models/user.dart';

class UserRepository {
  final Dio _dio;

  UserRepository() : _dio = Dio();

  Future<UserModel> getUser() async {
    try {
      final response = await _dio.get("https://randomuser.me/api/");

      final userData = response.data['results'][0];

      final user = UserModel(
        userName: userData['login']['username'],
        email: userData['email'],
        photo: userData['picture']['large'],
      );

      return user;
    } catch (e) {
      throw Exception("Failed load user data: $e");
    }
  }
}
