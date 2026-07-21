/// Default IR carrier frequency (Hz). Most ACs use 38 kHz; a few brands
/// use 36/40 kHz, which is why it is now per-profile.
const int kDefaultCarrierHz = 38000;

class DeviceProfile {
  String name;
  List<int> pattern;
  int frequency;

  DeviceProfile({
    required this.name,
    required this.pattern,
    this.frequency = kDefaultCarrierHz,
  });

  Map<String, dynamic> toJson() =>
      {'name': name, 'pattern': pattern, 'frequency': frequency};

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      name: json['name'],
      pattern: List<int>.from(json['pattern']),
      // Older profiles were saved without a frequency key.
      frequency: json['frequency'] as int? ?? kDefaultCarrierHz,
    );
  }

  static final List<DeviceProfile> defaultPresets = [
    DeviceProfile(name: 'LG / Beko / Arçelik', pattern: [9000,4500,560,560,560,1680,560,560,560,560,560,1680,560,560,560,560,560,1680,560,1680,560,1680,560,560,560,1680,560,1680,560,560,560,560,560,560,560,560,560,1680,560,560,560,560,560,560,560,560,560,560,560,560,560,1680,560,560,560,1680,560,1680,560,1680,560,1680,560,1680,560,1680,560,1680,560,40000]),
    DeviceProfile(name: 'Samsung', pattern: [3000,3000,500,1500,500,500,500,1500,500,500,500,1500,500,500,500,1500,500,500,500,1500,500,1500,500,500,500,1500,500,1500,500,500,500,500,500,500,500,1500,500,1500,500,500,500,1500,500,500,500,500,500,500,500,1500,500,1500,500,1500,500,1500,500,1500,500,1500,500]),
    DeviceProfile(name: 'Daikin', pattern: [3400,1700,450,450,450,1300,450,450,450,450,450,1300,450,450,450,450,450,1300,450,1300,450,1300,450,450,450,1300,450,1300,450,450,450,450,450,450,450,450,450,1300,450,450,450,450,450,450,450,450,450,450,450,450,450,1300,450,450,450,1300,450,1300,450,1300,450,1300,450,1300,450,1300,450,10000]),
    DeviceProfile(name: 'Dummy / Test', pattern: [9000,4500,560,560,560,1680,560,560,560,560]),
  ];
}
