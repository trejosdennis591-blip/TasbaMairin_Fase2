import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/trade_request.dart';
import 'package:flutter_application_1/services/trade_request_service.dart';

class TradeRequestsScreen extends StatefulWidget {
  const TradeRequestsScreen({super.key});

  @override
  State<TradeRequestsScreen> createState() =>
      _TradeRequestsScreenState();
}

class _TradeRequestsScreenState
    extends State<TradeRequestsScreen> {
  String usuarioId = '';

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final prefs =
        await SharedPreferences.getInstance();

    final id =
        prefs.getString('usuario_id') ?? '';

    print('USUARIO LOGUEADO: $id');

    if (!mounted) return;

    setState(() {
      usuarioId = id;
    });
  }

  Future<void> cancelar(int id) async {
    try {
      await TradeRequestService.cancelarSolicitud(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'Solicitud cancelada correctamente.',
          ),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> aceptar(int id) async {
    try {
      await TradeRequestService.aprobarSolicitud(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Solicitud aceptada correctamente.',
          ),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> rechazar(int id) async {
    try {
      await TradeRequestService.rechazarSolicitud(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Solicitud rechazada correctamente.',
          ),
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),
        title: const Text(
          'Solicitudes de Trueque',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: FutureBuilder<List<TradeRequest>>(
        future:
            TradeRequestService
                .obtenerSolicitudes(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final solicitudes =
              snapshot.data ?? [];

          if (solicitudes.isEmpty) {
            return const Center(
              child: Text(
                'No hay solicitudes de trueque.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                solicitudes.length,

            itemBuilder:
                (context, index) {
              final solicitud =
                  solicitudes[index];

              final esSolicitante =
                  usuarioId ==
                      solicitud.solicitanteId;

              final esPropietario =
                  usuarioId ==
                      solicitud.propietarioId;

              final pendiente =
                  solicitud.estado ==
                      'Pendiente';

              print(
                'USUARIO LOGUEADO: $usuarioId',
              );

              print(
                'SOLICITANTE: '
                '${solicitud.solicitanteId}',
              );

              print(
                'PROPIETARIO: '
                '${solicitud.propietarioId}',
              );

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Text(
                        solicitud
                            .nombreProducto,

                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        'Solicitante: '
                        '${solicitud.nombreSolicitante}',
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Fecha: '
                        '${solicitud.fecha.day}/'
                        '${solicitud.fecha.month}/'
                        '${solicitud.fecha.year}',

                        style:
                            const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        solicitud.mensaje,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        'Estado: '
                        '${solicitud.estado}',

                        style: TextStyle(
                          color:
                              solicitud.estado ==
                                      'Aceptado'
                                  ? Colors.green
                                  : solicitud.estado ==
                                          'Rechazado'
                                      ? Colors.red
                                      : Colors.orange,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ==================================================
                      // COMPRADOR / SOLICITANTE
                      // SOLO PUEDE CANCELAR
                      // ==================================================

                     if (pendiente && esSolicitante && !esPropietario)
                        SizedBox(
                          width:
                              double.infinity,

                          child:
                              ElevatedButton(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.orange,
                            ),

                            onPressed: () {
                              cancelar(
                                solicitud.id,
                              );
                            },

                            child:
                                const Text(
                              'Cancelar Solicitud',

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // ==================================================
                      // PROVEEDOR / PROPIETARIO
                      // PUEDE ACEPTAR O RECHAZAR
                      // ==================================================

                      if (pendiente && esPropietario && !esSolicitante)
                        Row(
                          children: [
                            Expanded(
                              child:
                                  ElevatedButton(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.green,
                                ),

                                onPressed: () {
                                  aceptar(
                                    solicitud.id,
                                  );
                                },

                                child:
                                    const Text(
                                  'Aceptar',

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  ElevatedButton(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                ),

                                onPressed: () {
                                  rechazar(
                                    solicitud.id,
                                  );
                                },

                                child:
                                    const Text(
                                  'Rechazar',

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}