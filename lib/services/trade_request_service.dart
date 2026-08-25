import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/trade_request.dart';

class TradeRequestService {
  static const String baseUrl =
      'http://192.168.1.25:3000/api';

  // ==========================================================
  // TOKEN
  // ==========================================================

  static Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa');
    }

    return token;
  }

  // ==========================================================
  // CREAR SOLICITUD
  // ==========================================================

  static Future<void> crearSolicitud({
    required int productoId,
    required String nombreProducto,
    required String solicitanteId,
    required String nombreSolicitante,
    required String mensaje,
  }) async {
    final token = await _obtenerToken();

    final response = await http.post(
      Uri.parse('$baseUrl/trueques'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productoOfrecidoId': productoId,
        'productoSolicitadoId': productoId,
        'usuarioSolicitaId':
            int.tryParse(solicitanteId) ?? 0,
        'mensaje': mensaje,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        data['mensaje'] ??
            'No se pudo crear el trueque',
      );
    }
  }

  // ==========================================================
  // OBTENER MIS TRUEQUES
  // ==========================================================

  static Future<List<TradeRequest>>
      obtenerSolicitudes() async {
    final token = await _obtenerToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/trueques/mis-trueques',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener los trueques',
      );
    }

    return (data['trueques'] as List)
        .map(
          (t) => TradeRequest(
            id: t['TruequeID'],
            productoId:
                t['ProductoSolicitadoID'],
            nombreProducto: '',
            solicitanteId:
                t['UsuarioSolicitaID']
                    .toString(),
            nombreSolicitante: '',
            mensaje: t['Mensaje'] ?? '',
            estado: t['Estado'] ?? '',
            fecha: DateTime.parse(
              t['FechaInicio'],
            ),
          ),
        )
        .toList();
  }

  // ==========================================================
  // APROBAR
  // ==========================================================

static Future<void> aprobarSolicitud(
  int id,
) async {
  final token = await _obtenerToken();

  print("ACEPTANDO TRUEQUE ID: $id");

  final response = await http.put(
    Uri.parse(
      '$baseUrl/trueques/$id/estado',
    ),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
  'estado': 'Aceptado',
    }),
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'No se pudo aprobar la solicitud',
    );
  }
}

  // ==========================================================
  // RECHAZAR
  // ==========================================================

  static Future<void> rechazarSolicitud(
    int id,
  ) async {
    final token = await _obtenerToken();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/trueques/$id/estado',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
         body: jsonEncode({
        'estado': 'Rechazado',
     }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo rechazar la solicitud',
      );
    }
  }
}