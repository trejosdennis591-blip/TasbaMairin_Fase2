import 'package:flutter/material.dart';

import 'package:flutter_application_1/screen/login_screen.dart';
import 'package:flutter_application_1/screen/my_products_screen.dart';
import 'package:flutter_application_1/screen/edit_profile_screen.dart';
import 'package:flutter_application_1/screen/trade_requests_screen.dart';
import 'package:flutter_application_1/services/trade_request_service.dart';
import 'package:flutter_application_1/screen/settings_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool cargando = true;

  // ==========================================================
  // DATOS DEL USUARIO
  // ==========================================================

  String nombre = "Usuario";
  String apellido = "";
  String correo = "";
  String telefono = "";
  String tipoUsuario = "";

  String? fotoPerfil;

  // ==========================================================
  // ESTADÍSTICAS
  // ==========================================================

  int cantidadProductos = 0;
  int cantidadFavoritos = 0;
  int cantidadTrueques = 0;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  // ==========================================================
  // CARGAR PERFIL
  // ==========================================================

 Future<void> cargarPerfil() async {
  final prefs = await SharedPreferences.getInstance();

  int cantidadTruequesLocal = 0;

  try {
    final solicitudes =
        await TradeRequestService.obtenerSolicitudes();

    cantidadTruequesLocal = solicitudes.length;
  } catch (e) {
    print('No se pudieron cargar los trueques: $e');
  }

  if (!mounted) return;

  setState(() {
    nombre = prefs.getString('nombre') ?? "Usuario";
    apellido = prefs.getString('apellido') ?? "";
    correo = prefs.getString('correo') ?? "";
    telefono = prefs.getString('telefono') ?? "";

    tipoUsuario =
        prefs.getString('tipo_usuario') ?? "";

    fotoPerfil =
        prefs.getString('foto_perfil');

    print('========================');
    print('FOTO PERFIL GUARDADA:');
    print(fotoPerfil);
    print('========================');

    cantidadProductos = 0;
    cantidadFavoritos = 0;

    cantidadTrueques =
        cantidadTruequesLocal;

    cargando = false;
  });
}

  // ==========================================================
  // EDITAR PERFIL
  // ==========================================================

  Future<void> editarPerfil() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      setState(() {
        cargando = true;
      });

      await cargarPerfil();
    }
  }

  // ==========================================================
  // CERRAR SESIÓN
  // ==========================================================

  Future<void> cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Cerrar sesión",
          ),
          content: const Text(
            "¿Seguro que quieres cerrar tu sesión?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Cancelar",
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    // Borrar token y datos del usuario.
    await AuthService.logout();

    if (!mounted) return;

    // Volver al login y eliminar las pantallas anteriores.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
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
        centerTitle: true,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          "Mi Perfil",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // FOTO DE PERFIL
                  // ==================================================

                  CircleAvatar(
  radius: 60,
  backgroundColor: const Color(0xFF016630),

  backgroundImage: (fotoPerfil != null &&
          fotoPerfil!.isNotEmpty)
      ? NetworkImage(
          "http://192.168.1.25:3000$fotoPerfil",
        )
      : null,

  child: (fotoPerfil == null ||
          fotoPerfil!.isEmpty)
      ? const Icon(
          Icons.person,
          size: 60,
          color: Colors.white,
        )
      : null,
),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // NOMBRE
                  // ==================================================

                  Text(
                    "$nombre $apellido",
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF016630),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // CORREO
                  // ==================================================

                  if (correo.isNotEmpty)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Icon(
                          Icons.email,
                          color: Colors.grey,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Flexible(
                          child: Text(
                            correo,
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // TELÉFONO
                  // ==================================================

                  if (telefono.isNotEmpty)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.grey,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Text(
                          telefono,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // TIPO DE USUARIO
                  // ==================================================

                  if (tipoUsuario.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFD0872E),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Text(
                        tipoUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // ESTADÍSTICAS
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 15,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,

                      children: [
                        Column(
                          children: [
                            Text(
                              cantidadProductos.toString(),

                              style: const TextStyle(
                                fontSize: 24,
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
                              "Productos",
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              cantidadFavoritos.toString(),

                              style: const TextStyle(
                                fontSize: 24,
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
                              "Favoritos",
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              cantidadTrueques.toString(),

                              style: const TextStyle(
                                fontSize: 24,
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
                              "Trueques",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // EDITAR PERFIL
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF016630),

                        minimumSize:
                            const Size(0, 55),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: editarPerfil,

                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Editar Perfil",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ==================================================
                  // MIS PUBLICACIONES
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF016630),
                          width: 2,
                        ),

                        minimumSize:
                            const Size(0, 55),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MyProductsScreen(),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.inventory_2,
                        color: Color(0xFF016630),
                      ),

                      label: const Text(
                        "Mis publicaciones",

                        style: TextStyle(
                          color: Color(0xFF016630),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ==================================================
                  // SOLICITUDES DE TRUEQUE
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF016630),
                          width: 2,
                        ),

                        minimumSize:
                            const Size(0, 55),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const TradeRequestsScreen(),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.swap_horiz,
                        color: Color(0xFF016630),
                      ),

                      label: const Text(
                        "Solicitudes de Trueque",

                        style: TextStyle(
                          color: Color(0xFF016630),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ==================================================
                  // CONFIGURACIÓN
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFD0872E),
                          width: 2,
                        ),

                        minimumSize:
                            const Size(0, 55),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SettingsScreen(),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.settings,
                        color: Color(0xFFD0872E),
                      ),

                      label: const Text(
                        "Configuración",

                        style: TextStyle(
                          color: Color(0xFFD0872E),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ==================================================
                  // CERRAR SESIÓN
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,

                        minimumSize:
                            const Size(0, 55),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: cerrarSesion,

                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Cerrar sesión",

                        style: TextStyle(
                          color: Colors.white,
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