import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_config.dart';

import 'package:flutter_application_1/screen/login_screen.dart';
import 'package:flutter_application_1/screen/my_products_screen.dart';
import 'package:flutter_application_1/screen/edit_profile_screen.dart';
import 'package:flutter_application_1/screen/trade_requests_screen.dart';
import 'package:flutter_application_1/services/trade_request_service.dart';
import 'package:flutter_application_1/screen/settings_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screen/my_reports_screen.dart';
import 'package:flutter_application_1/services/favorite_service.dart';
import 'package:flutter_application_1/services/product_service.dart';

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
String? fotoCarnet;


  // ==========================================================
  // ESTADÍSTICAS
  // ==========================================================

  int cantidadProductos = 0;
  int cantidadFavoritos = 0;
  int cantidadTrueques = 0;

  // ==========================================================
  // COLORES DEL PROYECTO
  // ==========================================================

  static const Color verde = Color(0xFF016630);
  static const Color naranja = Color(0xFFD0872E);
  static const Color fondo = Color(0xFFFFF8D6);

  // ==========================================================
  // INIT
  // ==========================================================

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
  int cantidadFavoritosLocal = 0;
  int cantidadProductosLocal = 0;

  try {
    final solicitudes =
        await TradeRequestService.obtenerSolicitudes();

    cantidadTruequesLocal = solicitudes.length;
  } catch (e) {
    print('No se pudieron cargar los trueques: $e');
  }

  // ==========================================================
  // CARGAR FAVORITOS
  // ==========================================================

  try {
    cantidadFavoritosLocal =
        await FavoriteService.cantidadFavoritos();
  } catch (e) {
    print('No se pudieron cargar los favoritos: $e');
  }

  // ==========================================================
  // CARGAR PRODUCTOS DEL PROVEEDOR
  // ==========================================================

  if (prefs.getString('tipo_usuario')?.toLowerCase() ==
    "proveedor") {
  try {
    final productos =
        await ProductService.obtenerMisProductos();

    print(
      "PERFIL - Total productos: ${productos.length}",
    );

    cantidadProductosLocal = productos.length;
  } catch (e) {
    print(
      'No se pudieron cargar los productos: $e',
    );
  }
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

    fotoCarnet =
    prefs.getString('foto_carnet');

    cantidadProductos = cantidadProductosLocal;
    cantidadFavoritos = cantidadFavoritosLocal;
    cantidadTrueques = cantidadTruequesLocal;

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Cerrar sesión",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: verde,
            ),
          ),
          content: const Text(
            "¿Seguro que quieres cerrar tu sesión?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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

    if (confirmar != true) {
      return;
    }

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // BOTÓN DE OPCIÓN
  // ==========================================================

  Widget opcionPerfil({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
    Color color = verde,
    String? subtitulo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 15),

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
                          color: Color(0xFF222222),
                        ),
                      ),

                      if (subtitulo != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitulo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: verde,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Mi Perfil",
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

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: verde,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ==================================================
                  // CABECERA DEL PERFIL
                  // ==================================================

                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: verde,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        5,
                        20,
                        30,
                      ),
                      child: Column(
                        children: [
                          // ========================================
                          // FOTO
                          // ========================================

                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.20),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor:
                                  const Color(0xFFE8F5E9),

                              backgroundImage:
                                  (fotoPerfil != null &&
                                          fotoPerfil!.isNotEmpty)
                                      ? NetworkImage(
                                          '${ApiConfig.serverUrl}$fotoPerfil',
                                        )
                                      : null,

                              child:
                                  (fotoPerfil == null ||
                                          fotoPerfil!.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 58,
                                          color: verde,
                                        )
                                      : null,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // ========================================
                          // NOMBRE
                          // ========================================

                          Text(
                            "$nombre $apellido",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 7),

                          // ========================================
                          // CORREO
                          // ========================================

                          if (correo.isNotEmpty)
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 17,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    correo,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 12),

                          // ========================================
                          // TIPO DE USUARIO
                          // ========================================

                          if (tipoUsuario.isNotEmpty)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: naranja,
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                              child: Text(
                                tipoUsuario,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // CONTENIDO
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                       // ============================================================
// ESTADÍSTICAS SEGÚN TIPO DE USUARIO
// ============================================================

Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    vertical: 20,
    horizontal: 10,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      if (tipoUsuario.toLowerCase() == "comprador") ...[
        // FAVORITOS
        _estadistica(
          cantidadFavoritos,
          "Favoritos",
          Icons.favorite_border,
        ),

        _separador(),

        // TRUEQUES
        _estadistica(
          cantidadTrueques,
          "Trueques",
          Icons.swap_horiz,
        ),
      ] else ...[
        // PRODUCTOS
        _estadistica(
          cantidadProductos,
          "Productos",
          Icons.inventory_2_outlined,
        ),

        _separador(),

        // TRUEQUES
        _estadistica(
          cantidadTrueques,
          "Trueques",
          Icons.swap_horiz,
        ),
      ],
    ],
  ),
),

