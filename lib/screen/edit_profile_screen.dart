import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/config/api_config.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  // ==========================================================
  // CONTROLADOR
  // ==========================================================

  final TextEditingController nombreController =
      TextEditingController();

  // ==========================================================
  // ESTADOS
  // ==========================================================

  bool guardando = false;

  // ==========================================================
  // DATOS
  // ==========================================================

  String telefono = '';
  String correo = '';

  // ==========================================================
  // FOTO
  // ==========================================================

  File? imagenPerfil;

  String? fotoPerfilActual;

  final ImagePicker picker = ImagePicker();

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    cargarDatosPerfil();
  }

  // ==========================================================
  // CARGAR DATOS DEL PERFIL
  // ==========================================================

  Future<void> cargarDatosPerfil() async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      nombreController.text =
          prefs.getString('nombre') ?? '';

      telefono =
          prefs.getString('telefono') ?? '';

      correo =
          prefs.getString('correo') ?? '';

      fotoPerfilActual =
          prefs.getString('foto_perfil');
    });
  }

  // ==========================================================
  // SELECCIONAR FOTO
  // ==========================================================

  Future<void> seleccionarFoto() async {
    if (guardando) {
      return;
    }

    try {
      final XFile? imagen =
          await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (imagen == null) {
        return;
      }

      final archivo =
          File(imagen.path);

      if (!await archivo.exists()) {
        throw Exception(
          'El archivo seleccionado no existe.',
        );
      }

      // ======================================================
      // COMPROBAR EXTENSIÓN
      // ======================================================

      final ruta =
          imagen.path.toLowerCase();

      final esImagenValida =
          ruta.endsWith('.jpg') ||
          ruta.endsWith('.jpeg') ||
          ruta.endsWith('.png') ||
          ruta.endsWith('.webp');

      if (!esImagenValida) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'Selecciona una imagen JPG, JPEG, PNG o WEBP.',
            ),
          ),
        );

        return;
      }

      if (!mounted) {
        return;
      }

      // ======================================================
      // GUARDAR FOTO NUEVA EN MEMORIA
      // ======================================================

      setState(() {
        imagenPerfil = archivo;
      });

    } catch (e) {
      debugPrint(
        'ERROR SELECCIONANDO FOTO DE PERFIL: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'No se pudo seleccionar la imagen: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // GUARDAR PERFIL
  // ==========================================================

  Future<void> guardarPerfil() async {
    if (guardando) {
      return;
    }

    final nombre =
        nombreController.text.trim();

    // ========================================================
    // VALIDACIÓN
    // ========================================================

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'El nombre es obligatorio.',
          ),
        ),
      );

      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      // ======================================================
      // ENVIAR AL BACKEND
      //
      // IMPORTANTE:
      // El teléfono se manda sin modificar.
      // La interfaz ya no permite editarlo.
      // ======================================================

      final respuesta =
          await AuthService.actualizarPerfil(
        nombre: nombre,
        telefono: telefono,
        fotoPerfil:
            imagenPerfil?.path,
      );

      // ======================================================
      // GUARDAR DATOS DEVUELTOS POR EL BACKEND
      // ======================================================

      final prefs =
          await SharedPreferences.getInstance();

      final usuario =
          respuesta['usuario'];

      if (usuario != null) {

        if (usuario['Nombre'] != null) {
          await prefs.setString(
            'nombre',
            usuario['Nombre'].toString(),
          );
        }

        if (usuario['Telefono'] != null) {
          await prefs.setString(
            'telefono',
            usuario['Telefono'].toString(),
          );
        }

        if (usuario['FotoPerfil'] != null) {
          await prefs.setString(
            'foto_perfil',
            usuario['FotoPerfil'].toString(),
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        guardando = false;
      });

      // ======================================================
      // MENSAJE DE ÉXITO
      // ======================================================

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              const Color(0xFF016630),
          content: Text(
            respuesta['mensaje'] ??
                'Perfil actualizado correctamente.',
          ),
        ),
      );

      // ======================================================
      // VOLVER AL PERFIL
      // ======================================================

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {
      debugPrint(
        'ERROR ACTUALIZANDO PERFIL: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // ==========================================================
  // CAMPO DE NOMBRE
  // ==========================================================

  Widget campoNombre() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          'Nombre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF016630),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextField(
          controller: nombreController,
          enabled: !guardando,

          decoration: InputDecoration(
            hintText:
                'Escribe tu nombre',

            prefixIcon:
                const Icon(
              Icons.person_outline,
              color: Color(0xFF016630),
            ),

            filled: true,

            fillColor:
                Colors.grey.shade50,

            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 17,
              horizontal: 15,
            ),

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),

              borderSide:
                  BorderSide.none,
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),

              borderSide:
                  BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),

              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF016630),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INFORMACIÓN NO EDITABLE
  // ==========================================================

  Widget campoInformacion({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF016630),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.grey.shade200,

            borderRadius:
                BorderRadius.circular(15),

            border:
                Border.all(
              color:
                  Colors.grey.shade300,
            ),
          ),

          child: Row(
            children: [

              Icon(
                icono,
                color:
                    Colors.grey.shade600,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  valor.isEmpty
                      ? 'No registrado'
                      : valor,

                  style:
                      TextStyle(
                    color:
                        Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
              ),

              Icon(
                Icons.lock_outline,
                size: 18,
                color:
                    Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FOTO DE PERFIL
  // ==========================================================

  Widget fotoPerfilWidget() {

    // --------------------------------------------------------
    // FOTO NUEVA SELECCIONADA
    // --------------------------------------------------------

    if (imagenPerfil != null) {
      return Container(
        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,

          border:
              Border.all(
            color:
                const Color(0xFFD0872E),
            width: 4,
          ),
        ),

        child: CircleAvatar(
          radius: 62,

          backgroundColor:
              const Color(0xFF016630),

          backgroundImage:
              FileImage(
            imagenPerfil!,
          ),
        ),
      );
    }

    // --------------------------------------------------------
    // FOTO ACTUAL DEL SERVIDOR
    // --------------------------------------------------------

    if (fotoPerfilActual != null &&
        fotoPerfilActual!.isNotEmpty) {

      String url;

      if (fotoPerfilActual!
          .startsWith('http')) {

        url =
            fotoPerfilActual!;

      } else {

        url =
    '${ApiConfig.serverUrl}$fotoPerfilActual';
      }

      return Container(
        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,

          border:
              Border.all(
            color:
                const Color(0xFFD0872E),
            width: 4,
          ),
        ),

        child: CircleAvatar(
          radius: 62,

          backgroundColor:
              const Color(0xFF016630),

          backgroundImage:
              NetworkImage(url),

          onBackgroundImageError:
              (_, __) {},
        ),
      );
    }

    // --------------------------------------------------------
    // SIN FOTO
    // --------------------------------------------------------

    return Container(
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,

        border:
            Border.all(
          color:
              const Color(0xFFD0872E),
          width: 4,
        ),
      ),

      child: const CircleAvatar(
        radius: 62,

        backgroundColor:
            Color(0xFF016630),

        child: Icon(
          Icons.person,
          size: 65,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nombreController.dispose();

    super.dispose();
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
          const Color(0xFFFFF4B8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF016630),

        elevation: 0,

        centerTitle: true,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ==================================================
            // CABECERA VERDE
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.only(
                top: 25,
                bottom: 75,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFF016630),

                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(35),
                  bottomRight:
                      Radius.circular(35),
                ),
              ),

              child: const Column(
                children: [

                  Icon(
                    Icons.manage_accounts,
                    color:
                        Colors.white,
                    size: 30,
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Personaliza tu perfil',
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Mantén actualizada tu información',
                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENIDO
            // ==================================================

            Transform.translate(
              offset:
                  const Offset(0, -55),

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  children: [

                    // ==========================================
                    // FOTO
                    // ==========================================

                    GestureDetector(
                      onTap: guardando
                          ? null
                          : seleccionarFoto,

                      child:
                          fotoPerfilWidget(),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    GestureDetector(
                      onTap: guardando
                          ? null
                          : seleccionarFoto,

                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(0xFFD0872E),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            Icon(
                              Icons.camera_alt,
                              color:
                                  Colors.white,
                              size: 17,
                            ),

                            SizedBox(
                              width: 7,
                            ),

                            Text(
                              'Cambiar foto',
                              style: TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==========================================
                    // TARJETA DE INFORMACIÓN
                    // ==========================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(
                              alpha: 0.08,
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

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // ====================================
                          // TÍTULO
                          // ====================================

                          const Text(
                            'Información personal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Color(0xFF016630),
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(
                            'Puedes modificar tu nombre y foto de perfil.',
                            style: TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ====================================
                          // NOMBRE
                          // ====================================

                          campoNombre(),

                          const SizedBox(
                            height: 20,
                          ),

                          // ====================================
                          // TELÉFONO
                          // ====================================

                          campoInformacion(
                            titulo:
                                'Teléfono',
                            valor:
                                telefono,
                            icono:
                                Icons.phone_outlined,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ====================================
                          // CORREO
                          // ====================================

                          campoInformacion(
                            titulo:
                                'Correo electrónico',
                            valor:
                                correo,
                            icono:
                                Icons.email_outlined,
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          // ====================================
                          // BOTÓN GUARDAR
                          // ====================================

                          SizedBox(
                            width:
                                double.infinity,

                            height:
                                55,

                            child:
                                ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF016630,
                                ),

                                disabledBackgroundColor:
                                    const Color(
                                  0xFF7A9E8A,
                                ),

                                elevation:
                                    2,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    15,
                                  ),
                                ),
                              ),

                              onPressed:
                                  guardando
                                      ? null
                                      : guardarPerfil,

                              icon: guardando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Colors.white,
                                        strokeWidth:
                                            3,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save_outlined,
                                      color:
                                          Colors.white,
                                    ),

                              label:
                                  Text(
                                guardando
                                    ? 'Guardando...'
                                    : 'Guardar cambios',

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==========================================
                    // AVISO
                    // ==========================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        15,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white.withValues(
                          alpha: 0.75,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD0872E,
                          ),
                        ),
                      ),

                      child: const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Icon(
                            Icons.info_outline,
                            color:
                                Color(0xFFD0872E),
                          ),

                          SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Text(
                              'El teléfono y correo electrónico están vinculados a tu cuenta y no se pueden modificar desde aquí.',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}