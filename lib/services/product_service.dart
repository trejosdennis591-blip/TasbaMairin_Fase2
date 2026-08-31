import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/product.dart';

class ProductService {
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
  // CONVERTIR PRODUCTO DEL BACKEND
  // ==========================================================

  static Product convertirProducto(
  Map<String, dynamic> data,
) {
  String? imagenUrl;

  final imagenes = data['imagenes'];

  if (imagenes is List && imagenes.isNotEmpty) {
    final primeraImagen = imagenes.first;

    if (primeraImagen is Map) {
      final url = primeraImagen['UrlImagen'];

      if (url != null && url.toString().isNotEmpty) {
        imagenUrl = url.toString();
      }
    }
  }

  return Product(
    id: data['ProductoID'] ?? 0,
    nombre: data['Nombre'] ?? '',
    comunidad: data['Ubicacion'] ?? '',
    categoria: data['CategoriaNombre'] ?? '',
    descripcion: data['Descripcion'] ?? '',
    cantidad: data['Cantidad']?.toString() ?? '',
    unidad: data['UnidadMedida'] ?? '',
    trueque: data['AceptaTrueque'] ?? '',
    ubicacion: data['Ubicacion'] ?? '',
    usuarioId: data['UsuarioID']?.toString() ?? '',
    correoUsuario: '',

    // Imagen del servidor
    imagen: imagenUrl,

    imagenBase64: null,
    imagenUsuario: null,
  );
}

  // ==========================================================
  // LISTAR PRODUCTOS
  // ==========================================================

