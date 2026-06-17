import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_controller.dart';
import 'services/level_repository.dart';
import 'screens/game_screen.dart';
import 'utils/royal_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()),
        Provider(create: (_) => LevelRepository()),
        ChangeNotifierProvider(create: (_) => ProgressController()),
      ],
      child: const WordMatchApp(),
    ),
  );
}

// ── İLERLEME KONTROLCÜSÜ ──────────────────────────────────
// Uygulama kapanmadan kilitleri hafızada tutar
class ProgressController extends ChangeNotifier {
  int _unlockedUpTo = 1;
  int get unlockedUpTo => _unlockedUpTo;

  void unlockNext(int completedIndex) {
    if (completedIndex + 1 >= _unlockedUpTo) {
      _unlockedUpTo = completedIndex + 2;
      notifyListeners();
    }
  }
}

class WordMatchApp extends StatelessWidget {
  const WordMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Eşleştir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: RC.gold),
        useMaterial3: true,
      ),
      home: const LevelSelectScreen(),
    );
  }
}

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});
  @override
  State<LevelSelectScreen> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelectScreen> {
  List<dynamic> _levels = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<LevelRepository>();
    final levels = await repo.loadAll();
    setState(() {
      _levels = levels;
      _loading = false;
    });
  }

  void _startLevel(int index) async {
    final progress = context.read<ProgressController>();
    if (index >= progress.unlockedUpTo) return;

    final ctrl = context.read<GameController>();
    ctrl.startLevel(_levels[index]);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ctrl),
            Provider.value(value: context.read<LevelRepository>()),
            ChangeNotifierProvider.value(value: progress),
          ],
          child: const GameScreen(),
        ),
      ),
    );

    // Menüye dönünce kilitleri güncelle
    if (ctrl.phase == GamePhase.levelSuccess) {
      progress.unlockNext(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressController>(
      builder: (context, progress, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B0A3E), Color(0xFF0D0520)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text('👑 Kelime Eşleştir',
                      style: TextStyle(
                          color: RC.gold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const Text('İngilizce - Türkçe',
                      style: TextStyle(color: RC.muted, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.unlockedUpTo} / ${_levels.length} Seviye Açık',
                    style: const TextStyle(color: RC.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(color: RC.gold))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _levels.length,
                            itemBuilder: (context, i) {
                              final locked = i >= progress.unlockedUpTo;
                              final isNext = i == progress.unlockedUpTo - 1;
                              return GestureDetector(
                                onTap: () => _startLevel(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: locked
                                        ? const Color(0xFF120830)
                                        : isNext
                                            ? const Color(0xFF3D1A6E)
                                            : RC.panel,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: locked
                                          ? const Color(0xFF2A1050)
                                          : isNext
                                              ? RC.gold
                                              : RC.goldDark,
                                      width: isNext ? 2 : 1,
                                    ),
                                    boxShadow: isNext
                                        ? [
                                            BoxShadow(
                                                color: RC.gold.withOpacity(0.3),
                                                blurRadius: 8)
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: locked
                                        ? Icon(Icons.lock,
                                            color: const Color(0xFF3A2050),
                                            size: 16)
                                        : Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              color:
                                                  isNext ? RC.gold : RC.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
