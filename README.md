<div align="center">

# PalabrApp

Aprende una palabra en español cada día, completa pequeñas misiones y construye tu racha. Diseño moderno con degradados, glassmorphism y animaciones.

</div>

---

## ✨ Características

- Palabra del día en español desde Wikcionario (ES) con timeouts y fallback (sin bloqueos).
- Definición clara y tarjeta destacada con diseño “jevi”.
- Misiones diarias sencillas (p. ej., “Busca un sinónimo y memorízalo”) que puedes marcar como hechas.
- Barra de racha: racha actual y mejor racha, basada en días con todas las misiones completadas.
- Historial con el mismo fondo degradado y tarjetas de estilo glass.
- Modo claro/oscuro con Material 3 y Google Fonts.
- Persistencia local con Hive (usuarios, días, progreso). Funciona sin conexión para historial y progreso.

## 📸 Capturas (opcional)

> Añade tus imágenes en `assets/screenshots/` y colócalas aquí.
>
> ![Login](assets/screenshots/login.png) > ![Home](assets/screenshots/home.png) > ![Historial](assets/screenshots/history.png)

## 🧭 Estructura rápida del proyecto

- `lib/main.dart`: arranque de la app, theming y punto de entrada.
- `lib/screens/login.dart`: login/registro simple con Hive.
- `lib/screens/home.dart`: palabra del día, misiones y barra de racha.
- `lib/screens/history.dart`: historial de palabras y progreso.
- `lib/services/local_db.dart`: acceso a Hive (usuarios/días, rachas).
- `lib/services/word_service.dart`: obtiene palabra + definición desde Wikcionario.
- `lib/widgets/mission_tile.dart`: ítem de misión (toggle, estilos, animación).
- `lib/widgets/streak_bar.dart`: barra de racha (actual/mejor) con gradiente.

## 🧩 Tecnologías

- Flutter + Material 3 + Google Fonts
- Hive + hive_flutter + path_provider
- http (Wikcionario)

## 🚀 Ejecutar el proyecto

Requisitos:

- Flutter SDK instalado (estable)
- Android SDK para móvil Android, y/o Windows Desktop habilitado si vas a correr en Windows

Instala dependencias:

```bash
flutter pub get
```

Ejecuta en Windows (desktop):

```bash
# habilitar soporte (una vez)
flutter config --enable-windows-desktop
# ejecutar
flutter run -d windows
```

Ejecuta en Android (emulador/dispositivo):

```bash
flutter run -d android
```

Build de producción:

```bash
# APK Android (release)
flutter build apk --release
# Windows (release)
flutter build windows --release
```

## 🧠 Cómo funciona (resumen)

- Al abrir, `WordService` pide una palabra aleatoria del Wikcionario en español y extrae la primera definición. Si algo tarda o falla, hay timeouts y un fallback (“Resiliencia”).
- En `Home`, tienes 3 misiones diarias. Al completar todas, el día se marca como “completado” y se actualiza la racha.
- La racha actual y la mejor se calculan sobre días completados para tu usuario.
- Todo queda guardado localmente con Hive: usuarios, días, palabra, definición, misiones y si el día está completado.

## 🗃️ Estructura de datos (Hive)

- Box `users`: mapa username → password.
- Box `data`: clave `username_YYYY-MM-DD` → { word, meaning, missions: [..], completed: bool, date: string }.
- Rachas:
  - `currentStreak(username)`: recorre días hacia atrás contando consecutivos completados.
  - `bestStreak(username)`: calcula la mejor racha entre todos los días.

## 🎨 Personalización rápida

- Cambiar nombre de la app: ya configurado como “PalabrApp” (Android/Windows/MaterialApp).
- Cambiar ícono del login:
  - Reemplaza el `Icon(Icons.translate_rounded, ...)` por el que prefieras o usa un asset con `Image.asset('assets/images/login_icon.png')` y decláralo en `pubspec.yaml`.
- Cambiar fuente o colores: ajusta `GoogleFonts.*` y `colorSchemeSeed` en `main.dart`.

## 🔒 Privacidad

- No se envían datos a servidores propios. Solo se consulta Wikcionario para la palabra/definición. El progreso vive en tu dispositivo (Hive).

## ❓ FAQ

- “Se queda cargando”: las peticiones tienen timeouts y fallback para no bloquear. Verifica conexión si no aparece contenido nuevo.
- “No aumenta mi racha”: la racha sube cuando todas las misiones del día están marcadas como hechas.
- “Quiero más misiones”: añade textos en `Home` (lista de misiones) o hazlo configurable desde la base local.

## 🤝 Contribuir

- Issues y PRs bienvenidos. Antes de abrir PR, corre el proyecto y verifica que compila en al menos un destino (Windows/Android).

## 📄 Licencia

Sin licencia definida aún. Puedes añadir MIT/Apache-2.0 según tu preferencia.
