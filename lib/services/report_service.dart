import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  static const String baseUrl =
      'http://192.168.1.26:3000/api';

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
        'No hay sesión activa',
      );
    }

    return token;
  }

  // ==========================================================
  // CREAR REPORTE
  // ==========================================================

  static Future<void> crearReporte({
    required int productoId,
    required String motivo,
    required String descripcion,
  }) async {
    final token =
        await _obtenerToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/reportes',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode({
        'productoId': productoId,
        'motivo': motivo,
        'descripcion': descripcion,
      }),
    );

    print(
      'REPORTE STATUS: ${response.statusCode}',
    );

    print(
      'REPORTE BODY: ${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        data['mensaje'] ??
            'No se pudo enviar el reporte',
      );
    }
  }

  // ==========================================================
  // OBTENER MIS REPORTES
  // ==========================================================

  static Future<List<dynamic>>
      obtenerReportes() async {
    final token =
        await _obtenerToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/reportes/mis-reportes',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    print(
      'MIS REPORTES STATUS: '
      '${response.statusCode}',
    );

    print(
      'MIS REPORTES BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener los reportes',
      );
    }

    return data['reportes'] ?? [];
  }
}