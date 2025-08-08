// Tarjeta/fila de misión: permite marcar una misión como hecha o pendiente
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionTile extends StatelessWidget {
  // Texto de la misión, estado (hecha o no) y callback para alternar
  final String text;
  final bool done;
  final VoidCallback onToggle;
  const MissionTile(
      {super.key,
      required this.text,
      required this.done,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    // Gradiente base (pendiente) y de éxito (hecha)
    final baseGradient = const LinearGradient(
      colors: [Color(0xFF1E1E2E), Color(0xFF312E81)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final successGradient = const LinearGradient(
      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: done ? successGradient : baseGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: done
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Botón circular izquierdo (bandera/check) para alternar
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Tooltip(
                    message:
                        done ? 'Marcar como pendiente' : 'Marcar como hecho',
                    child: Icon(
                      done ? Icons.check_rounded : Icons.flag_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration:
                      done ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Pastilla de estado a la derecha (Pendiente/Hecho) también alterna
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Colors.white,
                          size: 18),
                      const SizedBox(width: 6),
                      Text(done ? 'Hecho' : 'Pendiente',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
