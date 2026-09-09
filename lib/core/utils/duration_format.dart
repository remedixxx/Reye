String formatDurationClock(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final hours = safe.inHours;
  final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String formatShortDuration(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  if (safe.inHours > 0) {
    return '${safe.inHours}h ${safe.inMinutes.remainder(60)}m';
  }
  if (safe.inMinutes > 0) {
    return '${safe.inMinutes}m ${safe.inSeconds.remainder(60)}s';
  }
  return '${safe.inSeconds}s';
}
