import 'package:flutter/material.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool cargandoProductos = true;

  @override
  void initState() {
    super.initState();

    cargarProductos();
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
        centerTitle: true,

        title: const Text(
          "TasbaMairin",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          // ====================================================
          // ACTUALIZAR
          // ====================================================

          IconButton(
            onPressed: cargarProductos,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),

          // ====================================================
          // NOTIFICACIONES
          // ====================================================

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "No tienes notificaciones nuevas.",
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),

          const SizedBox(
            width: 5,
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: cargarProductos,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // BIENVENIDA
              // ==================================================

              const Text(
                "¡BIENVENIDA!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016630),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                "Encuentra productos de tu comunidad",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // BUSCADOR
              // ==================================================

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                      ),

                      SizedBox(
                        width: 10,
                      ),

                      Text(
                        "Buscar productos...",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // CATEGORÍAS
              // ==================================================

              const Text(
                "Categorías",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016630),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              SizedBox(
                height: 130,

                child: ListView(
                  scrollDirection: Axis.horizontal,

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
                              categoria: "Agrícola",
                            ),
                          ),
                        );
                      },

                      child: const CategoryCard(
                        imagen:
                            "assets/images/agricola.jpg",
                        texto: "Agrícola",
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

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
                              categoria: "Artesanías",
                            ),
                          ),
                        );
                      },

                      child: const CategoryCard(
                        imagen:
                            "assets/images/artesanias.jpg",
                        texto: "Artesanías",
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

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
                              categoria: "Plantas",
                            ),
                          ),
                        );
                      },

                      child: const CategoryCard(
                        imagen:
                            "assets/images/plantas.jpg",
                        texto: "Plantas",
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

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
                              categoria: "Alimentos",
                            ),
                          ),
                        );
                      },

                      child: const CategoryCard(
                        imagen:
                            "assets/images/alimentos.jpg",
                        texto: "Alimentos",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // DESTACADOS
              // ==================================================

              const Text(
                "Productos destacados",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016630),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              ...productosDestacados.map(
                (producto) => ProductCard(
                  producto: producto,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // PRODUCTOS RECIENTES
              // ==================================================

              const Text(
                "Productos publicados recientemente",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF016630),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              if (cargandoProductos)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                      20,
                    ),

                    child: CircularProgressIndicator(
                      color: Color(0xFF016630),
                    ),
                  ),
                )
              else if (productosRecientes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20,
                    ),

                    child: Text(
                      "Todavía no hay productos publicados.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                ...productosRecientes.map(
                  (producto) => ProductCard(
                    producto: producto,
                  ),
                ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTÓN PUBLICAR
      // ========================================================

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF016630),

        onPressed: () async {
          final resultado = await Navigator.push(
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

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      // ========================================================
      // NAVEGACIÓN
      // ========================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        selectedItemColor: const Color(0xFF016630),

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          switch (index) {
            // ==================================================
            // INICIO
            // ==================================================

            case 0:
              break;

            // ==================================================
            // FAVORITOS
            // ==================================================

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FavoritesScreen(),
                ),
              );
              break;

            // ==================================================
            // PERFIL
            // ==================================================

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfileScreen(),
                ),
              );
              break;

            // ==================================================
            // MENSAJES
            // ==================================================

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
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Inicio",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
            ),
            label: "Favoritos",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "Perfil",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
            ),
            label: "Mensajes",
          ),
        ],
      ),
    );
  }
}