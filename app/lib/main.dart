import 'package:flutter/material.dart';
import 'data/card_repository.dart';
import 'data/score_service.dart';
import 'data/theme_service.dart';
import 'data/sound_service.dart';
import 'data/security_service.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

final themeService = ThemeService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeService.init();
  await SoundService.init();
  runApp(const RadarDelFloroApp());
}

class RadarDelFloroApp extends StatefulWidget {
  const RadarDelFloroApp({super.key});

  @override
  State<RadarDelFloroApp> createState() => _RadarDelFloroAppState();
}

class _RadarDelFloroAppState extends State<RadarDelFloroApp> {
  @override
  void initState() {
    super.initState();
    themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar del Floro',
      debugShowCheckedModeBanner: false,
      themeMode: themeService.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: colorBg,
        colorScheme: ColorScheme.light(
          primary: colorAccentRed,
          secondary: colorAccentInk,
          surface: colorCard,
          onSurface: colorTextPrimary,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: colorBgWhite,
          foregroundColor: colorTextPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: colorCard,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: colorCardBorder, width: 0.5),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: colorAccentRed,
          secondary: colorAccentInk,
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFE0E0E0),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFFE0E0E0),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF333333), width: 0.5),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  final _repository = CardRepository();
  bool _loading = true;
  String? _error;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Security check
      final security = await SecurityService.checkSecurity();
      if (!security.isSecure && mounted) {
        setState(() {
          _loading = false;
          _error = '⚠️ ${security.warning}\n\nPor seguridad, la app no puede ejecutarse en dispositivos modificados.';
        });
        return;
      }

      await ScoreService.init();
      await _repository.loadCards();
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: colorBgWhite,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spinController,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorAccentRed,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      '?!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'RADAR DEL FLORO',
                style: TextStyle(
                  color: colorTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 200,
                height: 1,
                color: colorTextPrimary,
              ),
              const SizedBox(height: 4),
              const Text(
                'ELECCIONES PERÚ 2026',
                style: TextStyle(
                  color: colorTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  backgroundColor: colorCardBorder.withAlpha(77),
                  valueColor: const AlwaysStoppedAnimation<Color>(colorAccentRed),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cargando candidatos...',
                style: TextStyle(color: colorTextTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colorBgWhite,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: colorAccentRed, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error cargando datos',
                style: TextStyle(
                  color: colorAccentRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: const TextStyle(color: colorTextTertiary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _spinController.repeat();
                  _loadData();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccentRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return HomeScreen(repository: _repository);
  }
}
