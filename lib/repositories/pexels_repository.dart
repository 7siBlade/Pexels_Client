import 'package:dio/dio.dart';
import '../models/pexels.dart';

class PexelsRepository {
  final Dio _dio;

  PexelsRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: "https://api.pexels.com/v1/",
            headers: {
              "Authorization":
                  "4gveMvRM1V9FsFCcKH2rvspJo3CaB8JcO8g5zCmNox8wEfSGkIAqWCEo",
            },
          ),
        );

  Future<List<PexelsModel>> getPexels() async {
    try {
      final response = await _dio.get("curated?per_page=50");

      final List photos = response.data['photos'];

      final dataList = photos.map((photo) {
        return PexelsModel(
          namePhotographer: photo['photographer'],
          url: photo['src']['original'],
          description: photo['alt'],
        );
      }).toList();

      return dataList;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
