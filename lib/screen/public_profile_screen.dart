import 'package:flutter/material.dart';

import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/screen/chat_screen.dart';
import 'package:flutter_application_1/services/user_service.dart';

class PublicProfileScreen
    extends StatefulWidget {
  final String usuarioId;

  const PublicProfileScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<PublicProfileScreen>
      createState() =>
          _PublicProfileScreenState();
}

class _PublicProfileScreenState
    extends State<PublicProfileScreen> {

  // ==========================================================
  // COLORES DISEÑO 3
  // ==========================================================

  static const Color verde =
      Color(0xFF016630);

  static const Color verdeOscuro =
      Color(0xFF005126);

  static const Color verdeClaro =
      Color(0xFFE8F3EA);

  static const Color crema =
      Color(0xFFFFFDF5);

  static const Color amarilloFondo =
      Color(0xFFFFF4B8);

  static const Color naranja =
      Color(0xFFD0872E);

  // ==========================================================
  // ESTADO
  // ==========================================================

  bool cargando = true;
  bool error = false;

  String nombre = '';
  String apellido = '';
  String tipoUsuario = '';
  String fotoPerfil = '';

  int cantidadPublicaciones = 0;
  int cantidadResenas = 0;
  int cantidadActividad = 0;

  double promedioResenas = 0;

  List<dynamic> publicaciones = [];
  List<dynamic> resenas = [];
  List<dynamic> actividad = [];

  int pestanaSeleccionada = 0;

  // ==========================================================
  // INICIO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    cargarPerfil();
  }

  // ==========================================================
  // CARGAR PERFIL COMPLETO
  // ==========================================================

  Future<void> cargarPerfil() async {
    try {
      if (mounted) {
        setState(() {
          cargando = true;
          error = false;
        });
      }

      final usuario =
          await UserService
              .obtenerPerfilPublicoCompleto(
        widget.usuarioId,
      );

      if (!mounted) {
        return;
      }

      final estadisticas =
          usuario['estadisticas'];

      setState(() {
        nombre =
            (usuario['Nombre'] ?? '')
                .toString()
                .trim();

        apellido =
            (usuario['Apellido'] ?? '')
                .toString()
                .trim();

        tipoUsuario =
            (usuario['TipoUsuario'] ?? '')
                .toString()
                .trim();

        fotoPerfil =
            (usuario['FotoPerfil'] ?? '')
                .toString()
                .trim();

        if (estadisticas
            is Map<String, dynamic>) {
          cantidadPublicaciones =
              int.tryParse(
                    estadisticas[
                            'publicaciones']
                        .toString(),
                  ) ??
                  0;

          cantidadResenas =
              int.tryParse(
                    estadisticas[
                            'resenas']
                        .toString(),
                  ) ??
                  0;

          cantidadActividad =
              int.tryParse(
                    estadisticas[
                            'actividad']
                        .toString(),
                  ) ??
                  0;

          promedioResenas =
              double.tryParse(
                    estadisticas[
                            'promedioResenas']
                        .toString(),
                  ) ??
                  0;
        }

        publicaciones =
            usuario['publicaciones']
                    is List
                ? usuario[
                    'publicaciones']
                : [];

        resenas =
            usuario['resenas']
                    is List
                ? usuario['resenas']
                : [];

        actividad =
            usuario['actividad']
                    is List
                ? usuario[
                    'actividad']
                : [];

        cargando = false;
        error = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR PERFIL PÚBLICO: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
        error = true;
      });
    }
  }

  // ==========================================================
  // NOMBRE COMPLETO
  // ==========================================================

  String get nombreCompleto {
    final completo =
        '$nombre $apellido'.trim();

    if (completo.isEmpty) {
      return 'Usuario';
    }

    return completo;
  }

  // ==========================================================
  // FOTO
  // ==========================================================

  Widget construirFotoPerfil() {
    if (fotoPerfil.isEmpty) {
      return construirAvatarInicial();
    }

    String url =
        fotoPerfil.trim();

    if (url.startsWith('/')) {
      url =
          '${ApiConfig.serverUrl}$url';
    }

    if (!url.startsWith(
          'http://',
        ) &&
        !url.startsWith(
          'https://',
        )) {
      url =
          '${ApiConfig.serverUrl}$url';
    }

    return ClipOval(
      child: Image.network(
        url,
        width: 108,
        height: 108,
        fit: BoxFit.cover,
        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return construirAvatarInicial();
        },
        loadingBuilder:
            (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress ==
              null) {
            return child;
          }

          return const SizedBox(
            width: 108,
            height: 108,
            child: Center(
              child:
                  CircularProgressIndicator(
                color: verde,
                strokeWidth: 3,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget construirAvatarInicial() {
    String inicial = 'U';

    if (nombre.isNotEmpty) {
      inicial = nombre
          .substring(0, 1)
          .toUpperCase();
    }

    return Container(
      width: 108,
      height: 108,
      decoration:
          const BoxDecoration(
        shape: BoxShape.circle,
        color: verde,
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style:
            const TextStyle(
          color: Colors.white,
          fontSize: 45,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================================
  // TIPO DE USUARIO
  // ==========================================================

  Widget construirTipoUsuario() {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        const Icon(
          Icons.verified,
          color: verde,
          size: 19,
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          tipoUsuario.isNotEmpty
              ? tipoUsuario
              : 'Usuario',
          style:
              const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ESTADÍSTICA
  // ==========================================================

  Widget estadistica({
    required String numero,
    required String titulo,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            numero,
            style:
                const TextStyle(
              color: Colors.black87,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            titulo,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget separadorEstadistica() {
    return Container(
      width: 1,
      height: 35,
      color:
          Colors.grey.shade300,
    );
  }

  // ==========================================================
  // MENSAJE
  // ==========================================================

  Widget botonEnviarMensaje() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child:
          ElevatedButton.icon(
        onPressed:
            enviarMensaje,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              verde,
          foregroundColor:
              Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
        icon:
            const Icon(
          Icons.chat_bubble_outline,
          size: 20,
        ),
        label:
            const Text(
          'Enviar mensaje',
          style:
              TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PESTAÑAS
  // ==========================================================

  Widget construirPestanas() {
    return Container(
      height: 55,
      decoration:
          BoxDecoration(
        color: crema,
        border: Border(
          bottom:
              BorderSide(
            color:
                Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        children: [
          construirPestana(
            indice: 0,
            icono:
                Icons.inventory_2_outlined,
            texto:
                'Publicaciones',
          ),
          construirPestana(
            indice: 1,
            icono:
                Icons.star_outline,
            texto: 'Reseñas',
          ),
          construirPestana(
            indice: 2,
            icono:
                Icons.swap_horiz,
            texto: 'Actividad',
          ),
        ],
      ),
    );
  }

  Widget construirPestana({
    required int indice,
    required IconData icono,
    required String texto,
  }) {
    final seleccionada =
        pestanaSeleccionada ==
            indice;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            pestanaSeleccionada =
                indice;
          });
        },
        child: Container(
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            border:
                Border(
              bottom:
                  BorderSide(
                color:
                    seleccionada
                        ? verde
                        : Colors
                            .transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                icono,
                size: 18,
                color:
                    seleccionada
                        ? verde
                        : Colors.grey,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                texto,
                style:
                    TextStyle(
                  color:
                      seleccionada
                          ? verde
                          : Colors
                              .grey
                              .shade700,
                  fontSize: 12,
                  fontWeight:
                      seleccionada
                          ? FontWeight
                              .bold
                          : FontWeight
                              .normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CONTENIDO
  // ==========================================================

  Widget construirContenidoPestana() {
    if (pestanaSeleccionada ==
        0) {
      return construirPublicaciones();
    }

    if (pestanaSeleccionada ==
        1) {
      return construirResenas();
    }

    return construirActividad();
  }

  // ==========================================================
  // PUBLICACIONES
  // ==========================================================

  Widget construirPublicaciones() {
    if (publicaciones.isEmpty) {
      return construirVacio(
        icono:
            Icons.inventory_2_outlined,
        titulo:
            'Sin publicaciones',
        descripcion:
            'Este usuario todavía no tiene productos publicados.',
        color: verde,
      );
    }

    return Padding(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        children:
            publicaciones.map(
          (producto) {
            final nombreProducto =
                (producto['Nombre'] ??
                        'Producto')
                    .toString();

            final categoria =
                (producto[
                            'CategoriaNombre'] ??
                        '')
                    .toString();

            final descripcion =
                (producto[
                            'Descripcion'] ??
                        '')
                    .toString();

            final ubicacion =
                (producto[
                            'Ubicacion'] ??
                        '')
                    .toString();

            final fecha =
                (producto[
                            'FechaPublicacion'] ??
                        '')
                    .toString();

            final aceptaTrueque =
                (producto[
                            'AceptaTrueque'] ??
                        '')
                    .toString();

            return Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                      0.05,
                    ),
                    blurRadius: 8,
                    offset:
                        const Offset(
                      0,
                      3,
                    ),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration:
                            BoxDecoration(
                          color:
                              verdeClaro,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .inventory_2_outlined,
                          color: verde,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          nombreProducto,
                          style:
                              const TextStyle(
                            color: verde,
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (categoria
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      categoria,
                      style:
                          const TextStyle(
                        color: naranja,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  if (descripcion
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      descripcion,
                      maxLines: 3,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  if (ubicacion
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .location_on_outlined,
                          size: 17,
                          color: Colors
                              .grey,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            ubicacion,
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              fontSize:
                                  12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (aceptaTrueque
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .swap_horiz,
                          size: 17,
                          color:
                              naranja,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          aceptaTrueque,
                          style:
                              const TextStyle(
                            color:
                                naranja,
                            fontSize:
                                12,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (fecha
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      _formatearFechaTexto(
                        fecha,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ==========================================================
  // RESEÑAS
  // ==========================================================

  Widget construirResenas() {
    return Padding(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        children: [
          if (cantidadResenas >
              0)
            Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 14,
              ),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Icon(
                    Icons.star,
                    color:
                        Colors.amber,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    promedioResenas
                        .toStringAsFixed(
                      1,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: verde,
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    '($cantidadResenas reseñas)',
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          if (resenas.isEmpty)
            construirVacio(
              icono:
                  Icons.star_outline,
              titulo:
                  'Sin reseñas',
              descripcion:
                  'Este usuario todavía no ha recibido reseñas.',
              color:
                  Colors.amber.shade700,
            )
          else
            ...resenas.map(
              (resena) {
                final nombreAutor =
                    (resena[
                                'Nombre'] ??
                            'Usuario')
                        .toString();

                final apellidoAutor =
                    (resena[
                                'Apellido'] ??
                            '')
                        .toString();

                final comentario =
                    (resena[
                                'Comentario'] ??
                            '')
                        .toString();

                final calificacion =
                    double.tryParse(
                          resena[
                                  'Calificacion']
                              .toString(),
                        ) ??
                        0;

                final productoNombre =
                    (resena[
                                'ProductoNombre'] ??
                            '')
                        .toString();

                final fecha =
                    (resena[
                                'FechaResena'] ??
                            '')
                        .toString();

                final nombreAutorCompleto =
                    '$nombreAutor $apellidoAutor'
                        .trim();

                return Container(
                  width:
                      double.infinity,
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                verde,
                            child:
                                Text(
                              nombreAutor
                                      .isNotEmpty
                                  ? nombreAutor
                                      .substring(
                                      0,
                                      1,
                                    )
                                      .toUpperCase()
                                  : 'U',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  nombreAutorCompleto
                                          .isEmpty
                                      ? 'Usuario'
                                      : nombreAutorCompleto,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children:
                                      List.generate(
                                    5,
                                    (index) {
                                      return Icon(
                                        index <
                                                calificacion
                                            ? Icons
                                                .star
                                            : Icons
                                                .star_border,
                                        color:
                                            Colors.amber,
                                        size:
                                            18,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (comentario
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          comentario,
                          style:
                              const TextStyle(
                            fontSize:
                                14,
                            height:
                                1.4,
                          ),
                        ),
                      ],

                      if (productoNombre
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Producto: $productoNombre',
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                            fontSize:
                                12,
                          ),
                        ),
                      ],

                      if (fecha
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          _formatearFechaTexto(
                            fecha,
                          ),
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                            fontSize:
                                11,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // ACTIVIDAD
  // ==========================================================

  Widget construirActividad() {
    if (actividad.isEmpty) {
      return Padding(
        padding:
            const EdgeInsets.all(16),
        child: construirVacio(
          icono:
              Icons.swap_horiz,
          titulo:
              'Sin actividad',
          descripcion:
              'Este usuario todavía no tiene actividad de trueques.',
          color: naranja,
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        children:
            actividad.map(
          (item) {
            final estado =
                (item['Estado'] ??
                        'Pendiente')
                    .toString();

            final ofrecido =
                (item[
                            'ProductoOfrecidoNombre'] ??
                        'Producto')
                    .toString();

            final solicitado =
                (item[
                            'ProductoSolicitadoNombre'] ??
                        'Producto')
                    .toString();

            final fecha =
                (item[
                            'FechaInicio'] ??
                        '')
                    .toString();

            return Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration:
                            BoxDecoration(
                          color: naranja
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons.swap_horiz,
                          color:
                              naranja,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          'Trueque #${item['TruequeID'] ?? ''}',
                          style:
                              const TextStyle(
                            color:
                                verde,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'Ofreció: $ofrecido',
                    style:
                        const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Solicitó: $solicitado',
                    style:
                        const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .check_circle_outline,
                        size: 17,
                        color:
                            naranja,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        estado,
                        style:
                            const TextStyle(
                          color:
                              naranja,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ],
                  ),

                  if (fecha
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      _formatearFechaTexto(
                        fecha,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize:
                            11,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ==========================================================
  // ESTADO VACÍO
  // ==========================================================

  Widget construirVacio({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            size: 45,
            color: color,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            titulo,
            style:
                TextStyle(
              color: verde,
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            descripcion,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FECHA
  // ==========================================================

  String _formatearFechaTexto(
    String valor,
  ) {
    final fecha =
        DateTime.tryParse(
      valor,
    );

    if (fecha == null) {
      return '';
    }

    final dia = fecha.day
        .toString()
        .padLeft(2, '0');

    final mes = fecha.month
        .toString()
        .padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  // ==========================================================
  // ENVIAR MENSAJE
  // ==========================================================

  void enviarMensaje() {
    final id =
        widget.usuarioId.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el usuario.',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(
          nombre:
              nombreCompleto,
          grupo: false,
          usuarioId: id,
          productoId: '',
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget construirError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            const Icon(
              Icons
                  .person_off_outlined,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'No se pudo cargar el perfil',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
                color: verde,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Intenta nuevamente.',
              style:
                  TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed:
                  cargarPerfil,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    verde,
                foregroundColor:
                    Colors.white,
              ),
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          amarilloFondo,

      appBar: AppBar(
        backgroundColor:
            verdeOscuro,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title:
            const Text(
          'Perfil público',
          style:
              TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: verde,
              ),
            )
          : error
              ? construirError()
              : SafeArea(
                  child:
                      SingleChildScrollView(
                    child: Column(
                      children: [
                        // ======================================
                        // CABECERA DISEÑO 3
                        // ======================================

                        Container(
                          width:
                              double.infinity,
                          height: 115,
                          decoration:
                              const BoxDecoration(
                            color:
                                verde,
                            borderRadius:
                                BorderRadius
                                    .only(
                              bottomLeft:
                                  Radius.circular(
                                45,
                              ),
                              bottomRight:
                                  Radius.circular(
                                45,
                              ),
                            ),
                          ),
                        ),

                        Transform.translate(
                          offset:
                              const Offset(
                            0,
                            -55,
                          ),
                          child:
                              Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  16,
                            ),
                            child:
                                Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                20,
                                0,
                                20,
                                20,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    crema,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  24,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                      0.08,
                                    ),
                                    blurRadius:
                                        12,
                                    offset:
                                        const Offset(
                                      0,
                                      5,
                                    ),
                                  ),
                                ],
                              ),
                              child:
                                  Column(
                                children: [
                                  Transform.translate(
                                    offset:
                                        const Offset(
                                      0,
                                      -54,
                                    ),
                                    child:
                                        Container(
                                      padding:
                                          const EdgeInsets
                                              .all(
                                        5,
                                      ),
                                      decoration:
                                          const BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                        color:
                                            Colors.white,
                                      ),
                                      child:
                                          construirFotoPerfil(),
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        5,
                                  ),

                                  Text(
                                    nombreCompleto,
                                    textAlign:
                                        TextAlign
                                            .center,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.black87,
                                      fontSize:
                                          23,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        7,
                                  ),

                                  construirTipoUsuario(),

                                  const SizedBox(
                                    height:
                                        18,
                                  ),

                                  // =================================
                                  // CONTADORES REALES
                                  // =================================

                                  Row(
                                    children: [
                                      estadistica(
                                        numero:
                                            cantidadPublicaciones
                                                .toString(),
                                        titulo:
                                            'Publicaciones',
                                      ),

                                      separadorEstadistica(),

                                      estadistica(
                                        numero:
                                            promedioResenas
                                                .toStringAsFixed(
                                          1,
                                        ),
                                        titulo:
                                            'Reseñas',
                                      ),

                                      separadorEstadistica(),

                                      estadistica(
                                        numero:
                                            cantidadActividad
                                                .toString(),
                                        titulo:
                                            'Actividad',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height:
                                        20,
                                  ),
                               
                                ],
                              ),
                            ),
                          ),
                        ),

                        Transform.translate(
                          offset:
                              const Offset(
                            0,
                            -38,
                          ),
                          child:
                              construirPestanas(),
                        ),

                        Transform.translate(
                          offset:
                              const Offset(
                            0,
                            -25,
                          ),
                          child:
                              Container(
                            width:
                                double.infinity,
                            color:
                                crema,
                            child:
                                construirContenidoPestana(),
                          ),
                        ),

                        const SizedBox(
                          height:
                              10,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}