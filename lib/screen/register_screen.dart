import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ==========================================================
  // CONTROLADORES
  // ==========================================================

  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final correoController = TextEditingController();
  final telefonoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  // ==========================================================
  // ESTADOS
  // ==========================================================

  bool ocultarPassword = true;
  bool ocultarConfirmarPassword = true;
  bool registrando = false;

  // ==========================================================
  // TIPO DE USUARIA
  // ==========================================================

  String tipoUsuario = "";

  // ==========================================================
  // IMÁGENES
  // ==========================================================

  File? fotoPerfil;
  File? fotoCarnet;

  final ImagePicker picker = ImagePicker();

  // ==========================================================
  // REGISTRAR USUARIA
  // ==========================================================

  Future<void> registrarUsuario() async {
    if (registrando) {
      return;
    }

    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final correo = correoController.text.trim();
    final telefono = telefonoController.text.trim();
    final password = passwordController.text.trim();
    final confirmarPassword =
        confirmarPasswordController.text.trim();

    // ========================================================
    // VALIDAR CAMPOS
    // ========================================================

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        correo.isEmpty ||
        telefono.isEmpty ||
        password.isEmpty ||
        confirmarPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Complete todos los campos obligatorios.",
          ),
        ),
      );

      return;
    }

    // ========================================================
    // VALIDAR CONTRASEÑAS
    // ========================================================

    if (password != confirmarPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Las contraseñas no coinciden.",
          ),
        ),
      );

      return;
    }

    // ========================================================
    // VALIDAR TIPO DE USUARIA
    // ========================================================

    if (tipoUsuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Seleccione el tipo de usuaria.",
          ),
        ),
      );

      return;
    }

    setState(() {
      registrando = true;
    });

    try {
      // ======================================================
      // REGISTRAR EN EL BACKEND
      // ======================================================

     final respuesta = await AuthService.register(
  nombre: nombreController.text.trim(),
  apellido: apellidoController.text.trim(),
  telefono: telefonoController.text.trim(),
  correo: correoController.text.trim(),
  contrasena: passwordController.text.trim(),
  tipoUsuario: tipoUsuario,
  fotoPerfil: fotoPerfil,
  fotoCarnet: fotoCarnet,
);

      if (!mounted) {
        return;
      }

      setState(() {
        registrando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            respuesta['mensaje'] ??
                'Cuenta creada correctamente.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        registrando = false;
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
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ==========================================================
  // SELECCIONAR FOTO DE PERFIL
  // ==========================================================

  Future<void> seleccionarFotoPerfil() async {
    if (registrando) {
      return;
    }

    try {
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (imagen == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        fotoPerfil = File(imagen.path);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "No se pudo seleccionar la foto: $e",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SELECCIONAR FOTO DEL CARNET
  // ==========================================================

  Future<void> seleccionarFotoCarnet() async {
    if (registrando) {
      return;
    }

    try {
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (imagen == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        fotoCarnet = File(imagen.path);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "No se pudo seleccionar el carnet: $e",
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
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF016630),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 7),

        TextField(
          controller: controller,
          enabled: !registrando,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(
              icon,
              color: const Color(0xFF016630),
            ),

            suffixIcon: suffixIcon,

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF016630),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TARJETA PARA FOTO
  // ==========================================================

  Widget tarjetaFoto({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required VoidCallback onTap,
    required File? imagen,
    bool circular = false,
  }) {
    return GestureDetector(
      onTap: registrando ? null : onTap,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: const Color(0xFF016630).withOpacity(0.20),
            width: 1,
          ),
        ),

        child: Row(
          children: [
            // ==================================================
            // VISTA DE LA IMAGEN
            // ==================================================

            if (imagen != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  circular ? 50 : 12,
                ),
                child: Image.file(
                  imagen,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 70,
                height: 70,

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4B8),
                  borderRadius: BorderRadius.circular(
                    circular ? 50 : 12,
                  ),
                ),

                child: Icon(
                  icono,
                  size: 34,
                  color: const Color(0xFF016630),
                ),
              ),

            const SizedBox(width: 15),

            // ==================================================
            // TEXTO
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF016630),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    imagen == null
                        ? descripcion
                        : "Imagen seleccionada. Toca para cambiarla.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: Color(0xFF016630),
            ),
          ],
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
    apellidoController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        centerTitle: true,

        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Crear cuenta",
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
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          35,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ENCABEZADO
            // ==================================================

            Center(
              child: Container(
                width: 75,
                height: 75,

                decoration: BoxDecoration(
                  color: const Color(0xFF016630),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Icon(
                  Icons.people_alt,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                "Bienvenida a TasbaMairin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016630),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: Text(
                "Crea tu cuenta y forma parte de nuestra comunidad.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // INFORMACIÓN PERSONAL
            // ==================================================

            const Text(
              "Información personal",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF016630),
              ),
            ),

            const SizedBox(height: 15),

            campoTexto(
              titulo: "Nombre",
              hint: "Escribe tu nombre",
              controller: nombreController,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            campoTexto(
              titulo: "Apellido",
              hint: "Escribe tu apellido",
              controller: apellidoController,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            campoTexto(
              titulo: "Correo electrónico",
              hint: "Ej. ejemplo@correo.com",
              controller: correoController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            campoTexto(
              titulo: "Teléfono",
              hint: "Ej. 8888-8888",
              controller: telefonoController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 28),

            // ==================================================
            // SEGURIDAD
            // ==================================================

            const Text(
              "Seguridad",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF016630),
              ),
            ),

            const SizedBox(height: 15),

            campoTexto(
              titulo: "Contraseña",
              hint: "Crea una contraseña",
              controller: passwordController,
              icon: Icons.lock_outline,
              obscureText: ocultarPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  ocultarPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: const Color(0xFF016630),
                ),
                onPressed: registrando
                    ? null
                    : () {
                        setState(() {
                          ocultarPassword =
                              !ocultarPassword;
                        });
                      },
              ),
            ),

            const SizedBox(height: 16),

            campoTexto(
              titulo: "Confirmar contraseña",
              hint: "Repite tu contraseña",
              controller: confirmarPasswordController,
              icon: Icons.lock_outline,
              obscureText: ocultarConfirmarPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  ocultarConfirmarPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: const Color(0xFF016630),
                ),
                onPressed: registrando
                    ? null
                    : () {
                        setState(() {
                          ocultarConfirmarPassword =
                              !ocultarConfirmarPassword;
                        });
                      },
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // DOCUMENTACIÓN
            // ==================================================

            const Text(
              "Documentación",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF016630),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "Puedes agregar tus imágenes para completar tu perfil.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // FOTO DE PERFIL
            // ==================================================

            tarjetaFoto(
              titulo: "Foto de perfil",
              descripcion:
                  "Agrega una foto para identificar tu perfil.",
              icono: Icons.account_circle_outlined,
              onTap: seleccionarFotoPerfil,
              imagen: fotoPerfil,
              circular: true,
            ),

            const SizedBox(height: 14),

            // ==================================================
            // FOTO DEL CARNET
            // ==================================================

            tarjetaFoto(
              titulo: "Foto del carnet",
              descripcion:
                  "Selecciona una imagen de tu carnet.",
              icono: Icons.badge_outlined,
              onTap: seleccionarFotoCarnet,
              imagen: fotoCarnet,
            ),

            const SizedBox(height: 28),

            // ==================================================
            // TIPO DE USUARIA
            // ==================================================

            const Text(
              "Tipo de usuaria",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF016630),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "Selecciona cómo participarás en TasbaMairin.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 14),

// ==================================================
// PRODUCTORA
// ==================================================

GestureDetector(
  onTap: registrando
      ? null
      : () {
          setState(() {
            tipoUsuario = "Proveedor";
          });
        },

  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),

    decoration: BoxDecoration(
      color: tipoUsuario == "Proveedor"
          ? const Color(0xFF016630)
          : Colors.white,

      borderRadius: BorderRadius.circular(16),

      border: Border.all(
        color: const Color(0xFF016630),
      ),
    ),

    child: Row(
      children: [
        Icon(
          tipoUsuario == "Proveedor"
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: tipoUsuario == "Proveedor"
              ? Colors.white
              : const Color(0xFF016630),
        ),

        const SizedBox(width: 12),

        const Icon(
          Icons.agriculture_outlined,
          color: Color(0xFF016630),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            "Productora",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tipoUsuario == "Proveedor"
                  ? Colors.white
                  : const Color(0xFF016630),
            ),
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 12),

// ==================================================
// COMPRADORA
// ==================================================

GestureDetector(
  onTap: registrando
      ? null
      : () {
          setState(() {
            tipoUsuario = "Comprador";
          });
        },

  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),

    decoration: BoxDecoration(
      color: tipoUsuario == "Comprador"
          ? const Color(0xFF016630)
          : Colors.white,

      borderRadius: BorderRadius.circular(16),

      border: Border.all(
        color: const Color(0xFF016630),
      ),
    ),

    child: Row(
      children: [
        Icon(
          tipoUsuario == "Comprador"
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: tipoUsuario == "Comprador"
              ? Colors.white
              : const Color(0xFF016630),
        ),

        const SizedBox(width: 12),

        const Icon(
          Icons.shopping_basket_outlined,
          color: Color(0xFF016630),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            "Compradora",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tipoUsuario == "Comprador"
                  ? Colors.white
                  : const Color(0xFF016630),
            ),
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 30),

            // ==================================================
            // BOTÓN REGISTRARSE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF016630),

                  disabledBackgroundColor:
                      const Color(0xFF7A9E8A),

                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),

                onPressed: registrando
                    ? null
                    : registrarUsuario,

                child: registrando
                    ? const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),

                          SizedBox(width: 12),

                          Text(
                            "Creando cuenta...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Crear mi cuenta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // TEXTO FINAL
            // ==================================================

            Center(
              child: Text(
                "Al registrarte formarás parte de TasbaMairin.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}