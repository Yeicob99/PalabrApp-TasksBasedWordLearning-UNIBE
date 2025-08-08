// Barra de racha: muestra racha actual y mejor racha de forma visual
import 'package:flutter/material.dart';

class StreakBar extends StatelessWidget {
  // Recibe la racha actual y la mejor
  final int current;
  final int best;
  const StreakBar({super.key, required this.current, required this.best});

  @override
  Widget build(BuildContext context) {
    // Progreso (porcentaje) entre 0 y 1
    final progress = best == 0 ? 0.0 : (current / best).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1021),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: const [
                  Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                  SizedBox(width: 8),
                ]),
                Text('Mejor: $best',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Racha: $current',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white10,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    height: 10,
                    width: c.maxWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A00), Color(0xFFFF3D00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
