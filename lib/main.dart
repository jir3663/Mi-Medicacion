import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Medicación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Modelo de Datos para la Medicación Pautada
class MedicamentoConfig {
  final String nombre;
  final String dosis;
  final String frecuencia; // 'Cada día', '2 veces por semana', etc.
  final String hora;
  final String comentarios;
  final String? fotoUrl;

  MedicamentoConfig({
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    required this.hora,
    required this.comentarios,
    this.fotoUrl,
  });
}

// Modelo para el estado diario de cada medicina
class MedicamentoDia {
  final String nombre;
  final String dosis;
  final String hora;
  final String comentarios;
  bool tomada;

  MedicamentoDia({
    required this.nombre,
    required this.dosis,
    required this.hora,
    required this.comentarios,
    this.tomada = false,
  });
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Lista global de medicamentos configurados en Ajustes
  final List<MedicamentoConfig> _medicamentosConfigurados = [
    MedicamentoConfig(
      nombre: 'Orfidal',
      dosis: '1 tableta',
      frecuencia: 'Cada día',
      hora: '14:00',
      comentarios: 'Comer algo antes de tomarlo.',
    )
  ];

  // Base de datos simulada de días -> Medicamentos del día
  final Map<String, List<MedicamentoDia>> _historialDiario = {};
  final Map<String, String> _notasDiarias = {};

