import 'package:flutter/material.dart';
import 'data/card_repository.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RadarDelFloroApp());
}

class RadarDelFloroApp extends StatelessWidget {
  const RadarDelFloroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar del Floro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0d0d1a),
        colorScheme: ColorScheme.dark(
          primary: Colors.red[700]!,
          secondary: Colors.amber,
          surface: const Color(0xFF1a1a2e),
        ),
        fontFamily: 'Roboto',
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

class _LoadingScreenState extends State<LoadingScreen> {
  final _repository = CardRepository();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
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
      return const Scaffold(
        backgroundColor: Color(0xFF0d0d1a),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔍', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text(
                'Cargando candidatos...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Colors.red),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0d0d1a),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error cargando datos',
                style: TextStyle(color: Colors.red[300], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _loadData();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return HomeScreen(repository: _repository);
  }
}
