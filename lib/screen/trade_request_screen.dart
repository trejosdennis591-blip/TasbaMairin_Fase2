import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/trade_request_service.dart';

class TradeRequestScreen extends StatefulWidget {
  final Product producto;

  const TradeRequestScreen({
    super.key,
    required this.producto,
  });

  @override
  State<TradeRequestScreen> createState() =>
      _TradeRequestScreenState();
}

class _TradeRequestScreenState
    extends State<TradeRequestScreen> {
  final TextEditingController ofertaController =
      TextEditingController();

  bool enviando = false;

  Future<void> enviarSolicitud() async {
    final String oferta =
        ofertaController.text.trim();

    if (oferta.isEmpty) {
      return;
    }

    setState(() {
      enviando = true;
    });

     print(
  'USUARIO DUEÑO DEL PRODUCTO: ${widget.producto.usuarioId}',
);

await TradeRequestService.crearSolicitud(
  productoId: widget.producto.id,
  nombreProducto: widget.producto.nombre,
  solicitanteId: widget.producto.usuarioId,
  nombreSolicitante: "Usuario",
  mensaje: oferta,
);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Solicitud enviada correctamente.",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    ofertaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),

        title: const Text(
          "Solicitar Trueque",
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "¿Qué ofreces a cambio?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: ofertaController,
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
                      const Color(0xFF016630),
                ),

                onPressed: enviando
                    ? null
                    : enviarSolicitud,

                child: const Text(
                  "Enviar Solicitud",
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