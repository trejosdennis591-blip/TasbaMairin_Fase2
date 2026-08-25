class Message {
  final int? mensajeId;
  final String remitenteId;
  final String destinatarioId;
  final String mensaje;
  final DateTime fechaEnvio;
  final bool leido;
  final bool mio;

  Message({
    this.mensajeId,
    required this.remitenteId,
    required this.destinatarioId,
    required this.mensaje,
    required this.fechaEnvio,
    required this.leido,
    required this.mio,
  });
}