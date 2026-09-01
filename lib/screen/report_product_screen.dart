import 'package:flutter/material.dart';

import 'package:flutter_application_1/services/report_service.dart';

class ReportProductScreen extends StatefulWidget {
  final int usuarioReportadoId;

  const ReportProductScreen({
    super.key,
    required this.usuarioReportadoId,
  });

  @override
  State<ReportProductScreen> createState() =>
      _ReportProductScreenState();
}

class _ReportProductScreenState
    extends State<ReportProductScreen> {
  final TextEditingController descripcionController =
      TextEditingController();

  String motivoSeleccionado =
      "Contenido inapropiado";

  final List<String> motivos = [
    "Contenido inapropiado",
    "Información falsa",
    "Comportamiento inapropiado",
    "Spam",
    "Otro",
  ];

  bool enviando = false;

  // ==========================================================
  // ENVIAR REPORTE
  // ==========================================================

  Future<void> enviarReporte() async {
    if (enviando) {
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      await ReportService.crearReporte(
        usuarioReportadoId:
            widget.usuarioReportadoId,
        motivo: motivoSeleccionado,
        descripcion:
            descripcionController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Reporte enviado correctamente.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  // ==========================================================
  // LIBERAR CONTROLADOR
  // ==========================================================

  @override
  void dispose() {
    descripcionController.dispose();
    super.dispose();
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),

        title: const Text(
          "Reportar usuario",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ======================================================
      // CONTENIDO
      // ======================================================

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "Reportar usuario",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              "Selecciona el motivo del reporte y proporciona una descripción si lo consideras necesario.",
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // MOTIVO
            // ==================================================

            const Text(
              "Motivo",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),

              child:
                  DropdownButton<String>(
                isExpanded: true,
                underline:
                    const SizedBox(),

                value:
                    motivoSeleccionado,

                items:
                    motivos.map(
                  (motivo) {
                    return DropdownMenuItem<
                        String>(
                      value: motivo,
                      child:
                          Text(motivo),
                    );
                  },
                ).toList(),

                onChanged:
                    (valor) {
                  if (valor == null) {
                    return;
                  }

                  setState(() {
                    motivoSeleccionado =
                        valor;
                  });
                },
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // DESCRIPCIÓN
            // ==================================================

            const Text(
              "Descripción (opcional)",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextField(
              controller:
                  descripcionController,

              maxLines: 4,

              decoration:
                  InputDecoration(
                filled: true,
                fillColor:
                    Colors.white,

                hintText:
                    "Describe el problema...",

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ==================================================
            // BOTÓN ENVIAR
            // ==================================================

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                onPressed:
                    enviando
                        ? null
                        : enviarReporte,

                child:
                    enviando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.white,
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Text(
                            "Enviar reporte",
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}