import 'package:flutter_application_1/models/product.dart';

// ==========================================================
// PRODUCTOS PUBLICADOS
// ==========================================================
//
// Por ahora se mantienen en memoria.
// Más adelante estos productos podrán venir desde MySQL.
//

List<Product> productosRecientes = [];

// ==========================================================
// PRODUCTOS DESTACADOS
// ==========================================================

List<Product> productosDestacados = [
  Product(
    id: 1,
    nombre: "Plantas medicinales",
    comunidad: "Bilwi",
    categoria: "Plantas",
    imagen: "assets/images/plantas_medicinales.jpg",
    descripcion: "Plantas medicinales de la comunidad.",
  ),

  Product(
    id: 2,
    nombre: "Artesanías",
    comunidad: "Puerto Cabezas",
    categoria: "Artesanías",
    imagen: "assets/images/artesanias.jpg",
    descripcion: "Artesanías elaboradas por productores locales.",
  ),
];