const SizedBox(height: 28),

                        // ============================================
                        // SECCIÓN
                        // ============================================

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Mi cuenta",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ============================================
                        // EDITAR PERFIL
                        // ============================================

                        opcionPerfil(
                          icono: Icons.person_outline,
                          titulo: "Editar perfil",
                          subtitulo:
                              "Actualiza tus datos personales",
                          onTap: editarPerfil,
                        ),

                        if (fotoCarnet != null &&
    fotoCarnet!.isNotEmpty)
  opcionPerfil(
    icono: Icons.badge_outlined,
    titulo: "Ver carnet",
    subtitulo:
        "Consultar documento de identificación",
    onTap: () {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: verde,
                title: const Text(
                  "Carnet",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              InteractiveViewer(
                child: Image.network(
                  '${ApiConfig.serverUrl}$fotoCarnet',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),

                        // ============================================
                        // MIS PUBLICACIONES
                        // SOLO PARA PROVEEDORES
                        // ============================================

if (tipoUsuario.toLowerCase() == "proveedor")
  opcionPerfil(
    icono: Icons.inventory_2_outlined,
    titulo: "Mis publicaciones",
    subtitulo:
        "Administra tus productos",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MyProductsScreen(),
        ),
      );
    },
  ),

                        // ============================================
                        // TRUEQUES
                        // ============================================

                        opcionPerfil(
                          icono: Icons.swap_horiz,
                          titulo: "Solicitudes de trueque",
                          subtitulo:
                              "Revisa tus solicitudes",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TradeRequestsScreen(),
                              ),
                            );
                          },
                        ),

                        // ============================================
                        // REPORTES
                        // ============================================

                        opcionPerfil(
                          icono: Icons.flag_outlined,
                          titulo: "Mis reportes",
                          subtitulo:
                              "Consulta tus reportes realizados",
                          color: Colors.red,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyReportsScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // ============================================
                        // CONFIGURACIÓN
                        // ============================================

                        opcionPerfil(
                          icono: Icons.settings_outlined,
                          titulo: "Configuración",
                          subtitulo:
                              "Preferencias de la aplicación",
                          color: naranja,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SettingsScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // ============================================
                        // CERRAR SESIÓN
                        // ============================================

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: cerrarSesion,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Cerrar sesión",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ============================================
                        // NOMBRE DEL PROYECTO
                        // ============================================

                        const Text(
                          "TasbaMairin",
                          style: TextStyle(
                            color: verde,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Intercambia • Comparte • Conecta",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // WIDGET ESTADÍSTICA
  // ==========================================================

  Widget _estadistica(
    int cantidad,
    String titulo,
    IconData icono,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icono,
            color: verde,
            size: 24,
          ),

          const SizedBox(height: 7),

          Text(
            cantidad.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: verde,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEPARADOR DE ESTADÍSTICAS
  // ==========================================================

  Widget _separador() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.grey.shade200,
    );
  }
}