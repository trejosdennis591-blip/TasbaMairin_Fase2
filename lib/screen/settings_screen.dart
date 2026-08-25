import 'package:flutter/material.dart';

import 'package:flutter_application_1/screen/edit_profile_screen.dart';
import 'package:flutter_application_1/screen/change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ==========================================================
  // EDITAR PERFIL
  // ==========================================================

  void editarPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  // ==========================================================
  // CAMBIAR CONTRASEÑA
  // ==========================================================

  void cambiarContrasena(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  }

  // ==========================================================
  // PRIVACIDAD Y SEGURIDAD
  // ==========================================================

  void privacidadSeguridad(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.security,
                color: Color(0xFF016630),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Privacidad y seguridad",
                ),
              ),
            ],
          ),
          content: const Text(
            "Aquí podrás administrar las opciones "
            "relacionadas con la privacidad y seguridad "
            "de tu cuenta.\n\n"
            "Estas opciones podrán ampliarse posteriormente "
            "cuando la aplicación tenga conexión con la "
            "base de datos.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cerrar",
                style: TextStyle(
                  color: Color(0xFF016630),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // INFORMACIÓN
  // ==========================================================

  void mostrarInformacion(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "TasbaMairin",
      applicationVersion: "1.0",
      applicationLegalese:
          "Aplicación de intercambio comunitario.",
    );
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
          "Configuración",
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

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ====================================================
          // EDITAR PERFIL
          // ====================================================

          Card(
            color: Colors.white,
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),

              leading: const CircleAvatar(
                backgroundColor: Color(0xFF016630),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),

              title: const Text(
                "Editar perfil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              subtitle: const Text(
                "Modifica tu información personal",
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                editarPerfil(context);
              },
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ====================================================
          // CAMBIAR CONTRASEÑA
          // ====================================================

          Card(
            color: Colors.white,
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),

              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD0872E),
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),

              title: const Text(
                "Cambiar contraseña",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              subtitle: const Text(
                "Actualiza tu contraseña",
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                cambiarContrasena(context);
              },
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ====================================================
          // PRIVACIDAD Y SEGURIDAD
          // ====================================================

          Card(
            color: Colors.white,
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),

              leading: const CircleAvatar(
                backgroundColor: Color(0xFF016630),
                child: Icon(
                  Icons.security,
                  color: Colors.white,
                ),
              ),

              title: const Text(
                "Privacidad y seguridad",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              subtitle: const Text(
                "Administra tus opciones de seguridad",
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                privacidadSeguridad(context);
              },
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ====================================================
          // INFORMACIÓN
          // ====================================================

          Card(
            color: Colors.white,
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),

              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade700,
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
              ),

              title: const Text(
                "Información",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              subtitle: const Text(
                "Información de la aplicación",
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                mostrarInformacion(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}