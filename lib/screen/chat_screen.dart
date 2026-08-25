import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String nombre;
  final bool grupo;
  final String usuarioId;

  const ChatScreen({
    super.key,
    required this.nombre,
    required this.grupo,
    required this.usuarioId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController mensajeController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  // ==========================================================
  // USUARIO ACTUAL
  // ==========================================================

  // Por ahora usamos un usuario temporal.
  // Más adelante lo conectaremos con el usuario que inició sesión.

  final String usuarioActualId = "usuario_actual";

  // ==========================================================
  // OBTENER MENSAJES
  // ==========================================================

  List<Message> obtenerMensajes() {
    return MessageService.obtenerMensajes(
      usuarioId: usuarioActualId,
      otroUsuarioId: widget.usuarioId,
    );
  }

  @override
  void dispose() {
    mensajeController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ==========================================================
  // ENVIAR MENSAJE
  // ==========================================================

  void enviarMensaje() {
    final texto = mensajeController.text.trim();

    if (texto.isEmpty) {
      return;
    }

    MessageService.enviarMensaje(
      remitenteId: usuarioActualId,
      destinatarioId: widget.usuarioId,
      mensaje: texto,
    );

    setState(() {});

    mensajeController.clear();

    // Bajar automáticamente al último mensaje.
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // ==========================================================
  // BURBUJA DEL MENSAJE
  // ==========================================================

  Widget burbujaMensaje(Message mensaje) {
    return Align(
      alignment: mensaje.mio
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: mensaje.mio
              ? const Color(0xFF016630)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
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
    );
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final mensajes = obtenerMensajes();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      // ======================================================
      // BARRA SUPERIOR
      // ======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFF016630),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.nombre,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      // ======================================================
      // CUERPO
      // ======================================================

      body: Column(
        children: [
          // ==================================================
          // LISTA DE MENSAJES
          // ==================================================

          Expanded(
            child: mensajes.isEmpty
                ? const Center(
                    child: Text(
                      "No hay mensajes todavía.\n"
                      "Envía el primer mensaje.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(15),
                    itemCount: mensajes.length,
                    itemBuilder: (
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
          // ESCRIBIR MENSAJE
          // ==================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            color: Colors.white,

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mensajeController,
                    textInputAction:
                        TextInputAction.send,

                    onSubmitted: (_) {
                      enviarMensaje();
                    },

                    decoration: InputDecoration(
                      hintText:
                          "Escribe un mensaje...",

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor:
                      const Color(0xFF016630),

                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: enviarMensaje,
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