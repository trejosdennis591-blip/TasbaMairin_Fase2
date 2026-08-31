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

  // ==========================================================
  // ENVIAR SOLICITUD
  // ==========================================================

  Future<void> enviarSolicitud() async {
    final oferta =
        ofertaController.text.trim();

    if (oferta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'Escribe qué ofreces a cambio.',
          ),
        ),
      );

      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      await TradeRequestService.crearSolicitud(
  productoId: widget.producto.id,
  usuarioOfreceId:
      int.tryParse(widget.producto.usuarioId) ?? 0,
  mensaje: oferta,
);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Solicitud enviada correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString().replaceFirst(
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
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    ofertaController.dispose();
    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),
        title: const Text(
          'Solicitar Trueque',
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

            const SizedBox(height: 8),

            const Text(
              'Quieres solicitar este producto.',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              '¿Qué ofreces a cambio?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: ofertaController,
              maxLines: 4,
              enabled: !enviando,
              textInputAction:
                  TextInputAction.newline,
              decoration: InputDecoration(
                hintText:
                    'Describe lo que ofreces a cambio...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF016630),
                    width: 2,
                  ),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF016630),
                  disabledBackgroundColor:
                      Colors.grey,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                onPressed:
                    enviando
                        ? null
                        : enviarSolicitud,
                child: enviando
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Enviar Solicitud',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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