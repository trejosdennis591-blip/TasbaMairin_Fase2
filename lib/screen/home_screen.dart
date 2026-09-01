import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/data/products_data.dart';

import 'package:flutter_application_1/screen/favorites_screen.dart';
import 'package:flutter_application_1/screen/messages_screen.dart';
import 'package:flutter_application_1/screen/profile_screen.dart';
import 'package:flutter_application_1/screen/publish_product_screen.dart';
import 'package:flutter_application_1/screen/search_screen.dart';
import 'package:flutter_application_1/screen/category_products_screen.dart';

import 'package:flutter_application_1/widgets/category_card.dart';
import 'package:flutter_application_1/widgets/product_card.dart';
import '../widgets/ad_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool cargandoProductos = true;

  // ============================================================
  // TIPO DE USUARIO
  // ============================================================

  String tipoUsuario = '';
  String nombreUsuarioActual = "Usuario";

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    cargarTipoUsuario();
    cargarProductos();
  }

  // ============================================================
  // CARGAR TIPO DE USUARIO
  // ============================================================

  Future<void> cargarTipoUsuario() async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    final tipo =
    prefs.getString('tipo_usuario');

    setState(() {
      tipoUsuario =
          prefs.getString('tipo_usuario') ?? '';
    });
  }

  // ============================================================
  // CARGAR PRODUCTOS
  // ============================================================

  Future<void> cargarProductos() async {
    setState(() {
      cargandoProductos = true;
    });

    try {
      final productos =
          await ProductService.listarProductos();

      productosRecientes.clear();

      productosRecientes.addAll(productos);

      debugPrint(
        'PRODUCTOS CARGADOS: ${productosRecientes.length}',
      );

      for (final p in productosRecientes) {
        debugPrint(
          '${p.id} - ${p.nombre}',
        );
      }
    } catch (e) {
      debugPrint(
        'Error cargando productos: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      cargandoProductos = false;
    });
  }

  // ============================================================
  // COLOR PRINCIPAL
  // ============================================================

  static const Color verde =
      Color(0xFF016630);

  static const Color fondo =
      Color(0xFFFFF4B8);

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
        automaticallyImplyLeading: false,

        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "TasbaMairin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 1),

            Text(
              "Nuestra comunidad",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),

        actions: [

          // ====================================================
          // ACTUALIZAR
          // ====================================================

          IconButton(
            onPressed: cargandoProductos
                ? null
                : cargarProductos,

            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
          ),

          // ====================================================
          // NOTIFICACIONES
          // ====================================================

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "No tienes notificaciones nuevas.",
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: cargarProductos,

        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            100,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ==================================================
              // BIENVENIDA
              // ==================================================

              const Text(
                "¡Bienvenida!",
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: verde,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Encuentra productos de tu comunidad",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // BANNER HUERTO VERDE / ANUNCIO
              // ==================================================

              Container(
                width: double.infinity,
                height: 175,
                decoration: BoxDecoration(
                  color: verde,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -35,
                      top: -35,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      right: 25,
                      bottom: -55,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.eco_rounded,
                                      color: Colors.white,
                                      size: 29,
                                    ),
                                    SizedBox(width: 9),
                                    Text(
                                      "Huerto Verde",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Productos frescos de nuestra comunidad",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 11),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      "Intercambia y comparte",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_florist_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // BUSCADOR
              // ==================================================

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SearchScreen(),
                    ),
                  );
                },

                child: Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 15,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(18),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.06),
                        blurRadius: 8,
                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: const Row(
                    children: [

                      Icon(
                        Icons.search_rounded,
                        color: verde,
                        size: 25,
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "¿Qué estás buscando?",
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black38,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const AdBanner(),

              // ==================================================
              // CATEGORÍAS
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: const [

                  Text(
                    "Categorías",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: verde,
                    ),
                  ),

                  Text(
                    "Ver todas",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      color: verde,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 135,

                child: ListView(
                  scrollDirection:
                      Axis.horizontal,

                  children: [

                    // ==================================================
                    // AGRÍCOLA
                    // ==================================================

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CategoryProductsScreen(
                              categoria:
                                  "Agrícola",
                            ),
                          ),
                        );
                      },

                      child:
                          const CategoryCard(
                        imagen:
                            "assets/images/agricola.jpg",
                        texto: "Agrícola",
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ==================================================
                    // ARTESANÍAS
                    // ==================================================

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CategoryProductsScreen(
                              categoria:
                                  "Artesanías",
                            ),
                          ),
                        );
                      },

                      child:
                          const CategoryCard(
                        imagen:
                            "assets/images/artesanias.jpg",
                        texto: "Artesanías",
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ==================================================
                    // PLANTAS
                    // ==================================================

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CategoryProductsScreen(
                              categoria:
                                  "Plantas",
                            ),
                          ),
                        );
                      },

                      child:
                          const CategoryCard(
                        imagen:
                            "assets/images/plantas.jpg",
                        texto: "Plantas",
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ==================================================
                    // ALIMENTOS
                    // ==================================================

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CategoryProductsScreen(
                              categoria:
                                  "Alimentos",
                            ),
                          ),
                        );
                      },

                      child:
                          const CategoryCard(
                        imagen:
                            "assets/images/alimentos.jpg",
                        texto: "Alimentos",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PRODUCTOS DESTACADOS
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: const [

                  Text(
                    "Productos destacados",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: verde,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ...productosDestacados.map(
                (producto) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),

                  child: ProductCard(
                    producto: producto,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // PRODUCTOS RECIENTES
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: const [

                  Expanded(
                    child: Text(
                      "Publicados recientemente",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color: verde,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // CARGANDO
              // ==================================================

              if (cargandoProductos)

                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(25),

                    child:
                        CircularProgressIndicator(
                      color: verde,
                    ),
                  ),
                )

              // ==================================================
              // SIN PRODUCTOS
              // ==================================================

              else if (
                productosRecientes.isEmpty
              )

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(25),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: const Column(
                    children: [

                      Icon(
                        Icons.inventory_2_outlined,
                        size: 45,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Todavía no hay productos publicados.",
                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )

              // ==================================================
              // PRODUCTOS
              // ==================================================

              else

                ...productosRecientes.map(
                  (producto) =>
                      Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),

                    child: ProductCard(
                      producto: producto,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTÓN PUBLICAR
      // SOLO PARA PROVEEDORES
      // ========================================================

      floatingActionButton:
          tipoUsuario.toLowerCase() ==
                  'proveedor'
              ? FloatingActionButton.extended(

                  backgroundColor: verde,

                  elevation: 5,

                  onPressed: () async {
                    final resultado =
                        await Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const PublishProductScreen(),
                      ),
                    );

                    if (resultado == true) {
                      await cargarProductos();
                    }
                  },

                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Publicar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                )
              : null,

      // ========================================================
      // NAVEGACIÓN
      // ========================================================

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: 0,

        selectedItemColor: verde,

        unselectedItemColor:
            Colors.grey,

        backgroundColor:
            Colors.white,

        elevation: 10,

        type:
            BottomNavigationBarType.fixed,

        onTap: (index) {

  if (tipoUsuario.toLowerCase() == "proveedor") {

    switch (index) {

      case 0:
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ProfileScreen(),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MessagesScreen(),
          ),
        );
        break;
    }

  } else {

    switch (index) {

      case 0:
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FavoritesScreen(),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ProfileScreen(),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MessagesScreen(),
          ),
        );
        break;
    }
  }
},

        items: tipoUsuario.toLowerCase() == "proveedor"
    ? const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Inicio",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: "Perfil",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: "Mensajes",
        ),
      ]
    : const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Inicio",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          label: "Favoritos",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: "Perfil",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: "Mensajes",
        ),
      ],
      ),
    );
  }
}