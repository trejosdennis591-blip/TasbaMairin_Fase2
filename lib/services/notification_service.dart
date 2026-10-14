import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/config/api_config.dart';

class NotificationService {
  // ==========================================================
  // OBTENER TOKEN
  // ==========================================================

  static Future<String?> _obtenerToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  // ==========================================================
  // OBTENER NOTIFICACIONES
  // ==========================================================

  static Future<List<Map<String, dynamic>>>
      obtenerNotificaciones() async {
    final token =
        await _obtenerToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'No hay sesión iniciada',
      );
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      final lista =
          data['notificaciones'];

      if (lista is List) {
        return lista
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item,
              ),
            )
            .toList();
      }

      return [];
    }

    throw Exception(
      'No se pudieron obtener las notificaciones',
    );
  }

  // ==========================================================
  // CONTAR NO LEÍDAS
  // ==========================================================

  static Future<int> contarNoLeidas() async {
    final token =
        await _obtenerToken();

    if (token == null ||
        token.isEmpty) {
      return 0;
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/no-leidas',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body);

      return int.tryParse(
            data['total'].toString(),
          ) ??
          0;
    }

    throw Exception(
      'No se pudo obtener el contador de notificaciones',
    );
  }

  // ==========================================================
  // MARCAR UNA COMO LEÍDA
  // ==========================================================

  static Future<void> marcarComoLeida(
    int notificacionId,
  ) async {
    final token =
        await _obtenerToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'No hay sesión iniciada',
      );
    }

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/$notificacionId/leida',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo marcar la notificación como leída',
      );
    }
  }

  // ==========================================================
  // MARCAR TODAS COMO LEÍDAS
  // ==========================================================

  static Future<void> marcarTodasComoLeidas() async {
    final token =
        await _obtenerToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'No hay sesión iniciada',
      );
    }

    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/marcar-todas-leidas',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron marcar las notificaciones como leídas',
      );
    }
  }
}