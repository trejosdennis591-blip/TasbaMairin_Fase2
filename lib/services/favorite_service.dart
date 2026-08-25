import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/product_service.dart';

class FavoriteService {
  FavoriteService._();

 static const String baseUrl =
    'http://192.168.1.25:3000/api';

  // ==========================================================
  // TOKEN
  // ==========================================================

  static Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa');
    }

    return token;
  }

  // ==========================================================
  // COMPROBAR SI ES FAVORITO
  // ==========================================================

  static bool esFavorito(Product producto) {
    return producto.favorito;
  }

  // ==========================================================
  // AGREGAR / QUITAR FAVORITO
  // ==========================================================

  static Future<void> cambiarFavorito(
    Product producto,
  ) async {
    final token = await _obtenerToken();

    if (producto.favorito) {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/favoritos/${producto.id}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        producto.favorito = false;
        return;
      }

      throw Exception(
        'No se pudo eliminar favorito',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/favoritos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productoId': producto.id,
      }),
    );

    if (response.statusCode == 201) {
      producto.favorito = true;
      return;
    }

    throw Exception(
      'No se pudo guardar favorito',
    );
  }

  // ==========================================================
  // OBTENER FAVORITOS
  // ==========================================================

  static Future<List<Product>>
      obtenerFavoritos() async {
    final token = await _obtenerToken();

    final response = await http.get(
      Uri.parse('$baseUrl/favoritos'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data['productos'] as List)
          .map(
            (producto) =>
                ProductService.convertirProducto(
              producto,
            ),
          )
          .toList();
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudieron obtener favoritos',
    );
  }

  // ==========================================================
  // CANTIDAD FAVORITOS
  // ==========================================================

  static Future<int> cantidadFavoritos()
      async {
    final favoritos =
        await obtenerFavoritos();

    return favoritos.length;
  }

  // ==========================================================
  // CARGAR FAVORITOS
  // ==========================================================

  static Future<void> cargarFavoritos() async {}
}