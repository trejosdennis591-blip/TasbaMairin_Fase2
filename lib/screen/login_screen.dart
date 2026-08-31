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
      backgroundColor: const Color(0xFFEAF3D8),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // FONDO BOSCOSO CLARO
            // ==================================================

            Positioned.fill(
              child: CustomPaint(
                painter: _BosquePainter(),
              ),
            ),

            // Luz superior
            Positioned(
              top: -100,
              left: -80,
              right: -80,
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.90),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // HOJAS DECORATIVAS
            // ==================================================

            Positioned(
              top: -15,
              left: -20,
              child: _hojas(
                size: 115,
                opacity: 0.55,
                flip: false,
              ),
            ),

            Positioned(
              top: -20,
              right: -15,
              child: _hojas(
                size: 125,
                opacity: 0.50,
                flip: true,
              ),
            ),

            Positioned(
              bottom: -10,
              left: -20,
              child: _hojas(
                size: 145,
                opacity: 0.60,
                flip: true,
              ),
            ),

            Positioned(
              bottom: -15,
              right: -25,
              child: _hojas(
                size: 150,
                opacity: 0.60,
                flip: false,
              ),
            ),

            // ==================================================
            // CONTENIDO
            // ==================================================

            Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  22,
                  28,
                  22,
                  28,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // LOGO GRANDE - RECTANGULAR
                    // ==================================================

                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBEF)
                            .withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF4E783B)
                              .withValues(alpha: 0.65),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF315B32)
                                .withValues(alpha: 0.18),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          height: 230,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // FORMULARIO
                    // ==================================================

                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                      ),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFEF5)
                            .withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF789C5D)
                              .withValues(alpha: 0.55),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF315B32)
                                .withValues(alpha: 0.15),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // CORREO
                          _campoLogin(
                            controller: emailController,
                            hintText: 'Correo electrónico',
                            icon: Icons.mail_outline_rounded,
                            keyboardType:
                                TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 14),

                          // CONTRASEÑA
                          _campoLogin(
                            controller: passwordController,
                            hintText: 'Contraseña',
                            icon: Icons.lock_outline_rounded,
                            obscureText: ocultarContrasena,
                            suffixIcon: IconButton(
                              tooltip: ocultarContrasena
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              icon: Icon(
                                ocultarContrasena
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF3E6935),
                              ),
                              onPressed: () {
                                setState(() {
                                  ocultarContrasena =
                                      !ocultarContrasena;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // BOTÓN INICIAR SESIÓN
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: iniciarSesion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF4E873B),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: const Color(0xFF315B32)
                                    .withValues(alpha: 0.30),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // SEPARADOR
                          // ==================================================

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF6D875C)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE8F0D4),
                                    border: Border.all(
                                      color: const Color(0xFF6C8E55),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.eco_rounded,
                                      size: 15,
                                      color: Color(0xFF4E783B),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF6D875C)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // REGISTRO
                          // ==================================================

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment:
                                WrapCrossAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta?',
                                style: TextStyle(
                                  color: Color(0xFF40513A),
                                  fontSize: 14,
                                ),
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
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFF3D7132),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // FRASE INFERIOR
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          size: 18,
                          color: Color(0xFF47733A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Una comunidad que comparte',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF40513A)
                                .withValues(alpha: 0.90),
                          ),
                        ),
                      ],
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

  // ==========================================================
  // CAMPOS DEL LOGIN
  // ==========================================================

  Widget _campoLogin({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction:
          obscureText
              ? TextInputAction.done
              : TextInputAction.next,
      style: const TextStyle(
        color: Color(0xFF263726),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF788071),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4E783B),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF4F2E4),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFF82A961),
            width: 2,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HOJAS DECORATIVAS
  // ==========================================================

  Widget _hojas({
    required double size,
    required double opacity,
    required bool flip,
  }) {
    final contenido = Opacity(
      opacity: opacity,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              left: size * 0.20,
              top: size * 0.20,
              child: Transform.rotate(
                angle: -0.55,
                child: Icon(
                  Icons.eco_rounded,
                  size: size * 0.58,
                  color: const Color(0xFF70964C),
                ),
              ),
            ),
            Positioned(
              left: size * 0.45,
              top: size * 0.05,
              child: Transform.rotate(
                angle: 0.35,
                child: Icon(
                  Icons.eco_rounded,
                  size: size * 0.48,
                  color: const Color(0xFF8BAE5F),
                ),
              ),
            ),
            Positioned(
              left: size * 0.05,
              top: size * 0.45,
              child: Transform.rotate(
                angle: -0.9,
                child: Icon(
                  Icons.eco_rounded,
                  size: size * 0.42,
                  color: const Color(0xFF5D873F),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(
          flip ? -1.0 : 1.0,
          1.0,
        ),
      child: contenido,
    );
  }
}

// ============================================================
// FONDO DE BOSQUE
// ============================================================

class _BosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ========================================================
    // CIELO
    // ========================================================

    final cielo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFCEF),
          Color(0xFFEAF2D5),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      cielo,
    );

    // ========================================================
    // MONTAÑA LEJANA
    // ========================================================

    final montanaLejana = Paint()
      ..color = const Color(0xFFD5E3B9);

    final path1 = Path();

    path1.moveTo(0, size.height * 0.48);
    path1.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.36,
      size.width * 0.38,
      size.height * 0.47,
    );
    path1.quadraticBezierTo(
      size.width * 0.58,
      size.height * 0.31,
      size.width * 0.78,
      size.height * 0.45,
    );
    path1.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.37,
      size.width,
      size.height * 0.46,
    );

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, montanaLejana);

    // ========================================================
    // MONTAÑA PRINCIPAL
    // ========================================================

    final montana = Paint()
      ..color = const Color(0xFFB9CF91);

    final path2 = Path();

    path2.moveTo(0, size.height * 0.58);
    path2.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.45,
      size.width * 0.40,
      size.height * 0.57,
    );
    path2.quadraticBezierTo(
      size.width * 0.60,
      size.height * 0.43,
      size.width * 0.78,
      size.height * 0.56,
    );
    path2.quadraticBezierTo(
      size.width * 0.91,
      size.height * 0.48,
      size.width,
      size.height * 0.55,
    );

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, montana);

    // ========================================================
    // SUELO
    // ========================================================

    final suelo = Paint()
      ..color = const Color(0xFF9FBC78);

    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.25,
        size.height * 0.62,
        size.width * 1.5,
        size.height * 0.70,
      ),
      suelo,
    );

    // ========================================================
    // PINOS
    // ========================================================

    _pino(
      canvas,
      Offset(size.width * 0.08, size.height * 0.58),
      75,
      const Color(0xFF70965B),
    );

    _pino(
      canvas,
      Offset(size.width * 0.18, size.height * 0.62),
      95,
      const Color(0xFF5E8750),
    );

    _pino(
      canvas,
      Offset(size.width * 0.86, size.height * 0.59),
      90,
      const Color(0xFF668D52),
    );

    _pino(
      canvas,
      Offset(size.width * 0.95, size.height * 0.63),
      70,
      const Color(0xFF527C47),
    );

    _pino(
      canvas,
      Offset(size.width * 0.30, size.height * 0.67),
      48,
      const Color(0xFF82A866),
    );

    _pino(
      canvas,
      Offset(size.width * 0.70, size.height * 0.67),
      52,
      const Color(0xFF7C9F60),
    );
  }

  void _pino(
    Canvas canvas,
    Offset base,
    double altura,
    Color color,
  ) {
    final paint = Paint()..color = color;

    final ancho = altura * 0.65;

    final path = Path();

    path.moveTo(base.dx, base.dy - altura);

    path.lineTo(
      base.dx - ancho * 0.50,
      base.dy - altura * 0.35,
    );

    path.lineTo(
      base.dx - ancho * 0.27,
      base.dy - altura * 0.35,
    );

    path.lineTo(
      base.dx - ancho * 0.65,
      base.dy - altura * 0.05,
    );

    path.lineTo(
      base.dx + ancho * 0.65,
      base.dy - altura * 0.05,
    );

    path.lineTo(
      base.dx + ancho * 0.27,
      base.dy - altura * 0.35,
    );

    path.lineTo(
      base.dx + ancho * 0.50,
      base.dy - altura * 0.35,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}