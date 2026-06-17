import 'package:flutter/foundation.dart';

class TargetItem {
  final String icon;
  final String iconColor;
  final int count;
  int collected;

  TargetItem(
      {required this.icon,
      required this.iconColor,
      required this.count,
      this.collected = 0});

  factory TargetItem.fromJson(Map<String, dynamic> json) => TargetItem(
        icon: json['icon'] as String,
        iconColor: json['iconColor'] as String,
        count: json['count'] as int,
      );

  bool get isCompleted => collected >= count;
  int get remaining => (count - collected).clamp(0, count);

  TargetItem copyWith({int? collected}) => TargetItem(
        icon: icon,
        iconColor: iconColor,
        count: count,
        collected: collected ?? this.collected,
      );
}

class WordPair {
  final String english;
  final String turkish;
  final String icon;
  final String iconColor;
  const WordPair(
      {required this.english,
      required this.turkish,
      required this.icon,
      required this.iconColor});
  factory WordPair.fromJson(Map<String, dynamic> json) => WordPair(
        english: json['english'] as String,
        turkish: json['turkish'] as String,
        icon: json['icon'] as String,
        iconColor: json['iconColor'] as String,
      );
}

enum CardType { english, turkish }

enum CardState { faceDown, faceUp, matched, removed }

class CardModel {
  final String id;
  final String pairId;
  final String text;
  final CardType type;
  final String icon;
  final String iconColor;
  CardState state;

  CardModel(
      {required this.id,
      required this.pairId,
      required this.text,
      required this.type,
      required this.icon,
      required this.iconColor,
      this.state = CardState.faceUp});

  bool get isVisible => state != CardState.removed;
  bool get isMatched => state == CardState.matched;
}

class LevelData {
  final int id;
  final String title;
  final int maxMoves;
  final List<WordPair> wordPairs;
  final List<TargetItem> targets;

  const LevelData(
      {required this.id,
      required this.title,
      required this.maxMoves,
      required this.wordPairs,
      required this.targets});

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
        id: json['id'] as int,
        title: json['title'] as String,
        maxMoves: json['maxMoves'] as int,
        wordPairs: (json['wordPairs'] as List)
            .map((e) => WordPair.fromJson(e))
            .toList(),
        targets: (json['targets'] as List)
            .map((e) => TargetItem.fromJson(e))
            .toList(),
      );

  List<CardModel> generateCards() {
    final english = <CardModel>[];
    final turkish = <CardModel>[];

    for (int i = 0; i < wordPairs.length; i++) {
      final pair = wordPairs[i];
      final pairId = 'pair_${id}_$i';
      english.add(CardModel(
        id: '${pairId}_EN',
        pairId: pairId,
        text: pair.english,
        type: CardType.english,
        icon: pair.icon,
        iconColor: pair.iconColor,
        state: CardState.faceUp,
      ));
      turkish.add(CardModel(
        id: '${pairId}_TR',
        pairId: pairId,
        text: pair.turkish,
        type: CardType.turkish,
        icon: pair.icon,
        iconColor: pair.iconColor,
        state: CardState.faceUp,
      ));
    }

    // Türkçeleri karıştır (İngilizceler sabit solda kalır)
    turkish.shuffle();

    // Sol sütun EN, sağ sütun TR olacak şekilde birleştir
    final result = <CardModel>[];
    for (int i = 0; i < english.length; i++) {
      result.add(english[i]);
      result.add(turkish[i]);
    }
    return result;
  }
}
