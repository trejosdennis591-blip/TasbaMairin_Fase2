import 'package:flutter/material.dart';

import 'package:flutter_application_1/screen/chat_screen.dart';
import 'package:flutter_application_1/services/message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
  });

  @override
  State<MessagesScreen> createState() =>
      _MessagesScreenState();
}

class _MessagesScreenState
    extends State<MessagesScreen> {
  List<Map<String, String>>
      conversaciones = [];

  bool cargando = true;

  String? error;

  @override
  void initState() {
    super.initState();

    cargarConversaciones();
  }

  // ==========================================================
  // CARGAR CONVERSACIONES
  // ==========================================================

  Future<void> cargarConversaciones() async {
    try {
      setState(() {
        cargando = true;
        error = null;
      });

      final resultado =
          await MessageService
              .obtenerConversaciones();

      if (!mounted) {
        return;
      }

      setState(() {
        conversaciones = resultado;
        cargando = false;
      });
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
  // VACÍO
  // ==========================================================

  Widget pantallaVacia() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.chat_bubble_outline,

              size: 70,

              color:
                  Color(0xFF016630),
            ),

            SizedBox(
              height: 20,
            ),

            Text(
              'No tienes conversaciones todavía.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Text(
              'Puedes iniciar una conversación desde un producto.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget pantallaError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,

              size: 65,

              color: Colors.red,
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'No se pudieron cargar los mensajes.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              error ??
                  'Error desconocido',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed:
                  cargarConversaciones,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF016630,
                ),
              ),

              child:
                  const Text(
                'Reintentar',

                style:
                    TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LISTA
  // ==========================================================

  Widget listaConversaciones() {
    return RefreshIndicator(
      onRefresh:
          cargarConversaciones,

      child: ListView.builder(
        padding:
            const EdgeInsets.symmetric(
          vertical: 8,
        ),

        itemCount:
            conversaciones.length,

        itemBuilder:
            (
          context,
          index,
        ) {
          final conversacion =
              conversaciones[index];

          final usuarioId =
              conversacion[
                      'usuarioId'] ??
                  '';

          final productoId =
              conversacion[
                      'productoId'] ??
                  '';

          final nombre =
              conversacion[
                      'nombre'] ??
                  'Usuario';

          final ultimoMensaje =
              conversacion[
                      'ultimoMensaje'] ??
                  'Conversación';

          final hora =
              conversacion[
                      'hora'] ??
                  '';

          return Card(
            margin:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            child: ListTile(
              contentPadding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 15,
                vertical: 5,
              ),

              leading:
                  const CircleAvatar(
                radius: 28,

                backgroundColor:
                    Color(0xFF016630),

                child: Icon(
                  Icons.person,

                  color:
                      Colors.white,
                ),
              ),

              title: Text(
                nombre,

                style:
                    const TextStyle(
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

              trailing:
                  Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [
                  if (hora.isNotEmpty)
                    Text(
                      hora,

                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey,
                      ),
                    ),

                  const SizedBox(
                    height: 5,
                  ),

                  Container(
                    width: 10,
                    height: 10,

                    decoration:
                        const BoxDecoration(
                      color:
                          Colors.green,

                      shape:
                          BoxShape.circle,
                    ),
                  ),
                ],
              ),

              onTap: () async {
                // ==================================================
                // VALIDAR DATOS
                // ==================================================

                if (usuarioId.isEmpty ||
                    productoId.isEmpty) {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se pudo identificar la conversación.',
                      ),
                    ),
                  );

                  return;
                }

                // ==================================================
                // ABRIR CHAT
                // ==================================================

                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ChatScreen(
                      nombre:
                          nombre,

                      grupo:
                          false,

                      usuarioId:
                          usuarioId,

                      productoId:
                          productoId,
                    ),
                  ),
                );

                await cargarConversaciones();
              },
            ),
          );
        },
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
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),

        centerTitle: true,

        title:
            const Text(
          'Mensajes',

          style:
              TextStyle(
            color:
                Colors.white,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color:
              Colors.white,
        ),

        actions: [
          IconButton(
            onPressed:
                cargarConversaciones,

            icon:
                const Icon(
              Icons.refresh,

              color:
                  Colors.white,
            ),
          ),
        ],
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
              ? pantallaError()
              : conversaciones
                      .isEmpty
                  ? pantallaVacia()
                  : listaConversaciones(),
    );
  }
}