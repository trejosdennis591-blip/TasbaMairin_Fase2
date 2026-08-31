import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/screen/product_detail_screen.dart';
import 'package:flutter_application_1/services/favorite_service.dart';

class ProductCard extends StatefulWidget {
  final Product producto;

  const ProductCard({
    super.key,
    required this.producto,
  });

  @override
  State<ProductCard> createState() =>
      _ProductCardState();
}

class _ProductCardState
    extends State<ProductCard> {

  bool guardandoFavorito = false;

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
        final Uint8List bytes =
            base64Decode(
          widget.producto.imagenBase64!,
        );

        return Image.memory(
          bytes,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return imagenPredeterminada();
          },
        );
      } catch (_) {
        return imagenPredeterminada();
      }
    }

    // ========================================================
    // IMAGEN LOCAL
    // ========================================================

    if (widget.producto.imagenUsuario != null &&
        widget.producto.imagenUsuario!.isNotEmpty) {

      final archivo =
          File(widget.producto.imagenUsuario!);

      if (archivo.existsSync()) {
        return Image.file(
          archivo,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return imagenPredeterminada();
          },
        );
      }
    }

    // ========================================================
    // IMAGEN DEL BACKEND
    // ========================================================

    if (widget.producto.imagen != null &&
        widget.producto.imagen!.isNotEmpty) {

      String url =
          widget.producto.imagen!;

      // El backend devuelve:
      // /uploads/productos/archivo.jpg

      if (url.startsWith('/')) {
        url =
            'http://192.168.1.26:3000$url';
      }

      // Si ya viene como URL completa
      if (url.startsWith('http')) {
        return Image.network(
          url,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return imagenPredeterminada();
          },
        );
      }

      // Si por alguna razón viene como asset
      return Image.asset(
        url,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return imagenPredeterminada();
        },
      );
    }

    return imagenPredeterminada();
  }

  // ==========================================================
  // IMAGEN PREDETERMINADA
  // ==========================================================

  Widget imagenPredeterminada() {
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ==========================================================
  // CAMBIAR FAVORITO
  // ==========================================================

  Future<void> cambiarFavorito() async {

    if (guardandoFavorito) {
      return;
    }

    final eraFavorito =
        FavoriteService.esFavorito(
      widget.producto,
    );

    setState(() {
      guardandoFavorito = true;
    });

    try {
      await FavoriteService.cambiarFavorito(
        widget.producto,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        guardandoFavorito = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            eraFavorito
                ? "Eliminado de favoritos"
                : "Agregado a favoritos",
          ),
          duration:
              const Duration(seconds: 1),
        ),
      );
    } catch (e) {

      if (!mounted) {
        return;
      }

      setState(() {
        guardandoFavorito = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "No se pudo actualizar favoritos: $e",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    final esFavorito =
        FavoriteService.esFavorito(
      widget.producto,
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),
      elevation: 5,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
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
                const BorderRadius.only(
              topLeft:
                  Radius.circular(18),
              topRight:
                  Radius.circular(18),
            ),
            child:
                mostrarImagen(),
          ),

          // ==================================================
          // INFORMACIÓN
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.all(15),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ==================================================
                // NOMBRE
                // ==================================================

                Text(
                  widget.producto.nombre,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF016630),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==================================================
                // UBICACIÓN
                // ==================================================

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
                        widget.producto
                                .ubicacion
                                .isNotEmpty
                            ? widget.producto
                                .ubicacion
                            : widget.producto
                                .comunidad,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==================================================
                // CATEGORÍA
                // ==================================================

                Text(
                  widget.producto.categoria,
                  style:
                      const TextStyle(
                    color:
                        Colors.black54,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ==================================================
                // BOTONES
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    // ==============================================
                    // FAVORITO
                    // ==============================================

                    IconButton(
                      onPressed:
                          guardandoFavorito
                              ? null
                              : cambiarFavorito,

                      icon:
                          guardandoFavorito
                              ? const SizedBox(
                                  width: 25,
                                  height: 25,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                  ),
                                )
                              : Icon(
                                  esFavorito
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      Colors.red,
                                  size: 30,
                                ),
                    ),

                    // ==============================================
                    // VER PRODUCTO
                    // ==============================================

                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFD0872E,
                        ),
                      ),

                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(
                              producto:
                                  widget.producto,
                            ),
                          ),
                        );
                      },

                      child:
                          const Text(
                        "Ver",
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}