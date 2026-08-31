class Resena {
  final int resenaId;
  final int productoId;
  final int usuarioId;
  final int calificacion;
  final String? comentario;
  final DateTime fechaResena;
  final String nombre;
  final String apellido;

  Resena({
    required this.resenaId,
    required this.productoId,
    required this.usuarioId,
    required this.calificacion,
    this.comentario,
    required this.fechaResena,
    required this.nombre,
    required this.apellido,
  });

  factory Resena.fromJson(
    Map<String, dynamic> json,
  ) {
    return Resena(
      resenaId:
          int.parse(json['ResenaID'].toString()),
      productoId:
          int.parse(json['ProductoID'].toString()),
      usuarioId:
          int.parse(json['UsuarioID'].toString()),
      calificacion:
          int.parse(json['Calificacion'].toString()),
      comentario:
          json['Comentario']?.toString(),
      fechaResena:
          DateTime.parse(
        json['FechaResena'].toString(),
      ),
      nombre:
          json['Nombre']?.toString() ?? '',
      apellido:
          json['Apellido']?.toString() ?? '',
    );
  }
}