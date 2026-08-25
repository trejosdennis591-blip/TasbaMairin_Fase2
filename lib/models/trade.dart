class Trade {
  final int id;

  final int productoOfrecidoId;
  final int productoSolicitadoId;

  final String usuarioOfreceId;
  final String usuarioSolicitaId;

  String estado;

  final DateTime fechaInicio;
  DateTime? fechaCierre;

  Trade({
    required this.id,
    required this.productoOfrecidoId,
    required this.productoSolicitadoId,
    required this.usuarioOfreceId,
    required this.usuarioSolicitaId,
    required this.estado,
    required this.fechaInicio,
    this.fechaCierre,
  });
}