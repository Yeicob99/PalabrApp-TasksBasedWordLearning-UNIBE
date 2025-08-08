<div align="center">
<img width="500" height="500" alt="Logo Educación Cerebro Ilustración Moderno Naranja y Morado" src="https://github.com/user-attachments/assets/8d42c0b4-ecf0-4006-93aa-58c76a550476" />

# PalabrApp

Aprende una palabra en español cada día, completa pequeñas misiones y construye tu racha. Proyecto final de la materia desarrollo de aplicaciones móviles

</div>

---

## Características

- Palabra del día en español desde Wikcionario (ES) con timeouts y fallback (sin bloqueos).
- Misiones diarias sencillas (p. ej., “Busca un sinónimo y memorízalo”) que puedes marcar como hechas.
- Barra de racha: racha actual y mejor racha, basada en días con todas las misiones completadas.
- Modo claro/oscuro con Material 3 y Google Fonts.
- Persistencia local con Hive (usuarios, días, progreso). Funciona sin conexión para historial y progreso.

##  Estructura rápida del proyecto

- `lib/main.dart`: arranque de la app, theming y punto de entrada.
- `lib/screens/login.dart`: login/registro simple con Hive.
- `lib/screens/home.dart`: palabra del día, misiones y barra de racha.
- `lib/screens/history.dart`: historial de palabras y progreso.
- `lib/services/local_db.dart`: acceso a Hive (usuarios/días, rachas).
- `lib/services/word_service.dart`: obtiene palabra + definición desde Wikcionario.
- `lib/widgets/mission_tile.dart`: ítem de misión (toggle, estilos, animación).
- `lib/widgets/streak_bar.dart`: barra de racha (actual/mejor) con gradiente.

##  Tecnologías

- Flutter + Material 3 + Google Fonts
- Hive + hive_flutter 
- http api(Wikcionario)

##  Ejecutar el proyecto

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


## Licencia

Sin licencia definida aún. 
<img width="915" height="816" alt="untitled" src="https://github.com/user-attachments/assets/7016d1ac-1574-4c98-98b0-678456b8b705" />


