import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/models/review.dart';
import 'package:flutter_application_1/screen/chat_screen.dart';
import 'package:flutter_application_1/services/favorite_service.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/services/review_service.dart';
import 'package:flutter_application_1/screen/trade_request_screen.dart';
import 'package:flutter_application_1/screen/report_product_screen.dart';

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

class _ProductDetailScreenState extends State<ProductDetailScreen> {

// ==========================================================

// RESEÑA

// ==========================================================

double calificacionSeleccionada = 0;

final TextEditingController comentarioController =

TextEditingController();

bool enviandoResena = false;

// Usuario local temporal.

// Cuando conectemos la base de datos lo cambiaremos

// por el usuario real de la sesión.

final String usuarioActualId = "usuario_local";

final String nombreUsuarioActual = "Usuario";

// ==========================================================

// MOSTRAR IMAGEN

// ==========================================================

Widget mostrarImagen() {

// --------------------------------------------------------

// BASE64

// --------------------------------------------------------



if (widget.producto.imagenBase64 != null &&

    widget.producto.imagenBase64!.isNotEmpty) {

  try {

    final Uint8List bytes =

        base64Decode(widget.producto.imagenBase64!);



    return Image.memory(

      bytes,

      width: double.infinity,

      height: 230,

      fit: BoxFit.cover,

    );

  } catch (_) {

    return imagenVacia();

  }

}



// --------------------------------------------------------

// IMAGEN LOCAL

// --------------------------------------------------------



if (widget.producto.imagenUsuario != null &&

    widget.producto.imagenUsuario!.isNotEmpty) {

  final archivo = File(widget.producto.imagenUsuario!);



  if (archivo.existsSync()) {

    return Image.file(

      archivo,

      width: double.infinity,

      height: 230,

      fit: BoxFit.cover,

    );

  }

}



// --------------------------------------------------------

// ASSET

// --------------------------------------------------------



if (widget.producto.imagen != null &&

    widget.producto.imagen!.isNotEmpty) {

  return Image.asset(

    widget.producto.imagen!,

    width: double.infinity,

    height: 230,

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

      nombre: "Usuario",

      grupo: false,

      usuarioId: usuarioId,

    ),

  ),

);

}

// ==========================================================

// SELECCIONAR ESTRELLA

// ==========================================================

