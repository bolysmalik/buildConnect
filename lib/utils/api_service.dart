// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_valhalla/features/routing/data/models/product.dart';


class ApiService {
  final String _apiUrl = 'http://telecom.schoolmaster.kz:8081/api/v1/lookup';

  Future<Product?> getProductInfo(String barcode, String model) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'barcode': barcode,
        'model': model,
      }),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      // Возвращаем null, если товар не найден
      return null;
    } else {
      // Для всех других ошибок продолжаем выбрасывать исключение
      throw Exception('Ошибка при получении данных о продукте. Статус-код: ${response.statusCode}');
    }
  }
}