import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/favorite_service.dart';
import 'package:flutter_application_1/widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool cargando = true;

  List<Product> favoritos = [];

  @override
  void initState() {
    super.initState();
    cargarFavoritos();
  }

 Future<void> cargarFavoritos() async {
  if (mounted) {
    setState(() {
      cargando = true;
    });
  }

  try {
    final productos =
        await FavoriteService.obtenerFavoritos();

    if (!mounted) return;

    setState(() {
      favoritos = productos;
      cargando = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error cargando favoritos: $e',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        centerTitle: true,

        title: const Text(
          "Mis Favoritos",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: cargando
                ? null
                : cargarFavoritos,
          ),
        ],
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : favoritos.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Aún no tienes productos favoritos.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarFavoritos,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoritos.length,

                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return ProductCard(
                        producto: favoritos[index],
                      );
                    },
                  ),
                ),
    );
  }
}