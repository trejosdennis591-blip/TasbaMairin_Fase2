import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final actualController = TextEditingController();
  final nuevaController = TextEditingController();
  final confirmarController = TextEditingController();

  bool ocultarActual = true;
  bool ocultarNueva = true;
  bool ocultarConfirmar = true;

  // ==========================================================
  // CAMBIAR CONTRASEÑA
  // ==========================================================

  void cambiarContrasena() {
    final actual = actualController.text.trim();
    final nueva = nuevaController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (actual.isEmpty ||
        nueva.isEmpty ||
        confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Completa todos los campos.",
          ),
        ),
      );
      return;
    }

    if (nueva.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La nueva contraseña debe tener al menos 6 caracteres.",
          ),
        ),
      );
      return;
    }

    if (nueva != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Las contraseñas nuevas no coinciden.",
          ),
        ),
      );
      return;
    }

    // ========================================================
    // POR AHORA
    // ========================================================
    //
    // Aquí posteriormente conectaremos la base de datos
    // para cambiar realmente la contraseña.
    //

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "La contraseña está lista para ser actualizada.",
        ),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    actualController.dispose();
    nuevaController.dispose();
    confirmarController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        elevation: 0,

        title: const Text(
          "Cambiar contraseña",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ICONO
              // ==================================================

              Center(
                child: Container(
                  width: 80,
                  height: 80,

                  decoration: const BoxDecoration(
                    color: Color(0xFF016630),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.lock,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // TITULO
              // ==================================================

              const Center(
                child: Text(
                  "Actualizar contraseña",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF016630),
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Center(
                child: Text(
                  "Ingresa tu contraseña actual y crea una nueva.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // CONTRASEÑA ACTUAL
              // ==================================================

              TextField(
                controller: actualController,
                obscureText: ocultarActual,

                decoration: InputDecoration(
                  labelText: "Contraseña actual",

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarActual = !ocultarActual;
                      });
                    },

                    icon: Icon(
                      ocultarActual
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // NUEVA CONTRASEÑA
              // ==================================================

              TextField(
                controller: nuevaController,
                obscureText: ocultarNueva,

                decoration: InputDecoration(
                  labelText: "Nueva contraseña",

                  prefixIcon: const Icon(
                    Icons.lock,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarNueva = !ocultarNueva;
                      });
                    },

                    icon: Icon(
                      ocultarNueva
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "La contraseña debe tener al menos 6 caracteres.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // CONFIRMAR CONTRASEÑA
              // ==================================================

              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmar,

                decoration: InputDecoration(
                  labelText: "Confirmar nueva contraseña",

                  prefixIcon: const Icon(
                    Icons.lock,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarConfirmar =
                            !ocultarConfirmar;
                      });
                    },

                    icon: Icon(
                      ocultarConfirmar
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // BOTÓN
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: cambiarContrasena,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF016630),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: const Text(
                    "Cambiar contraseña",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}