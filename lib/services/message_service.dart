import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/config/api_config.dart';

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class MessageService {
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
      '${ApiConfig.baseUrl}/mensajes/'
      '$otroUsuarioId/'
      '$productoId',
    );

    print(
      '====================================',
    );

    final response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/mensajes/'
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

        imagen:
            m['Imagen']
                ?.toString(),

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
  String? imagenPath,
}) async {
  final token =
      await _obtenerToken();

  final request =
      http.MultipartRequest(
    'POST',
    Uri.parse(
      '${ApiConfig.baseUrl}/mensajes',
    ),
  );

  request.headers[
          'Authorization'] =
      'Bearer $token';

  request.fields[
          'destinatarioId'] =
      destinatarioId;

  request.fields[
          'productoId'] =
      productoId;

  request.fields[
          'contenido'] =
      mensaje.trim();

  if (imagenPath != null &&
      imagenPath.isNotEmpty) {

    final extension =
        path.extension(imagenPath).toLowerCase();

    MediaType tipoImagen;

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        tipoImagen =
            MediaType('image', 'jpeg');
        break;

      case '.png':
        tipoImagen =
            MediaType('image', 'png');
        break;

      case '.webp':
        tipoImagen =
            MediaType('image', 'webp');
        break;

      default:
        throw Exception(
          'Formato de imagen no permitido: $extension',
        );
    }

    print(
      '========== ARCHIVO A ENVIAR ==========',
    );

    print(
      'PATH: $imagenPath',
    );

    print(
      'EXTENSION: $extension',
    );

    print(
      'MIME: $tipoImagen',
    );

    print(
      '=======================================',
    );

    final archivo =
        await http.MultipartFile.fromPath(
      'imagen',
      imagenPath,
      contentType: tipoImagen,
    );

    request.files.add(
      archivo,
    );
  }

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
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
        '${ApiConfig.baseUrl}/mensajes/conversaciones',
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

          'imagenPerfil':
              item['imagenPerfil']
                      ?.toString() ??
                  '',
        };
      },
    ).toList();
  }

  // ==========================================================
  // OBTENER MENSAJES NO LEÍDOS
  // ==========================================================

  static Future<int>
      obtenerMensajesNoLeidos() async {
    final token =
        await _obtenerToken();

    final response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/mensajes/conversaciones',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'No se pudieron obtener las notificaciones',
      );
    }

    return int.tryParse(
          data['mensajesNoLeidos']
              .toString(),
        ) ??
        0;
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