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
    final prefs =
        await SharedPreferences.getInstance();

    final id =
        prefs.getString('usuario_id');

    final nombre =
        prefs.getString('nombre');

    final tipo =
    prefs.getString('tipo_usuario');

    if (!mounted) {
      return;
    }

    setState(() {
  usuarioActualId =
      id != null ? int.tryParse(id) : null;

  nombreUsuarioActual =
      nombre != null &&
              nombre.trim().isNotEmpty
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
  // IMAGEN BASE64
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
        height: 230,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return imagenVacia();
        },
      );
    } catch (_) {
      // Continuamos con las siguientes opciones.
    }
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
        height: 230,
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

    // Si viene así:
    // /uploads/productos/imagen.jpg
    if (url.startsWith('/')) {
      url =
          '${ApiConfig.serverUrl}$url';
    }

    // Si viene así:
    // uploads/productos/imagen.jpg
    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url =
          '${ApiConfig.serverUrl}$url';
    }

    return Image.network(
      url,
      width: double.infinity,
      height: 230,
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
          height: 230,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF016630),
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

  // ========================================================
  // SIN IMAGEN
  // ========================================================

  return imagenVacia();
}

  // ==========================================================
  // IMAGEN VACÍA
  // ==========================================================

  Widget imagenVacia() {
    return Container(
      width: double.infinity,
      height: 230,
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
            "Escribe un comentario.",
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
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.red,
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
            iconSize: 42,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 3,
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
            size: 20,
          );
        },
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
            BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Deja tu reseña",
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF016630),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "¿Qué te pareció este producto?",
            style: TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          estrellasSeleccion(),

          if (calificacionSeleccionada >
              0)
            Center(
              child: Text(
                "${calificacionSeleccionada.toInt()} de 5 estrellas",
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF016630),
                ),
              ),
            ),

          const SizedBox(height: 15),

          TextField(
            controller:
                comentarioController,
            enabled:
                !enviandoResena,
            maxLines: 4,
            decoration:
                InputDecoration(
              hintText:
                  "Escribe tu experiencia con este producto...",
              filled: true,
              fillColor:
                  Colors.grey.shade100,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  enviandoResena
                      ? null
                      : enviarResena,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF016630,
                ),
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
              child: enviandoResena
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        color:
                            Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Publicar reseña",
                      style:
                          TextStyle(
                        color:
                            Colors.white,
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
            color:
                Color(0xFF016630),
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
              BorderRadius.circular(15),
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
              "Sé la primera persona en dejar una.",
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
                BorderRadius.circular(
              15,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        const Color(
                      0xFF016630,
                    ),
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
                            FontWeight
                                .bold,
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
                  fontSize: 16,
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
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    double promedio = 0;

    if (resenas.isNotEmpty) {
      double suma = 0;

      for (final resena
          in resenas) {
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

    final double
        calificacionMostrar =
        cantidad > 0
            ? promedio
            : widget.producto
                .calificacion;

    final int resenasMostrar =
        cantidad > 0
            ? cantidad
            : widget.producto
                .cantidadResenas;

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),
        centerTitle: true,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.producto.nombre,
          style:
              const TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGEN
            // ==================================================

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              child:
                  mostrarImagen(),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // NOMBRE
            // ==================================================

            Text(
              widget.producto.nombre,
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF016630),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // INFORMACIÓN
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                15,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.category,
                        color:
                            Color(0xFF016630),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          widget.producto
                              .categoria,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (widget.producto
                      .ubicacion
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color:
                              Color(
                            0xFF016630,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            widget.producto
                                .ubicacion,
                            style:
                                const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (widget.producto
                      .cantidad
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          color:
                              Color(
                            0xFF016630,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${widget.producto.cantidad} ${widget.producto.unidad}",
                          style:
                              const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // DESCRIPCIÓN
            // ==================================================

            const Text(
              "Descripción",
              style:
                  TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF016630),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              widget.producto.descripcion,
              style:
                  const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // TRUEQUE
            // ==================================================

            const Text(
              "Intercambia por",
              style:
                  TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF016630),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                15,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Text(
                widget.producto.trueque
                        .isNotEmpty
                    ? widget.producto
                        .trueque
                    : "No especificado",
                style:
                    const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // CALIFICACIÓN
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                15,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      const Icon(
                        Icons.star,
                        color:
                            Colors.amber,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        calificacionMostrar
                            .toStringAsFixed(
                          1,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "($resenasMostrar reseñas)",
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  estrellasResena(
                    calificacionMostrar,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
// BOTONES PRINCIPALES
// SOLO COMPRADORES
// ==================================================

if (tipoUsuario.toLowerCase() != 'proveedor')
  Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF016630),
            minimumSize:
                const Size(0, 55),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
          ),
          onPressed: contactar,
          icon: const Icon(
            Icons.message,
            color: Colors.white,
          ),
          label: const Text(
            "Contactar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFFD0872E),
            minimumSize:
                const Size(0, 55),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TradeRequestScreen(
                  producto:
                      widget.producto,
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.swap_horiz,
            color: Colors.white,
          ),
          label: const Text(
            "Trueque",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),

      const SizedBox(width: 10),

      IconButton(
        iconSize: 35,
        onPressed: () async {
          final bool eraFavorito =
              FavoriteService.esFavorito(
            widget.producto,
          );

          await FavoriteService
              .cambiarFavorito(
            widget.producto,
          );

          if (!mounted) {
            return;
          }

          setState(() {});

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                eraFavorito
                    ? "Producto eliminado de favoritos"
                    : "Producto agregado a favoritos",
              ),
              duration:
                  const Duration(
                seconds: 1,
              ),
            ),
          );
        },
        icon: Icon(
          FavoriteService.esFavorito(
            widget.producto,
          )
              ? Icons.favorite
              : Icons.favorite_border,
          color: Colors.red,
        ),
      ),
    ],
  ),

const SizedBox(
  height: 15,
),

            // ==================================================
// REPORTAR USUARIO
// SOLO PARA COMPRADORES
// ==================================================

if (tipoUsuario == 'Comprador')
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(
          0,
          55,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15,
          ),
        ),
      ),
      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReportProductScreen(
        usuarioReportadoId: int.parse(
          widget.producto.usuarioId,
        ),
      ),
    ),
  );
},
      icon: const Icon(
        Icons.report,
        color: Colors.white,
      ),
      label: const Text(
        'Reportar usuario',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    ),
  ),

const SizedBox(
  height: 15,
),

            // ==================================================
// UBICACIÓN
// ==================================================

if (tipoUsuario == 'Comprador')
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Color(0xFFD0872E),
          width: 2,
        ),
        minimumSize: const Size(
          0,
          55,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
        if (widget.producto.ubicacion.trim().isEmpty) {
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
                  onPressed: () => Navigator.pop(context),
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                ),
              ),
            ],
          ),
        );
      },
      icon: const Icon(
        Icons.location_on,
        color: Color(0xFFD0872E),
      ),
      label: const Text(
        "Ver ubicación",
        style: TextStyle(
          color: Color(0xFFD0872E),
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

const SizedBox(
  height: 30,
),

            // ==================================================
            // FORMULARIO RESEÑA
            // ==================================================

            if (tipoUsuario.toLowerCase() != 'proveedor')
  construirFormularioResena(),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // OPINIONES
            // ==================================================

            const Text(
              "Opiniones de otros usuarios",
              style:
                  TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF016630),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            construirResenas(),

            const SizedBox(
              height: 30,
            ),
          ],
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