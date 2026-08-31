import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/message.dart';

class MessageService {
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
        'No hay una sesión activa',
      );
    }

    return token;
  }

  // ==========================================================
  // OBTENER USUARIO ACTUAL
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

    final id =
        int.tryParse(usuarioId);

    if (id == null) {
      throw Exception(
        'El ID del usuario no es válido',
      );
    }

    return id;
  }

  // ==========================================================
  // OBTENER CONVERSACIÓN
  // ==========================================================

  static Future<List<Message>>
      obtenerMensajes({
    required String otroUsuarioId,
    required String productoId,
  }) async {
    final token =
        await _obtenerToken();

    print(
      '====================================',
    );

    print(
      'USUARIO DESTINO: $otroUsuarioId',
    );

    print(
      'PRODUCTO: $productoId',
    );

    print(
      'URL: '
      '$baseUrl/mensajes/'
      '$otroUsuarioId/'
      '$productoId',
    );

    print(
      '====================================',
    );

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/mensajes/'
        '$otroUsuarioId/'
        '$productoId',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    print(
      'MENSAJES STATUS: '
      '${response.statusCode}',
    );

    print(
      'MENSAJES BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener los mensajes',
      );
    }

    final List lista =
        data['mensajes'] ?? [];

    final usuarioActual =
        await _obtenerUsuarioId();

    // ========================================================
    // CONVERTIR MENSAJES
    // ========================================================

    return lista.map<Message>((m) {
      final remitente =
          int.parse(
        m['RemitenteID'].toString(),
      );

      return Message(
        mensajeId:
            m['MensajeID'] != null
                ? int.parse(
                    m['MensajeID'].toString(),
                  )
                : null,

        remitenteId:
            remitente.toString(),

        destinatarioId:
            m['DestinatarioID']
                .toString(),

        mensaje:
            m['Contenido']
                    ?.toString() ??
                '',

        fechaEnvio:
            DateTime.parse(
          m['FechaEnvio']
              .toString(),
        ),

        leido:
            m['Leido'].toString() == '1' ||
            m['Leido'] == true,

        mio:
            remitente ==
                usuarioActual,

        // ====================================================
        // FOTO DE PERFIL
        // ====================================================

        imagenPerfil:
            m['FotoPerfil']
                ?.toString(),
      );
    }).toList();
  }

  // ==========================================================
  // ENVIAR MENSAJE
  // ==========================================================

  static Future<void> enviarMensaje({
    required String destinatarioId,
    required String productoId,
    required String mensaje,
  }) async {
    if (mensaje.trim().isEmpty) {
      return;
    }

    final token =
        await _obtenerToken();

    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/mensajes',
      ),
      headers: {
        'Content-Type':
            'application/json',

        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode({
        'destinatarioId':
            int.parse(
          destinatarioId,
        ),

        'productoId':
            int.parse(
          productoId,
        ),

        'contenido':
            mensaje.trim(),
      }),
    );

    print(
      'ENVIAR MENSAJE STATUS: '
      '${response.statusCode}',
    );

    print(
      'ENVIAR MENSAJE BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        data['mensaje'] ??
            'No se pudo enviar el mensaje',
      );
    }
  }

  // ==========================================================
  // OBTENER CONVERSACIONES
  // ==========================================================

  static Future<
      List<Map<String, String>>>
      obtenerConversaciones() async {
    final token =
        await _obtenerToken();

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/mensajes/conversaciones',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    print(
      'CONVERSACIONES STATUS: '
      '${response.statusCode}',
    );

    print(
      'CONVERSACIONES BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener las conversaciones',
      );
    }

    final List lista =
        data['conversaciones'] ?? [];

    return lista
        .map<Map<String, String>>(
      (item) {
        return {
          'usuarioId':
              item['usuarioId']
                      ?.toString() ??
                  '',

          'nombre':
              item['nombre']
                      ?.toString() ??
                  'Usuario',

          'productoId':
              item['productoId']
                      ?.toString() ??
                  '',

          'ultimoMensaje':
              item['ultimoMensaje']
                      ?.toString() ??
                  '',

          'hora':
              item['hora']
                      ?.toString() ??
                  '',

          // ==================================================
          // FOTO DE PERFIL
          // ==================================================

          'imagenPerfil':
              item['imagenPerfil']
                      ?.toString() ??
                  '',
        };
      },
    ).toList();
  }

  // ==========================================================
  // MARCAR COMO LEÍDO
  // ==========================================================

  static Future<void> marcarComoLeido({
    required String otroUsuarioId,
    required String productoId,
  }) async {
    // El backend marca los mensajes
    // como leídos al abrir la conversación.
  }

  // ==========================================================
  // LIMPIAR MENSAJES
  // ==========================================================

  static Future<void> limpiarMensajes() async {
    // Los mensajes están almacenados en MySQL.
  }
}