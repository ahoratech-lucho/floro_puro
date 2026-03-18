import 'package:flutter/material.dart';

// CDN base URL
// For dev:  'http://localhost:9090'
// For prod: '' (same origin — nginx serves images from /images/)
const String cdnBaseUrl = const String.fromEnvironment(
  'CDN_URL',
  defaultValue: 'http://localhost:9090',
);
const String caricatureUrlBase = '$cdnBaseUrl/images/caricaturas_webp/';
const String photoUrlBase = '$cdnBaseUrl/images/photos_webp/';

// Game config
const int cardsPerRound = 15;
const int guaranteedInterestingCards = 3;

// Scoring
const int scoreExactMatch = 3;
const int scoreAdjacentMatch = 1;
const int scoreMiss = 0;

// ===== NEWSPAPER / EDITORIAL THEME =====

// Risk level colors (kept vibrant for contrast on light bg)
const Color colorAlertaMaxima = Color(0xFFC62828); // deep red
const Color colorBanderaRoja = Color(0xFFD84315); // deep orange
const Color colorMuchoFloro = Color(0xFFE65100); // orange
const Color colorDudoso = Color(0xFF1565C0); // blue
const Color colorPasaRaspando = Color(0xFF2E7D32); // green

// Main palette — newspaper/editorial
const Color colorBg = Color(0xFFF5F0EB);         // warm cream paper
const Color colorBgWhite = Color(0xFFFFFDF8);     // white paper
const Color colorCard = Colors.white;             // card white
const Color colorCardBorder = Color(0xFFD5CEC5);  // subtle warm border
const Color colorDivider = Color(0xFFBDB5AA);     // newspaper rule line

// Text colors
const Color colorTextPrimary = Color(0xFF1A1A1A);   // near-black
const Color colorTextSecondary = Color(0xFF4A4A4A);  // dark gray
const Color colorTextTertiary = Color(0xFF7A7A7A);   // medium gray
const Color colorTextMuted = Color(0xFFAAAAAA);       // light gray

// Accent colors — editorial red + ink blue
const Color colorAccentRed = Color(0xFFC62828);      // editorial red
const Color colorAccentRedLight = Color(0xFFFFEBEE);  // light red bg
const Color colorAccentInk = Color(0xFF1A237E);       // dark ink blue
const Color colorAccentGold = Color(0xFFBF8A30);      // muted gold, not neon

// Interactive
const Color colorChipSelected = Color(0xFF1A1A1A);   // black chip when selected
const Color colorChipDefault = Color(0xFFF0ECE6);    // cream chip default
const Color colorButtonPrimary = Color(0xFFC62828);   // red CTA
const Color colorButtonText = Colors.white;

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
