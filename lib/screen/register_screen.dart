import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';

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
  
  bool ocultarPassword = true;
 bool ocultarConfirmarPassword = true;

  // ==========================================================
  // TIPO DE USUARIO
  // ==========================================================

  String tipoUsuario = "";

  // ==========================================================
  // IMÁGENES
  // ==========================================================

  File? fotoPerfil;
  File? fotoCarnet;

  final ImagePicker picker = ImagePicker();

  // ==========================================================
  // REGISTRAR USUARIO
  // ==========================================================

  Future<void> registrarUsuario() async {
    if (passwordController.text !=
        confirmarPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Las contraseñas no coinciden",
          ),
        ),
      );

      return;
    }

    if (tipoUsuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Seleccione el tipo de usuario",
          ),
        ),
      );

      return;
    }

    if (nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        telefonoController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Complete todos los campos",
          ),
        ),
      );

      return;
    }

    try {
  final respuesta = await AuthService.register(
    nombre: nombreController.text.trim(),
    apellido: apellidoController.text.trim(),
    telefono: telefonoController.text.trim(),
    correo: correoController.text.trim(),
    contrasena: passwordController.text.trim(),
    tipoUsuario: tipoUsuario,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.green,
      content: Text(respuesta['mensaje']),
    ),
  );

  if (!mounted) return;

  Navigator.pop(context);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Text(e.toString()),
    ),
  );
 }
}

  // ==========================================================
  // FOTO PERFIL
  // ==========================================================

  Future<void> seleccionarFotoPerfil() async {
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagen != null) {
      setState(() {
        fotoPerfil = File(imagen.path);
      });
    }
  }

  // ==========================================================
  // FOTO CARNET
  // ==========================================================

  Future<void> seleccionarFotoCarnet() async {
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagen != null) {
      setState(() {
        fotoCarnet = File(imagen.path);
      });
    }
  }

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

    appBar: AppBar(
      backgroundColor: const Color(0xFF016630),
      title: const Text(
        "Registro",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "Crear Cuenta",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF016630),
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // NOMBRE
          // ==================================================

          TextField(
            controller: nombreController,
            decoration: InputDecoration(
              labelText: "Nombre",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // APELLIDO
          // ==================================================

          TextField(
            controller: apellidoController,
            decoration: InputDecoration(
              labelText: "Apellido",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // CORREO
          // ==================================================

          TextField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Correo electrónico",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // TELÉFONO
          // ==================================================

          TextField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Teléfono",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // CONTRASEÑA
          // ==================================================

TextField(
  controller: passwordController,
  obscureText: ocultarPassword,
  decoration: InputDecoration(
    labelText: "Contraseña",

    suffixIcon: IconButton(
      icon: Icon(
        ocultarPassword
            ? Icons.visibility
            : Icons.visibility_off,
      ),
      onPressed: () {
        setState(() {
          ocultarPassword = !ocultarPassword;
        });
      },
    ),

    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
),

          const SizedBox(height: 15),

          // ==================================================
          // CONFIRMAR CONTRASEÑA
          // ==================================================

         TextField(
  controller: confirmarPasswordController,
  obscureText: ocultarConfirmarPassword,
  decoration: InputDecoration(
    labelText: "Confirmar Contraseña",

    suffixIcon: IconButton(
      icon: Icon(
        ocultarConfirmarPassword
            ? Icons.visibility
            : Icons.visibility_off,
      ),
      onPressed: () {
        setState(() {
          ocultarConfirmarPassword =
              !ocultarConfirmarPassword;
        });
      },
    ),

    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
),

          const SizedBox(height: 25),

          // ==================================================
          // FOTO PERFIL
          // ==================================================

          if (fotoPerfil != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(fotoPerfil!),
            ),

          if (fotoPerfil != null)
            const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: seleccionarFotoPerfil,
              icon: const Icon(Icons.photo_camera),
              label: const Text(
                "Agregar foto de perfil",
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // FOTO CARNET
          // ==================================================

          if (fotoCarnet != null)
            Image.file(
              fotoCarnet!,
              height: 120,
            ),

          if (fotoCarnet != null)
            const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: seleccionarFotoCarnet,
              icon: const Icon(Icons.badge),
              label: const Text(
                "Agregar foto del carnet",
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Seleccione el tipo de usuario",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          RadioListTile<String>(
            title: const Text("Proveedor"),
            value: "Proveedor",
            groupValue: tipoUsuario,
            onChanged: (value) {
              setState(() {
                tipoUsuario = value!;
              });
            },
          ),

          RadioListTile<String>(
            title: const Text("Comprador"),
            value: "Comprador",
            groupValue: tipoUsuario,
            onChanged: (value) {
              setState(() {
                tipoUsuario = value!;
              });
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF016630),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: registrarUsuario,
              child: const Text(
                "Registrarse",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
}