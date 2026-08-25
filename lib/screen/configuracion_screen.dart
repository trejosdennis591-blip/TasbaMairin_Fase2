import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() =>
      _ConfiguracionScreenState();
}

class _ConfiguracionScreenState
    extends State<ConfiguracionScreen> {
  bool notificacionesActivadas = true;

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
          // CUENTA
          // ====================================================

          const Text(
            "Cuenta",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF016630),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              children: [
                // ==================================================
                // EDITAR PERFIL
                // ==================================================

                ListTile(
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
                    ),
                  ),

                  subtitle: const Text(
                    "Modifica tu información personal",
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Editar perfil próximamente",
                        ),
                      ),
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // CAMBIAR CONTRASEÑA
                // ==================================================

                ListTile(
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
                    ),
                  ),

                  subtitle: const Text(
                    "Actualiza tu contraseña",
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Cambiar contraseña próximamente",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // PREFERENCIAS
          // ====================================================

          const Text(
            "Preferencias",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF016630),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              children: [
                // ==================================================
                // NOTIFICACIONES
                // ==================================================

                SwitchListTile(
                  value: notificacionesActivadas,

                  activeColor: const Color(0xFF016630),

                  onChanged: (valor) {
                    setState(() {
                      notificacionesActivadas = valor;
                    });
                  },

                  secondary: const CircleAvatar(
                    backgroundColor: Color(0xFF016630),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                  ),

                  title: const Text(
                    "Notificaciones",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Recibir notificaciones de la aplicación",
                  ),
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // PRIVACIDAD
                // ==================================================

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                    ),
                  ),

                  title: const Text(
                    "Privacidad y seguridad",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Administra tu privacidad",
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Privacidad próximamente",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // INFORMACIÓN
          // ====================================================

          const Text(
            "Información",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF016630),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF016630),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              ),

              title: const Text(
                "Acerca de TasbaMairin",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                "Información de la aplicación",
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "TasbaMairin",
                  applicationVersion: "1.0.0",
                  applicationLegalese:
                      "Aplicación de intercambio comunitario.",
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // ====================================================
          // CERRAR SESIÓN
          // ====================================================

          SizedBox(
            height: 52,

            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,

                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        "Cerrar sesión",
                      ),

                      content: const Text(
                        "¿Estás segura de que quieres cerrar sesión?",
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text(
                            "Cancelar",
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Cerrar sesión próximamente",
                                ),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF016630),
                          ),

                          child: const Text(
                            "Cerrar sesión",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },

              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),

              label: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}