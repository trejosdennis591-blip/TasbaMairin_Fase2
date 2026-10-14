import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/screen/chat_screen.dart';
import 'package:flutter_application_1/screen/trade_request_screen.dart';
import 'package:flutter_application_1/screen/report_product_screen.dart';
import 'package:flutter_application_1/services/favorite_service.dart';
import 'package:flutter_application_1/services/resena_service.dart';
import 'package:flutter_application_1/screen/public_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product producto;

  const ProductDetailScreen({
    super.key,
    required this.producto,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  // ==========================================================
  // RESEÑAS
  // ==========================================================

  double calificacionSeleccionada = 0;

  final TextEditingController comentarioController =
      TextEditingController();

  bool enviandoResena = false;

  List<Map<String, dynamic>> resenas = [];

  bool cargandoResenas = true;

  // ==========================================================
  // USUARIO ACTUAL
  // ==========================================================

  int? usuarioActualId;

  String nombreUsuarioActual = "Usuario";
  String tipoUsuario = '';

  // ==========================================================
  // COLORES DEL DISEÑO 3
  // ==========================================================

  static const Color verde = Color(0xFF016630);
  static const Color verdeClaro = Color(0xFFE8F3EA);
  static const Color crema = Color(0xFFFFFDF5);
  static const Color amarilloFondo = Color(0xFFFFF4B8);
  static const Color naranja = Color(0xFFD0872E);
  static const Color rojo = Color(0xFFD32F2F);

  // ==========================================================
  // INICIO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    cargarUsuarioActual();
    cargarResenas();
  }

  // ==========================================================
  // CARGAR USUARIO ACTUAL
  // ==========================================================

  Future<void> cargarUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString('usuario_id');
    final nombre = prefs.getString('nombre');
    final tipo = prefs.getString('tipo_usuario');

    if (!mounted) {
      return;
    }

    setState(() {
      usuarioActualId =
          id != null ? int.tryParse(id) : null;

      nombreUsuarioActual =
          nombre != null && nombre.trim().isNotEmpty
              ? nombre.trim()
              : "Usuario";

      tipoUsuario = tipo ?? '';
    });
  }

  // ==========================================================
  // CARGAR RESEÑAS
  // ==========================================================

  Future<void> cargarResenas() async {
    try {
      final resultado =
          await ResenaService.obtenerResenas(
        productoId: widget.producto.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        resenas = resultado;
        cargandoResenas = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR CARGANDO RESEÑAS: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        cargandoResenas = false;
      });
    }
  }

  // ==========================================================
  // MOSTRAR IMAGEN
  // ==========================================================

  Widget mostrarImagen() {
    // ========================================================
    // BASE64
    // ========================================================

    if (widget.producto.imagenBase64 != null &&
        widget.producto.imagenBase64!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(
          widget.producto.imagenBase64!,
        );

        return Image.memory(
          bytes,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return imagenVacia();
          },
        );
      } catch (_) {}
    }

    // ========================================================
    // IMAGEN DEL TELÉFONO
    // ========================================================

    if (widget.producto.imagenUsuario != null &&
        widget.producto.imagenUsuario!.isNotEmpty) {
      final archivo = File(
        widget.producto.imagenUsuario!,
      );

      if (archivo.existsSync()) {
        return Image.file(
          archivo,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return imagenVacia();
          },
        );
      }
    }

    // ========================================================
    // IMAGEN DEL SERVIDOR
    // ========================================================

    if (widget.producto.imagen != null &&
        widget.producto.imagen!.isNotEmpty) {
      String url =
          widget.producto.imagen!.trim();

      if (url.startsWith('/')) {
        url = '${ApiConfig.serverUrl}$url';
      }

      if (!url.startsWith('http://') &&
          !url.startsWith('https://')) {
        url = '${ApiConfig.serverUrl}$url';
      }

      return Image.network(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(
                color: verde,
              ),
            ),
          );
        },
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          debugPrint(
            'ERROR IMAGEN DETALLE: $url',
          );

          return imagenVacia();
        },
      );
    }

    return imagenVacia();
  }

  // ==========================================================
  // IMAGEN VACÍA
  // ==========================================================

  Widget imagenVacia() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 70,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ==========================================================
// VER PERFIL DEL USUARIO
// ==========================================================

