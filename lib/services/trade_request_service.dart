import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/trade_request.dart';
import 'package:flutter_application_1/config/api_config.dart';

class TradeRequestService {
  // ==========================================================
  // TOKEN
  // ==========================================================

  static Future<String> _obtenerToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa');
    }

    return token;
  }

  // ==========================================================
  // USUARIO LOGUEADO
  // ==========================================================

  static Future<int> _obtenerUsuarioId() async {
    final prefs =
        await SharedPreferences.getInstance();

    final usuarioId =
        prefs.getString('usuario_id');

    if (usuarioId == null ||
        usuarioId.isEmpty) {
      throw Exception(
        'No se encontró el usuario logueado',
      );
    }

    final id = int.tryParse(usuarioId);

    if (id == null) {
      throw Exception(
        'El ID del usuario no es válido',
      );
    }

    return id;
  }

  // ==========================================================
  // CREAR SOLICITUD
  // ==========================================================

  static Future<void> crearSolicitud({
    required int productoId,
    required int usuarioOfreceId,
    required String mensaje,
  }) async {
    final token =
        await _obtenerToken();

    final usuarioLogueado =
        await _obtenerUsuarioId();

    print(
      '==============================',
    );

    print(
      'CREANDO TRUEQUE',
    );

    print(
      'Usuario logueado: $usuarioLogueado',
    );

    print(
      'Producto solicitado: $productoId',
    );

    print(
      'Mensaje: $mensaje',
    );

    print(
      '==============================',
    );

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/trueques',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode({
        'productoOfrecidoId':
            productoId,
        'productoSolicitadoId':
            productoId,
        'usuarioOfreceId':
            usuarioOfreceId,
        'usuarioSolicitaId':
            usuarioLogueado,
        'mensaje':
            mensaje,
      }),
    );

    print(
      'CREAR TRUEQUE STATUS: '
      '${response.statusCode}',
    );

    print(
      'CREAR TRUEQUE BODY: '
      '${response.body}',
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {};
    }

    if (response.statusCode != 201) {
      throw Exception(
        data is Map &&
                data['mensaje'] != null
            ? data['mensaje']
                .toString()
            : 'No se pudo crear el trueque',
      );
    }
  }

  // ==========================================================
  // OBTENER MIS TRUEQUES
  // ==========================================================

  static Future<List<TradeRequest>>
      obtenerSolicitudes() async {
    final token =
        await _obtenerToken();

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/trueques/mis-trueques',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta inválida',
      );
    }

    print(
      'TRUEQUES RECIBIDOS:',
    );

    print(
      data['trueques'],
    );

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener los trueques',
      );
    }

    final lista =
        data['trueques'];

    if (lista is! List) {
      return [];
    }

    return lista.map<TradeRequest>((t) {
      return TradeRequest(
        id: t['TruequeID'] is int
            ? t['TruequeID']
            : int.parse(
                t['TruequeID'].toString(),
              ),

        productoId:
            t['ProductoSolicitadoID'] is int
                ? t['ProductoSolicitadoID']
                : int.parse(
                    t['ProductoSolicitadoID']
                        .toString(),
                  ),

        nombreProducto:
            t['NombreProducto']
                    ?.toString() ??
                '',

        solicitanteId:
            t['UsuarioSolicitaID']
                .toString(),

        propietarioId:
            t['UsuarioOfreceID']
                .toString(),

        nombreSolicitante:
            t['NombreSolicitante']
                    ?.toString() ??
                '',

        mensaje:
            t['Mensaje']
                    ?.toString() ??
                '',

        estado:
            t['Estado']
                    ?.toString() ??
                '',

        fecha: DateTime.parse(
          t['FechaInicio']
              .toString(),
        ),
      );
    }).toList();
  }

  // ==========================================================
  // APROBAR
  // ==========================================================

  static Future<void>
      aprobarSolicitud(int id) async {
    final token =
        await _obtenerToken();

    final response =
        await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/trueques/$id/estado',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode({
        'estado': 'Aceptado',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo aprobar la solicitud',
      );
    }
  }

  // ==========================================================
  // RECHAZAR
  // ==========================================================

  static Future<void>
      rechazarSolicitud(int id) async {
    final token =
        await _obtenerToken();

    final response =
        await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/trueques/$id/estado',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
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

  // ==========================================================
  // CANCELAR
  // ==========================================================

  static Future<void>
      cancelarSolicitud(int id) async {
    final token =
        await _obtenerToken();

    final response =
        await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/trueques/$id',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'No se pudo cancelar la solicitud',
      );
    }
  }
}