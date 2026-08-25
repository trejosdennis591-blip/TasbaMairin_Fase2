import 'package:flutter/material.dart';

import 'package:flutter_application_1/screen/chat_screen.dart';
import 'package:flutter_application_1/services/message_service.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});

  final String usuarioActualId = "usuario_actual";

  @override
  Widget build(BuildContext context) {
    final conversaciones =
        MessageService.obtenerConversaciones(
      usuarioId: usuarioActualId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        centerTitle: true,
        title: const Text(
          "Mensajes",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: conversaciones.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 70,
                      color: Color(0xFF016630),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No tienes conversaciones todavía.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Puedes iniciar una conversación desde un producto.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount: conversaciones.length,
              itemBuilder: (context, index) {
                final conversacion =
                    conversaciones[index];

                final usuarioId =
                    conversacion["usuarioId"] ?? "";

                final nombre =
                    "Usuario $usuarioId";

                final ultimoMensaje =
                    conversacion["ultimoMensaje"] ??
                        "Conversación";

                final hora =
                    conversacion["hora"] ?? "";

                return Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),

                    leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Color(0xFF016630),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                    title: Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Text(
                      ultimoMensaje,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    trailing: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        if (hora.isNotEmpty)
                          Text(
                            hora,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(height: 5),

                        Container(
                          width: 10,
                          height: 10,
                          decoration:
                              const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(
                            nombre: nombre,
                            grupo: false,
                            usuarioId: usuarioId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}