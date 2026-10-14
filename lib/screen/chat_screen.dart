import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/services/message_service.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/screen/public_profile_screen.dart';

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
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController mensajeController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final ImagePicker picker = ImagePicker();

  XFile? imagenSeleccionada;

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
        otroUsuarioId: widget.usuarioId,
        productoId: widget.productoId,
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
  // OBTENER IMAGEN DEL USUARIO
  // ==========================================================

  String? obtenerImagenUsuario() {
    for (final mensaje in mensajes) {
      if (!mensaje.mio &&
          mensaje.imagenPerfil != null &&
          mensaje.imagenPerfil!.trim().isNotEmpty) {
        return mensaje.imagenPerfil;
      }
    }

    for (final mensaje in mensajes) {
      if (mensaje.imagenPerfil != null &&
          mensaje.imagenPerfil!.trim().isNotEmpty) {
        return mensaje.imagenPerfil;
      }
    }

    return null;
  }

  // ==========================================================
  // CONSTRUIR URL DE IMAGEN
  // ==========================================================

  String construirUrlImagen(String imagen) {
    final valor = imagen.trim();

    if (valor.startsWith('http://') ||
        valor.startsWith('https://')) {
      return valor;
    }

    String baseUrl = ApiConfig.baseUrl.trim();

    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(
        0,
        baseUrl.length - 1,
      );
    }

    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(
        0,
        baseUrl.length - 4,
      );
    }

    if (valor.startsWith('/')) {
      return '$baseUrl$valor';
    }

    return '$baseUrl/$valor';
  }

  // ==========================================================
  // MOSTRAR IMAGEN DE PERFIL
  // ==========================================================

  Widget mostrarImagenPerfil({
    double radio = 22,
  }) {
    final imagen = obtenerImagenUsuario();

    if (imagen == null ||
        imagen.trim().isEmpty) {
      return CircleAvatar(
        radius: radio,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          color: const Color(0xFF016630),
          size: radio * 1.1,
        ),
      );
    }

    final valor = imagen.trim();

    // BASE64
    try {
      String base64String = valor;

      if (base64String.contains(',')) {
        base64String =
            base64String.split(',').last;
      }

      final Uint8List bytes =
          base64Decode(base64String);

      return CircleAvatar(
        radius: radio,
        backgroundColor: Colors.white,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (_) {}

    // ARCHIVO LOCAL
    try {
      final archivo = File(valor);

      if (archivo.existsSync()) {
        return CircleAvatar(
          radius: radio,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(archivo),
        );
      }
    } catch (_) {}

    // URL
    try {
      final url = construirUrlImagen(valor);

      return CircleAvatar(
        radius: radio,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(url),
      );
    } catch (_) {}

    return CircleAvatar(
      radius: radio,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        color: const Color(0xFF016630),
        size: radio * 1.1,
      ),
    );
  }

  // ==========================================================
  // SELECCIONAR IMAGEN
  // ==========================================================

  Future<void> seleccionarImagen() async {
    try {
      final XFile? imagen =
          await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagen == null) {
        print(
          'NO SE SELECCIONÓ NINGUNA IMAGEN',
        );
        return;
      }

      print(
        '========== IMAGEN SELECCIONADA ==========',
      );

      print(
        'PATH: ${imagen.path}',
      );

      print(
        'NAME: ${imagen.name}',
      );

      print(
        'EXISTS: ${File(imagen.path).existsSync()}',
      );

      print(
        '=========================================',
      );

      setState(() {
        imagenSeleccionada = imagen;
      });
    } catch (e) {
      print(
        'ERROR AL SELECCIONAR IMAGEN: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo seleccionar la imagen: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // VISTA PREVIA DE IMAGEN
  // ==========================================================

  Widget vistaPreviaImagen() {
    if (imagenSeleccionada == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.file(
                  File(imagenSeleccionada!.path),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagenSeleccionada = null;
                    });
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration:
                        const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Imagen seleccionada',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ENVIAR MENSAJE
  // ==========================================================

  Future<void> enviarMensaje() async {
    final texto =
        mensajeController.text.trim();

    print(
      '========== INTENTANDO ENVIAR ==========',
    );

    print(
      'TEXTO: "$texto"',
    );

    print(
      'IMAGEN PATH: ${imagenSeleccionada?.path}',
    );

    print(
      'IMAGEN NULL: ${imagenSeleccionada == null}',
    );

    print(
      '=======================================',
    );

    if (texto.isEmpty &&
        imagenSeleccionada == null) {
      return;
    }

    try {
      await MessageService.enviarMensaje(
        destinatarioId: widget.usuarioId,
        productoId: widget.productoId,
        mensaje: texto,
        imagenPath:
            imagenSeleccionada?.path,
      );

      if (!mounted) {
        return;
      }

      mensajeController.clear();

      setState(() {
        imagenSeleccionada = null;
      });

      await cargarMensajes();
    } catch (e) {
      print(
        'ERROR ENVIANDO MENSAJE: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
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
      const Duration(milliseconds: 200),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // ==========================================================
  // AVATAR PEQUEÑO
  // ==========================================================

  Widget avatarMensaje(Message mensaje) {
    if (mensaje.mio) {
      return const SizedBox(width: 36);
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

    try {
      final url =
          construirUrlImagen(imagen);

      return CircleAvatar(
        radius: 18,
        backgroundImage:
            NetworkImage(url),
      );
    } catch (_) {}

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
          const EdgeInsets.all(10),
      decoration:
          BoxDecoration(
        color: mensaje.mio
            ? const Color(0xFF016630)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // IMAGEN
          if (mensaje.imagen != null &&
              mensaje.imagen!
                  .trim()
                  .isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 8,
              ),
              child:
                  _mostrarImagenMensaje(
                mensaje.imagen!,
              ),
            ),

          // TEXTO
          if (mensaje.mensaje
              .trim()
              .isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 4,
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
            ),
        ],
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
        avatarMensaje(mensaje),

        const SizedBox(width: 8),

        Flexible(
          child: contenido,
        ),
      ],
    );
  }

  // ==========================================================
  // MOSTRAR IMAGEN DEL MENSAJE
  // ==========================================================

  Widget _mostrarImagenMensaje(
    String imagen,
  ) {
    final valor =
        imagen.trim();

    print(
      '========== MOSTRANDO IMAGEN ==========',
    );

    print(
      'IMAGEN RECIBIDA: $valor',
    );

    final urlImagen =
        construirUrlImagen(valor);

    print(
      'URL FINAL IMAGEN: $urlImagen',
    );

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(12),
      child: Image.network(
        urlImagen,
        width: 220,
        height: 220,
        fit: BoxFit.cover,

        loadingBuilder:
            (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return const SizedBox(
            width: 220,
            height: 220,
            child: Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF016630),
              ),
            ),
          );
        },

        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          print(
            'ERROR CARGANDO IMAGEN: $error',
          );

          print(
            'URL QUE FALLÓ: $urlImagen',
          );

          return Container(
            width: 220,
            height: 220,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
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

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: GestureDetector(
  onTap: () {
    final usuarioId =
        widget.usuarioId.trim();

    if (usuarioId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el usuario de este chat.',
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
  },
  child: Row(
    children: [
      mostrarImagenPerfil(
        radio: 22,
      ),

      const SizedBox(width: 12),

      Expanded(
        child: Text(
          widget.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      const Icon(
        Icons.person_outline,
        color: Colors.white,
        size: 22,
                ),
              ],
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
          : error != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Text(
                          error!,
                          textAlign:
                              TextAlign.center,
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
                    Expanded(
                      child:
                          mensajes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay mensajes todavía.\n'
                                    'Envía el primer mensaje.',
                                    textAlign:
                                        TextAlign.center,
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
                                      const EdgeInsets.all(15),
                                  itemCount:
                                      mensajes.length,
                                  itemBuilder:
                                      (
                                    context,
                                    index,
                                  ) {
                                    return burbujaMensaje(
                                      mensajes[index],
                                    );
                                  },
                                ),
                    ),

                    // ==================================================
                    // CAJA DE MENSAJE
                    // ==================================================

                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          vistaPreviaImagen(),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                // BOTÓN IMAGEN
                                IconButton(
                                  icon:
                                      const Icon(
                                    Icons.image,
                                    color:
                                        Color(0xFF016630),
                                  ),
                                  onPressed:
                                      seleccionarImagen,
                                ),

                                // CAMPO TEXTO
                                Expanded(
                                  child:
                                      TextField(
                                    controller:
                                        mensajeController,

                                    textInputAction:
                                        TextInputAction.send,

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
                                            BorderRadius.circular(
                                          30,
                                        ),
                                      ),

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                // BOTÓN VERDE
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
                    ),
                  ],
                ),
    );
  }
}