class Report {
  final int id;

  final int productoId;

  final String usuarioId;

  final String motivo;

  final String descripcion;

  final DateTime fechaReporte;

  String estado;

  Report({
    required this.id,
    required this.productoId,
    required this.usuarioId,
    required this.motivo,
    required this.descripcion,
    required this.fechaReporte,
    required this.estado,
  });
}