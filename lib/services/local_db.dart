// Hive es una base de datos local ligera. La usamos para guardar usuarios y días.
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class LocalDB {
  // Cajas de Hive (como tablas): usuarios y datos diarios
  static late Box users;
  static late Box data;

  static Future<void> init() async {
    // Obtenemos carpeta de documentos de la app y arrancamos Hive
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    // Caja de usuarios: username -> password
    users = await Hive.openBox('users');
    // Caja de datos: clave "usuario_YYYY-MM-DD" -> mapa con palabra, significado, misiones y completed
    data = await Hive.openBox('data');
  }

  static bool userExists(String username) => users.containsKey(username);

  static Future<void> createUser(String username, String password) async {
    await users.put(username, password);
  }

  static bool validateLogin(String username, String password) {
    // Revisa si el usuario existe y compara la contraseña
    if (!userExists(username)) return false;
    return users.get(username) == password;
  }

  static Future<void> deleteUser(String username) async {
    // Borra el usuario y también todos sus días guardados
    await users.delete(username);
    final keysToDelete = data.keys
        .where((k) => k.toString().startsWith('${username}_'))
        .toList();
    await data.deleteAll(keysToDelete);
  }

  static String keyFor(String username, DateTime date) =>
      // Clave con fecha YYYY-MM-DD para identificar cada día
      '${username}_${date.toIso8601String().substring(0, 10)}';

  static Map<String, dynamic>? readDay(String username, DateTime date) {
    // Devuelve el mapa del día (o null si no existe)
    final raw = data.get(keyFor(username, date));
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  static Future<void> createDay(
      String username, DateTime date, Map<String, dynamic> payload) async {
    // Crea/guarda la info del día (si no existía)
    await data.put(keyFor(username, date), payload);
  }

  static Future<void> updateDay(
      String username, DateTime date, Map<String, dynamic> payload) async {
    // Actualiza la info del día (si ya existía)
    await data.put(keyFor(username, date), payload);
  }

  static Future<void> deleteDay(String username, DateTime date) async {
    // Elimina el día indicado
    await data.delete(keyFor(username, date));
  }

  static List<MapEntry<String, Map<String, dynamic>>> historyFor(
      String username) {
    // Recorre toda la caja de datos y recoge solo los días de ese usuario
    final entries = <MapEntry<String, Map<String, dynamic>>>[];
    for (final k in data.keys) {
      final ks = k.toString();
      if (ks.startsWith('${username}_')) {
        final v = Map<String, dynamic>.from(data.get(k));
        entries.add(MapEntry(ks, v));
      }
    }
    // Ordena por fecha descendente (más reciente primero)
    entries.sort((a, b) => b.key.compareTo(a.key));
    return entries;
  }

  // ---------- Rachas (streaks) ----------
  static bool hasDay(String username, DateTime date) {
    // ¿Existe algún registro para ese día? (independiente de completed)
    return data.containsKey(keyFor(username, date));
  }

  static bool isCompleted(String username, DateTime date) {
    // Mira si el día tiene la bandera 'completed' en true
    final entry = data.get(keyFor(username, date));
    if (entry == null) return false;
    try {
      final map = Map<String, dynamic>.from(entry);
      return map['completed'] == true;
    } catch (_) {
      return false;
    }
  }

  static int currentStreak(String username) {
    // Cuenta hacia atrás desde hoy días consecutivos con 'completed = true'
    int streak = 0;
    DateTime day = DateTime.now();
    // normalizar a fecha (yyyy-MM-dd)
    day = DateTime(day.year, day.month, day.day);
    while (isCompleted(username, day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int bestStreak(String username) {
    // Calcula la mejor racha encontrada entre todos los días completados
    // obtener todas las fechas COMPLETADAS para el usuario
    final completedDates = <DateTime>[];
    for (final k in data.keys) {
      final ks = k.toString();
      if (ks.startsWith('${username}_')) {
        final raw = data.get(k);
        try {
          final map = Map<String, dynamic>.from(raw);
          if (map['completed'] == true) {
            final dateStr = ks.split('_').last; // yyyy-MM-dd
            final parts = dateStr.split('-').map(int.parse).toList();
            completedDates.add(DateTime(parts[0], parts[1], parts[2]));
          }
        } catch (_) {}
      }
    }
    if (completedDates.isEmpty) return 0;
    completedDates.sort();
    int best = 1;
    int cur = 1;
    for (int i = 1; i < completedDates.length; i++) {
      final prev = completedDates[i - 1];
      final now = completedDates[i];
      if (now.difference(prev).inDays == 1) {
        cur += 1;
      } else if (now.difference(prev).inDays == 0) {
        continue;
      } else {
        if (cur > best) best = cur;
        cur = 1;
      }
    }
    if (cur > best) best = cur;
    return best;
  }
}
