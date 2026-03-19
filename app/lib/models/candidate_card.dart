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
  final String? dni;
  final String? linkJNE;

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
    this.dni,
    this.linkJNE,
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
      pensionAlimenticia: (json['pensionAlimenticia'] is String)
          ? json['pensionAlimenticia']
          : (json['pensionAlimenticia'] == true ? 'sí' : 'no determinado'),
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
      dni: json['dni'],
      linkJNE: json['linkJNE'],
    );
  }

  /// Whether the frase is a real quote vs generic placeholder
  bool get hasRealFrase =>
      frase.isNotEmpty &&
      !frase.startsWith('Candidato de') &&
      !frase.startsWith('Candidata de') &&
      frase.length > 20;

  /// Whether patronDominante is a real pattern vs placeholder
  bool get hasRealPatron =>
      patronDominante.isNotEmpty &&
      patronDominante != 'Sin patron dominante';

  bool get hasControversies =>
      controversias.isNotEmpty ||
      antecedentes.isNotEmpty ||
      procesosJudiciales.isNotEmpty ||
      senales.isNotEmpty ||
      indiceFloro > 20;

  /// Whether this candidate has any real data to show (not empty/placeholder)
  bool get hasRealData =>
      indiceFloro > 0 ||
      controversias.isNotEmpty ||
      antecedentes.isNotEmpty ||
      procesosJudiciales.isNotEmpty ||
      senales.isNotEmpty ||
      cambiosPartido.isNotEmpty ||
      (pensionAlimenticia != 'no determinado' && pensionAlimenticia != 'no');

  /// Number of total red flags (for badge display)
  int get totalRedFlags =>
      controversias.length +
      antecedentes.length +
      procesosJudiciales.length +
      senales.length;

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
