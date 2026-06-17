import 'package:flutter/foundation.dart';
import '../models/level_data.dart';

enum GamePhase { idle, playing, levelSuccess, levelFailed }

class GameController extends ChangeNotifier {
  GamePhase _phase = GamePhase.idle;
  LevelData? _currentLevel;
  List<CardModel> _cards = [];
  List<TargetItem> _targets = [];
  int _movesRemaining = 0;
  int _totalMovesMade = 0;
  CardModel? _firstSelected;
  bool _inputLocked = false;
  int _rewardedAdsWatched = 0;

  GamePhase get phase => _phase;
  LevelData? get currentLevel => _currentLevel;
  List<CardModel> get cards => List.unmodifiable(_cards);
  List<TargetItem> get targets => List.unmodifiable(_targets);
  int get movesRemaining => _movesRemaining;
  int get totalMovesMade => _totalMovesMade;
  CardModel? get firstSelected => _firstSelected;
  bool get inputLocked => _inputLocked;
  bool get canWatchAd =>
      _rewardedAdsWatched < 1 && _phase == GamePhase.levelFailed;

  // Seviye bitişi: tüm kartlar eşleşti mi?
  bool get allCardsMatched => _cards.every(
      (c) => c.state == CardState.matched || c.state == CardState.removed);

  void startLevel(LevelData level) {
    _currentLevel = level;
    _cards = level.generateCards();
    _targets = level.targets.map((t) => t.copyWith(collected: 0)).toList();
    _movesRemaining = level.maxMoves;
    _totalMovesMade = 0;
    _firstSelected = null;
    _inputLocked = false;
    _rewardedAdsWatched = 0;
    _phase = GamePhase.playing;
    notifyListeners();
  }

  void restartLevel() {
    if (_currentLevel != null) startLevel(_currentLevel!);
  }

  Future<void> onCardTapped(CardModel card) async {
    if (_inputLocked) return;
    if (_phase != GamePhase.playing) return;
    if (card.state == CardState.removed || card.state == CardState.matched)
      return;
    if (card == _firstSelected) return;

    if (_firstSelected != null) {
      _movesRemaining--;
      _totalMovesMade++;
      if (_movesRemaining < 0) _movesRemaining = 0;
    }

    card.state = CardState.faceUp;

    if (_firstSelected == null) {
      _firstSelected = card;
      notifyListeners();
      return;
    }

    final second = card;
    _inputLocked = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final first = _firstSelected!;
    final isMatch = first.pairId == second.pairId && first.type != second.type;

    if (isMatch) {
      first.state = CardState.matched;
      second.state = CardState.matched;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
      first.state = CardState.removed;
      second.state = CardState.removed;
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      first.state = CardState.faceUp;
      second.state = CardState.faceUp;
    }

    _firstSelected = null;
    _inputLocked = false;
    _checkState();
    notifyListeners();
  }

  void _checkState() {
    // Kazanma koşulu: TÜM kartlar eşleşti
    if (allCardsMatched) {
      _phase = GamePhase.levelSuccess;
    } else if (_movesRemaining <= 0) {
      _phase = GamePhase.levelFailed;
    }
  }

  Future<void> watchAdForMoves() async {
    if (!canWatchAd) return;
    await Future.delayed(const Duration(seconds: 1));
    _movesRemaining += 5;
    _rewardedAdsWatched++;
    _phase = GamePhase.playing;
    _inputLocked = false;
    notifyListeners();
  }
}
