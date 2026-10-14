import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/config/api_config.dart';

class UserService {
  // ==========================================================
  // OBTENER TOKEN
  // ==========================================================

  static Future<String> _obtenerToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'No hay una sesión activa',
      );
    }

    return token;
  }

  // ==========================================================
  // OBTENER PERFIL PÚBLICO
  // ==========================================================

  static Future<Map<String, dynamic>>
      obtenerPerfilPublico(
    String usuarioId,
  ) async {
    final id = usuarioId.trim();

    if (id.isEmpty) {
      throw Exception(
        'ID de usuario inválido',
      );
    }

    final token =
        await _obtenerToken();

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/usuarios/$id',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
        'Content-Type':
            'application/json',
      },
    );

    Map<String, dynamic> data;

    try {
      data = jsonDecode(
        response.body,
      );
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta inválida',
      );
    }

    if (response.statusCode == 200) {
      final usuario =
          data['usuario'];

      if (usuario
          is Map<String, dynamic>) {
        return usuario;
      }

      throw Exception(
        'El servidor no devolvió los datos del usuario',
      );
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudo obtener el perfil',
    );
  }

    static Future<Map<String, dynamic>>
      obtenerPerfilPublicoCompleto(
    String usuarioId,
  ) async {
    final id = usuarioId.trim();

    if (id.isEmpty) {
      throw Exception(
        'ID de usuario inválido',
      );
    }

    final token =
        await _obtenerToken();

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/usuarios/$id/completo',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
        'Content-Type':
            'application/json',
      },
    );

    Map<String, dynamic> data;

    try {
      data = jsonDecode(
        response.body,
      );
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta inválida',
      );
    }

    if (response.statusCode == 200) {
      final usuario =
          data['usuario'];

      if (usuario
          is Map<String, dynamic>) {
        return usuario;
      }

      throw Exception(
        'El servidor no devolvió los datos del usuario',
      );
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudo obtener el perfil público',
    );
  }
}