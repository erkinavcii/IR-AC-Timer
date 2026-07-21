// Pure countdown/progress math shared by the active-task UI.

/// Formats a duration as "HH:MM:SS".
String formatHms(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// Formats an epoch timestamp as "HH:mm" in local time.
String formatHmFromEpoch(int epochMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Remaining fraction of a countdown: 1.0 just after scheduling, 0.0 at fire.
double countdownProgress({
  required int targetEpochMs,
  required int scheduledEpochMs,
  required int nowEpochMs,
}) {
  final total = targetEpochMs - scheduledEpochMs;
  if (total <= 0) return 0.0;
  return ((targetEpochMs - nowEpochMs) / total).clamp(0.0, 1.0);
}

/// Elapsed fraction of the current cycle interval: 0.0 right after a fire,
/// approaching 1.0 as the next trigger nears.
double cycleProgress({
  required int nextTriggerEpochMs,
  required int intervalMinutes,
  required int nowEpochMs,
}) {
  final intervalMs = intervalMinutes * 60 * 1000;
  if (intervalMs <= 0) return 0.0;
  final remaining = nextTriggerEpochMs - nowEpochMs;
  return 1.0 - (remaining / intervalMs).clamp(0.0, 1.0);
}
