import 'package:flutter/material.dart';

import 'package:flutter_application_1/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color verde =
      Color(0xFF016630);

  static const Color fondo =
      Color(0xFFFFF4B8);

  List<Map<String, dynamic>> notificaciones = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();

    cargarNotificaciones();
  }

  // ==========================================================
  // CARGAR NOTIFICACIONES
  // ==========================================================

  Future<void> cargarNotificaciones() async {
    try {
      final resultado =
          await NotificationService
              .obtenerNotificaciones();

      if (!mounted) return;

      setState(() {
        notificaciones = resultado;
        cargando = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR CARGANDO NOTIFICACIONES: $e',
      );

      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  // ==========================================================
  // MARCAR COMO LEÍDA
  // ==========================================================

  Future<void> marcarComoLeida(
    int id,
  ) async {
    try {
      await NotificationService
          .marcarComoLeida(id);

      await cargarNotificaciones();
    } catch (e) {
      debugPrint(
        'ERROR MARCANDO NOTIFICACIÓN: $e',
      );
    }
  }

  // ==========================================================
  // MARCAR TODAS COMO LEÍDAS
  // ==========================================================

  Future<void> marcarTodasComoLeidas() async {
    try {
      await NotificationService
          .marcarTodasComoLeidas();

      await cargarNotificaciones();
    } catch (e) {
      debugPrint(
        'ERROR MARCANDO TODAS: $e',
      );
    }
  }

  // ==========================================================
  // ICONO SEGÚN TIPO
  // ==========================================================

  IconData obtenerIcono(
    String tipo,
  ) {
    switch (tipo) {
      case 'mensaje':
        return Icons.chat_bubble_outline_rounded;

      case 'trueque':
        return Icons.swap_horiz_rounded;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  // ==========================================================
  // COLOR SEGÚN TIPO
  // ==========================================================

  Color obtenerColor(
    String tipo,
  ) {
    switch (tipo) {
      case 'mensaje':
        return Colors.blue;

      case 'trueque':
        return verde;

      default:
        return Colors.orange;
    }
  }

  // ==========================================================
  // FECHA
  // ==========================================================

  String mostrarFecha(
    dynamic fecha,
  ) {
    if (fecha == null) {
      return '';
    }

    try {
      final date =
          DateTime.parse(
        fecha.toString(),
      );

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return fecha.toString();
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (notificaciones.any(
            (n) => n['Leida'] == 0,
          ))
            IconButton(
              tooltip:
                  'Marcar todas como leídas',
              onPressed:
                  marcarTodasComoLeidas,
              icon: const Icon(
                Icons.done_all_rounded,
              ),
            ),
        ],
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : notificaciones.isEmpty
              ? _crearVacio()
              : RefreshIndicator(
                  onRefresh:
                      cargarNotificaciones,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    itemCount:
                        notificaciones.length,
                    itemBuilder:
                        (context, index) {
                      final notificacion =
                          notificaciones[index];

                      final id =
                          int.tryParse(
                        notificacion[
                                'NotificacionID']
                            .toString(),
                      );

                      final tipo =
                          notificacion[
                                  'Tipo']
                              ?.toString() ??
                          '';

                      final titulo =
                          notificacion[
                                  'Titulo']
                              ?.toString() ??
                          '';

                      final mensaje =
                          notificacion[
                                  'Mensaje']
                              ?.toString() ??
                          '';

                      final leida =
                          notificacion[
                                  'Leida'] ==
                              1;

                      return _crearNotificacion(
                        id: id,
                        tipo: tipo,
                        titulo: titulo,
                        mensaje: mensaje,
                        leida: leida,
                        fecha:
                            notificacion[
                                'FechaCreacion'],
                      );
                    },
                  ),
                ),
    );
  }

  // ==========================================================
  // TARJETA DE NOTIFICACIÓN
  // ==========================================================

  Widget _crearNotificacion({
    required int? id,
    required String tipo,
    required String titulo,
    required String mensaje,
    required bool leida,
    required dynamic fecha,
  }) {
    final color =
        obtenerColor(tipo);

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: leida ? 1 : 3,

      color: leida
          ? Colors.white
          : const Color(0xFFE8F5E9),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),

        onTap: () {
          if (!leida && id != null) {
            marcarComoLeida(id);
          }
        },

        child: Padding(
          padding:
              const EdgeInsets.all(14),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    0.12,
                  ),
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  obtenerIcono(tipo),
                  color: color,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  leida
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                              color:
                                  Colors.black87,
                            ),
                          ),
                        ),

                        if (!leida)
                          Container(
                            width: 9,
                            height: 9,
                            decoration:
                                const BoxDecoration(
                              color:
                                  Colors.red,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      mensaje,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      mostrarFecha(fecha),
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SIN NOTIFICACIONES
  // ==========================================================

  Widget _crearVacio() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color:
                  verde.withOpacity(0.5),
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'No tienes notificaciones',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.black87,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Aquí aparecerán tus mensajes, '
              'solicitudes de trueque y otras novedades.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}