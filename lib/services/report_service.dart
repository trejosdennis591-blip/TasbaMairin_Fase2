import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/config/api_config.dart';

class ReportService {
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
  //
  // Puede reportar:
  // - Un producto
  // - Un usuario
  //
  // Para reportar un producto:
  //   productoId debe tener valor.
  //
  // Para reportar un usuario:
  //   usuarioReportadoId debe tener valor.
  // ==========================================================

  static Future<void> crearReporte({
    int? productoId,
    int? usuarioReportadoId,
    required String motivo,
    required String descripcion,
  }) async {
    // --------------------------------------------------------
    // COMPROBAR QUE SE ESTÁ REPORTANDO ALGO
    // --------------------------------------------------------

    if (productoId == null &&
        usuarioReportadoId == null) {
      throw Exception(
        'Debes indicar el producto o usuario que deseas reportar',
      );
    }

    // --------------------------------------------------------
    // EVITAR ENVIAR LOS DOS A LA VEZ
    // --------------------------------------------------------

    if (productoId != null &&
        usuarioReportadoId != null) {
      throw Exception(
        'No puedes reportar un producto y un usuario al mismo tiempo',
      );
    }

    // --------------------------------------------------------
    // VALIDAR MOTIVO
    // --------------------------------------------------------

    if (motivo.trim().isEmpty) {
      throw Exception(
        'Debes indicar el motivo del reporte',
      );
    }

    // --------------------------------------------------------
    // VALIDAR DESCRIPCIÓN
    // --------------------------------------------------------

    if (descripcion.trim().isEmpty) {
      throw Exception(
        'Debes explicar el motivo del reporte',
      );
    }

    final token =
        await _obtenerToken();

    // --------------------------------------------------------
    // BODY
    // --------------------------------------------------------

    final Map<String, dynamic> body = {
      'motivo': motivo.trim(),
      'descripcion': descripcion.trim(),
    };

    // Reporte de producto
    if (productoId != null) {
      body['productoId'] = productoId;
    }

    // Reporte de usuario
    if (usuarioReportadoId != null) {
      body['usuarioReportadoId'] =
          usuarioReportadoId;
    }

    // --------------------------------------------------------
    // ENVIAR REPORTE
    // --------------------------------------------------------

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/reportes',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print(
      'REPORTE STATUS: ${response.statusCode}',
    );

    print(
      'REPORTE BODY: ${response.body}',
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {};
    }

    // --------------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------------

    if (response.statusCode != 201) {
      throw Exception(
        data is Map &&
                data['mensaje'] != null
            ? data['mensaje'].toString()
            : 'No se pudo enviar el reporte',
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
        '${ApiConfig.baseUrl}/reportes/mis-reportes',
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

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta inválida',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        data is Map &&
                data['mensaje'] != null
            ? data['mensaje'].toString()
            : 'No se pudieron obtener los reportes',
      );
    }

    return data['reportes'] ?? [];
  }
}