import 'package:flutter/material.dart';

class CentroAyudaScreen extends StatelessWidget {
  const CentroAyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1C8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Centro de Ayuda',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        // Las tres rayitas
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'como_usar') {
                _mostrarComoUsar(context);
              }

              if (value == 'publicar') {
                _mostrarMensaje(
                  context,
                  'Para publicar un producto, entra a la sección de productos y selecciona la opción para publicar.',
                );
              }

              if (value == 'mensajes') {
                _mostrarMensaje(
                  context,
                  'Puedes revisar tus mensajes desde la sección de mensajes.',
                );
              }

              if (value == 'notificaciones') {
                _mostrarMensaje(
                  context,
                  'La campana 🔔 te muestra cuando tienes nuevas notificaciones.',
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'como_usar',
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: Color(0xFF016630),
                    ),
                    SizedBox(width: 10),
                    Text('¿Cómo usar la aplicación?'),
                  ],
                ),
              ),

              PopupMenuItem(
                value: 'publicar',
                child: Row(
                  children: [
                    Icon(
                      Icons.add_box_outlined,
                      color: Color(0xFF016630),
                    ),
                    SizedBox(width: 10),
                    Text('Publicar un producto'),
                  ],
                ),
              ),

              PopupMenuItem(
                value: 'mensajes',
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      color: Color(0xFF016630),
                    ),
                    SizedBox(width: 10),
                    Text('Usar los mensajes'),
                  ],
                ),
              ),

              PopupMenuItem(
                value: 'notificaciones',
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Color(0xFF016630),
                    ),
                    SizedBox(width: 10),
                    Text('Ver notificaciones'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              '¿Necesitas ayuda?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF016630),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Aquí puedes encontrar información sencilla para utilizar TasbaMairin.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 25),

            _tarjetaAyuda(
              icono: Icons.menu,
              titulo: 'Menú de ayuda',
              descripcion:
                  'Presiona las tres rayitas de la parte superior para encontrar diferentes opciones de ayuda.',
            ),

            _tarjetaAyuda(
              icono: Icons.notifications_none,
              titulo: 'Notificaciones',
              descripcion:
                  'Revisa la campana para saber si tienes nuevos mensajes o avisos.',
            ),

            _tarjetaAyuda(
              icono: Icons.chat_outlined,
              titulo: 'Mensajes',
              descripcion:
                  'Puedes comunicarte con otras personas mediante el sistema de mensajes.',
            ),

            _tarjetaAyuda(
              icono: Icons.swap_horiz,
              titulo: 'Trueques',
              descripcion:
                  'Puedes revisar y gestionar las solicitudes de trueque desde la aplicación.',
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF016630),
                    size: 32,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Si tienes alguna duda, revisa las opciones del menú de arriba.',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TARJETA DE AYUDA
  // ==========================================================

  static Widget _tarjetaAyuda({
    required IconData icono,
    required String titulo,
    required String descripcion,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFFE5F2E9),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icono,
              color: const Color(0xFF016630),
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF016630),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MOSTRAR MENSAJE
  // ==========================================================

  static void _mostrarMensaje(
    BuildContext context,
    String mensaje,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Ayuda',
            style: TextStyle(
              color: Color(0xFF016630),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(mensaje),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF016630),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // ¿CÓMO USAR LA APLICACIÓN?
  // ==========================================================

  static void _mostrarComoUsar(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '¿Cómo usar TasbaMairin?',
            style: TextStyle(
              color: Color(0xFF016630),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  '1. Explora los productos disponibles.',
                ),

                SizedBox(height: 10),

                Text(
                  '2. Puedes buscar y filtrar productos.',
                ),

                SizedBox(height: 10),

                Text(
                  '3. Utiliza los mensajes para comunicarte.',
                ),

                SizedBox(height: 10),

                Text(
                  '4. Revisa la campana para ver tus notificaciones.',
                ),

                SizedBox(height: 10),

                Text(
                  '5. También puedes realizar trueques con otros usuarios.',
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF016630),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}