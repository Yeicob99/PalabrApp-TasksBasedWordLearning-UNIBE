// Servicio que obtiene una palabra y su definición en español desde Wikcionario
import 'dart:convert';
import 'package:http/http.dart' as http;

class WordResult {
  final String word;
  final String meaning;
  final List<String> examples; // no usamos ejemplos

  WordResult({
    required this.word,
    required this.meaning,
    required this.examples,
  });
}

class WordService {
  const WordService();

  /// Obtiene palabra y definición en ES.
  /// Intenta varias veces con timeouts cortos y devuelve un fallback si falla.
  Future<WordResult> fetchWordOfDay() async {
    try {
      for (int i = 0; i < 6; i++) {
        // 1) Pide una palabra al azar en ES (máx 3s)
        final word = await _randomWordES()
            .timeout(const Duration(seconds: 3), onTimeout: () => 'palabra');

        // 2) Busca la primera definición en ES de esa palabra (máx 3s)
        final def = await _lookupES(word)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);

        if (def != null && def.trim().isNotEmpty) {
          // 3) Si encontramos definición, construimos el resultado
          return WordResult(
            word: _cap(word),
            meaning: def,
            examples: const [],
          );
        }
      }
      // 4) Si nada funcionó, devolvemos una palabra/definición de respaldo
      return WordResult(
        word: 'Resiliencia',
        meaning:
            'Capacidad de adaptarse y recuperarse ante la adversidad o los cambios.',
        examples: const [],
      );
    } catch (_) {
      // 5) Cualquier error general también devuelve el mismo respaldo
      return WordResult(
        word: 'Resiliencia',
        meaning:
            'Capacidad de adaptarse y recuperarse ante la adversidad o los cambios.',
        examples: const [],
      );
    }
  }

  // ---------- RANDOM: palabra al azar desde Wikcionario ES ----------
  Future<String> _randomWordES() async {
    // Llama al API de MediaWiki para devolver una página aleatoria (título = palabra)
    final uri = Uri.parse(
      'https://es.wiktionary.org/w/api.php'
      '?action=query&list=random&rnnamespace=0&rnlimit=1&format=json&origin=*',
    );
    final r = await http.get(uri).timeout(const Duration(seconds: 3));
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body);
      final title = data['query']?['random']?[0]?['title'];
      if (title is String && title.isNotEmpty) {
        return title;
      }
    }
    // Si falla, devolvemos una palabra genérica
    return 'palabra';
  }

  // ---------- LOOKUP: primera acepción en español ----------
  Future<String?> _lookupES(String word) async {
    // Consultamos el wikitexto completo para poder localizar la sección de Español
    // Pedimos el wikitexto para poder parsear la sección de Español
    final uri = Uri.parse(
      'https://es.wiktionary.org/w/api.php'
      '?action=parse&prop=wikitext&page=${Uri.encodeComponent(word)}'
      '&format=json&origin=*',
    );
    final r = await http.get(uri).timeout(const Duration(seconds: 3));
    if (r.statusCode != 200) return null;

    final data = jsonDecode(r.body);
    final wikitext = data['parse']?['wikitext']?['*'];
    if (wikitext is! String) return null;

    // Buscar sección de Español: "== {{lengua|es}} ==" o "==Español=="
    final text = wikitext;
    final esStart = _indexOfAny(text, [
      RegExp(r'^==\s*\{\{lengua\|es\}\}\s*==\s*$', multiLine: true),
      RegExp(r'^==\s*Español\s*==\s*$', multiLine: true),
    ]);
    if (esStart == -1) return null;

    // Cortar desde Español hasta la siguiente sección "== ... =="
    final nextSection = RegExp(r'^==[^=].*==\s*$', multiLine: true);
    final esSlice = text.substring(esStart);
    final next = nextSection.firstMatch(esSlice);
    final esBlock = next == null ? esSlice : esSlice.substring(0, next.start);

    // Tomar la primera línea de definición: empieza con "# " en wikitext
    final defMatch =
        RegExp(r'^\#\s+(.+)$', multiLine: true).firstMatch(esBlock);
    if (defMatch == null) return null;

    var def = defMatch.group(1) ?? '';

    // Limpiar wikitexto básico: enlaces [[...]], plantillas {{...}}, citas, etc.
    def = def
        // [[enlace|texto]] o [[texto]]
        .replaceAllMapped(
            RegExp(r'\[\[(?:[^|\]]+\|)?([^\]]+)\]\]'), (m) => m.group(1) ?? '')
        // plantillas {{...}}
        .replaceAll(RegExp(r'\{\{[^}]+\}\}'), '')
        // cursivas ''
        .replaceAll(RegExp(r"''"), '')
        // referencias <ref>...</ref> y etiquetas
        .replaceAll(RegExp(r'<ref[^>]*>.*?<\/ref>', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();

    // Poner punto final si no trae
    if (def.isNotEmpty && !RegExp(r'[.!?]$').hasMatch(def)) {
      def = '$def.';
    }
    return def;
  }

  // Encuentra el índice de la primera coincidencia de cualquiera de los patrones
  int _indexOfAny(String src, List<RegExp> patterns) {
    final matches = <int>[];
    for (final p in patterns) {
      final m = p.firstMatch(src);
      if (m != null) matches.add(m.start);
    }
    if (matches.isEmpty) return -1;
    matches.sort();
    return matches.first;
  }

  // Pone la primera letra en mayúscula para mostrar bonito
  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
