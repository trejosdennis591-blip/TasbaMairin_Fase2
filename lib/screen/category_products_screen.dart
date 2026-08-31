import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/screen/product_detail_screen.dart';
import 'package:flutter_application_1/services/product_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoria;

  const CategoryProductsScreen({
    super.key,
    required this.categoria,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends State<CategoryProductsScreen> {
  // ==========================================================
  // PRODUCTOS
  // ==========================================================

  List<Product> productos = [];

  bool cargando = true;

  String? error;

  // ==========================================================
  // INICIO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    cargarProductos();
  }

  // ==========================================================
  // CARGAR PRODUCTOS DEL BACKEND
  // ==========================================================

  Future<void> cargarProductos() async {
    try {
      setState(() {
        cargando = true;
        error = null;
      });

      final resultado =
          await ProductService.listarProductos();

      final filtrados = resultado.where((producto) {
        return producto.categoria.trim().toLowerCase() ==
            widget.categoria.trim().toLowerCase();
      }).toList();

      if (!mounted) return;

      setState(() {
        productos = filtrados;
        cargando = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR CARGANDO PRODUCTOS DE CATEGORÍA: $e',
      );

      if (!mounted) return;

      setState(() {
        cargando = false;
        error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  // ==========================================================
  // MOSTRAR IMAGEN DEL PRODUCTO
  // ==========================================================

  Widget mostrarImagen(Product producto) {
  // ========================================================
  // IMAGEN DEL TELÉFONO
  // ========================================================

  if (producto.imagenUsuario != null &&
      producto.imagenUsuario!.isNotEmpty) {
    final archivo = File(
      producto.imagenUsuario!,
    );

    if (archivo.existsSync()) {
      return Image.file(
        archivo,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return imagenPredeterminada();
        },
      );
    }
  }

  // ========================================================
  // IMAGEN BASE64
  // ========================================================

  if (producto.imagenBase64 != null &&
      producto.imagenBase64!.isNotEmpty) {
    try {
      final Uint8List bytes = base64Decode(
        producto.imagenBase64!,
      );

      return Image.memory(
        bytes,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return imagenPredeterminada();
        },
      );
    } catch (_) {
      // Continuamos con la imagen del servidor.
    }
  }

  // ========================================================
  // IMAGEN DEL SERVIDOR
  // ========================================================

  if (producto.imagen != null &&
      producto.imagen!.isNotEmpty) {
    String url = producto.imagen!.trim();

    // Si el backend devuelve solamente:
    // /uploads/productos/imagen.jpg
    // le agregamos el servidor.
    if (url.startsWith('/')) {
      url = 'http://192.168.1.26:3000$url';
    }

    // Si devuelve uploads/productos/imagen.jpg
    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'http://192.168.1.26:3000/$url';
    }

    return Image.network(
      url,
      width: double.infinity,
      height: 220,
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
          height: 220,
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
          'ERROR IMAGEN PRODUCTO: $url',
        );

        return imagenPredeterminada();
      },
    );
  }

  // ========================================================
  // SIN IMAGEN
  // ========================================================

  return imagenPredeterminada();
}

  // ==========================================================
  // IMAGEN PREDETERMINADA
  // ==========================================================

  Widget imagenPredeterminada() {
    return Container(
      width: double.infinity,
      height: 220,
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
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.categoria,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ====================================================
          // ENCABEZADO
          // ====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF016630),
            ),
            child: Column(
              children: [
                Text(
                  widget.categoria,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  cargando
                      ? "Cargando productos..."
                      : "${productos.length} producto(s) disponibles",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // CONTENIDO
          // ====================================================

          Expanded(
            child: _construirContenido(),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CONTENIDO
  // ==========================================================

  Widget _construirContenido() {
    // ========================================================
    // CARGANDO
    // ========================================================

    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF016630),
        ),
      );
    }

    // ========================================================
    // ERROR
    // ========================================================

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                "No se pudieron cargar los productos.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: cargarProductos,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF016630),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Intentar nuevamente",
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================================
    // SIN PRODUCTOS
    // ========================================================

    if (productos.isEmpty) {
      return RefreshIndicator(
        onRefresh: cargarProductos,
        color: const Color(0xFF016630),
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),

            Icon(
              Icons.inventory_2_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 15),

            Center(
              child: Text(
                "No hay productos en esta categoría.",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            SizedBox(height: 300),
          ],
        ),
      );
    }

    // ========================================================
    // LISTA
    // ========================================================

    return RefreshIndicator(
      onRefresh: cargarProductos,
      color: const Color(0xFF016630),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: productos.length,
        itemBuilder: (
          context,
          index,
        ) {
          final producto = productos[index];

          return Card(
            margin: const EdgeInsets.only(
              bottom: 20,
            ),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(
                      producto: producto,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // IMAGEN
                  // ==========================================

                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: mostrarImagen(
                      producto,
                    ),
                  ),

                  // ==========================================
                  // INFORMACIÓN
                  // ==========================================

                  Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ====================================
                        // NOMBRE
                        // ====================================

                        Text(
                          producto.nombre,
                          style: const TextStyle(
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

                        // ====================================
                        // UBICACIÓN
                        // ====================================

                        if (producto
                                .ubicacion
                                .isNotEmpty ||
                            producto
                                .comunidad
                                .isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 18,
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Expanded(
                                child: Text(
                                  producto
                                          .ubicacion
                                          .isNotEmpty
                                      ? producto
                                          .ubicacion
                                      : producto
                                          .comunidad,
                                  style:
                                      const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ====================================
                        // DESCRIPCIÓN
                        // ====================================

                        Text(
                          producto.descripcion,
                          maxLines: 3,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ====================================
                        // VER DETALLES
                        // ====================================

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFFD0872E,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(
                                    producto:
                                        producto,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Ver detalles",
                              style: TextStyle(
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}