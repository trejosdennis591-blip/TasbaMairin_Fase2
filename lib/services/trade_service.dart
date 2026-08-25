import 'package:flutter_application_1/models/trade.dart';

class TradeService {
  TradeService._();

  static final List<Trade> _trueques = [];

  // ==========================================================
  // CREAR TRUEQUE
  // ==========================================================

  static Future<void> crearTrueque({
    required int productoOfrecidoId,
    required int productoSolicitadoId,
    required String usuarioOfreceId,
    required String usuarioSolicitaId,
  }) async {
    final Trade nuevoTrueque = Trade(
      id: DateTime.now().millisecondsSinceEpoch,
      productoOfrecidoId: productoOfrecidoId,
      productoSolicitadoId: productoSolicitadoId,
      usuarioOfreceId: usuarioOfreceId,
      usuarioSolicitaId: usuarioSolicitaId,
      estado: "Pendiente",
      fechaInicio: DateTime.now(),
    );

    _trueques.insert(0, nuevoTrueque);
  }

  // ==========================================================
  // ACEPTAR TRUEQUE
  // ==========================================================

  static Future<void> aceptarTrueque(int id) async {
    final Trade? trueque = obtenerTrueque(id);

    if (trueque == null) {
      return;
    }

    trueque.estado = "Aceptado";
  }

  // ==========================================================
  // RECHAZAR TRUEQUE
  // ==========================================================

  static Future<void> rechazarTrueque(int id) async {
    final Trade? trueque = obtenerTrueque(id);

    if (trueque == null) {
      return;
    }

    trueque.estado = "Rechazado";
    trueque.fechaCierre = DateTime.now();
  }

  // ==========================================================
  // COMPLETAR TRUEQUE
  // ==========================================================

  static Future<void> completarTrueque(int id) async {
    final Trade? trueque = obtenerTrueque(id);

    if (trueque == null) {
      return;
    }

    trueque.estado = "Completado";
    trueque.fechaCierre = DateTime.now();
  }

  // ==========================================================
  // OBTENER TRUEQUE
  // ==========================================================

  static Trade? obtenerTrueque(int id) {
    try {
      return _trueques.firstWhere(
        (trueque) => trueque.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // OBTENER TRUEQUES DE USUARIO
  // ==========================================================

  static List<Trade> obtenerTruequesUsuario(
    String usuarioId,
  ) {
    return _trueques.where(
      (trueque) =>
          trueque.usuarioOfreceId == usuarioId ||
          trueque.usuarioSolicitaId == usuarioId,
    ).toList();
  }

  // ==========================================================
  // OBTENER TODOS
  // ==========================================================

  static List<Trade> obtenerTrueques() {
    return List<Trade>.from(_trueques);
  }
}