// Shared, validated parser for raw IR patterns entered as
// comma-separated microsecond durations ("9000, 4500, 560, ...").

/// A raw IR frame needs at least one mark/space pair.
const int kMinIrPatternLength = 2;

/// ConsumerIrManager rejects absurdly long patterns; 1024 marks is far
/// beyond any real AC frame.
const int kMaxIrPatternLength = 1024;

/// Sanity cap per mark/space — 500 ms is longer than any real IR burst.
const int kMaxIrMarkMicros = 500000;

/// Parses [input] into a list of microsecond durations, or returns null
/// when the input is empty, non-numeric, non-positive, or out of bounds.
List<int>? tryParseIrPattern(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final parts = trimmed.split(',');
  if (parts.length < kMinIrPatternLength || parts.length > kMaxIrPatternLength) {
    return null;
  }
  final pattern = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part.trim());
    if (value == null || value <= 0 || value > kMaxIrMarkMicros) return null;
    pattern.add(value);
  }
  return pattern;
}

String formatIrPattern(List<int> pattern) => pattern.join(', ');

/// Reasonable bounds for an IR carrier frequency (Hz). Consumer IR is
/// typically 36–40 kHz; this range is deliberately generous.
const int kMinCarrierHz = 20000;
const int kMaxCarrierHz = 60000;

/// Parses a carrier frequency in Hz, or null when out of range / invalid.
int? tryParseFrequency(String input) {
  final value = int.tryParse(input.trim());
  if (value == null || value < kMinCarrierHz || value > kMaxCarrierHz) {
    return null;
  }
  return value;
}

