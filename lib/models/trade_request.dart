class TradeRequest {
  final int id;

  final int productoId;

  final String nombreProducto;

  final String solicitanteId;

  final String nombreSolicitante;

  final String mensaje;

  String estado;

  final DateTime fecha;

  TradeRequest({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.solicitanteId,
    required this.nombreSolicitante,
    required this.mensaje,
    required this.estado,
    required this.fecha,
  });
}