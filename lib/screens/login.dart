// Pantalla de inicio de sesión y registro (muy simple con Hive)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_db.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;

  void _submit() async {
    // Lee usuario y contraseña, valida y navega a Home si todo bien
    final u = _user.text.trim();
    final p = _pass.text.trim();
    if (u.isEmpty || p.isEmpty) {
      _snack('Completa usuario y contraseña');
      return;
    }
    if (_isLogin) {
      if (LocalDB.validateLogin(u, p)) {
        _goHome(u);
      } else {
        _snack('Usuario o contraseña incorrectos');
      }
    } else {
      if (LocalDB.userExists(u)) {
        _snack('Ese usuario ya existe');
      } else {
        await LocalDB.createUser(u, p);
        _snack('Usuario creado. ¡Bienvenid@!');
        _goHome(u);
      }
    }
  }

  void _goHome(String u) {
    // Reemplaza la pantalla actual por Home, pasando el username
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(username: u)));
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    // Degradado de fondo que igualamos en todas las pantallas
    final gradient = const LinearGradient(
      colors: [Color(0xFF6D4AFF), Color(0xFF00D4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            // Limitamos el ancho para que se vea bien en pantallas grandes
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: Colors.white.withOpacity(0.08),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // Icono y título de la app
                    Icon(Icons.auto_awesome, color: Colors.white, size: 56),
                    const SizedBox(height: 8),
                    Text('Palabra del Día',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 16),
                    // Campos de usuario/contraseña con estilo
                    TextField(
                      controller: _user,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pass,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Botón de entrar / registrarse
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B1B1F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _submit,
                        child: Text(_isLogin ? 'Entrar' : 'Registrarme',
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    // Enlace para alternar entre login y registro
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'Crear cuenta' : 'Ya tengo cuenta',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
