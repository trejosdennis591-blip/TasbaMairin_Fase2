class Product {
  // ==========================================================
  // ID
  // ==========================================================

  final int id;

  // ==========================================================
  // DATOS DEL PRODUCTO
  // ==========================================================

  final String nombre;
  final String comunidad;
  final String categoria;
  final String descripcion;

  final String cantidad;
  final String unidad;
  final String trueque;
  final String ubicacion;

  // ==========================================================
  // USUARIO QUE PUBLICÓ EL PRODUCTO
  // ==========================================================

  final String usuarioId;
  final String correoUsuario;

  // ==========================================================
  // IMAGEN
  // ==========================================================

  final String? imagenBase64;
  final String? imagenUsuario;
  final String? imagen;

  // ==========================================================
  // CALIFICACIÓN
  // ==========================================================

  double calificacion;
  int cantidadResenas;

  // ==========================================================
  // FAVORITO
  // ==========================================================

  bool favorito;

  // ==========================================================
  // PRODUCTO MARCADO
  // ==========================================================

  bool marcado;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  Product({
    required this.id,
    required this.nombre,
    required this.comunidad,
    required this.categoria,
    required this.descripcion,
    this.cantidad = "",
    this.unidad = "",
    this.trueque = "",
    this.ubicacion = "",
    this.usuarioId = "",
    this.correoUsuario = "",
    this.imagenBase64,
    this.imagenUsuario,
    this.imagen,
    this.calificacion = 0,
    this.cantidadResenas = 0,
    this.favorito = false,
    this.marcado = false,
  });
}