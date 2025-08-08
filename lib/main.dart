// Importamos Flutter y paquetes de fuentes/servicios usados en la app
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/local_db.dart';
import 'screens/login.dart';

void main() async {
  // Asegura que Flutter esté listo antes de hacer cosas async
  WidgetsFlutterBinding.ensureInitialized();
  // Iniciamos la base de datos local (Hive) antes de arrancar la app
  await LocalDB.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Color base (seed) para generar una paleta de colores
    final seed = const Color(0xFF6D4AFF);
    return MaterialApp(
      title: 'PalabrApp',
      theme: ThemeData(
        // Tema claro con Material 3 y tipografías de Google
        colorSchemeSeed: seed,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        // Tema oscuro equivalente para cuando el sistema esté en dark
        colorSchemeSeed: seed,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        brightness: Brightness.dark,
      ),
      // Usa el tema (claro/oscuro) según el sistema del usuario
      themeMode: ThemeMode.system,
      // Primera pantalla: Login de usuario
      home: const LoginPage(),
    );
  }
}
