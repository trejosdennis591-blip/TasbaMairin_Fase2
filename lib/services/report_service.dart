import 'package:flutter_application_1/models/report.dart';

class ReportService {
  ReportService._();

  static final List<Report> _reportes = [];

  static Future<void> crearReporte({
    required int productoId,
    required String usuarioId,
    required String motivo,
    required String descripcion,
  }) async {
    final Report reporte = Report(
      id: DateTime.now().millisecondsSinceEpoch,
      productoId: productoId,
      usuarioId: usuarioId,
      motivo: motivo,
      descripcion: descripcion,
      fechaReporte: DateTime.now(),
      estado: "Pendiente",
    );

    _reportes.insert(
      0,
      reporte,
    );
  }

  static List<Report> obtenerReportes() {
    return List<Report>.from(
      _reportes,
    );
  }

  static int cantidadReportes() {
    return _reportes.length;
  }
}