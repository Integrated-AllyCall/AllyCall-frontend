String formatDuration(double seconds) {
  final int totalSeconds = seconds.floor();
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int secs = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}