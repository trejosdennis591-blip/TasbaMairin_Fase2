import 'package:flutter_application_1/models/message.dart';

class MessageService {
  // ==========================================================
  // MENSAJES
  // ==========================================================

  static final List<Message> _mensajes = [];

  // ==========================================================
  // OBTENER MENSAJES
  // ==========================================================

  static List<Message> obtenerMensajes({
    required String usuarioId,
    required String otroUsuarioId,
  }) {
    return _mensajes.where((mensaje) {
      final mismaConversacion =
          mensaje.remitenteId == usuarioId &&
          mensaje.destinatarioId == otroUsuarioId;

      final conversacionInversa =
          mensaje.remitenteId == otroUsuarioId &&
          mensaje.destinatarioId == usuarioId;

      return mismaConversacion || conversacionInversa;
    }).toList();
  }

  // ==========================================================
  // ENVIAR MENSAJE
  // ==========================================================

  static void enviarMensaje({
    required String remitenteId,
    required String destinatarioId,
    required String mensaje,
  }) {
    if (mensaje.trim().isEmpty) {
      return;
    }

    _mensajes.add(
      Message(
        remitenteId: remitenteId,
        destinatarioId: destinatarioId,
        mensaje: mensaje.trim(),
        fechaEnvio: DateTime.now(),
        leido: false,
        mio: true,
      ),
    );
  }

  // ==========================================================
  // MARCAR MENSAJE COMO LEÍDO
  // ==========================================================

  static void marcarComoLeido(int mensajeId) {
    final indice = _mensajes.indexWhere(
      (mensaje) => mensaje.mensajeId == mensajeId,
    );

    if (indice == -1) {
      return;
    }

    final mensaje = _mensajes[indice];

    _mensajes[indice] = Message(
      mensajeId: mensaje.mensajeId,
      remitenteId: mensaje.remitenteId,
      destinatarioId: mensaje.destinatarioId,
      mensaje: mensaje.mensaje,
      fechaEnvio: mensaje.fechaEnvio,
      leido: true,
      mio: mensaje.mio,
    );
  }

  // ==========================================================
  // LIMPIAR MENSAJES
  // ==========================================================

  static void limpiarMensajes() {
    _mensajes.clear();
  }

  // ==========================================================
  // OBTENER CONVERSACIONES
  // ==========================================================

  static List<Map<String, String>> obtenerConversaciones({
    required String usuarioId,
  }) {
    final Map<String, Map<String, String>>
        conversaciones = {};

    for (final mensaje in _mensajes) {
      String otroUsuarioId;

      if (mensaje.remitenteId == usuarioId) {
        otroUsuarioId = mensaje.destinatarioId;
      } else if (mensaje.destinatarioId == usuarioId) {
        otroUsuarioId = mensaje.remitenteId;
      } else {
        continue;
      }

      conversaciones[otroUsuarioId] = {
        "usuarioId": otroUsuarioId,
        "ultimoMensaje": mensaje.mensaje,
        "hora":
            "${mensaje.fechaEnvio.hour.toString().padLeft(2, '0')}:"
            "${mensaje.fechaEnvio.minute.toString().padLeft(2, '0')}",
      };
    }

    return conversaciones.values.toList();
  }
}