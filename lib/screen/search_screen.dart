import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/data/products_data.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/screen/home_screen.dart';
import 'package:flutter_application_1/screen/product_detail_screen.dart';
import 'package:flutter_application_1/config/api_config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  String textoBusqueda = "";

  // ==========================================================
  // MOSTRAR IMAGEN DEL PRODUCTO
  // ==========================================================

  Widget mostrarImagenProducto(
    Product producto,
  ) {
    // ========================================================
    // 1. BASE64
    // ========================================================

    if (producto.imagenBase64 != null &&
        producto.imagenBase64!
            .trim()
            .isNotEmpty) {
      try {
        String valor =
            producto.imagenBase64!.trim();

        if (valor.contains(',')) {
          valor =
              valor.split(',').last;
        }

        final Uint8List bytes =
            base64Decode(valor);

        return Image.memory(
          bytes,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return imagenVacia();
          },
        );
      } catch (e) {
        debugPrint(
          "ERROR DECODIFICANDO BASE64: $e",
        );
      }
    }

    // ========================================================
    // 2. IMAGEN LOCAL
    // ========================================================

    if (producto.imagenUsuario != null &&
        producto.imagenUsuario!
            .trim()
            .isNotEmpty) {
      try {
        final archivo =
            File(
          producto.imagenUsuario!,
        );

        if (archivo.existsSync()) {
          return Image.file(
            archivo,
            width: 65,
            height: 65,
            fit: BoxFit.cover,
          );
        }
      } catch (e) {
        debugPrint(
          "ERROR CARGANDO IMAGEN LOCAL: $e",
        );
      }
    }

    // ========================================================
    // 3. IMAGEN DEL SERVIDOR
    // ========================================================

    if (producto.imagen != null &&
        producto.imagen!
            .trim()
            .isNotEmpty) {
      final valor =
          producto.imagen!.trim();

      debugPrint(
        "IMAGEN PRODUCTO: $valor",
      );

      // ------------------------------------------------------
      // URL COMPLETA
      // ------------------------------------------------------

      if (valor.startsWith(
            'http://',
          ) ||
          valor.startsWith(
            'https://',
          )) {
        return Image.network(
          valor,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            debugPrint(
              "ERROR IMAGEN NETWORK: $error",
            );

            return imagenVacia();
          },
        );
      }

      // ------------------------------------------------------
      // RUTA DEL BACKEND
      // ------------------------------------------------------

      if (valor.startsWith('/')) {
        final baseUrl =
            ApiConfig.baseUrl
                .replaceAll(
              '/api',
              '',
            );

        final urlFinal =
            '$baseUrl$valor';

        debugPrint(
          "URL FINAL PRODUCTO: $urlFinal",
        );

        return Image.network(
          urlFinal,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            debugPrint(
              "ERROR CARGANDO IMAGEN PRODUCTO: $error",
            );

            debugPrint(
              "URL QUE FALLÓ: $urlFinal",
            );

            return imagenVacia();
          },
        );
      }

      // ------------------------------------------------------
      // ASSET DE FLUTTER
      // ------------------------------------------------------

      if (valor.startsWith(
            'assets/',
          )) {
        return Image.asset(
          valor,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return imagenVacia();
          },
        );
      }

      // ------------------------------------------------------
      // ARCHIVO LOCAL
      // ------------------------------------------------------

      try {
        final archivo =
            File(valor);

        if (archivo.existsSync()) {
          return Image.file(
            archivo,
            width: 65,
            height: 65,
            fit: BoxFit.cover,
          );
        }
      } catch (_) {}
    }

    // ========================================================
    // 4. SIN IMAGEN
    // ========================================================

    return imagenVacia();
  }

  // ==========================================================
  // IMAGEN VACÍA
  // ==========================================================

  Widget imagenVacia() {
    return Container(
      width: 65,
      height: 65,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 30,
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
    final List<Product> resultados =
        [
      ...productosDestacados,
      ...productosRecientes,
    ].where(
      (producto) {
        return producto.nombre
            .toLowerCase()
            .contains(
              textoBusqueda
                  .toLowerCase(),
            );
      },
    ).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),

        centerTitle: true,

        title: const Text(
          "Buscar productos",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            // ==================================================
            // BUSCADOR
            // ==================================================

            TextField(
              onChanged: (value) {
                setState(() {
                  textoBusqueda =
                      value;
                });
              },

              decoration:
                  InputDecoration(
                hintText:
                    "Buscar producto...",

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // RESULTADOS
            // ==================================================

            Expanded(
              child:
                  resultados.isEmpty
                      ? const Center(
                          child: Text(
                            "No se encontraron productos.",
                            style:
                                TextStyle(
                              fontSize:
                                  17,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              resultados
                                  .length,

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final Product
                                producto =
                                resultados[
                                    index];

                            return Card(
                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    15,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  15,
                                ),
                              ),

                              child:
                                  ListTile(
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      10,
                                  vertical:
                                      6,
                                ),

                                // ==================================================
                                // IMAGEN
                                // ==================================================

                                leading:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),

                                  child:
                                      mostrarImagenProducto(
                                    producto,
                                  ),
                                ),

                                // ==================================================
                                // NOMBRE
                                // ==================================================

                                title:
                                    Text(
                                  producto
                                      .nombre,

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                // ==================================================
                                // UBICACIÓN
                                // ==================================================

                                subtitle:
                                    Text(
                                  producto
                                          .comunidad
                                          .isNotEmpty
                                      ? producto
                                          .comunidad
                                      : "Ubicación no disponible",
                                ),

                                // ==================================================
                                // BOTÓN VER
                                // ==================================================

                                trailing:
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
                                        20,
                                      ),
                                    ),
                                  ),

                                  onPressed:
                                      () {
                                    Navigator
                                        .push(
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
                                    "Ver",
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      // ========================================================
      // NAVEGACIÓN INFERIOR
      // ========================================================

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: 1,

        selectedItemColor:
            const Color(0xFF016630),

        unselectedItemColor:
            Colors.grey,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const HomeScreen(),
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Inicio",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: "Buscar",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
            ),
            label: "Mensajes",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}