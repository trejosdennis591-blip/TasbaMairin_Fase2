import 'package:flutter_application_1/models/review.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  // ==========================================================
  // RESEÑAS LOCALES
  // ==========================================================

  static final List<Review> _resenas = [];

  // ==========================================================
  // AGREGAR RESEÑA
  // ==========================================================

  static Future<void> agregarResena({
    required int productoId,
    required String usuarioId,
    required String nombreUsuario,
    required double calificacion,
    required String comentario,
  }) async {
    if (calificacion < 1 || calificacion > 5) {
      return;
    }

    if (comentario.trim().isEmpty) {
      return;
    }

    final Review nuevaResena = Review(
      id: DateTime.now().millisecondsSinceEpoch,
      productoId: productoId,
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario,
      calificacion: calificacion,
      comentario: comentario.trim(),
      fecha: DateTime.now(),
    );

    _resenas.insert(0, nuevaResena);
  }

  // ==========================================================
  // OBTENER RESEÑAS DE UN PRODUCTO
  // ==========================================================

  static List<Review> obtenerResenas(int productoId) {
    return _resenas
        .where(
          (resena) => resena.productoId == productoId,
        )
        .toList();
  }

  // ==========================================================
  // COMPROBAR SI EL USUARIO YA RESEÑÓ
  // ==========================================================

  static bool usuarioYaReseno({
    required int productoId,
    required String usuarioId,
  }) {
    return _resenas.any(
      (resena) =>
          resena.productoId == productoId &&
          resena.usuarioId == usuarioId,
    );
  }

  // ==========================================================
  // OBTENER CANTIDAD DE RESEÑAS
  // ==========================================================

  static int cantidadResenas(int productoId) {
    return _resenas
        .where(
          (resena) => resena.productoId == productoId,
        )
        .length;
  }

  // ==========================================================
  // OBTENER PROMEDIO
  // ==========================================================

  static double promedioCalificacion(int productoId) {
    final List<Review> resenas =
        obtenerResenas(productoId);

    if (resenas.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final Review resena in resenas) {
      total += resena.calificacion;
    }

    return total / resenas.length;
  }

  // ==========================================================
  // ELIMINAR RESEÑA
  // ==========================================================

  static void eliminarResena(int id) {
    _resenas.removeWhere(
      (resena) => resena.id == id,
    );
  }
}