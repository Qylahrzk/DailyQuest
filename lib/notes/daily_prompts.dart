class DailyPrompts {
  static List<String> prompts = [
    "Write about something you're grateful for.",
    "Describe your happiest memory.",
    "Note three goals for the week.",
    "Write about someone who inspires you.",
    "Describe your perfect day.",
  ];

  static String getTodayPrompt() {
    final day = DateTime.now().day;
    return prompts[day % prompts.length];
  }
}
