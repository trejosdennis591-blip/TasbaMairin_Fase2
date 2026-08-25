import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/services/product_service.dart';

class PublishProductScreen extends StatefulWidget {
  const PublishProductScreen({super.key});

  @override
  State<PublishProductScreen> createState() =>
      _PublishProductScreenState();
}

class _PublishProductScreenState
    extends State<PublishProductScreen> {
  // ==========================================================
  // IMAGEN
  // ==========================================================

  File? imagenSeleccionada;

  final ImagePicker picker = ImagePicker();

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController descripcionController =
      TextEditingController();

  final TextEditingController cantidadController =
      TextEditingController();

  final TextEditingController unidadController =
      TextEditingController();

  final TextEditingController truequeController =
      TextEditingController();

  final TextEditingController ubicacionController =
      TextEditingController();

  // ==========================================================
  // CATEGORÍA
  // ==========================================================

  String categoriaSeleccionada = "Agrícola";

  final List<String> categorias = [
    "Agrícola",
    "Artesanías",
    "Plantas",
    "Alimentos",
    "Ganadería",
  ];

  // ==========================================================
  // ESTADO
  // ==========================================================

  bool publicando = false;

  // ==========================================================
  // SELECCIONAR IMAGEN
  // ==========================================================

  Future<void> seleccionarImagen() async {
    if (publicando) {
      return;
    }

    try {
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (imagen != null && mounted) {
        setState(() {
          imagenSeleccionada = File(imagen.path);
        });
      }
    } catch (e) {
      debugPrint(
        "ERROR SELECCIONANDO IMAGEN: $e",
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se pudo seleccionar la imagen.",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // PUBLICAR PRODUCTO
  // ==========================================================

Future<void> publicarProducto() async {
  if (publicando) {
    return;
  }

  final String nombre = nombreController.text.trim();
  final String descripcion = descripcionController.text.trim();
  final String cantidad = cantidadController.text.trim();
  final String unidad = unidadController.text.trim();
  final String trueque = truequeController.text.trim();
  final String ubicacion = ubicacionController.text.trim();

  // ========================================================
  // VALIDAR CAMPOS
  // ========================================================

  if (nombre.isEmpty ||
      descripcion.isEmpty ||
      cantidad.isEmpty ||
      unidad.isEmpty ||
      trueque.isEmpty ||
      ubicacion.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Complete todos los campos.",
        ),
      ),
    );

    return;
  }

  setState(() {
    publicando = true;
  });

  try {
    // ======================================================
    // MAPEAR CATEGORÍA DE FLUTTER A ID DE MYSQL
    // ======================================================

    final Map<String, int> categoriasIds = {
      'Agrícola': 1,
      'Artesanías': 2,
      'Plantas': 3,
      'Alimentos': 4,
      'Ganadería': 5,
    };

    final int? categoriaId =
        categoriasIds[categoriaSeleccionada];

    if (categoriaId == null) {
      throw Exception(
        'La categoría seleccionada no es válida.',
      );
    }

    // ======================================================
    // CREAR PRODUCTO EN EL BACKEND
    // ======================================================

    await ProductService.crearProducto(
      categoriaId: categoriaId,
      nombre: nombre,
      descripcion: descripcion,
      cantidad: cantidad,
      unidadMedida: unidad,
      aceptaTrueque: trueque,
      ubicacion: ubicacion,
      imagenes: [],
    );

    // ======================================================
    // ÉXITO
    // ======================================================

    if (!mounted) {
      return;
    }

    setState(() {
      publicando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Producto publicado correctamente.",
        ),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(
      context,
      true,
    );
  } catch (e) {
    debugPrint(
      "ERROR PUBLICANDO PRODUCTO: $e",
    );

    if (!mounted) {
      return;
    }

    setState(() {
      publicando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "No se pudo publicar el producto: $e",
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    cantidadController.dispose();
    unidadController.dispose();
    truequeController.dispose();
    ubicacionController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        centerTitle: true,

        title: const Text(
          "Publicar Producto",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // IMAGEN
            // ==================================================

            GestureDetector(
              onTap: publicando
                  ? null
                  : seleccionarImagen,

              child: Container(
                height: 180,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child:
                    imagenSeleccionada == null
                        ? const Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 60,
                                color:
                                    Color(0xFF016630),
                              ),

                              SizedBox(
                                height: 10,
                              ),

                              Text(
                                "Agregar imagen",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),

                            child: Image.file(
                              imagenSeleccionada!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // NOMBRE
            // ==================================================

            const Text(
              "Nombre del producto",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nombreController,
              enabled: !publicando,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CATEGORÍA
            // ==================================================

            const Text(
              "Categoría",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: DropdownButton<String>(
                isExpanded: true,

                value: categoriaSeleccionada,

                underline: const SizedBox(),

                items: categorias.map(
                  (String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,

                      child: Text(
                        categoria,
                      ),
                    );
                  },
                ).toList(),

                onChanged: publicando
                    ? null
                    : (String? valor) {
                        if (valor == null) {
                          return;
                        }

                        setState(() {
                          categoriaSeleccionada =
                              valor;
                        });
                      },
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DESCRIPCIÓN
            // ==================================================

            const Text(
              "Descripción",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  descripcionController,

              enabled: !publicando,

              maxLines: 4,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CANTIDAD
            // ==================================================

            const Text(
              "Cantidad",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: cantidadController,

              enabled: !publicando,

              keyboardType:
                  TextInputType.number,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // UNIDAD
            // ==================================================

            const Text(
              "Unidad de medida",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: unidadController,

              enabled: !publicando,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // TRUEQUE
            // ==================================================

            const Text(
              "¿Qué deseas recibir en el trueque?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: truequeController,

              enabled: !publicando,

              maxLines: 2,

              decoration: InputDecoration(
                hintText:
                    "Ej. Maíz, frijoles, artesanías...",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // UBICACIÓN
            // ==================================================

            const Text(
              "Ubicación",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
                  ubicacionController,

              enabled: !publicando,

              decoration: InputDecoration(
                hintText:
                    "Ej. Bilwi, Puerto Cabezas",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                suffixIcon: const Icon(
                  Icons.location_on,
                ),
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // BOTÓN PUBLICAR
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF016630),

                  disabledBackgroundColor:
                      const Color(0xFF7A9E8A),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                onPressed: publicando
                    ? null
                    : publicarProducto,

                child: publicando
                    ? const SizedBox(
                        width: 25,
                        height: 25,

                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Publicar Producto",

                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}