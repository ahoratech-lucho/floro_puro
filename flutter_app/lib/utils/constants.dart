import 'package:flutter/material.dart';

// CDN base URL - change when you deploy to Vercel
const String cdnBaseUrl = 'https://radardelfloro.vercel.app';
const String caricatureUrlBase = '$cdnBaseUrl/images/caricatures/';
const String photoUrlBase = '$cdnBaseUrl/images/photos/';

// Game config
const int cardsPerRound = 15;
const int guaranteedInterestingCards = 3;

// Scoring
const int scoreExactMatch = 3;
const int scoreAdjacentMatch = 1;
const int scoreMiss = 0;

// Colors
const Color colorAlertaMaxima = Color(0xFFDC2626);
const Color colorBanderaRoja = Color(0xFFEA580C);
const Color colorMuchoFloro = Color(0xFFF59E0B);
const Color colorDudoso = Color(0xFF3B82F6);
const Color colorPasaRaspando = Color(0xFF22C55E);

const Color colorBg = Color(0xFF0F172A);
const Color colorCard = Color(0xFF1E293B);
const Color colorAccent = Color(0xFFF59E0B);

Color colorForNivel(String nivel) {
  switch (nivel) {
    case 'Alerta maxima':
      return colorAlertaMaxima;
    case 'Bandera roja':
      return colorBanderaRoja;
    case 'Mucho floro':
      return colorMuchoFloro;
    case 'Dudoso':
      return colorDudoso;
    default:
      return colorPasaRaspando;
  }
}