  static Future<List<Product>>
      listarProductos({
    int? categoriaId,
    String? busqueda,
    String? estado,
  }) async {
    final parametros =
        <String, String>{};

    if (categoriaId != null) {
      parametros['categoriaId'] =
          categoriaId.toString();
    }

    if (busqueda != null &&
        busqueda.isNotEmpty) {
      parametros['busqueda'] =
          busqueda;
    }

    if (estado != null &&
        estado.isNotEmpty) {
      parametros['estado'] =
          estado;
    }

    final uri = Uri.parse(
      '$baseUrl/productos',
    ).replace(
      queryParameters: parametros,
    );

    final response =
        await http.get(uri);

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data['productos'] as List)
          .map(
            (producto) =>
                convertirProducto(
              producto,
            ),
          )
          .toList();
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudieron obtener los productos',
    );
  }

  // ==========================================================
  // OBTENER PRODUCTO POR ID
  // ==========================================================

  static Future<Map<String, dynamic>>
      obtenerProducto(
    int productoId,
  ) async {
    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/productos/$productoId',
      ),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['producto'];
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudo obtener el producto',
    );
  }

  // ==========================================================
  // CREAR PRODUCTO CON IMAGEN
  // ==========================================================

  static Future<Map<String, dynamic>>
      crearProducto({
    required int categoriaId,
    required String nombre,
    String? descripcion,
    String? cantidad,
    String? unidadMedida,
    String? aceptaTrueque,
    String? ubicacion,
    List<File>? imagenes,
  }) async {
    final token =
        await _obtenerToken();

    final request =
        http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/productos',
      ),
    );

    // ========================================================
    // TOKEN
    // ========================================================

    request.headers['Authorization'] =
        'Bearer $token';

    // ========================================================
    // DATOS DEL PRODUCTO
    // ========================================================

    request.fields['categoriaId'] =
        categoriaId.toString();

    request.fields['nombre'] =
        nombre;

    if (descripcion != null &&
        descripcion.isNotEmpty) {
      request.fields['descripcion'] =
          descripcion;
    }

    if (cantidad != null &&
        cantidad.isNotEmpty) {
      request.fields['cantidad'] =
          cantidad;
    }

    if (unidadMedida != null &&
        unidadMedida.isNotEmpty) {
      request.fields['unidadMedida'] =
          unidadMedida;
    }

    if (aceptaTrueque != null &&
        aceptaTrueque.isNotEmpty) {
      request.fields['aceptaTrueque'] =
          aceptaTrueque;
    }

    if (ubicacion != null &&
        ubicacion.isNotEmpty) {
      request.fields['ubicacion'] =
          ubicacion;
    }

    // ========================================================
    // IMÁGENES
    // ========================================================

    if (imagenes != null &&
        imagenes.isNotEmpty) {
      for (final imagen in imagenes) {
        final archivo =
            await http.MultipartFile
                .fromPath(
          'imagenes',
          imagen.path,
        );

        request.files.add(
          archivo,
        );
      }
    }

    // ========================================================
    // ENVIAR
    // ========================================================

    final streamedResponse =
        await request.send();

    final response =
        await http.Response
            .fromStream(
      streamedResponse,
    );

    print(
      'CREAR PRODUCTO STATUS: '
      '${response.statusCode}',
    );

    print(
      'CREAR PRODUCTO BODY: '
      '${response.body}',
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data['producto'];
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudo crear el producto',
    );
  }

  // ==========================================================
  // ACTUALIZAR PRODUCTO
  // ==========================================================

  static Future<Map<String, dynamic>>
      actualizarProducto({
    required int productoId,
    String? nombre,
    String? descripcion,
    String? cantidad,
    String? unidadMedida,
    String? aceptaTrueque,
    String? ubicacion,
    int? categoriaId,
  }) async {
    final token =
        await _obtenerToken();

    final body =
        <String, dynamic>{};

    if (nombre != null) {
      body['nombre'] = nombre;
    }

    if (descripcion != null) {
      body['descripcion'] =
          descripcion;
    }

    if (cantidad != null) {
      body['cantidad'] =
          cantidad;
    }

    if (unidadMedida != null) {
      body['unidadMedida'] =
          unidadMedida;
    }

    if (aceptaTrueque != null) {
      body['aceptaTrueque'] =
          aceptaTrueque;
    }

    if (ubicacion != null) {
      body['ubicacion'] =
          ubicacion;
    }

    if (categoriaId != null) {
      body['categoriaId'] =
          categoriaId;
    }

    final response =
        await http.put(
      Uri.parse(
        '$baseUrl/productos/$productoId',
      ),
      headers: {
        'Content-Type':
            'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['producto'];
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudo actualizar el producto',
    );
  }

  // ==========================================================
  // ELIMINAR PRODUCTO
  // ==========================================================

  static Future<void>
      eliminarProducto(
    int productoId,
  ) async {
    final token =
        await _obtenerToken();

    final response =
        await http.delete(
      Uri.parse(
        '$baseUrl/productos/$productoId',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudo eliminar el producto',
    );
  }

  // ==========================================================
  // MIS PRODUCTOS
  // ==========================================================

  static Future<List<Product>>
      obtenerMisProductos() async {
    final token =
        await _obtenerToken();

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/productos/mis-productos',
      ),
      headers: {
        'Authorization':
            'Bearer $token',
      },
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data['productos'] as List)
          .map(
            (producto) =>
                convertirProducto(
              producto,
            ),
          )
          .toList();
    }

    throw Exception(
      data['mensaje'] ??
          'No se pudieron obtener tus productos',
    );
  }

  // ==========================================================
  // CALIFICAR PRODUCTO
  // ==========================================================

  static Future<void>
      calificarProducto(
    Product producto,
    double nuevaCalificacion,
  ) async {
    if (nuevaCalificacion < 1 ||
        nuevaCalificacion > 5) {
      return;
    }

    final double
        calificacionAnterior =
        producto.calificacion;

    final int resenasAnteriores =
        producto.cantidadResenas;

    final int nuevasResenas =
        resenasAnteriores + 1;

    final double promedio =
        resenasAnteriores == 0
            ? nuevaCalificacion
            : ((calificacionAnterior *
                        resenasAnteriores) +
                    nuevaCalificacion) /
                nuevasResenas;

    producto.calificacion =
        promedio;

    producto.cantidadResenas =
        nuevasResenas;
  }
}