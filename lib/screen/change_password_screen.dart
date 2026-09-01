import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

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

  bool cargando = false;

  // ==========================================================
  // CAMBIAR CONTRASEÑA
  // ==========================================================

  Future<void> cambiarContrasena() async {
    final actual = actualController.text.trim();
    final nueva = nuevaController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (actual.isEmpty ||
        nueva.isEmpty ||
        confirmar.isEmpty) {
      mostrarMensaje(
        "Completa todos los campos.",
      );
      return;
    }

    if (nueva.length < 6) {
      mostrarMensaje(
        "La nueva contraseña debe tener al menos 6 caracteres.",
      );
      return;
    }

    if (nueva != confirmar) {
      mostrarMensaje(
        "Las contraseñas nuevas no coinciden.",
      );
      return;
    }

    if (cargando) return;

    setState(() {
      cargando = true;
    });

    try {
      // ======================================================
      // OBTENER TOKEN
      // ======================================================

      // IMPORTANTE:
      // Cambia esta parte por la forma en que tu app guarda
      // actualmente el token después del login.
      //
      // Si ya tienes un AuthService/Storage para el token,
      // aquí debemos usar ese mismo.

      final token = await obtenerToken();

      if (token == null || token.isEmpty) {
        mostrarMensaje(
          "No hay una sesión activa. Inicia sesión nuevamente.",
        );

        return;
      }

      // ======================================================
      // PETICIÓN AL BACKEND
      // ======================================================

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/usuarios/cambiar-contrasena',
      );

      print("CAMBIAR CONTRASEÑA URL: $url");

      final respuesta = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'contrasenaActual': actual,
          'nuevaContrasena': nueva,
        }),
      );

      print(
        "CAMBIAR CONTRASEÑA STATUS: ${respuesta.statusCode}",
      );

      print(
        "CAMBIAR CONTRASEÑA RESPUESTA: ${respuesta.body}",
      );

      // ======================================================
      // RESPUESTA
      // ======================================================

      Map<String, dynamic> datos = {};

      try {
        datos = jsonDecode(respuesta.body);
      } catch (_) {}

      if (respuesta.statusCode >= 200 &&
          respuesta.statusCode < 300) {
        mostrarMensaje(
          datos['mensaje'] ??
              "Contraseña actualizada correctamente.",
        );

        actualController.clear();
        nuevaController.clear();
        confirmarController.clear();

      } else {
        mostrarMensaje(
          datos['mensaje'] ??
              "No se pudo cambiar la contraseña.",
        );
      }

    } catch (error) {
      print(
        "ERROR CAMBIANDO CONTRASEÑA APP: $error",
      );

      mostrarMensaje(
        "No se pudo conectar con el servidor.",
      );

    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  // ==========================================================
  // OBTENER TOKEN
  // ==========================================================

  Future<String?> obtenerToken() async {
    /*
      AQUÍ HAY QUE USAR EL MISMO LUGAR DONDE TU APP GUARDA
      EL TOKEN DEL LOGIN.

      Por ahora intentamos obtenerlo desde SharedPreferences.
    */

    // Esta función se completará según cómo tengas guardado
    // actualmente el token en tu proyecto.

    return null;
  }

  // ==========================================================
  // MENSAJE
  // ==========================================================

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

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

              const SizedBox(height: 20),

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

              const SizedBox(height: 8),

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

              const SizedBox(height: 30),

              // ==================================================
              // CONTRASEÑA ACTUAL
              // ==================================================

              TextField(
                controller: actualController,
                obscureText: ocultarActual,

                enabled: !cargando,

                decoration: InputDecoration(
                  labelText: "Contraseña actual",

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon: IconButton(
                    onPressed: cargando
                        ? null
                        : () {
                            setState(() {
                              ocultarActual =
                                  !ocultarActual;
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
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // NUEVA CONTRASEÑA
              // ==================================================

              TextField(
                controller: nuevaController,
                obscureText: ocultarNueva,

                enabled: !cargando,

                decoration: InputDecoration(
                  labelText: "Nueva contraseña",

                  prefixIcon: const Icon(
                    Icons.lock,
                  ),

                  suffixIcon: IconButton(
                    onPressed: cargando
                        ? null
                        : () {
                            setState(() {
                              ocultarNueva =
                                  !ocultarNueva;
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
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "La contraseña debe tener al menos 6 caracteres.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CONFIRMAR
              // ==================================================

              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmar,

                enabled: !cargando,

                decoration: InputDecoration(
                  labelText:
                      "Confirmar nueva contraseña",

                  prefixIcon: const Icon(
                    Icons.lock,
                  ),

                  suffixIcon: IconButton(
                    onPressed: cargando
                        ? null
                        : () {
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
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // BOTÓN
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed:
                      cargando
                          ? null
                          : cambiarContrasena,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF016630),

                    disabledBackgroundColor:
                        Colors.grey,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Cambiar contraseña",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
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