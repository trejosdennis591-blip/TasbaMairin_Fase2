import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/data/products_data.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/screen/product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoria;

  const CategoryProductsScreen({
    super.key,
    required this.categoria,
  });

  // ==========================================================
  // BANNER
  // ==========================================================

  String obtenerBanner() {
    switch (categoria) {
      case "Agrícola":
        return "assets/images/banner_agricola.jpg";

      case "Artesanías":
        return "assets/images/banner_artesanias.jpg";

      case "Plantas":
        return "assets/images/banner_plantas.jpg";

      case "Alimentos":
        return "assets/images/banner_alimentos.jpg";

      default:
        return "assets/images/banner_agricola.jpg";
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
        );
      } catch (_) {
        // Si Base64 está dañada, continuamos
        // con la siguiente opción.
      }
    }

    // ========================================================
    // IMAGEN ASSET
    // ========================================================

    if (producto.imagen != null &&
        producto.imagen!.isNotEmpty) {
      return Image.asset(
        producto.imagen!,
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
    final List<Product> productos = [
      ...productosDestacados,
      ...productosRecientes,
    ].where((producto) {
      return producto.categoria == categoria;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        centerTitle: true,

        title: Text(
          categoria,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
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
                  categoria,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  "${productos.length} producto(s) disponibles",

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // PRODUCTOS
          // ====================================================

          Expanded(
            child: productos.isEmpty
                ? const Center(
                    child: Text(
                      "No hay productos en esta categoría.",

                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: productos.length,

                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final producto =
                          productos[index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 20,
                        ),

                        elevation: 6,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),

                          onTap: () {
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

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              // ==================================
                              // IMAGEN
                              // ==================================

                              ClipRRect(
                                borderRadius:
                                    const BorderRadius
                                        .vertical(
                                  top:
                                      Radius.circular(
                                    20,
                                  ),
                                ),

                                child:
                                    mostrarImagen(
                                  producto,
                                ),
                              ),

                              // ==================================
                              // INFORMACIÓN
                              // ==================================

                              Padding(
                                padding:
                                    const EdgeInsets
                                        .all(16),

                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    // ==========================
                                    // NOMBRE
                                    // ==========================

                                    Text(
                                      producto.nombre,

                                      style:
                                          const TextStyle(
                                        fontSize: 22,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        color:
                                            Color(
                                          0xFF016630,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    // ==========================
                                    // UBICACIÓN
                                    // ==========================

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .location_on,
                                          color:
                                              Colors.red,
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
                                              fontSize:
                                                  15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    // ==========================
                                    // DESCRIPCIÓN
                                    // ==========================

                                    Text(
                                      producto
                                          .descripcion,

                                      maxLines: 3,

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors
                                                .black54,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 18,
                                    ),

                                    // ==========================
                                    // VER DETALLES
                                    // ==========================

                                    SizedBox(
                                      width:
                                          double.infinity,

                                      height: 50,

                                      child:
                                          ElevatedButton(
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
                                              builder:
                                                  (_) =>
                                                      ProductDetailScreen(
                                                producto:
                                                    producto,
                                              ),
                                            ),
                                          );
                                        },

                                        child:
                                            const Text(
                                          "Ver detalles",

                                          style:
                                              TextStyle(
                                            color:
                                                Colors
                                                    .white,
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
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
          ),
        ],
      ),
    );
  }
}