void verPerfilUsuario() {
  final String usuarioId =
      widget.producto.usuarioId.trim();

  if (usuarioId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se encontró el usuario que publicó este producto.',
        ),
      ),
    );

    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PublicProfileScreen(
        usuarioId: usuarioId,
      ),
    ),
  );
}

  // ==========================================================
  // CONTACTAR
  // ==========================================================

  void contactar() {
    final String usuarioId =
        widget.producto.usuarioId.trim();

    if (usuarioId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se encontró el usuario que publicó este producto.",
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          nombre: widget.producto.nombre,
          grupo: false,
          usuarioId: usuarioId,
          productoId:
              widget.producto.id.toString(),
        ),
      ),
    );
  }

  // ==========================================================
  // CONTACTAR PARA TRUEQUE
  // ==========================================================

  void contactarTrueque() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TradeRequestScreen(
          producto: widget.producto,
        ),
      ),
    );
  }

  // ==========================================================
  // FAVORITO
  // ==========================================================

  Future<void> cambiarFavorito() async {
    final bool eraFavorito =
        FavoriteService.esFavorito(
      widget.producto,
    );

    await FavoriteService.cambiarFavorito(
      widget.producto,
    );

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: verde,
        content: Text(
          eraFavorito
              ? "Producto eliminado de favoritos"
              : "Producto guardado",
        ),
        duration:
            const Duration(seconds: 1),
      ),
    );
  }

  // ==========================================================
  // REPORTAR USUARIO
  // ==========================================================

  void reportarUsuario() {
    final int? idUsuario =
        int.tryParse(
      widget.producto.usuarioId,
    );

    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se encontró el usuario.",
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportProductScreen(
          usuarioReportadoId:
              idUsuario,
        ),
      ),
    );
  }

  // ==========================================================
  // UBICACIÓN
  // ==========================================================

  void mostrarUbicacion() {
    if (widget.producto.ubicacion
        .trim()
        .isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            "Ubicación",
          ),
          content: const Text(
            "Este producto fue publicado antes de que se agregara el sistema de ubicación.",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text(
                "Aceptar",
              ),
            ),
          ],
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Ubicación del producto",
        ),
        content: Text(
          widget.producto.ubicacion,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text(
              "Cerrar",
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SELECCIONAR ESTRELLA
  // ==========================================================

  void seleccionarEstrella(
    double estrella,
  ) {
    setState(() {
      calificacionSeleccionada =
          estrella;
    });
  }

  // ==========================================================
  // ENVIAR RESEÑA
  // ==========================================================

  Future<void> enviarResena() async {
    if (enviandoResena) {
      return;
    }

    final String comentario =
        comentarioController.text.trim();

    if (calificacionSeleccionada < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona una calificación de 1 a 5 estrellas.",
          ),
        ),
      );

      return;
    }

    if (comentario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Escribe qué te pareció el producto.",
          ),
        ),
      );

      return;
    }

    setState(() {
      enviandoResena = true;
    });

    try {
      await ResenaService.crearResena(
        productoId:
            widget.producto.id,
        calificacion:
            calificacionSeleccionada.toInt(),
        comentario: comentario,
      );

      await cargarResenas();

      if (!mounted) {
        return;
      }

      comentarioController.clear();

      setState(() {
        calificacionSeleccionada = 0;
        enviandoResena = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: verde,
          content: Text(
            "Reseña publicada correctamente.",
          ),
          duration:
              Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        enviandoResena = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: rojo,
          content: Text(
            "No se pudo publicar la reseña: $e",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // ESTRELLAS INTERACTIVAS
  // ==========================================================

  Widget estrellasSeleccion() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final double valor =
              index + 1.0;

          return IconButton(
            onPressed: enviandoResena
                ? null
                : () =>
                    seleccionarEstrella(
                      valor,
                    ),
            iconSize: 40,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            icon: Icon(
              valor <=
                      calificacionSeleccionada
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // ESTRELLAS DE RESEÑA
  // ==========================================================

  Widget estrellasResena(
    double calificacion,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: List.generate(
        5,
        (index) {
          final double valor =
              index + 1.0;

          return Icon(
            valor <= calificacion
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
            size: 19,
          );
        },
      ),
    );
  }

  // ==========================================================
  // TARJETA DE ACCIÓN
  // ==========================================================

  Widget botonAccion({
    required IconData icono,
    required String texto,
    required VoidCallback onPressed,
    Color color = verde,
    Color textoColor = Colors.white,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textoColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          icono,
          color: textoColor,
        ),
        label: Text(
          texto,
          style: TextStyle(
            color: textoColor,
            fontSize: 15,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FORMULARIO DE RESEÑA
  // ==========================================================

  Widget construirFormularioResena() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.rate_review_outlined,
                  color: verde,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dejar reseña",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                        color: verde,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Cuéntanos qué te pareció el producto",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              "¿Cómo calificas este producto?",
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 4),

          estrellasSeleccion(),

          if (calificacionSeleccionada > 0)
            Center(
              child: Text(
                "${calificacionSeleccionada.toInt()} de 5 estrellas",
                style: const TextStyle(
                  color: verde,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 15),

          TextField(
            controller:
                comentarioController,
            enabled:
                !enviandoResena,
            maxLines: 5,
            maxLength: 500,
            decoration:
                InputDecoration(
              hintText:
                  "Escribe qué te pareció el producto, su calidad o tu experiencia...",
              filled: true,
              fillColor:
                  const Color(0xFFF8F8F4),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                borderSide:
                    BorderSide.none,
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                borderSide:
                    const BorderSide(
                  color: verde,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  enviandoResena
                      ? null
                      : enviarResena,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: verde,
                disabledBackgroundColor:
                    Colors.grey,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              icon: enviandoResena
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.star,
                      color:
                          Colors.white,
                    ),
              label: Text(
                enviandoResena
                    ? "Publicando..."
                    : "Enviar reseña",
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LISTA DE RESEÑAS
  // ==========================================================

  Widget construirResenas() {
    if (cargandoResenas) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(20),
          child:
              CircularProgressIndicator(
            color: verde,
          ),
        ),
      );
    }

    if (resenas.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 45,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "Todavía no hay reseñas.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Sé la primera persona en dejar una opinión.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          resenas.map((resena) {
        final String nombre =
            (resena['Nombre'] ??
                    'Usuario')
                .toString();

        final String apellido =
            (resena['Apellido'] ??
                    '')
                .toString();

        final String nombreCompleto =
            '$nombre $apellido'
                .trim();

        final double calificacion =
            double.tryParse(
                  resena[
                          'Calificacion']
                      .toString(),
                ) ??
                0;

        final String comentario =
            (resena['Comentario'] ??
                    '')
                .toString();

        DateTime? fecha;

        if (resena[
                'FechaResena'] !=
            null) {
          fecha = DateTime.tryParse(
            resena['FechaResena']
                .toString(),
          );
        }

        return Container(
          width: double.infinity,
          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        verde,
                    child: Text(
                      nombre.isNotEmpty
                          ? nombre
                              .substring(
                              0,
                              1,
                            )
                              .toUpperCase()
                          : "?",
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          nombreCompleto
                                  .isEmpty
                              ? "Usuario"
                              : nombreCompleto,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        estrellasResena(
                          calificacion,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                comentario,
                style:
                    const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              if (fecha != null) ...[
                const SizedBox(
                  height: 8,
                ),
                Text(
                  _formatearFecha(
                    fecha,
                  ),
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // FORMATEAR FECHA
  // ==========================================================

  String _formatearFecha(
    DateTime fecha,
  ) {
    final String dia =
        fecha.day
            .toString()
            .padLeft(2, "0");

    final String mes =
        fecha.month
            .toString()
            .padLeft(2, "0");

    final String ano =
        fecha.year.toString();

    return "$dia/$mes/$ano";
  }

  // ==========================================================
  // INFORMACIÓN DEL PRODUCTO
  // ==========================================================

  Widget informacionProducto() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (widget.producto
              .categoria
              .isNotEmpty)
            _filaInformacion(
              Icons.category_outlined,
              "Categoría",
              widget.producto.categoria,
            ),

          if (widget.producto
              .ubicacion
              .isNotEmpty)
            _filaInformacion(
              Icons.location_on_outlined,
              "Ubicación",
              widget.producto.ubicacion,
            ),

          if (widget.producto
              .cantidad
              .isNotEmpty)
            _filaInformacion(
              Icons.inventory_2_outlined,
              "Cantidad",
              "${widget.producto.cantidad} ${widget.producto.unidad}",
            ),

          _filaInformacion(
            Icons.swap_horiz,
            "Acepta trueque",
            widget.producto.trueque
                    .trim()
                    .isNotEmpty
                ? widget.producto.trueque
                : "No especificado",
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILA DE INFORMACIÓN
  // ==========================================================

  Widget _filaInformacion(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: verdeClaro,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icono,
              color: verde,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  valor,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CALIFICACIÓN GENERAL
  // ==========================================================

  Widget tarjetaCalificacion(
    double promedio,
    int cantidad,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF1C7,
              ),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 27,
                ),
                Text(
                  promedio
                      .toStringAsFixed(1),
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Calificación del producto",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                estrellasResena(
                  promedio,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  "$cantidad reseñas",
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    double promedio = 0;

    if (resenas.isNotEmpty) {
      double suma = 0;

      for (final resena in resenas) {
        suma +=
            double.tryParse(
                  resena[
                          'Calificacion']
                      .toString(),
                ) ??
                0;
      }

      promedio =
          suma / resenas.length;
    }

    final int cantidad =
        resenas.length;

    final double calificacionMostrar =
        cantidad > 0
            ? promedio
            : widget.producto
                .calificacion;

    final int resenasMostrar =
        cantidad > 0
            ? cantidad
            : widget.producto
                .cantidadResenas;

    final bool esProveedor =
        tipoUsuario.toLowerCase() ==
            'proveedor';

    final bool esFavorito =
        FavoriteService.esFavorito(
      widget.producto,
    );

    return Scaffold(
      backgroundColor:
          amarilloFondo,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: verde,
        elevation: 0,
        centerTitle: false,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Detalle del producto",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                "Guardar producto",
            onPressed:
                cambiarFavorito,
            icon: Icon(
              esFavorito
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),

      // ======================================================
      // CONTENIDO
      // ======================================================

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // IMAGEN PRINCIPAL
              // ==================================================

              Stack(
                children: [
                  SizedBox(
                    width:
                        double.infinity,
                    height: 300,
                    child:
                        mostrarImagen(),
                  ),

                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.black
                            .withOpacity(
                          0.60,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child:
                          const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo,
                            color:
                                Colors.white,
                            size: 17,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Producto",
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // TARJETA PRINCIPAL
              // ==================================================

              Transform.translate(
                offset:
                    const Offset(0, -18),
                child: Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: crema,
                    borderRadius:
                        BorderRadius.only(
                      topLeft:
                          Radius.circular(
                        28,
                      ),
                      topRight:
                          Radius.circular(
                        28,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // ==========================================
                      // NOMBRE + CATEGORÍA
                      // ==========================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  widget
                                      .producto
                                      .nombre,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        27,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color:
                                        verde,
                                  ),
                                ),

                                if (widget
                                    .producto
                                    .categoria
                                    .isNotEmpty)
                                  Container(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      top:
                                          8,
                                    ),
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          11,
                                      vertical:
                                          6,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          verdeClaro,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        20,
                                      ),
                                    ),
                                    child:
                                        Text(
                                      widget
                                          .producto
                                          .categoria,
                                      style:
                                          const TextStyle(
                                        color:
                                            verde,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize:
                                            13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed:
                                cambiarFavorito,
                            icon:
                                Icon(
                              esFavorito
                                  ? Icons
                                      .favorite
                                  : Icons
                                      .favorite_border,
                              color:
                                  esFavorito
                                      ? Colors
                                          .red
                                      : verde,
                              size:
                                  30,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==========================================
                      // DATOS RÁPIDOS
                      // ==========================================

                      informacionProducto(),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==========================================
                      // DESCRIPCIÓN
                      // ==========================================

                      const Text(
                        "Descripción",
                        style:
                            TextStyle(
                          fontSize:
                              20,
                          fontWeight:
                              FontWeight
                                  .bold,
                          color:
                              verde,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(
                          15,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                        child: Text(
                          widget
                              .producto
                              .descripcion
                              .trim()
                              .isNotEmpty
                              ? widget
                                  .producto
                                  .descripcion
                              : "No hay una descripción disponible.",
                          style:
                              const TextStyle(
                            fontSize:
                                15,
                            height:
                                1.45,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==========================================
                      // TRUEQUE
                      // ==========================================

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(
                          16,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFEAF6EC,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                          border:
                              Border.all(
                            color:
                                Colors.green
                                    .shade100,
                          ),
                        ),
                        child:
                            Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  13,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .swap_horiz,
                                color:
                                    verde,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const Text(
                                    "Acepta trueque",
                                    style:
                                        TextStyle(
                                      color:
                                          verde,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    widget
                                            .producto
                                            .trueque
                                            .trim()
                                            .isNotEmpty
                                        ? widget
                                            .producto
                                            .trueque
                                        : "No especificado",
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==========================================
                      // CALIFICACIÓN
                      // ==========================================

                      tarjetaCalificacion(
                        calificacionMostrar,
                        resenasMostrar,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ==========================================
                      // BOTONES PRINCIPALES
                      // ==========================================

                      if (!esProveedor) ...[
                        const Text(
                          "¿Qué quieres hacer?",
                          style:
                              TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                verde,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  botonAccion(
                                icono:
                                    Icons.swap_horiz,
                                texto:
                                    "Contactar para trueque",
                                color:
                                    verde,
                                onPressed:
                                    contactarTrueque,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            SizedBox(
                              width: 58,
                              height: 54,
                              child:
                                  OutlinedButton(
                                onPressed:
                                    cambiarFavorito,
                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  side:
                                      const BorderSide(
                                    color:
                                        verde,
                                    ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                ),
                                child:
                                    Icon(
                                  esFavorito
                                      ? Icons
                                          .favorite
                                      : Icons
                                          .favorite_border,
                                  color:
                                      esFavorito
                                          ? Colors.red
                                          : verde,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Row(
  children: [
    Expanded(
      child: botonAccion(
        icono:
            Icons.message_outlined,
        texto:
            "Enviar mensaje",
        color:
            naranja,
        onPressed:
            contactar,
      ),
    ),

    const SizedBox(
      width: 10,
    ),

    Expanded(
      child: botonAccion(
        icono:
            Icons.person_outline,
        texto:
            "Ver perfil",
        color:
            verde,
        onPressed:
            verPerfilUsuario,
      ),
    ),
  ],
),

                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              OutlinedButton.icon(
                            onPressed:
                                reportarUsuario,
                            style:
                                OutlinedButton
                                    .styleFrom(
                              minimumSize:
                                  const Size(
                                0,
                                52,
                              ),
                              side:
                                  const BorderSide(
                                color:
                                    rojo,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                            ),
                            icon:
                                const Icon(
                              Icons
                                  .flag_outlined,
                              color:
                                  rojo,
                            ),
                            label:
                                const Text(
                              "Reportar usuario",
                              style:
                                  TextStyle(
                                color:
                                    rojo,
                                fontSize:
                                    15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              OutlinedButton.icon(
                            onPressed:
                                mostrarUbicacion,
                            style:
                                OutlinedButton
                                    .styleFrom(
                              minimumSize:
                                  const Size(
                                0,
                                52,
                              ),
                              side:
                                  const BorderSide(
                                color:
                                    naranja,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                            ),
                            icon:
                                const Icon(
                              Icons
                                  .location_on_outlined,
                              color:
                                  naranja,
                            ),
                            label:
                                const Text(
                              "Ver ubicación",
                              style:
                                  TextStyle(
                                color:
                                    naranja,
                                fontSize:
                                    15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 28,
                      ),

                      // ==========================================
                      // DEJAR RESEÑA
                      // ==========================================

                      if (!esProveedor)
                        construirFormularioResena(),

                      const SizedBox(
                        height: 28,
                      ),

                      // ==========================================
                      // OPINIONES
                      // ==========================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Opiniones de otros usuarios",
                              style:
                                  TextStyle(
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    verde,
                              ),
                            ),
                          ),
                          if (resenas.isNotEmpty)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    10,
                                vertical:
                                    5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    verdeClaro,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),
                              child:
                                  Text(
                                "${resenas.length}",
                                style:
                                    const TextStyle(
                                  color:
                                      verde,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      construirResenas(),

                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // LIMPIEZA
  // ==========================================================

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }
}