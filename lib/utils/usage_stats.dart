/// Flat per-event runtime assumption for the "estimated saved" figure.
/// We can't know when the user would otherwise have turned the AC off, so
/// this is an explicit, clearly-labeled estimate — not a measurement.
const int kEstimatedSavedHoursPerEvent = 3;

/// Modes that represent an unattended shutdown the user might otherwise
/// have forgotten. Widget "transmit now" taps are attended, so they are
/// counted toward totals but excluded from the saved-runtime estimate.
const Set<String> _savedRuntimeModes = {'countdown', 'recurring', 'cycle'};

class UsageStatsSummary {
  final int totalTransmissions;
  final int last7Days;
  final int? lastTransmissionMs;
  final int estimatedSavedHours;

  const UsageStatsSummary({
    required this.totalTransmissions,
    required this.last7Days,
    required this.lastTransmissionMs,
    required this.estimatedSavedHours,
  });
}

/// Summarizes raw stats events (each a map with 't' epoch ms and 'mode').
UsageStatsSummary summarizeStats(List<dynamic> events, {int? nowMs}) {
  final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
  const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;

  int total = 0;
  int last7 = 0;
  int? lastMs;
  int savedEvents = 0;

  for (final e in events) {
    if (e is! Map) continue;
    final t = e['t'];
    final mode = e['mode']?.toString() ?? '';
    if (t is! int) continue;
    total++;
    if (now - t <= sevenDaysMs) last7++;
    if (lastMs == null || t > lastMs) lastMs = t;
    if (_savedRuntimeModes.contains(mode)) savedEvents++;
  }

  return UsageStatsSummary(
    totalTransmissions: total,
    last7Days: last7,
    lastTransmissionMs: lastMs,
    estimatedSavedHours: savedEvents * kEstimatedSavedHoursPerEvent,
  );
}
