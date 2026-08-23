import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis.dart';

class StorageService {
  static const String _historyKey = 'analysis_history';
  static const String _tagsKey = 'analysis_tags';

  Future<void> saveAnalysis(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistoryRaw();

    final entry = result.toJson();
    history.add(entry);

    if (history.length > 100) {
      history.removeAt(0);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<List<AnalysisResult>> getHistory() async {
    final raw = await getHistoryRaw();
    return raw.map((e) => AnalysisResult.fromStorage(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getHistoryRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> deleteAnalysisAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistoryRaw();
    if (index < history.length) {
      history.removeAt(index);
      await prefs.setString(_historyKey, jsonEncode(history));
    }
  }

  Future<void> updateTag(String id, String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistoryRaw();
    for (var entry in history) {
      if (entry['timestamp'] == id ||
          (entry['mensagemOriginal']?.substring(0, 20) == id)) {
        entry['tagEmocional'] = tag;
        break;
      }
    }
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<List<String>> getAvailableTags() async {
    final prefs = await SharedPreferences.getInstance();
    final tagsStr = prefs.getString(_tagsKey);
    if (tagsStr == null || tagsStr.isEmpty) {
      return [
        'confuso',
        'aliviado',
        'preocupado',
        'feliz',
        'ansioso',
        'neutro'
      ];
    }
    try {
      return List<String>.from(jsonDecode(tagsStr));
    } catch (_) {
      return [
        'confuso',
        'aliviado',
        'preocupado',
        'feliz',
        'ansioso',
        'neutro'
      ];
    }
  }

  Future<void> addTag(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final tags = await getAvailableTags();
    if (!tags.contains(tag)) {
      tags.add(tag);
      await prefs.setString(_tagsKey, jsonEncode(tags));
    }
  }
}
