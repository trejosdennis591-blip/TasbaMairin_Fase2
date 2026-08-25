import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        title: const Text(
          "Solicitudes de Trueque",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: FutureBuilder<List<TradeRequest>>(
        future:
            TradeRequestService.obtenerSolicitudes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                "No hay solicitudes de trueque.",
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
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        "Solicitante: ${solicitud.nombreSolicitante}",
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        "Fecha: "
                        "${solicitud.fecha.day}/"
                        "${solicitud.fecha.month}/"
                        "${solicitud.fecha.year}",
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
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
                        "Estado: ${solicitud.estado}",
                        style:
                            TextStyle(
                          color: solicitud
                                      .estado ==
                                  "Aceptada"
                              ? Colors.green
                              : solicitud.estado ==
                                      "Rechazada"
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight:FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

if (solicitud.estado == "Pendiente")
  Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () async {
            await TradeRequestService
                .aprobarSolicitud(
              solicitud.id,
            );

            if (!mounted) return;

            setState(() {});
          },
          child: const Text(
            "Aceptar",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            await TradeRequestService
                .rechazarSolicitud(
              solicitud.id,
            );

            if (!mounted) return;

            setState(() {});
          },
          child: const Text(
            "Rechazar",
            style: TextStyle(
              color: Colors.white,
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