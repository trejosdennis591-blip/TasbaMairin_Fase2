import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/screen/product_detail_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() =>
      _MyProductsScreenState();
}

class _MyProductsScreenState
    extends State<MyProductsScreen> {
  List<Product> productos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();

    cargarProductos();
  }

  // ==========================================================
  // CARGAR PRODUCTOS
  // ==========================================================

  Future<void> cargarProductos() async {
    try {
      final lista =
          await ProductService.obtenerMisProductos();

      if (!mounted) return;

      setState(() {
        productos = lista;
        cargando = false;
      });
    } catch (e) {
      debugPrint(
        'Error cargando mis productos: $e',
      );

      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  // ==========================================================
  // IMAGEN DEL PRODUCTO
  // ==========================================================

  Widget mostrarImagen(Product producto) {
    if (producto.imagenBase64 != null &&
        producto.imagenBase64!.isNotEmpty) {
      try {
        final Uint8List bytes =
            base64Decode(producto.imagenBase64!);

        return Image.memory(
          bytes,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return imagenVacia();
      }
    }

    if (producto.imagen != null &&
        producto.imagen!.isNotEmpty) {
      return Image.asset(
        producto.imagen!,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    }

    return imagenVacia();
  }

  // ==========================================================
  // IMAGEN VACÍA
  // ==========================================================

  Widget imagenVacia() {
    return Container(
      width: 110,
      height: 110,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  // ==========================================================
  // TARJETA PRODUCTO
  // ==========================================================

  Widget tarjetaProducto(
    BuildContext context,
    Product producto,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
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
        child: Padding(
          padding:
              const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child:
                    mostrarImagen(producto),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 18,
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
                      height: 6,
                    ),

                    Text(
                      producto.categoria,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w500,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    if (producto
                        .ubicacion
                        .isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on,
                            size: 17,
                            color:
                                Colors
                                    .red,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Expanded(
                            child: Text(
                              producto
                                  .ubicacion,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                        ],
                      ),

                    if (producto
                        .cantidad
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        "${producto.cantidad} ${producto.unidad}",
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color:
                    Color(0xFF016630),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
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

        title: const Text(
          "Mis publicaciones",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF016630),
              ),
            )
          : productos.isEmpty
              ? const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(
                      30,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .inventory_2_outlined,
                          size: 70,
                          color: Color(
                            0xFF016630,
                          ),
                        ),

                        SizedBox(
                          height: 15,
                        ),

                        Text(
                          "No tienes publicaciones todavía.",
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        SizedBox(
                          height: 8,
                        ),

                        Text(
                          "Cuando publiques un producto aparecerá aquí.",
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              TextStyle(
                            color:
                                Colors
                                    .grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets
                          .all(16),
                  children: [
                    Text(
                      "${productos.length} publicación${productos.length == 1 ? '' : 'es'}",
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .bold,
                        color: Color(
                          0xFF016630,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    ...productos.map(
                      (producto) =>
                          tarjetaProducto(
                        context,
                        producto,
                      ),
                    ),
                  ],
                ),
    );
  }
}