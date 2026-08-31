import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/report_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() =>
      _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  bool cargando = true;

  List<dynamic> reportes = [];

  String? error;

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }

  // ==========================================================
  // CARGAR MIS REPORTES
  // ==========================================================

  Future<void> cargarReportes() async {
    try {
      setState(() {
        cargando = true;
        error = null;
      });

      // Usamos el método que EXISTE actualmente
      // en tu ReportService.
      final resultado = await ReportService.obtenerReportes();

      if (!mounted) return;

      setState(() {
        reportes = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  // ==========================================================
  // COLOR DEL ESTADO
  // ==========================================================

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'revisado':
        return Colors.green;

      case 'descartado':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // ==========================================================
  // FORMATEAR FECHA
  // ==========================================================

  String formatearFecha(dynamic fecha) {
    if (fecha == null) {
      return '';
    }

    final texto = fecha.toString().trim();

    if (texto.isEmpty) {
      return '';
    }

    try {
      final fechaDate = DateTime.parse(texto).toLocal();

      final dia = fechaDate.day.toString().padLeft(2, '0');
      final mes = fechaDate.month.toString().padLeft(2, '0');
      final anio = fechaDate.year.toString();

      final hora = fechaDate.hour.toString().padLeft(2, '0');
      final minuto = fechaDate.minute.toString().padLeft(2, '0');

      return '$dia/$mes/$anio - $hora:$minuto';
    } catch (e) {
      return texto;
    }
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4B8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF016630),

        title: const Text(
          'Mis Reportes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF016630),
              ),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'No se pudieron cargar los reportes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: cargarReportes,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : reportes.isEmpty
                  ? RefreshIndicator(
                      onRefresh: cargarReportes,
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 250),

                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.report_outlined,
                                  size: 70,
                                  color: Colors.grey,
                                ),

                                SizedBox(height: 15),

                                Text(
                                  'No has enviado reportes.',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: cargarReportes,

                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),

                        itemCount: reportes.length,

                        itemBuilder: (context, index) {
                          final reporte = reportes[index];

                          // ==================================================
                          // DATOS DEL REPORTE
                          // ==================================================

                          final motivo =
                              reporte['Motivo']?.toString() ?? '';

                          final descripcion =
                              reporte['Descripcion']?.toString() ?? '';

                          final estado =
                              reporte['Estado']?.toString() ??
                                  'Pendiente';

                          final fecha =
                              reporte['FechaReporte'];

                          // ==================================================
                          // NOMBRE DEL PRODUCTO
                          // ==================================================

                          final nombreProducto =
                              reporte['NombreProducto']?.toString() ??
                                  'Producto';

                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 15,
                            ),

                            elevation: 3,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(16),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  // ==================================================
                                  // PRODUCTO
                                  // ==================================================

                                  Text(
                                    nombreProducto,

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ==================================================
                                  // MOTIVO
                                  // ==================================================

                                  Text(
                                    'Motivo: $motivo',

                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // ==================================================
                                  // DESCRIPCIÓN
                                  // ==================================================

                                  const Text(
                                    'Descripción:',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    descripcion.trim().isEmpty
                                        ? 'Sin descripción.'
                                        : descripcion,

                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ==================================================
                                  // ESTADO
                                  // ==================================================

                                  Row(
                                    children: [
                                      const Text(
                                        'Estado: ',

                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),

                                        decoration: BoxDecoration(
                                          color:
                                              colorEstado(estado),

                                          borderRadius:
                                              BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: Text(
                                          estado,

                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // ==================================================
                                  // FECHA
                                  // ==================================================

                                  Text(
                                    formatearFecha(fecha),

                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}