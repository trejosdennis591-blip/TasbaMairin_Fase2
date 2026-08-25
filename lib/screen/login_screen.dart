import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/home_screen.dart';
import 'package:flutter_application_1/screen/register_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarContrasena = true;

  // ==========================================================
  // INICIAR SESIÓN
  // ==========================================================

Future<void> iniciarSesion() async {
  final correo = emailController.text.trim();
  final contrasena = passwordController.text;

  if (correo.isEmpty || contrasena.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingresa tu correo y contraseña'),
      ),
    );
    return;
  }

  try {
   final respuesta = await AuthService.login(
  correo,
  contrasena,
);

final prefs = await SharedPreferences.getInstance();

await prefs.setString(
  'token',
  respuesta['token'],
);

final usuario = respuesta['usuario'];

await prefs.setString(
  'nombre',
  usuario['Nombre'] ?? '',
);

await prefs.setString(
  'apellido',
  usuario['Apellido'] ?? '',
);

await prefs.setString(
  'correo',
  usuario['Correo'] ?? '',
);

await prefs.setString(
  'telefono',
  usuario['Telefono'] ?? '',
);

await prefs.setString(
  'tipo_usuario',
  usuario['TipoUsuario'] ?? '',
);

await prefs.setString(
  'token',
  respuesta['token'],
);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ====================================================
          // FONDO
          // ====================================================

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/fondo_login.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ====================================================
          // OSCURECER FONDO
          // ====================================================

          Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),

          // ====================================================
          // CONTENIDO
          // ====================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 10,
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ======================================
                        // LOGO
                        // ======================================

                        Image.asset(
                          "assets/images/logo.jpeg",
                          width: 120,
                        ),

                        const SizedBox(height: 20),

                        // ======================================
                        // TÍTULO
                        // ======================================

                        const Text(
                          "Bienvenido",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF016630),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Inicia sesión para continuar",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ======================================
                        // CORREO
                        // ======================================

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Correo electrónico",
                            prefixIcon: const Icon(
                              Icons.email,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ======================================
                        // CONTRASEÑA
                        // ======================================

                        TextField(
                          controller: passwordController,
                          obscureText: ocultarContrasena,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: const Icon(
                              Icons.lock,
                            ),

                            suffixIcon: IconButton(
                            icon: Icon(
                              ocultarContrasena
                              ? Icons.visibility
                              : Icons.visibility_off,
                            ),
                              onPressed: () {
                             setState(() {
                              ocultarContrasena = !ocultarContrasena;
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

                        const SizedBox(height: 30),

                        // ======================================
                        // BOTÓN INICIAR SESIÓN
                        // ======================================

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF016630),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ======================================
                        // REGISTRO
                        // ======================================

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "¿No tienes una cuenta? ",
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Registrarse",
                                style: TextStyle(
                                  color: Color(0xFFD0872E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}