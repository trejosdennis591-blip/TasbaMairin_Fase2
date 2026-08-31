import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.1.26:3000/api';

  // ==========================================================
  // OBTENER TIPO MIME
  // ==========================================================

  static String obtenerTipoMime(String path) {
    final extension =
        path.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      default:
        throw Exception(
          'Formato de imagen no compatible. '
          'Usa JPG, JPEG, PNG o WEBP.',
        );
    }
  }

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

    if (response.statusCode != 200) {
      throw Exception(
        data['mensaje'] ??
            'Error al iniciar sesión',
      );
    }

    final prefs =
        await SharedPreferences.getInstance();

    final usuario = data['usuario'];

    if (usuario == null ||
        usuario is! Map<String, dynamic>) {
      throw Exception(
        'El servidor no devolvió los datos del usuario',
      );
    }

    final token = data['token'];

    if (token == null ||
        token.toString().isEmpty) {
      throw Exception(
        'El servidor no devolvió el token',
      );
    }

    // ========================================================
    // LIMPIAR SESIÓN ANTERIOR
    // ========================================================

    await prefs.remove('token');
    await prefs.remove('usuario_id');
    await prefs.remove('nombre');
    await prefs.remove('apellido');
    await prefs.remove('correo');
    await prefs.remove('telefono');
    await prefs.remove('tipo_usuario');
    await prefs.remove('estado');
    await prefs.remove('foto_perfil');

    // ========================================================
    // GUARDAR SESIÓN
    // ========================================================

    await prefs.setString(
      'token',
      token.toString(),
    );

    if (usuario['UsuarioID'] != null) {
      await prefs.setString(
        'usuario_id',
        usuario['UsuarioID'].toString(),
      );
    }

    await prefs.setString(
      'nombre',
      usuario['Nombre']?.toString() ?? '',
    );

    await prefs.setString(
      'apellido',
      usuario['Apellido']?.toString() ?? '',
    );

    await prefs.setString(
      'correo',
      usuario['Correo']?.toString() ?? '',
    );

    await prefs.setString(
      'telefono',
      usuario['Telefono']?.toString() ?? '',
    );

    await prefs.setString(
      'tipo_usuario',
      usuario['TipoUsuario']?.toString() ?? '',
    );

    await prefs.setString(
      'estado',
      usuario['Estado']?.toString() ?? '',
    );

    if (usuario['FotoPerfil'] != null &&
        usuario['FotoPerfil']
            .toString()
            .isNotEmpty) {
      await prefs.setString(
        'foto_perfil',
        usuario['FotoPerfil'].toString(),
      );
    }

    print('================================');
    print('LOGIN CORRECTO');
    print(
      'USUARIO ID: ${usuario['UsuarioID']}',
    );
    print(
      'NOMBRE: ${usuario['Nombre']}',
    );
    print('TOKEN GUARDADO CORRECTAMENTE');
    print('================================');

    return data;
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
    File? fotoPerfil,
    File? fotoCarnet,
  }) async {
    // ========================================================
    // VALIDAR TIPO DE USUARIO
    // ========================================================

    if (tipoUsuario != 'Proveedor' &&
        tipoUsuario != 'Comprador') {
      throw Exception(
        "tipoUsuario debe ser 'Proveedor' o 'Comprador'",
      );
    }

    // ========================================================
    // CREAR PETICIÓN MULTIPART
    // ========================================================

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/registro'),
    );

    // ========================================================
    // CAMPOS
    // ========================================================

    request.fields['nombre'] = nombre;
    request.fields['apellido'] = apellido;
    request.fields['telefono'] = telefono;
    request.fields['correo'] = correo;
    request.fields['contrasena'] = contrasena;
    request.fields['tipoUsuario'] = tipoUsuario;

    // ========================================================
    // FOTO DE PERFIL
    // ========================================================

    if (fotoPerfil != null) {
      final tipoMime =
          obtenerTipoMime(fotoPerfil.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'fotoPerfil',
          fotoPerfil.path,
          contentType:
              MediaType.parse(tipoMime),
        ),
      );
    }

    // ========================================================
    // FOTO DE CARNET
    // ========================================================

    if (fotoCarnet != null) {
      final tipoMime =
          obtenerTipoMime(fotoCarnet.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'fotoCarnet',
          fotoCarnet.path,
          contentType:
              MediaType.parse(tipoMime),
        ),
      );
    }

    // ========================================================
    // ENVIAR
    // ========================================================

    print('================================');
    print('ENVIANDO REGISTRO');
    print('TIPO: $tipoUsuario');
    print(
      'FOTO PERFIL: ${fotoPerfil?.path ?? 'NO'}',
    );
    print(
      'FOTO CARNET: ${fotoCarnet?.path ?? 'NO'}',
    );
    print('================================');

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    print('STATUS REGISTRO: ${response.statusCode}');
    print('RESPUESTA: ${response.body}');

    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        'El servidor devolvió una respuesta inválida',
      );
    }

    // ========================================================
    // REGISTRO CORRECTO
    // ========================================================

    if (response.statusCode == 201) {
      final prefs =
          await SharedPreferences.getInstance();

      final usuario = data['usuario'];
      final token = data['token'];

      // ======================================================
      // GUARDAR SESIÓN SI EL BACKEND LA DEVUELVE
      // ======================================================

      if (token != null &&
          token.toString().isNotEmpty) {
        await prefs.setString(
          'token',
          token.toString(),
        );
      }

      if (usuario != null &&
          usuario is Map<String, dynamic>) {

        if (usuario['UsuarioID'] != null) {
          await prefs.setString(
            'usuario_id',
            usuario['UsuarioID'].toString(),
          );
        }

        await prefs.setString(
          'nombre',
          usuario['Nombre']?.toString() ?? nombre,
        );

        await prefs.setString(
          'apellido',
          usuario['Apellido']?.toString() ??
              apellido,
        );

        await prefs.setString(
          'correo',
          usuario['Correo']?.toString() ??
              correo,
        );

        await prefs.setString(
          'telefono',
          usuario['Telefono']?.toString() ??
              telefono,
        );

        await prefs.setString(
          'tipo_usuario',
          usuario['TipoUsuario']?.toString() ??
              tipoUsuario,
        );

        await prefs.setString(
          'estado',
          usuario['Estado']?.toString() ??
              'Activo',
        );

        if (usuario['FotoPerfil'] != null &&
            usuario['FotoPerfil']
                .toString()
                .isNotEmpty) {
          await prefs.setString(
            'foto_perfil',
            usuario['FotoPerfil'].toString(),
          );
        }
      }

      print('================================');
      print('REGISTRO CORRECTO');
      print(
        'USUARIO ID: ${usuario?['UsuarioID']}',
      );
      print(
        'FOTO PERFIL: ${usuario?['FotoPerfil']}',
      );
      print('================================');

      return data;
    }

    // ========================================================
    // ERROR
    // ========================================================

    throw Exception(
      data['mensaje'] ??
          'Error al registrar usuario',
    );
  }

  // ==========================================================
  // ACTUALIZAR PERFIL
  // ==========================================================

  static Future<Map<String, dynamic>> actualizarPerfil({
    required String nombre,
    required String telefono,
    String? fotoPerfil,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('token');

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'No hay una sesión activa',
      );
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/auth/perfil'),
    );

    request.headers['Authorization'] =
        'Bearer $token';

    request.fields['nombre'] = nombre;
    request.fields['telefono'] = telefono;

    // ========================================================
    // FOTO
    // ========================================================

    if (fotoPerfil != null &&
        fotoPerfil.isNotEmpty) {
      final tipoMime =
          obtenerTipoMime(fotoPerfil);

      request.files.add(
        await http.MultipartFile.fromPath(
          'fotoPerfil',
          fotoPerfil,
          contentType:
              MediaType.parse(tipoMime),
        ),
      );
    }

    // ========================================================
    // ENVIAR
    // ========================================================

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final data =
        jsonDecode(response.body);

    // ========================================================
    // CORRECTO
    // ========================================================

    if (response.statusCode == 200) {
      final usuario =
          data['usuario'];

      if (usuario != null &&
          usuario is Map<String, dynamic>) {

        await prefs.setString(
          'nombre',
          usuario['Nombre']?.toString() ??
              nombre,
        );

        await prefs.setString(
          'telefono',
          usuario['Telefono']?.toString() ??
              telefono,
        );

        if (usuario['FotoPerfil'] != null &&
            usuario['FotoPerfil']
                .toString()
                .isNotEmpty) {
          await prefs.setString(
            'foto_perfil',
            usuario['FotoPerfil'].toString(),
          );
        }
      }

      return data;
    }

    // ========================================================
    // ERROR
    // ========================================================

    throw Exception(
      data['mensaje'] ??
          'Error al actualizar el perfil',
    );
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
    await prefs.remove('foto_perfil');
  }
}