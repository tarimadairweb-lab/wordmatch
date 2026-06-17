import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level_data.dart';

class LevelRepository {
  List<LevelData>? _cache;

  Future<List<LevelData>> loadAll() async {
    if (_cache != null) return _cache!;
    final json = await rootBundle.loadString('assets/data/levels.json');
    final data = jsonDecode(json) as Map<String, dynamic>;
    _cache =
        (data['levels'] as List).map((e) => LevelData.fromJson(e)).toList();
    return _cache!;
  }

  Future<LevelData?> getById(int id) async {
    final levels = await loadAll();
    try {
      return levels.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> totalCount() async {
    final levels = await loadAll();
    return levels.length;
  }
}