  @override
  Widget build(BuildContext context) {
    // Definimos las pestañas: Calendario primero, Ajustes SIEMPRE el último
    final List<Widget> pantallas = [
      CalendarioScreen(
        medicamentosConfig: _medicamentosConfigurados,
        historialDiario: _historialDiario,
        notasDiarias: _notasDiarias,
        onActualizar: () => setState(() {}),
      ),
      AjustesScreen(
        medicamentosConfig: _medicamentosConfigurados,
        onAgregar: (nuevoMed) {
          setState(() {
            _medicamentosConfigurados.add(nuevoMed);
          });
        },
        onEliminar: (index) {
          setState(() {
            _medicamentosConfigurados.removeAt(index);
          });
        },
      ),
    ];

    return Scaffold(
      body: pantallas[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

// ================= PANTALLA 1: CALENDARIO =================
class CalendarioScreen extends StatefulWidget {
  final List<MedicamentoConfig> medicamentosConfig;
  final Map<String, List<MedicamentoDia>> historialDiario;
  final Map<String, String> notasDiarias;
  final VoidCallback onActualizar;

  const CalendarioScreen({
    super.key,
    required this.medicamentosConfig,
    required this.historialDiario,
    required this.notasDiarias,
    required this.onActualizar,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  bool esCuadricula = false; // Selector rápido de vista

  @override
  Widget build(BuildContext context) {
    // Datos del usuario (Perfil Superior)
    const String nombreUsuario = 'María García López';
    const int edad = 72;
    const String peso = '68 kg';
    const String estatura = '1.60 m';
    const String grupoSanguineo = 'A+';

    // Generamos los próximos 30 días para el calendario
    final hoy = DateTime.now();
    final listaDias = List.generate(30, (index) => hoy.add(Duration(days: index)));

    return SafeArea(
      child: Column(
        children: [
          // 1. TARJETA DE PERFIL (Primera Plana)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        nombreUsuario,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Edad: $edad años | Peso: $peso | Altura: $estatura'),
                      const SizedBox(height: 2),
                      Text(
                        'Grupo Sanguíneo: $grupoSanguineo',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. BOTÓN DE SELECCIÓN RÁPIDA (Lista / Cuadrícula)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Calendario de Tomas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Lista'), icon: Icon(Icons.view_list)),
                    ButtonSegment(value: true, label: Text('Cuadrícula'), icon: Icon(Icons.grid_view)),
                  ],
                  selected: {esCuadricula},
                  onSelectionChanged: (Set<bool> nuevaSeleccion) {
                    setState(() {
                      esCuadricula = nuevaSeleccion.first;
                    });
                  },
                ),
              ],
            ),
          ),

          // 3. CONTENIDO DEL CALENDARIO (Tarjetas diarias)
          Expanded(
            child: esCuadricula
                ? GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: listaDias.length,
                    itemBuilder: (context, index) {
                      return _buildTarjetaDia(context, listaDias[index], true);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: listaDias.length,
                    itemBuilder: (context, index) {
                      return _buildTarjetaDia(context, listaDias[index], false);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaDia(BuildContext context, DateTime fecha, bool compacto) {
    final fechaClave = DateFormat('yyyy-MM-dd').format(fecha);
    final nombreDia = DateFormat('EEE, dd MMM', 'es_ES').format(fecha);

    // Asegurar que existan las tomas para este día basadas en la configuración
    if (!widget.historialDiario.containsKey(fechaClave)) {
      widget.historialDiario[fechaClave] = widget.medicamentosConfig
          .map((m) => MedicamentoDia(
                nombre: m.nombre,
                dosis: m.dosis,
                hora: m.hora,
                comentarios: m.comentarios,
              ))
          .toList();
    }

    final tomasDelDia = widget.historialDiario[fechaClave]!;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          // Abrir detalle del día al hacer clic en la tarjeta
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleDiaScreen(
                fechaStr: nombreDia,
                tomas: tomasDelDia,
                notaActual: widget.notasDiarias[fechaClave] ?? '',
                onGuardarNota: (nota) {
                  widget.notasDiarias[fechaClave] = nota;
                },
              ),
            ),
          );
          widget.onActualizar();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(nombreDia, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const Divider(),
              if (tomasDelDia.isEmpty)
                const Text('Sin medicamentos', style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                ...tomasDelDia.map((t) => Row(
                      children: [
                        Icon(
                          t.tomada ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                          color: t.tomada ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${t.hora} - ${t.nombre} (${t.dosis})',
                            style: TextStyle(
                              fontSize: compacto ? 11 : 13,
                              decoration: t.tomada ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PANTALLA DETALLE DE TARJETA DIARIA =================
class DetalleDiaScreen extends StatefulWidget {
  final String fechaStr;
  final List<MedicamentoDia> tomas;
  final String notaActual;
  final Function(String) onGuardarNota;

  const DetalleDiaScreen({
    super.key,
    required this.fechaStr,
    required this.tomas,
    required this.notaActual,
    required this.onGuardarNota,
  });

  @override
  State<DetalleDiaScreen> createState() => _DetalleDiaScreenState();
}

class _DetalleDiaScreenState extends State<DetalleDiaScreen> {
  late TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _notaController = TextEditingController(text: widget.notaActual);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Día: ${widget.fechaStr}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Medicamentos Pautados:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.tomas.map((t) => CheckboxListTile(
                  title: Text('${t.nombre} - ${t.dosis} (${t.hora})'),
                  subtitle: Text('Nota: ${t.comentarios}'),
                  value: t.tomada,
                  activeColor: Colors.teal,
                  onChanged: (bool? valor) {
                    setState(() {
                      t.tomada = valor ?? false;
                    });
                  },
                )),
            const Divider(height: 30),
            const Text('Anotaciones y Observaciones del Día:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notaController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: Hoy me sentí mareado por la mañana...',
              ),
              onChanged: (valor) {
                widget.onGuardarNota(valor);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= PANTALLA 2: AJUSTES (SIEMPRE LA ÚLTIMA) =================
class AjustesScreen extends StatefulWidget {
  final List<MedicamentoConfig> medicamentosConfig;
  final Function(MedicamentoConfig) onAgregar;
  final Function(int) onEliminar;

  const AjustesScreen({
    super.key,
    required this.medicamentosConfig,
    required this.onAgregar,
    required this.onEliminar,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _nombreController = TextEditingController();
  final _dosisController = TextEditingController();
  final _horaController = TextEditingController(text: '09:00');
  final _comentarioController = TextEditingController();
  String _frecuenciaSeleccionada = 'Cada día';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Configuración de Medicación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Añade o modifica los medicamentos pautados para el calendario', style: TextStyle(color: Colors.grey)),
            const Divider(height: 20),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre del Medicamento (ej. Orfidal)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dosisController,
                    decoration: const InputDecoration(labelText: 'Dosis (ej. 1 tableta, 5ml)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _horaController,
                    decoration: const InputDecoration(labelText: 'Hora de toma (ej. 14:00)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _comentarioController,
                    decoration: const InputDecoration(labelText: 'Comentarios (ej. Tomar con comida)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    onPressed: () {
                      if (_nombreController.text.isNotEmpty) {
                        widget.onAgregar(MedicamentoConfig(
                          nombre: _nombreController.text,
                          dosis: _dosisController.text,
                          frecuencia: _frecuenciaSeleccionada,
                          hora: _horaController.text,
                          comentarios: _comentarioController.text,
                        ));
                        _nombreController.clear();
                        _dosisController.clear();
                        _comentarioController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medicamento pautado correctamente')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir Medicamento a la Pauta'),
                  ),
                  const Divider(height: 30),
                  const Text('Medicamentos Activos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...widget.medicamentosConfig.asMap().entries.map((entry) {
                    int index = entry.key;
                    Med = entry.value;
                    return Card(
                      child: ListTile(
                        title: Text('${Med.nombre} (${Med.dosis})'),
                        subtitle: Text('Hora: ${Med.hora} | Nota: ${Med.comentarios}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => widget.onEliminar(index),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
