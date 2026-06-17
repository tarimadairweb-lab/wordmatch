import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_controller.dart';
import '../services/level_repository.dart';
import '../models/level_data.dart';
import '../utils/royal_theme.dart';
import '../widgets/game_widgets.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, ctrl, _) {
        if (ctrl.currentLevel == null) {
          return const Scaffold(
            backgroundColor: RC.bg,
            body: Center(child: CircularProgressIndicator(color: RC.gold)),
          );
        }
        const crossAxis = 2;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B0A3E), Color(0xFF0D0520)],
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: RC.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Column(children: [
                              Text('Seviye ${ctrl.currentLevel!.id}',
                                  style: const TextStyle(
                                      color: RC.muted, fontSize: 11)),
                              Text(ctrl.currentLevel!.title,
                                  style: const TextStyle(
                                      color: RC.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            MovesCounter(
                              moves: ctrl.movesRemaining,
                              maxMoves: ctrl.currentLevel!.maxMoves,
                            ),
                          ],
                        ),
                      ),
                      TargetBar(targets: ctrl.targets),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxis,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: ctrl.cards.length,
                            itemBuilder: (context, i) {
                              final card = ctrl.cards[i];
                              return CardWidget(
                                card: card,
                                isSelected: card == ctrl.firstSelected,
                                onTap: ctrl.inputLocked
                                    ? null
                                    : () => ctrl.onCardTapped(card),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (ctrl.phase == GamePhase.levelSuccess ||
                    ctrl.phase == GamePhase.levelFailed)
                  ResultOverlay(
                    ctrl: ctrl,
                    onNextLevel: () async {
                      final repo = context.read<LevelRepository>();
                      final nextId = ctrl.currentLevel!.id + 1;
                      final next = await repo.getById(nextId);
                      if (next != null) {
                        ctrl.startLevel(next);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
