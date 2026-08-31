import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/report_service.dart';

class ReportProductScreen extends StatefulWidget {
  final Product producto;

  const ReportProductScreen({
    super.key,
    required this.producto,
  });

  @override
  State<ReportProductScreen> createState() =>
      _ReportProductScreenState();
}

class _ReportProductScreenState
    extends State<ReportProductScreen> {
  final TextEditingController descripcionController =
      TextEditingController();

  String motivoSeleccionado = "Contenido inapropiado";

  final List<String> motivos = [
    "Contenido inapropiado",
    "Información falsa",
    "Producto prohibido",
    "Spam",
    "Otro",
  ];

  bool enviando = false;

  Future<void> enviarReporte() async {
    if (enviando) {
      return;
    }

    setState(() {
      enviando = true;
    });

    await ReportService.crearReporte(
  productoId: widget.producto.id,
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

    setState(() {
      enviando = false;
    });
  }

  @override
  void dispose() {
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),

        title: const Text(
          "Reportar producto",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              widget.producto.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Motivo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),

                value: motivoSeleccionado,

                items: motivos.map(
                  (motivo) {
                    return DropdownMenuItem(
                      value: motivo,
                      child: Text(motivo),
                    );
                  },
                ).toList(),

                onChanged: (valor) {
                  if (valor == null) {
                    return;
                  }

                  setState(() {
                    motivoSeleccionado = valor;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Descripción (opcional)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descripcionController,
              maxLines: 4,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),

                onPressed: enviando
                    ? null
                    : enviarReporte,

                child: const Text(
                  "Enviar reporte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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