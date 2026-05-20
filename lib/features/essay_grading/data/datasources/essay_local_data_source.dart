import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/essay_history_model.dart';

/// Local data source for caching essay history
/// Uses SharedPreferences for persistent storage
abstract class EssayLocalDataSource {
  /// Save a grading result to history
  Future<void> cacheResult(EssayHistoryModel item);

  /// Retrieve all cached history items
  Future<List<EssayHistoryModel>> getHistory();

  /// Delete a specific history item
  Future<void> deleteHistoryItem(String id);

  /// Clear all history
  Future<void> clearHistory();
}

class EssayLocalDataSourceImpl implements EssayLocalDataSource {
  final SharedPreferences sharedPreferences;

  EssayLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheResult(EssayHistoryModel item) async {
    try {
      final history = await getHistory();
      history.insert(0, item); // Add new item at the top

      final jsonList = history.map((h) => h.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await sharedPreferences.setString(AppConstants.historyKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to cache result: $e');
    }
  }

  @override
  Future<List<EssayHistoryModel>> getHistory() async {
    try {
      final jsonString = sharedPreferences.getString(AppConstants.historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((j) => EssayHistoryModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read history: $e');
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((item) => item.id == id);

      final jsonList = history.map((h) => h.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await sharedPreferences.setString(AppConstants.historyKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to delete history item: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await sharedPreferences.remove(AppConstants.historyKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear history: $e');
    }
  }
}
