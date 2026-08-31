import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String nombre;
  final bool grupo;
  final String usuarioId;
  final String productoId;

  const ChatScreen({
    super.key,
    required this.nombre,
    required this.grupo,
    required this.usuarioId,
    required this.productoId,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final TextEditingController
      mensajeController =
      TextEditingController();

  final ScrollController
      scrollController =
      ScrollController();

  List<Message> mensajes = [];

  bool cargando = true;

  String? error;

  // ==========================================================
  // INICIO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    cargarMensajes();
  }

  // ==========================================================
  // CARGAR MENSAJES
  // ==========================================================

  Future<void> cargarMensajes() async {
    try {
      setState(() {
        cargando = true;
        error = null;
      });

      final resultado =
          await MessageService.obtenerMensajes(
        otroUsuarioId:
            widget.usuarioId,
        productoId:
            widget.productoId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        mensajes = resultado;
        cargando = false;
      });

      bajarAlFinal();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = e.toString();
      });
    }
  }

  // ==========================================================
  // OBTENER IMAGEN DEL OTRO USUARIO
  // ==========================================================

  String? obtenerImagenUsuario() {
    for (final mensaje in mensajes) {
      if (!mensaje.mio &&
          mensaje.imagenPerfil != null &&
          mensaje.imagenPerfil!
              .trim()
              .isNotEmpty) {
        return mensaje.imagenPerfil;
      }
    }

    for (final mensaje in mensajes) {
      if (mensaje.imagenPerfil != null &&
          mensaje.imagenPerfil!
              .trim()
              .isNotEmpty) {
        return mensaje.imagenPerfil;
      }
    }

    return null;
  }

  // ==========================================================
  // MOSTRAR IMAGEN
  // ==========================================================

  Widget mostrarImagenPerfil({
    double radio = 22,
  }) {
    final imagen =
        obtenerImagenUsuario();

    // --------------------------------------------------------
    // SIN IMAGEN
    // --------------------------------------------------------

    if (imagen == null ||
        imagen.trim().isEmpty) {
      return CircleAvatar(
        radius: radio,
        backgroundColor:
            Colors.white,
        child: Icon(
          Icons.person,
          color:
              const Color(0xFF016630),
          size: radio * 1.1,
        ),
      );
    }

    final valor =
        imagen.trim();

    // --------------------------------------------------------
    // BASE64
    // --------------------------------------------------------

    try {
      String base64String =
          valor;

      if (base64String
          .contains(',')) {
        base64String =
            base64String
                .split(',')
                .last;
      }

      final Uint8List bytes =
          base64Decode(
        base64String,
      );

      return CircleAvatar(
        radius: radio,
        backgroundColor:
            Colors.white,
        backgroundImage:
            MemoryImage(bytes),
      );
    } catch (_) {
      // Continuamos con las siguientes opciones.
    }

    // --------------------------------------------------------
    // ARCHIVO LOCAL
    // --------------------------------------------------------

    try {
      final archivo =
          File(valor);

      if (archivo.existsSync()) {
        return CircleAvatar(
          radius: radio,
          backgroundColor:
              Colors.white,
          backgroundImage:
              FileImage(archivo),
        );
      }
    } catch (_) {}

    // --------------------------------------------------------
    // URL
    // --------------------------------------------------------

    if (valor.startsWith('http://') ||
        valor.startsWith('https://')) {
      return CircleAvatar(
        radius: radio,
        backgroundColor:
            Colors.white,
        backgroundImage:
            NetworkImage(valor),
        onBackgroundImageError:
            (_, __) {},
      );
    }

    // --------------------------------------------------------
    // RESPALDO
    // --------------------------------------------------------

    return CircleAvatar(
      radius: radio,
      backgroundColor:
          Colors.white,
      child: Icon(
        Icons.person,
        color:
            const Color(0xFF016630),
        size: radio * 1.1,
      ),
    );
  }

  // ==========================================================
  // ENVIAR
  // ==========================================================

  Future<void> enviarMensaje() async {
    final texto =
        mensajeController.text.trim();

    if (texto.isEmpty) {
      return;
    }

    try {
      await MessageService.enviarMensaje(
        destinatarioId:
            widget.usuarioId,
        productoId:
            widget.productoId,
        mensaje:
            texto,
      );

      mensajeController.clear();

      await cargarMensajes();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo enviar el mensaje: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BAJAR AL FINAL
  // ==========================================================

  void bajarAlFinal() {
    Future.delayed(
      const Duration(
        milliseconds: 200,
      ),
      () {
        if (scrollController
            .hasClients) {
          scrollController.animateTo(
            scrollController
                .position
                .maxScrollExtent,
            duration:
                const Duration(
              milliseconds: 300,
            ),
            curve:
                Curves.easeOut,
          );
        }
      },
    );
  }

  // ==========================================================
  // AVATAR PEQUEÑO
  // ==========================================================

  Widget avatarMensaje(
    Message mensaje,
  ) {
    if (mensaje.mio) {
      return const SizedBox(
        width: 36,
      );
    }

    final imagen =
        mensaje.imagenPerfil;

    if (imagen == null ||
        imagen.trim().isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor:
            Color(0xFF016630),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    try {
      String valor =
          imagen.trim();

      if (valor.contains(',')) {
        valor =
            valor.split(',').last;
      }

      final bytes =
          base64Decode(valor);

      return CircleAvatar(
        radius: 18,
        backgroundImage:
            MemoryImage(bytes),
      );
    } catch (_) {}

    if (imagen.startsWith(
          'http://',
        ) ||
        imagen.startsWith(
          'https://',
        )) {
      return CircleAvatar(
        radius: 18,
        backgroundImage:
            NetworkImage(imagen),
      );
    }

    return const CircleAvatar(
      radius: 18,
      backgroundColor:
          Color(0xFF016630),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  // ==========================================================
  // BURBUJA
  // ==========================================================

  Widget burbujaMensaje(
    Message mensaje,
  ) {
    final contenido =
        Container(
      constraints:
          const BoxConstraints(
        maxWidth: 300,
      ),
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: mensaje.mio
            ? const Color(
                0xFF016630,
              )
            : Colors.white,
        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),
      child: Text(
        mensaje.mensaje,
        style: TextStyle(
          color: mensaje.mio
              ? Colors.white
              : Colors.black,
          fontSize: 16,
        ),
      ),
    );

    if (mensaje.mio) {
      return Align(
        alignment:
            Alignment.centerRight,
        child: contenido,
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        avatarMensaje(
          mensaje,
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          child: contenido,
        ),
      ],
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    mensajeController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: Row(
          children: [
            mostrarImagenPerfil(
              radio: 22,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                widget.nombre,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF016630),
              ),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(30),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        const Icon(
                          Icons
                              .error_outline,
                          size: 60,
                          color: Colors.red,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Text(
                          error!,
                          textAlign:
                              TextAlign
                                  .center,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        ElevatedButton(
                          onPressed:
                              cargarMensajes,
                          child:
                              const Text(
                            'Reintentar',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // ==================================================
                    // MENSAJES
                    // ==================================================

                    Expanded(
                      child:
                          mensajes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay mensajes todavía.\n'
                                    'Envía el primer mensaje.',
                                    textAlign:
                                        TextAlign
                                            .center,
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize:
                                          16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller:
                                      scrollController,

                                  padding:
                                      const EdgeInsets
                                          .all(
                                    15,
                                  ),

                                  itemCount:
                                      mensajes.length,

                                  itemBuilder:
                                      (
                                    context,
                                    index,
                                  ) {
                                    return burbujaMensaje(
                                      mensajes[
                                          index],
                                    );
                                  },
                                ),
                    ),

                    // ==================================================
                    // CAJA DE MENSAJE
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),

                      color:
                          Colors.white,

                      child: Row(
                        children: [
                          Expanded(
                            child:
                                TextField(
                              controller:
                                  mensajeController,

                              textInputAction:
                                  TextInputAction
                                      .send,

                              onSubmitted:
                                  (_) {
                                enviarMensaje();
                              },

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Escribe un mensaje...',

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    30,
                                  ),
                                ),

                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      20,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          CircleAvatar(
                            backgroundColor:
                                const Color(
                              0xFF016630,
                            ),

                            child:
                                IconButton(
                              icon:
                                  const Icon(
                                Icons.send,
                                color:
                                    Colors.white,
                              ),

                              onPressed:
                                  enviarMensaje,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}