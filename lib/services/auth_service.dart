import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
 static const String baseUrl =
    'http://192.168.1.25:3000/api';

  // ==========================================================
  // INICIAR SESIÓN
  // ==========================================================

  static Future<Map<String, dynamic>> login(
    String correo,
    String contrasena,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      final usuario = data['usuario'];

      await prefs.setString(
        'token',
        data['token'],
      );

      if (usuario != null) {
        await prefs.setString(
          'usuario_id',
          usuario['UsuarioID'].toString(),
        );

        await prefs.setString(
          'nombre',
          usuario['Nombre'] ?? '',
        );

        await prefs.setString(
          'apellido',
          usuario['Apellido'] ?? '',
        );

        await prefs.setString(
          'correo',
          usuario['Correo'] ?? '',
        );

        await prefs.setString(
          'telefono',
          usuario['Telefono'] ?? '',
        );

        await prefs.setString(
          'tipo_usuario',
          usuario['TipoUsuario'] ?? '',
        );

        await prefs.setString(
          'estado',
          usuario['Estado'] ?? '',
        );
      }

      return data;
    } else {
      throw Exception(
        data['mensaje'] ?? 'Error al iniciar sesión',
      );
    }
  }

  // ==========================================================
  // REGISTRAR USUARIO
  // ==========================================================

  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String contrasena,
    required String tipoUsuario,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registro'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'correo': correo,
        'contrasena': contrasena,
        'tipoUsuario': tipoUsuario,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(
        data['mensaje'] ?? 'Error al registrar usuario',
      );
    }
  }

  // ==========================================================
  // ACTUALIZAR PERFIL
  // ==========================================================

  static Future<Map<String, dynamic>> actualizarPerfil({
    required String nombre,
    required String telefono,
    String? fotoPerfil,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa');
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/perfil'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['nombre'] = nombre;
    request.fields['telefono'] = telefono;

    if (fotoPerfil != null && fotoPerfil.isNotEmpty) {
      final extension =
          fotoPerfil.split('.').last.toLowerCase();

      String tipoMime;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          tipoMime = 'image/jpeg';
          break;

        case 'png':
          tipoMime = 'image/png';
          break;

        case 'webp':
          tipoMime = 'image/webp';
          break;

        default:
          throw Exception(
            'Formato de imagen no compatible',
          );
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'fotoPerfil',
          fotoPerfil,
          contentType: MediaType.parse(tipoMime),
        ),
      );
    }

    final streamedResponse = await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final usuario = data['usuario'];

      if (usuario != null) {
        await prefs.setString(
          'nombre',
          usuario['Nombre'] ?? '',
        );

        await prefs.setString(
          'telefono',
          usuario['Telefono'] ?? '',
        );

        if (usuario['FotoPerfil'] != null) {
          await prefs.setString(
            'foto_perfil',
            usuario['FotoPerfil'],
          );
        }
      }

      return data;
    } else {
      throw Exception(
        data['mensaje'] ??
            'Error al actualizar el perfil',
      );
    }
  }

  // ==========================================================
  // CERRAR SESIÓN
  // ==========================================================

  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('usuario_id');
    await prefs.remove('nombre');
    await prefs.remove('apellido');
    await prefs.remove('correo');
    await prefs.remove('telefono');
    await prefs.remove('tipo_usuario');
    await prefs.remove('estado');
  }
}