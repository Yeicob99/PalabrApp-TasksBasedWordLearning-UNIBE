// Pantalla principal: muestra la palabra, misiones y racha del usuario
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_db.dart';
import '../widgets/mission_tile.dart';
import '../widgets/streak_bar.dart';
import 'history.dart';
import 'login.dart';
import '../services/word_service.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado básico: fecha de hoy, datos del día, servicio, loading y rachas
  late DateTime _today;
  Map<String, dynamic>? _data;
  final _service = const WordService();
  bool _loading = true;
  int _curStreak = 0;
  int _bestStreak = 0;

  Future<void> _load() async {
    // Carga los datos del día: si no hay, los crea (con fallback sin red)
    setState(() => _loading = true);
    _today = DateTime.now();
    try {
      _data = LocalDB.readDay(widget.username, _today);

      if (_data == null) {
        // Pedimos palabra del día (máx 8s) y si falla usamos un texto local
        final fallback = WordResult(
          word: 'Palabra',
          meaning: 'Sin conexión. Inténtalo más tarde.',
          examples: const [],
        );
        WordResult wr;
        try {
          wr = await _service
              .fetchWordOfDay()
              .timeout(const Duration(seconds: 8), onTimeout: () => fallback);
        } catch (_) {
          wr = fallback;
        }
        final payload = {
          'word': wr.word,
          'meaning': wr.meaning,
          'missions': [
            {'text': 'Di la palabra hoy en una conversación', 'done': false},
            {'text': 'Escribe una oración usando la palabra', 'done': false},
            {'text': 'Busca un sinónimo y memorízalo', 'done': false},
          ],
          'completed': false,
        };
        // Guardamos el día en la base local
        await LocalDB.createDay(widget.username, _today, payload);
        _data = payload;
      }

      // Migración: si hay misiones antiguas con "ejemplo", las cambiamos
      if (_data != null) {
        final missions = List<Map<String, dynamic>>.from(_data!['missions']);
        bool changed = false;
        for (int i = 0; i < missions.length; i++) {
          final txt = (missions[i]['text'] as String).toLowerCase();
          if (txt.contains('ejemplo')) {
            final done = missions[i]['done'] == true;
            missions[i] = {
              'text': 'Busca un sinónimo y memorízalo',
              'done': done,
            };
            changed = true;
          }
        }
        if (changed) {
          _data!['missions'] = missions;
          await LocalDB.updateDay(widget.username, _today, _data!);
        }
      }

      // Calculamos racha actual y mejor racha
      _curStreak = LocalDB.currentStreak(widget.username);
      _bestStreak = LocalDB.bestStreak(widget.username);

      if (mounted) setState(() => _loading = false);
    } finally {
      // Como seguridad: actualizamos rachas y quitamos el spinner siempre
      _curStreak = LocalDB.currentStreak(widget.username);
      _bestStreak = LocalDB.bestStreak(widget.username);
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _toggleMission(int i) async {
    // Marca/Desmarca la misión i, y si todas quedan hechas marca el día completo
    if (_data == null) return;
    _data!['missions'][i]['done'] = !_data!['missions'][i]['done'];
    // si todas completadas, marcar día como completado
    final list = List<Map<String, dynamic>>.from(_data!['missions']);
    final allDone = list.every((m) => m['done'] == true);
    _data!['completed'] = allDone;
    await LocalDB.updateDay(widget.username, _today, _data!);
    // actualizar rachas si procede y mostrar mensaje
    if (allDone) {
      _curStreak = LocalDB.currentStreak(widget.username);
      _bestStreak = LocalDB.bestStreak(widget.username);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Completaste todas las misiones de hoy!')),
        );
      }
    }
    setState(() {});
  }

  void _deleteToday() async {
    await LocalDB.deleteDay(widget.username, _today);
    _data = null;
    _curStreak = LocalDB.currentStreak(widget.username);
    _bestStreak = LocalDB.bestStreak(widget.username);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eliminado el día de hoy')));
    }
  }

  void _logout() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _newCustomWord() async {
    // Permite escribir una palabra y significado propios para hoy
    final wCtrl = TextEditingController();
    final mCtrl = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva palabra para hoy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: wCtrl,
                decoration: const InputDecoration(labelText: 'Palabra')),
            TextField(
                controller: mCtrl,
                decoration: const InputDecoration(labelText: 'Significado')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (res == true) {
      final payload = {
        'word': wCtrl.text.isEmpty ? 'Palabra' : wCtrl.text,
        'meaning': mCtrl.text.isEmpty ? 'Significado' : mCtrl.text,
        'missions': [
          {'text': 'Di la palabra hoy en una conversación', 'done': false},
          {'text': 'Escribe una oración usando la palabra', 'done': false},
          {'text': 'Busca un sinónimo y memorízalo', 'done': false},
        ],
        'completed': false,
      };
      await LocalDB.updateDay(widget.username, _today, payload);
      _data = payload;
      _curStreak = LocalDB.currentStreak(widget.username);
      _bestStreak = LocalDB.bestStreak(widget.username);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Degradado de fondo para toda la pantalla
    final gradient = const LinearGradient(
      colors: [Color(0xFF6D4AFF), Color(0xFF00D4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Según el estado: spinner, mensaje vacío o el contenido principal
    final body = _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : (_data == null
            ? const Center(
                child: Text('No hay palabra para hoy',
                    style: TextStyle(color: Colors.white)))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de rachas
                      StreakBar(current: _curStreak, best: _bestStreak),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFFA855F7)],
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1.6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.white.withOpacity(0.06),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 22,
                                  offset: const Offset(0, 12)),
                            ],
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _data!['word'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _data!['meaning'],
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Misiones',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      ...List.generate((_data!['missions'] as List).length,
                          (i) {
                        final m = _data!['missions'][i];
                        return MissionTile(
                            text: m['text'],
                            done: m['done'],
                            onToggle: () => _toggleMission(i));
                      }),
                    ],
                  ),
                ),
              ));

    // Aplicamos el fondo degradado y una AppBar transparente al Scaffold
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Hola, ${widget.username}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(onPressed: _newCustomWord, icon: const Icon(Icons.add)),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HistoryPage(username: widget.username)),
              ),
              icon: const Icon(Icons.history),
            ),
            IconButton(
                onPressed: _deleteToday,
                icon: const Icon(Icons.delete_forever)),
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          ],
        ),
        body: body,
      ),
    );
  }
}
