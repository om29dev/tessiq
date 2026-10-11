import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  SharedPreferences? _prefs;
  int bestStreak = 0;
  int currentStreak = 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    bestStreak = _prefs?.getInt('best_streak') ?? 0;
    currentStreak = _prefs?.getInt('current_streak') ?? 0;
  }

  Future<int> recordWin() async {
    currentStreak++;
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
      await _prefs?.setInt('best_streak', bestStreak);
    }
    await _prefs?.setInt('current_streak', currentStreak);
    return currentStreak;
  }

  Future<void> resetCurrentStreak() async {
    currentStreak = 0;
    await _prefs?.setInt('current_streak', 0);
  }
}
