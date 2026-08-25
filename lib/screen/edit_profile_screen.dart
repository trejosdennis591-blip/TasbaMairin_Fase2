import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/auth_service.dart';

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
  // CONTROLADORES
  // ==========================================================

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController descripcionController =
      TextEditingController();

  // ==========================================================
  // ESTADOS
  // ==========================================================

  bool guardando = false;

  // ==========================================================
  // FOTO
  // ==========================================================

  File? imagenPerfil;

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
  // CARGAR DATOS DEL USUARIO
  // ==========================================================

  Future<void> cargarDatosPerfil() async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      nombreController.text =
          prefs.getString('nombre') ?? '';

      telefonoController.text =
          prefs.getString('telefono') ?? '';
    });
  }

  // ==========================================================
  // SELECCIONAR FOTO
  // ==========================================================

  Future<void> seleccionarFoto() async {
    try {
      final XFile? imagen =
          await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagen == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        imagenPerfil = File(imagen.path);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
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
    final nombre =
        nombreController.text.trim();

    final telefono =
        telefonoController.text.trim();

    // ========================================================
    // VALIDACIÓN
    // ========================================================

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
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
      // ACTUALIZAR EN EL BACKEND
      // ======================================================

      final respuesta =
          await AuthService.actualizarPerfil(
        nombre: nombre,
        telefono: telefono,
        fotoPerfil:
            imagenPerfil?.path,
      );

      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            respuesta['mensaje'] ??
                'Perfil actualizado correctamente.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
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
  // CAMPO DE TEXTO
  // ==========================================================

  Widget campoTexto({
    required String titulo,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
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
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextField(
          controller: controller,
          enabled: !guardando,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color:
                        const Color(0xFF016630),
                  )
                : null,

            filled: true,

            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FOTO DE PERFIL
  // ==========================================================

  Widget fotoPerfilWidget() {
    if (imagenPerfil != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor:
            const Color(0xFF016630),
        backgroundImage:
            FileImage(imagenPerfil!),
      );
    }

    return const CircleAvatar(
      radius: 60,
      backgroundColor:
          Color(0xFF016630),
      child: Icon(
        Icons.person,
        size: 65,
        color: Colors.white,
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    descripcionController.dispose();

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

        centerTitle: true,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ================================================
            // FOTO
            // ================================================

            Center(
              child: GestureDetector(
                onTap: guardando
                    ? null
                    : seleccionarFoto,

                child: fotoPerfilWidget(),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Center(
              child: Text(
                'Toca la foto para cambiarla',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ================================================
            // NOMBRE
            // ================================================

            campoTexto(
              titulo: 'Nombre',
              controller:
                  nombreController,
              hint:
                  'Escribe tu nombre',
              icon:
                  Icons.person,
            ),

            const SizedBox(
              height: 20,
            ),

            // ================================================
            // TELÉFONO
            // ================================================

            campoTexto(
              titulo: 'Teléfono',
              controller:
                  telefonoController,
              hint:
                  'Ej. 8888-8888',
              icon:
                  Icons.phone,
            ),

            const SizedBox(
              height: 20,
            ),

            // ================================================
            // DESCRIPCIÓN
            // ================================================

            campoTexto(
              titulo: 'Descripción',
              controller:
                  descripcionController,
              hint:
                  'Cuéntanos algo sobre ti',
              icon:
                  Icons.info_outline,
              maxLines: 4,
            ),

            const SizedBox(
              height: 20,
            ),

            // ================================================
            // CORREO
            // ================================================

            const Text(
              'Correo electrónico',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            FutureBuilder<
                SharedPreferences>(
              future:
                  SharedPreferences
                      .getInstance(),

              builder:
                  (context, snapshot) {

                final correo =
                    snapshot.data
                            ?.getString(
                              'correo',
                            ) ??
                        'Sin correo';

                return Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade200,

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color:
                            Color(0xFF016630),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          correo,
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                            fontSize:
                                16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(
              height: 35,
            ),

            // ================================================
            // GUARDAR
            // ================================================

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton.icon(
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF016630,
                  ),

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
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                        color:
                            Colors.white,
                      ),

                label: Text(
                  guardando
                      ? 'Guardando...'
                      : 'Guardar cambios',

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}