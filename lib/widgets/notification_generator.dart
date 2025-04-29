import 'dart:math';

String generateRandomNotification({String? userName}) {
  final List<String> notifications = [
    "New habit, new you! Let’s make it stick!",
    "Great choice! This habit could change your life.",
    "Every habit starts with a single step. You've got this!",
    "Consistency builds success. Well done!",
    "Discipline is choosing between what you want now and what you want most.",
    "You’re building the future, one habit at a time.",
    "Adding this habit is a step toward greatness!",
    "Tiny changes, remarkable results. Keep it up!",
    "Your journey just got stronger. Let’s go!",
    "Habits shape destiny — awesome move!"
  ];

  final random = Random();
  String baseMessage = notifications[random.nextInt(notifications.length)];

  if (userName != null && userName.isNotEmpty) {
    return "$userName, $baseMessage";
  } else {
    return baseMessage;
  }
}
