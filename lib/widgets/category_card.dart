import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String imagen;
  final String texto;

  const CategoryCard({
    super.key,
    required this.imagen,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagen,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}