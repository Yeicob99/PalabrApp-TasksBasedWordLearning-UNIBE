// Pantalla de historial: lista todos los días guardados del usuario
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_db.dart';

class HistoryPage extends StatelessWidget {
  final String username;
  const HistoryPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // Trae el historial de la base local y aplica el mismo fondo degradado
    final items = LocalDB.historyFor(username);
    final gradient = const LinearGradient(
      colors: [Color(0xFF6D4AFF), Color(0xFF00D4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Historial',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ),
        // Si no hay elementos, mostramos un texto, si no, una lista de tarjetas
        body: items.isEmpty
            ? const Center(
                child: Text('Sin historial todavía',
                    style: TextStyle(color: Colors.white)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final entry = items[i];
                  final date = entry.key.split('_').last; // yyyy-MM-dd
                  final word = entry.value['word'];
                  final missions = (entry.value['missions'] as List);
                  final doneCount =
                      missions.where((m) => m['done'] == true).length;
                  return Card(
                    // Tarjeta con transparencia para efecto “vidrio”
                    color: Colors.white.withOpacity(0.08),
                    shadowColor: Colors.black54,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text('$word — $date',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      subtitle: Text(
                          'Completadas: $doneCount/${missions.length}',
                          style: GoogleFonts.inter(color: Colors.white70)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
