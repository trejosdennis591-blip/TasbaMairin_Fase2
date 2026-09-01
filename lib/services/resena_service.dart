import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/config/api_config.dart';

class ResenaService {

  // ==========================================================
  // OBTENER TOKEN
  // ==========================================================

  static Future<String> _obtenerToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa',
      );
    }

    return token;
  }

  // ==========================================================
  // OBTENER RESEÑAS DE UN PRODUCTO
  // ==========================================================

  static Future<List<Map<String, dynamic>>> obtenerResenas({
    required int productoId,
  }) async {
    final token =
        await _obtenerToken();

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/resenas/producto/$productoId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'RESEÑAS STATUS: ${response.statusCode}',
    );

    print(
      'RESEÑAS BODY: ${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener las reseñas',
      );
    }

    final List lista =
        data['resenas'] ?? [];

    return lista
        .map(
          (resena) =>
              Map<String, dynamic>.from(
            resena,
          ),
        )
        .toList();
  }

  // ==========================================================
  // CREAR RESEÑA
  // ==========================================================

  static Future<void> crearResena({
    required int productoId,
    required int calificacion,
    String? comentario,
  }) async {
    if (calificacion < 1 ||
        calificacion > 5) {
      throw Exception(
        'La calificación debe estar entre 1 y 5 estrellas',
      );
    }

    final token =
        await _obtenerToken();

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/resenas',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode({
        'productoId': productoId,
        'calificacion': calificacion,
        'comentario':
            comentario?.trim() ?? '',
      }),
    );

    print(
      'CREAR RESEÑA STATUS: '
      '${response.statusCode}',
    );

    print(
      'CREAR RESEÑA BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        data['mensaje'] ??
            'No se pudo enviar la reseña',
      );
    }
  }

  // ==========================================================
  // ACTUALIZAR RESEÑA
  // ==========================================================

  static Future<void> actualizarResena({
    required int resenaId,
    required int calificacion,
    String? comentario,
  }) async {
    if (calificacion < 1 ||
        calificacion > 5) {
      throw Exception(
        'La calificación debe estar entre 1 y 5 estrellas',
      );
    }

    final token =
        await _obtenerToken();

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/resenas/$resenaId',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode({
        'calificacion': calificacion,
        'comentario':
            comentario?.trim() ?? '',
      }),
    );

    print(
      'ACTUALIZAR RESEÑA STATUS: '
      '${response.statusCode}',
    );

    print(
      'ACTUALIZAR RESEÑA BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudo actualizar la reseña',
      );
    }
  }

  // ==========================================================
  // ELIMINAR RESEÑA
  // ==========================================================

  static Future<void> eliminarResena({
    required int resenaId,
  }) async {
    final token =
        await _obtenerToken();

    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/resenas/$resenaId',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    print(
      'ELIMINAR RESEÑA STATUS: '
      '${response.statusCode}',
    );

    print(
      'ELIMINAR RESEÑA BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudo eliminar la reseña',
      );
    }
  }
}