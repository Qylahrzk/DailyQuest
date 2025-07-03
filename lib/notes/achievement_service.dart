class AchievementService {
  static int _xp = 0;

  static void addXp(int points) {
    _xp += points;
    print("XP is now $_xp");
    // Here you could show confetti, etc.
  }

  static void checkAchievements() {
    if (_xp >= 50) {
      print("Achievement unlocked: Note Taker!");
    }
  }
}
