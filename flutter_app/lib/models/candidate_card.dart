class CandidateCard {
  final String id;
  final String nombre;
  final String? partido;
  final String? cargo;
  final String? region;
  final String? foto;
  final String? caricatura;
  final String frase;
  final List<String> senales;
  final List<String> antecedentes;
  final List<String> controversias;
  final String pensionAlimenticia;
  final List<String> procesosJudiciales;
  final List<String> cambiosPartido;
  final int indiceFloro;
  final Map<String, int> puntajes;
  final String nivel;
  final String nivelRiesgo;
  final String respuestaIdeal;
  final String patronDominante;
  final String fraseNarrador;
  final List<String> fuentes;

  CandidateCard({
    required this.id,
    required this.nombre,
    this.partido,
    this.cargo,
    this.region,
    this.foto,
    this.caricatura,
    required this.frase,
    required this.senales,
    required this.antecedentes,
    required this.controversias,
    required this.pensionAlimenticia,
    required this.procesosJudiciales,
    required this.cambiosPartido,
    required this.indiceFloro,
    required this.puntajes,
    required this.nivel,
    required this.nivelRiesgo,
    required this.respuestaIdeal,
    required this.patronDominante,
    required this.fraseNarrador,
    required this.fuentes,
  });

  factory CandidateCard.fromJson(Map<String, dynamic> json) {
    return CandidateCard(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      partido: json['partido'],
      cargo: json['cargo'],
      region: json['region'],
      foto: json['foto'],
      caricatura: json['caricatura'],
      frase: json['frase'] ?? '',
      senales: List<String>.from(json['senales'] ?? []),
      antecedentes: List<String>.from(json['antecedentes'] ?? []),
      controversias: List<String>.from(json['controversias'] ?? []),
      pensionAlimenticia: json['pensionAlimenticia'] ?? 'no determinado',
      procesosJudiciales: List<String>.from(json['procesosJudiciales'] ?? []),
      cambiosPartido: List<String>.from(json['cambiosPartido'] ?? []),
      indiceFloro: (json['indiceFloro'] ?? 0).toInt(),
      puntajes: Map<String, int>.from(
        (json['puntajes'] ?? {}).map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
      nivel: json['nivel'] ?? 'Pasa raspando',
      nivelRiesgo: json['nivelRiesgo'] ?? 'no determinado',
      respuestaIdeal: json['respuestaIdeal'] ?? 'Pasa raspando',
      patronDominante: json['patronDominante'] ?? 'Sin patron dominante',
      fraseNarrador: json['fraseNarrador'] ?? '',
      fuentes: List<String>.from(json['fuentes'] ?? []),
    );
  }

  bool get hasControversies => senales.isNotEmpty || indiceFloro > 20;

  String get caricatureWebpId {
    if (caricatura == null) return id;
    return caricatura!
        .replaceAll('caricatures/', '')
        .replaceAll('.png', '');
  }

  String get photoWebpId {
    if (foto == null) return id;
    return foto!
        .replaceAll('photos/', '')
        .replaceAll('.jpg', '');
  }
}