void seleccionarEstrella(double estrella) {

setState(() {

  calificacionSeleccionada = estrella;

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



// --------------------------------------------------------

// VALIDAR ESTRELLAS

// --------------------------------------------------------



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



// --------------------------------------------------------

// VALIDAR COMENTARIO

// --------------------------------------------------------



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



// --------------------------------------------------------

// COMPROBAR SI YA RESEÑÓ

// --------------------------------------------------------



final bool yaReseno =

    ReviewService.usuarioYaReseno(

  productoId: widget.producto.id,

  usuarioId: usuarioActualId,

);



if (yaReseno) {

  ScaffoldMessenger.of(context).showSnackBar(

    const SnackBar(

      content: Text(

        "Ya dejaste una reseña para este producto.",

      ),

    ),

  );



  return;

}



setState(() {

  enviandoResena = true;

});



try {

  // ------------------------------------------------------

  // GUARDAR RESEÑA

  // ------------------------------------------------------



  await ReviewService.agregarResena(

    productoId: widget.producto.id,

    usuarioId: usuarioActualId,

    nombreUsuario: nombreUsuarioActual,

    calificacion: calificacionSeleccionada,

    comentario: comentario,

  );



  // ------------------------------------------------------

  // ACTUALIZAR CALIFICACIÓN DEL PRODUCTO

  // ------------------------------------------------------



  await ProductService.calificarProducto(

    widget.producto,

    calificacionSeleccionada,

  );



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

      duration: Duration(seconds: 2),

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

  mainAxisAlignment: MainAxisAlignment.center,

  children: List.generate(

    5,

    (index) {

      final double valor =

          index + 1.0;



      return IconButton(

        onPressed: enviandoResena

            ? null

            : () => seleccionarEstrella(valor),

        iconSize: 42,

        padding: const EdgeInsets.symmetric(

          horizontal: 3,

        ),

        icon: Icon(

          valor <= calificacionSeleccionada

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

// MOSTRAR ESTRELLAS DE UNA RESEÑA

// ==========================================================

Widget estrellasResena(double calificacion) {

return Row(

  mainAxisSize: MainAxisSize.min,

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

// SECCIÓN PARA DEJAR RESEÑA

// ==========================================================

Widget construirFormularioResena() {

final bool yaReseno =

    ReviewService.usuarioYaReseno(

  productoId: widget.producto.id,

  usuarioId: usuarioActualId,

);



if (yaReseno) {

  return Container(

    width: double.infinity,

    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

    ),

    child: const Column(

      children: [

        Icon(

          Icons.check_circle,

          color: Color(0xFF016630),

          size: 40,

        ),

        SizedBox(height: 8),

        Text(

          "Ya dejaste una reseña de este producto.",

          textAlign: TextAlign.center,

          style: TextStyle(

            fontSize: 16,

            fontWeight: FontWeight.bold,

          ),

        ),

      ],

    ),

  );

}



return Container(

  width: double.infinity,

  padding: const EdgeInsets.all(18),

  decoration: BoxDecoration(

    color: Colors.white,

    borderRadius: BorderRadius.circular(15),

  ),

  child: Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      const Text(

        "Deja tu reseña",

        style: TextStyle(

          fontSize: 21,

          fontWeight: FontWeight.bold,

          color: Color(0xFF016630),

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



      // --------------------------------------------------

      // ESTRELLAS

      // --------------------------------------------------



      estrellasSeleccion(),



      if (calificacionSeleccionada > 0)

        Center(

          child: Text(

            "${calificacionSeleccionada.toInt()} de 5 estrellas",

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              color: Color(0xFF016630),

            ),

          ),

        ),



      const SizedBox(height: 15),



      // --------------------------------------------------

      // COMENTARIO

      // --------------------------------------------------



      TextField(

        controller: comentarioController,

        enabled: !enviandoResena,

        maxLines: 4,

        decoration: InputDecoration(

          hintText:

              "Escribe tu experiencia con este producto...",

          filled: true,

          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(15),

          ),

        ),

      ),



      const SizedBox(height: 15),



      // --------------------------------------------------

      // BOTÓN

      // --------------------------------------------------



      SizedBox(

        width: double.infinity,

        height: 50,

        child: ElevatedButton(

          onPressed:

              enviandoResena ? null : enviarResena,

          style: ElevatedButton.styleFrom(

            backgroundColor:

                const Color(0xFF016630),

            disabledBackgroundColor:

                Colors.grey,

            shape: RoundedRectangleBorder(

              borderRadius:

                  BorderRadius.circular(15),

            ),

          ),

          child: enviandoResena

              ? const SizedBox(

                  width: 22,

                  height: 22,

                  child:

                      CircularProgressIndicator(

                    color: Colors.white,

                    strokeWidth: 2,

                  ),

                )

              : const Text(

                  "Publicar reseña",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 16,

                    fontWeight: FontWeight.bold,

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

final List<Review> resenas =

    ReviewService.obtenerResenas(

  widget.producto.id,

);



if (resenas.isEmpty) {

  return Container(

    width: double.infinity,

    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

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

          textAlign: TextAlign.center,

          style: TextStyle(

            color: Colors.grey,

          ),

        ),

      ],

    ),

  );

}



return Column(

  children: resenas.map(

    (Review resena) {

      return Container(

        width: double.infinity,

        margin: const EdgeInsets.only(

          bottom: 12,

        ),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:

              BorderRadius.circular(15),

        ),

        child: Column(

          crossAxisAlignment:

              CrossAxisAlignment.start,

          children: [

            // --------------------------------------------

            // USUARIO

            // --------------------------------------------



            Row(

              children: [

                CircleAvatar(

                  backgroundColor:

                      const Color(0xFF016630),

                  child: Text(

                    resena.nombreUsuario

                            .isNotEmpty

                        ? resena.nombreUsuario

                            .substring(0, 1)

                            .toUpperCase()

                        : "?",

                    style: const TextStyle(

                      color: Colors.white,

                      fontWeight:

                          FontWeight.bold,

                    ),

                  ),

                ),

const SizedBox(width: 10),

Expanded(

                  child: Column(

                    crossAxisAlignment:

                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        resena.nombreUsuario,

                        style: const TextStyle(

                          fontWeight:

                              FontWeight.bold,

                          fontSize: 16,

                        ),

                      ),



                      const SizedBox(height: 3),



                      estrellasResena(

                        resena.calificacion,

                      ),

                    ],

                  ),

                ),

              ],

            ),



            const SizedBox(height: 12),



            // --------------------------------------------

            // COMENTARIO

            // --------------------------------------------



            Text(

              resena.comentario,

              style: const TextStyle(

                fontSize: 16,

              ),

            ),



            const SizedBox(height: 8),



            // --------------------------------------------

            // FECHA

            // --------------------------------------------



            Text(

              _formatearFecha(

                resena.fecha,

              ),

              style: const TextStyle(

                color: Colors.grey,

                fontSize: 12,

              ),

            ),

          ],

        ),

      );

    },

  ).toList(),

);

}

// ==========================================================

// FORMATEAR FECHA

// ==========================================================

String _formatearFecha(DateTime fecha) {

final String dia =

    fecha.day.toString().padLeft(2, "0");



final String mes =

    fecha.month.toString().padLeft(2, "0");



final String ano =

    fecha.year.toString();



return "$dia/$mes/$ano";

}

// ==========================================================

// BUILD

// ==========================================================

@override

Widget build(BuildContext context) {

final double promedio =

    ReviewService.promedioCalificacion(

  widget.producto.id,

);



final int cantidad =

    ReviewService.cantidadResenas(

  widget.producto.id,

);



// Si todavía no hay reseñas nuevas, usamos

// la calificación que ya tenga el producto.

final double calificacionMostrar =

    cantidad > 0

        ? promedio

        : widget.producto.calificacion;



final int resenasMostrar =

    cantidad > 0

        ? cantidad

        : widget.producto.cantidadResenas;



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



    iconTheme:

        const IconThemeData(

      color: Colors.white,

    ),



    title: Text(

      widget.producto.nombre,

      style: const TextStyle(

        color: Colors.white,

      ),

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



        ClipRRect(

          borderRadius:

              BorderRadius.circular(20),

          child: mostrarImagen(),

        ),



        const SizedBox(height: 20),



        // ==================================================

        // NOMBRE

        // ==================================================



        Text(

          widget.producto.nombre,

          style: const TextStyle(

            fontSize: 28,

            fontWeight: FontWeight.bold,

            color: Color(0xFF016630),

          ),

        ),



        const SizedBox(height: 20),



        // ==================================================

        // INFORMACIÓN

        // ==================================================



        Container(

          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:

                BorderRadius.circular(15),

          ),



          child: Column(

            crossAxisAlignment:

                CrossAxisAlignment.start,



            children: [

              // CATEGORÍA



              Row(

                children: [

                  const Icon(

                    Icons.category,

                    color: Color(0xFF016630),

                  ),



                  const SizedBox(width: 10),



                  Expanded(

                    child: Text(

                      widget.producto.categoria,

                      style:

                          const TextStyle(

                        fontSize: 17,

                        fontWeight:

                            FontWeight.bold,

                      ),

                    ),

                  ),

                ],

              ),



              // UBICACIÓN



              if (widget.producto.ubicacion

                  .isNotEmpty) ...[

                const SizedBox(height: 15),



                Row(

                  children: [

                    const Icon(

                      Icons.location_on,

                      color:

                          Color(0xFF016630),

                    ),



                    const SizedBox(width: 10),



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



              // CANTIDAD



              if (widget.producto.cantidad

                  .isNotEmpty) ...[

                const SizedBox(height: 15),



                Row(

                  children: [

                    const Icon(

                      Icons.inventory_2,

                      color:

                          Color(0xFF016630),

                    ),



                    const SizedBox(width: 10),



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



        const SizedBox(height: 25),



        // ==================================================

        // DESCRIPCIÓN

        // ==================================================



        const Text(

          "Descripción",

          style: TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

            color: Color(0xFF016630),

          ),

        ),



        const SizedBox(height: 10),



        Text(

          widget.producto.descripcion,

          style: const TextStyle(

            fontSize: 16,

          ),

        ),



        const SizedBox(height: 25),

// ==================================================

// TRUEQUE

        // ==================================================



        const Text(

          "Intercambia por",

          style: TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

            color: Color(0xFF016630),

          ),

        ),



        const SizedBox(height: 10),



        Container(

          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:

                BorderRadius.circular(15),

          ),



          child: Text(

            widget.producto.trueque.isNotEmpty

                ? widget.producto.trueque

                : "No especificado",

            style: const TextStyle(

              fontSize: 16,

            ),

          ),

        ),



        const SizedBox(height: 30),



        // ==================================================

        // CALIFICACIÓN

        // ==================================================



        Container(

          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:

                BorderRadius.circular(15),

          ),



          child: Column(

            children: [

              Row(

                mainAxisAlignment:

                    MainAxisAlignment.center,

                children: [

                  const Icon(

                    Icons.star,

                    color: Colors.amber,

                    size: 30,

                  ),



                  const SizedBox(width: 8),



                  Text(

                    calificacionMostrar

                        .toStringAsFixed(1),

                    style:

                        const TextStyle(

                      fontSize: 20,

                      fontWeight:

                          FontWeight.bold,

                    ),

                  ),



                  const SizedBox(width: 8),



                  Text(

                    "($resenasMostrar reseñas)",

                    style:

                        const TextStyle(

                      color: Colors.grey,

                    ),

                  ),

                ],

              ),



              const SizedBox(height: 5),



              // ESTRELLAS DEL PROMEDIO



              estrellasResena(

                calificacionMostrar,

              ),

            ],

          ),

        ),



        const SizedBox(height: 30),



        // ==================================================

        // CONTACTAR + FAVORITO

        // ==================================================



        Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF016630),
          minimumSize: const Size(0, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
          backgroundColor: const Color(0xFFD0872E),
          minimumSize: const Size(0, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => TradeRequestScreen(
            producto: widget.producto,
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

        await FavoriteService.cambiarFavorito(
          widget.producto,
        );

        if (!mounted) {
          return;
        }

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              eraFavorito
                  ? "Producto eliminado de favoritos"
                  : "Producto agregado a favoritos",
            ),
            duration: const Duration(
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

        const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      minimumSize: const Size(0, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportProductScreen(
            producto: widget.producto,
          ),
        ),
      );
    },
    icon: const Icon(
      Icons.report,
      color: Colors.white,
    ),
    label: const Text(
      "Reportar producto",
      style: TextStyle(
        color: Colors.white,
        fontSize: 17,
      ),
    ),
  ),
),



        // ==================================================

        // UBICACIÓN

        // ==================================================



        SizedBox(

          width: double.infinity,



          child:

              OutlinedButton.icon(

            style:

                OutlinedButton.styleFrom(

              side: const BorderSide(

                color: Color(0xFFD0872E),

                width: 2,

              ),



              minimumSize:

                  const Size(0, 55),



              shape:

                  RoundedRectangleBorder(

                borderRadius:

                    BorderRadius.circular(15),

              ),

            ),



           onPressed: () {
  if (widget.producto.ubicacion.trim().isEmpty) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ubicación"),
        content: const Text(
          "Este producto fue publicado antes de que se agregara el sistema de ubicación.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );

    return;
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Ubicación del producto"),
      content: Text(widget.producto.ubicacion),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
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

                fontWeight:

                    FontWeight.bold,

              ),

            ),

          ),

        ),



        const SizedBox(height: 30),



        // ==================================================

        // DEJAR RESEÑA

        // ==================================================



        construirFormularioResena(),



        const SizedBox(height: 30),



        // ==================================================

        // RESEÑAS DE OTROS USUARIOS

        // ==================================================



        const Text(

          "Opiniones de otros usuarios",

          style: TextStyle(

            fontSize: 22,

            fontWeight: FontWeight.bold,

            color: Color(0xFF016630),

          ),

        ),

const SizedBox(height: 12),

construirResenas(),



            const SizedBox(height: 30),

          ],

        ),

      ),

    );

  }

}


