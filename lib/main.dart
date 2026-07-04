import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_strings.dart';
import 'splash_screen.dart';

// ─────────────────────────────────────────────────────────────
// Theme Constants
// ─────────────────────────────────────────────────────────────
class AppColors {
  static const Color bg = Color(0xFF05050A);
  static const Color card = Color(0xFF0D0D14);
  static const Color cardBorder = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF12121C);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentDim = Color(0xFF0A3D4F);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFFF5252);
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textDim = Color(0xFF555570);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D0D14), Color(0xFF10101A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─────────────────────────────────────────────────────────────
// Device Profile Model
// ─────────────────────────────────────────────────────────────
class DeviceProfile {
  String name;
  List<int> pattern;

  DeviceProfile({required this.name, required this.pattern});

  Map<String, dynamic> toJson() => {'name': name, 'pattern': pattern};

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      name: json['name'],
      pattern: List<int>.from(json['pattern']),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final ValueNotifier<String> langNotifier = ValueNotifier('tr');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MyApp.langNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    MyApp.langNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() {
    AppStrings.setLang(MyApp.langNotifier.value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AC Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.card,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Animated Glow Ring Widget
// ─────────────────────────────────────────────────────────────
class GlowRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double glowIntensity;

  GlowRingPainter({required this.progress, required this.color, this.glowIntensity = 0.4});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;
    const strokeWidth = 6.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Progress ring
    final ringPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: [color, color.withOpacity(0.6), color],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      ringPaint,
    );

    // Endpoint dot
    final dotAngle = -math.pi / 2 + sweepAngle;
    final dotPos = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(dotPos, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant GlowRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const MethodChannel _channel =
      MethodChannel('com.example.ir_ac_timer/ir');

  // Status
  bool _hasIr = false;
  bool _exactAlarmGranted = false;
  bool _batteryOptimizationIgnored = false;
  Map<String, dynamic>? _activeTask;
  Timer? _countdownTimer;
  Timer? _statusPollTimer;
  String _timeRemainingStr = "";
  double _countdownProgress = 0.0;

  // Inputs
  String _selectedMode = "countdown";
  int _selectedHour = 1;
  int _selectedMinute = 0;
  int _alarmHour = 3;
  int _alarmMinute = 0;

  // Cycle mode state
  int _cycleIntervalMinutes = 30;
  bool _cycleHasStartTime = false;
  int _cycleStartHour = 22;
  int _cycleStartMinute = 0;
  bool _cycleHasEndTime = false;
  int _cycleEndHour = 9;
  int _cycleEndMinute = 0;

  // Profiles
  List<DeviceProfile> _profiles = [];
  DeviceProfile? _selectedProfile;
  final TextEditingController _irPatternController = TextEditingController();
  bool _showProfiles = false;

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static final List<DeviceProfile> _defaultPresets = [
    DeviceProfile(name: 'LG / Beko / Arçelik', pattern: [9000,4500,560,560,560,1680,560,560,560,560,560,1680,560,560,560,560,560,1680,560,1680,560,1680,560,560,560,1680,560,1680,560,560,560,560,560,560,560,560,560,1680,560,560,560,560,560,560,560,560,560,560,560,560,560,1680,560,560,560,1680,560,1680,560,1680,560,1680,560,1680,560,1680,560,1680,560,40000]),
    DeviceProfile(name: 'Samsung', pattern: [3000,3000,500,1500,500,500,500,1500,500,500,500,1500,500,500,500,1500,500,500,500,1500,500,1500,500,500,500,1500,500,1500,500,500,500,500,500,500,500,1500,500,1500,500,500,500,1500,500,500,500,500,500,500,500,1500,500,1500,500,1500,500,1500,500,1500,500,1500,500]),
    DeviceProfile(name: 'Daikin', pattern: [3400,1700,450,450,450,1300,450,450,450,450,450,1300,450,450,450,450,450,1300,450,1300,450,1300,450,450,450,1300,450,1300,450,450,450,450,450,450,450,450,450,1300,450,450,450,450,450,450,450,450,450,450,450,450,450,1300,450,450,450,1300,450,1300,450,1300,450,1300,450,1300,450,1300,450,10000]),
    DeviceProfile(name: 'Dummy / Test', pattern: [9000,4500,560,560,560,1680,560,560,560,560]),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadProfilesAndStatus();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatusAndTask());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _statusPollTimer?.cancel();
    _irPatternController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkStatusAndTask();
  }

  // ── Data Methods ──────────────────────────────────────────
  Future<void> _loadProfilesAndStatus() async {
    await _loadDeviceProfiles();
    await _checkStatusAndTask();
  }

  Future<void> _loadDeviceProfiles() async {
    try {
      final String? profilesJsonStr = await _channel.invokeMethod('getProfiles');
      final String? selectedName = await _channel.invokeMethod('getSelectedProfile');
      List<DeviceProfile> loaded = [];
      if (profilesJsonStr != null && profilesJsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(profilesJsonStr);
        loaded = decoded.map((e) => DeviceProfile.fromJson(e)).toList();
      }
      if (loaded.isEmpty) {
        loaded = List.from(_defaultPresets);
        await _saveProfilesToStore(loaded);
      }
      DeviceProfile selected = loaded.firstWhere(
        (p) => p.name == selectedName,
        orElse: () => loaded.first,
      );
      setState(() {
        _profiles = loaded;
        _selectedProfile = selected;
        _irPatternController.text = selected.pattern.join(', ');
      });
    } catch (e) {
      debugPrint("Error loading profiles: $e");
    }
  }

  Future<void> _saveProfilesToStore(List<DeviceProfile> list) async {
    await _channel.invokeMethod('saveProfiles', {'profiles': jsonEncode(list.map((e) => e.toJson()).toList())});
  }

  Future<void> _updateSelectedProfile(DeviceProfile? p) async {
    if (p == null) return;
    setState(() {
      _selectedProfile = p;
      _irPatternController.text = p.pattern.join(', ');
    });
    await _channel.invokeMethod('saveSelectedProfile', {'name': p.name});
  }

  Future<void> _addProfile(String name, List<int> pattern) async {
    if (name.isEmpty) return;
    if (_profiles.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      _snack(AppStrings.get('profileExists'), AppColors.warning);
      return;
    }
    final np = DeviceProfile(name: name, pattern: pattern);
    final updated = List<DeviceProfile>.from(_profiles)..add(np);
    await _saveProfilesToStore(updated);
    setState(() => _profiles = updated);
    await _updateSelectedProfile(np);
  }

  Future<void> _editProfile(DeviceProfile old, String newName, List<int> newPattern) async {
    if (newName.isEmpty) return;
    final updated = _profiles.map((p) {
      if (p.name == old.name) return DeviceProfile(name: newName, pattern: newPattern);
      return p;
    }).toList();
    await _saveProfilesToStore(updated);
    setState(() => _profiles = updated);
    await _updateSelectedProfile(updated.firstWhere((p) => p.name == newName));
  }

  Future<void> _deleteProfile(DeviceProfile profile) async {
    if (_profiles.length <= 1) {
      _snack(AppStrings.get('minOneProfile'), AppColors.warning);
      return;
    }
    final updated = List<DeviceProfile>.from(_profiles)..removeWhere((p) => p.name == profile.name);
    await _saveProfilesToStore(updated);
    setState(() => _profiles = updated);
    await _updateSelectedProfile(updated.first);
  }

  Future<void> _saveChangesToCurrentProfile() async {
    if (_selectedProfile == null) return;
    final pattern = _parsePattern();
    if (pattern == null) return;
    await _editProfile(_selectedProfile!, _selectedProfile!.name, pattern);
    _snack(AppStrings.get('savedOk'), AppColors.success);
  }

  Future<void> _checkStatusAndTask() async {
    try {
      final bool hasIr = await _channel.invokeMethod('hasIrEmitter');
      final Map<dynamic, dynamic>? perms = await _channel.invokeMethod('checkPermissions');
      final bool exact = perms?['exactAlarmGranted'] ?? false;
      final bool battery = perms?['batteryOptimizationIgnored'] ?? false;
      final String? taskStr = await _channel.invokeMethod('getTask');
      Map<String, dynamic>? task;
      if (taskStr != null) task = jsonDecode(taskStr) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _hasIr = hasIr;
          _exactAlarmGranted = exact;
          _batteryOptimizationIgnored = battery;
          _activeTask = task;
        });
        _updateCountdown();
      }
    } catch (e) {
      debugPrint("Status check error: $e");
    }
  }

  void _updateCountdown() {
    _countdownTimer?.cancel();
    if (_activeTask == null) return;
    final String mode = _activeTask!['mode'] ?? '';
    if (mode == 'countdown') {
      final int target = _activeTask!['oneTimeEpochMillis'] ?? 0;
      final int scheduled = _activeTask!['scheduledTime'] ?? 0;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final int now = DateTime.now().millisecondsSinceEpoch;
        final int total = target - scheduled;
        final int remaining = target - now;
        if (remaining <= 0) {
          timer.cancel();
          _checkStatusAndTask();
        } else {
          final d = Duration(milliseconds: remaining);
          if (mounted) {
            setState(() {
              _timeRemainingStr = "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
              _countdownProgress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
            });
          }
        }
      });
    } else if (mode == 'recurring') {
      final h = _activeTask!['targetHour'] ?? 0;
      final m = _activeTask!['targetMinute'] ?? 0;
      if (mounted) {
        setState(() {
          _timeRemainingStr = "${AppStrings.get('everyDay')} ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
          _countdownProgress = 1.0;
        });
      }
    } else if (mode == 'cycle') {
      final int intervalMin = _activeTask!['cycleIntervalMinutes'] ?? 30;
      final int nextTriggerEpoch = _activeTask!['nextTriggerEpochMillis'] ?? 0;
      final int endEpoch = _activeTask!['cycleEndEpochMillis'] ?? 0;

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Re-read from active task in case it updated
        final int curNext = _activeTask?['nextTriggerEpochMillis'] ?? nextTriggerEpoch;
        final int now = DateTime.now().millisecondsSinceEpoch;
        final int remaining = curNext - now;
        if (remaining <= 0) {
          timer.cancel();
          _checkStatusAndTask();
          return;
        }
        final d = Duration(milliseconds: remaining);
        final String endStr = endEpoch > 0
            ? DateTime.fromMillisecondsSinceEpoch(endEpoch).hour.toString().padLeft(2, '0') +
              ':' +
              DateTime.fromMillisecondsSinceEpoch(endEpoch).minute.toString().padLeft(2, '0')
            : '';
        if (mounted) {
          setState(() {
            _timeRemainingStr = "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
            _countdownProgress = 1.0 - (remaining / (intervalMin * 60 * 1000)).clamp(0.0, 1.0);
            if (endStr.isNotEmpty) {
              // Store end time string for display
            }
          });
        }
      });
    }
  }

  // ── Actions ───────────────────────────────────────────────
  Future<void> _requestExactAlarm() async => await _channel.invokeMethod('requestExactAlarmPermission');
  Future<void> _requestIgnoreBattery() async => await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
  Future<void> _openAutostart() async {
    final bool ok = await _channel.invokeMethod('openAutostartSettings');
    if (!ok && mounted) _snack(AppStrings.get('autostartFail'), AppColors.warning);
  }

  List<int>? _parsePattern() {
    try {
      final p = _irPatternController.text.split(',').map((e) => int.parse(e.trim())).toList();
      if (p.isEmpty) throw Exception();
      return p;
    } catch (_) {
      _snack(AppStrings.get('invalidPattern'), AppColors.danger);
      return null;
    }
  }

  Future<void> _startTimer() async {
    if (!_exactAlarmGranted) { _snack(AppStrings.get('needExactAlarm'), AppColors.warning); return; }
    final pattern = _parsePattern();
    if (pattern == null) return;
    int dur = 0;
    if (_selectedMode == 'countdown') {
      dur = (_selectedHour * 60) + _selectedMinute;
      if (dur <= 0) { _snack(AppStrings.get('needDuration'), AppColors.warning); return; }
    }
    try {
      final Map<String, dynamic> args = {
        'mode': _selectedMode,
        'targetHour': _selectedMode == 'recurring' ? _alarmHour : 0,
        'targetMinute': _selectedMode == 'recurring' ? _alarmMinute : 0,
        'durationMinutes': dur,
        'pattern': pattern,
      };
      if (_selectedMode == 'cycle') {
        args['cycleIntervalMinutes'] = _cycleIntervalMinutes;
        args['cycleStartHour'] = _cycleHasStartTime ? _cycleStartHour : -1;
        args['cycleStartMinute'] = _cycleHasStartTime ? _cycleStartMinute : -1;
        args['cycleEndHour'] = _cycleHasEndTime ? _cycleEndHour : -1;
        args['cycleEndMinute'] = _cycleHasEndTime ? _cycleEndMinute : -1;
      }
      final bool ok = await _channel.invokeMethod('scheduleTask', args);
      if (ok) {
        _checkStatusAndTask();
        String successMsg;
        switch (_selectedMode) {
          case 'countdown': successMsg = AppStrings.get('timerSetOk'); break;
          case 'recurring': successMsg = AppStrings.get('alarmSetOk'); break;
          case 'cycle':     successMsg = AppStrings.get('cycleSetOk'); break;
          default:          successMsg = AppStrings.get('timerSetOk');
        }
        _snack(successMsg, AppColors.success);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.danger);
    }
  }

  Future<void> _cancelActiveTask() async {
    try {
      await _channel.invokeMethod('cancelTask');
      _countdownTimer?.cancel();
      setState(() { _activeTask = null; _timeRemainingStr = ""; _countdownProgress = 0.0; });
      _snack(AppStrings.get('timerCancelled'), AppColors.danger);
    } catch (e) { debugPrint("Cancel error: $e"); }
  }

  Future<void> _testTransmit() async {
    final pattern = _parsePattern();
    if (pattern == null) return;
    try {
      final bool ok = await _channel.invokeMethod('transmitIr', {'pattern': pattern});
      _snack(ok ? AppStrings.get('testSent') : AppStrings.get('testFailed'), ok ? AppColors.success : AppColors.danger);
    } catch (e) {
      _snack('Error: $e', AppColors.danger);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
      ]),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Dialogs ───────────────────────────────────────────────
  void _showAddProfileDialog() {
    final nc = TextEditingController();
    final cc = TextEditingController(text: "9000, 4500, 560, 560");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.get('addProfile'), style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(nc, AppStrings.get('profileName'), AppStrings.get('profileNameHint')),
          const SizedBox(height: 12),
          _dialogField(cc, AppStrings.get('signalPattern'), '9000, 4500, 560...', maxLines: 3),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              try {
                final p = cc.text.split(',').map((e) => int.parse(e.trim())).toList();
                if (nc.text.trim().isNotEmpty && p.isNotEmpty) { _addProfile(nc.text.trim(), p); Navigator.pop(context); }
              } catch (_) { _snack(AppStrings.get('invalidPattern'), AppColors.danger); }
            },
            child: Text(AppStrings.get('add')),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_selectedProfile == null) return;
    final nc = TextEditingController(text: _selectedProfile!.name);
    final cc = TextEditingController(text: _selectedProfile!.pattern.join(', '));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.get('editProfile'), style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(nc, AppStrings.get('profileName'), ''),
          const SizedBox(height: 12),
          _dialogField(cc, AppStrings.get('signalPattern'), '', maxLines: 3),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              try {
                final p = cc.text.split(',').map((e) => int.parse(e.trim())).toList();
                if (nc.text.trim().isNotEmpty && p.isNotEmpty) { _editProfile(_selectedProfile!, nc.text.trim(), p); Navigator.pop(context); }
              } catch (_) { _snack(AppStrings.get('invalidPattern'), AppColors.danger); }
            },
            child: Text(AppStrings.get('save')),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontFamily: maxLines > 1 ? 'monospace' : 'Roboto'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDim),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatusRow(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _activeTask != null
                    ? _buildActiveView(key: const ValueKey('active'))
                    : _buildSetupView(key: const ValueKey('setup')),
              ),
              const SizedBox(height: 24),
              _buildProfilesSection(),
              const SizedBox(height: 16),
              if (_activeTask == null) _buildXiaomiCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        // Animated icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, __) => Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3 * _pulseAnimation.value), blurRadius: 16, spreadRadius: 2)],
            ),
            child: const Icon(Icons.ac_unit_rounded, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                child: Text(AppStrings.get('appTitle'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white)),
              ),
              Text(AppStrings.get('appSubtitle'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.5)),
            ],
          ),
        ),
        // Language toggle
        GestureDetector(
          onTap: () {
            final next = AppStrings.isTr ? 'en' : 'tr';
            MyApp.langNotifier.value = next;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(AppStrings.isTr ? '🇹🇷' : '🇬🇧', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(AppStrings.isTr ? 'TR' : 'EN', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Status Row ────────────────────────────────────────────
  Widget _buildStatusRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _statusItem(AppStrings.get('irEmitter'), _hasIr ? AppStrings.get('available') : AppStrings.get('unavailable'), _hasIr ? AppColors.success : AppColors.danger, null),
          _statusDivider(),
          _statusItem(AppStrings.get('exactAlarm'), _exactAlarmGranted ? AppStrings.get('active') : AppStrings.get('grantPerm'), _exactAlarmGranted ? AppColors.success : AppColors.warning, _exactAlarmGranted ? null : _requestExactAlarm),
          _statusDivider(),
          _statusItem(AppStrings.get('dozeBattery'), _batteryOptimizationIgnored ? AppStrings.get('batteryExempt') : AppStrings.get('disablePerm'), _batteryOptimizationIgnored ? AppColors.success : AppColors.warning, _batteryOptimizationIgnored ? null : _requestIgnoreBattery),
        ],
      ),
    );
  }

  Widget _statusItem(String label, String value, Color color, VoidCallback? onTap) {
    final child = Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(value, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
        ),
      ],
    );
    return Expanded(child: onTap != null ? GestureDetector(onTap: onTap, child: child) : child);
  }

  Widget _statusDivider() => Container(width: 1, height: 32, color: AppColors.cardBorder, margin: const EdgeInsets.symmetric(horizontal: 4));

  // ── Active Task View ──────────────────────────────────────
  Widget _buildActiveView({Key? key}) {
    final mode = _activeTask?['mode'] ?? '';
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.05), blurRadius: 30, spreadRadius: 5)],
      ),
      child: Column(children: [
        Text(
          mode == 'countdown' ? AppStrings.get('countdownActive')
              : mode == 'cycle' ? AppStrings.get('cycleActive')
              : AppStrings.get('recurringActive'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 200, height: 200,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => CustomPaint(
              painter: GlowRingPainter(progress: _countdownProgress, color: AppColors.accent, glowIntensity: 0.2 + 0.2 * _pulseAnimation.value),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_timeRemainingStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: mode == 'countdown' || mode == 'cycle' ? 28 : 18,
                      fontWeight: FontWeight.w300, color: AppColors.textPrimary, letterSpacing: 2)),
                const SizedBox(height: 4),
                if (mode == 'countdown') Text(AppStrings.get('remaining'), style: const TextStyle(color: AppColors.textDim, fontSize: 11))
                else if (mode == 'cycle') ...[Text(AppStrings.get('nextSignal'), style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
                  if ((_activeTask?['cycleEndEpochMillis'] ?? 0) > 0) ...[const SizedBox(height: 4),
                    Text('${AppStrings.get('cycleUntil')} ${DateTime.fromMillisecondsSinceEpoch(_activeTask!['cycleEndEpochMillis'] as int).hour.toString().padLeft(2,'0')}:${DateTime.fromMillisecondsSinceEpoch(_activeTask!['cycleEndEpochMillis'] as int).minute.toString().padLeft(2,'0')}', style: const TextStyle(color: AppColors.warning, fontSize: 10))]]
                else if (mode == 'recurring') Text(AppStrings.get('everyDay'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
              ])),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _gradientButton(AppStrings.get('cancelTimer'), AppColors.dangerGradient, Icons.close, _cancelActiveTask),
      ]),
    );
  }

  // ── Setup View ────────────────────────────────────────────
  Widget _buildSetupView({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Mode tabs
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          _modeTab('countdown', Icons.timer_outlined, AppStrings.get('countdown')),
          _modeTab('recurring', Icons.alarm_rounded, AppStrings.get('scheduled')),
          _modeTab('cycle', Icons.loop_rounded, AppStrings.get('cycle')),
        ]),
      ),
      const SizedBox(height: 24),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedMode == 'countdown'
            ? _buildCountdownPicker(key: const ValueKey('cp'))
            : _selectedMode == 'recurring'
                ? _buildAlarmPicker(key: const ValueKey('ap'))
                : _buildCyclePicker(key: const ValueKey('cyc')),
      ),
      const SizedBox(height: 24),
      _gradientButton(AppStrings.get('startTimer'), AppColors.accentGradient, Icons.play_arrow_rounded, _startTimer),
    ]);
  }

  Widget _modeTab(String mode, IconData icon, String label) {
    final sel = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: sel ? Border.all(color: AppColors.accent.withOpacity(0.2)) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: sel ? AppColors.accent : AppColors.textDim),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? AppColors.textPrimary : AppColors.textDim)),
          ]),
        ),
      ),
    );
  }

  // ── Countdown Picker ──────────────────────────────────────
  Widget _buildCountdownPicker({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(AppStrings.get('quickSelect'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _presetChip('15m', 0, 15), _presetChip('30m', 0, 30), _presetChip('1h', 1, 0),
        _presetChip('1.5h', 1, 30), _presetChip('2h', 2, 0), _presetChip('3h', 3, 0), _presetChip('4h', 4, 0),
      ]),
      const SizedBox(height: 20),
      Text(AppStrings.get('customTime'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _wheelPicker(_selectedHour, 12, AppStrings.get('hour'), (v) => setState(() => _selectedHour = v)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
        _wheelPicker(_selectedMinute, 59, AppStrings.get('minute'), (v) => setState(() => _selectedMinute = v)),
      ]),
    ]);
  }

  Widget _presetChip(String label, int h, int m) {
    final sel = _selectedHour == h && _selectedMinute == m;
    return GestureDetector(
      onTap: () => setState(() { _selectedHour = h; _selectedMinute = m; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.accent.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.accent.withOpacity(0.5) : AppColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(color: sel ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  Widget _wheelPicker(int val, int max, String label, ValueChanged<int> onChanged) {
    return Container(
      width: 90, height: 110,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(children: [
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 38, perspective: 0.004, diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: val),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max + 1,
              builder: (_, i) {
                if (i < 0 || i > max) return null;
                final s = i == val;
                return Center(child: Text(i.toString().padLeft(2, '0'), style: TextStyle(fontSize: s ? 22 : 16, fontWeight: s ? FontWeight.w700 : FontWeight.w400, color: s ? AppColors.accent : AppColors.textDim)));
              },
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDim))),
      ]),
    );
  }

  // ── Alarm Picker ──────────────────────────────────────────
  Widget _buildAlarmPicker({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(AppStrings.get('scheduledTime'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _wheelPicker(_alarmHour, 23, AppStrings.get('hour'), (v) => setState(() => _alarmHour = v)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
        _wheelPicker(_alarmMinute, 59, AppStrings.get('minute'), (v) => setState(() => _alarmMinute = v)),
      ]),
      const SizedBox(height: 10),
      Text(AppStrings.get('scheduledDesc'), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
    ]);
  }

  // ── Cycle Picker ──────────────────────────────────────────
  Widget _buildCyclePicker({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── Interval ──
      Text(AppStrings.get('cycleInterval'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(AppStrings.get('cycleIntervalDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
      const SizedBox(height: 12),
      // Quick interval chips
      Wrap(spacing: 8, runSpacing: 8, children: [
        _cycleChip('10m', 10), _cycleChip('15m', 15), _cycleChip('20m', 20),
        _cycleChip('30m', 30), _cycleChip('45m', 45), _cycleChip('60m', 60),
        _cycleChip('90m', 90),
      ]),
      const SizedBox(height: 14),
      // Custom interval wheel
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 90, height: 110,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
          child: Column(children: [
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 38, perspective: 0.004, diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(initialItem: _cycleIntervalMinutes),
                onSelectedItemChanged: (v) => setState(() => _cycleIntervalMinutes = v == 0 ? 1 : v),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 121,
                  builder: (_, i) {
                    if (i == 0) return null;
                    final s = i == _cycleIntervalMinutes;
                    return Center(child: Text('$i', style: TextStyle(fontSize: s ? 22 : 16, fontWeight: s ? FontWeight.w700 : FontWeight.w400, color: s ? AppColors.accent : AppColors.textDim)));
                  },
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(AppStrings.get('minute'), style: const TextStyle(fontSize: 10, color: AppColors.textDim))),
          ]),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${AppStrings.get('cycleEvery')} $_cycleIntervalMinutes ${AppStrings.get('cycleMin')}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(AppStrings.get('cycleIntervalDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
        ])),
      ]),
      const SizedBox(height: 20),
      // ── Start Time ──
      Row(children: [
        Expanded(child: Text(AppStrings.get('cycleStart'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
        Switch(
          value: _cycleHasStartTime,
          onChanged: (v) => setState(() => _cycleHasStartTime = v),
          activeColor: AppColors.accent,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ]),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _cycleHasStartTime ? Column(children: [
          const SizedBox(height: 8),
          Text(AppStrings.get('cycleStartDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _wheelPicker(_cycleStartHour, 23, AppStrings.get('hour'), (v) => setState(() => _cycleStartHour = v)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
            _wheelPicker(_cycleStartMinute, 59, AppStrings.get('minute'), (v) => setState(() => _cycleStartMinute = v)),
          ]),
        ]) : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(AppStrings.get('cycleNoStart'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        ),
      ),
      const SizedBox(height: 20),
      // ── End Time ──
      Row(children: [
        Expanded(child: Text(AppStrings.get('cycleEnd'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
        Switch(
          value: _cycleHasEndTime,
          onChanged: (v) => setState(() => _cycleHasEndTime = v),
          activeColor: AppColors.accent,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ]),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _cycleHasEndTime ? Column(children: [
          const SizedBox(height: 8),
          Text(AppStrings.get('cycleEndDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _wheelPicker(_cycleEndHour, 23, AppStrings.get('hour'), (v) => setState(() => _cycleEndHour = v)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
            _wheelPicker(_cycleEndMinute, 59, AppStrings.get('minute'), (v) => setState(() => _cycleEndMinute = v)),
          ]),
        ]) : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(AppStrings.get('cycleNoEnd'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        ),
      ),
    ]);
  }


  Widget _cycleChip(String label, int minutes) {
    final sel = _cycleIntervalMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _cycleIntervalMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.accent.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.accent.withOpacity(0.5) : AppColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(color: sel ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  // ── Gradient Button ───────────────────────────────────────
  Widget _gradientButton(String label, LinearGradient gradient, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ]),
      ),
    );
  }

  // ── Profiles Section ──────────────────────────────────────
  Widget _buildProfilesSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GestureDetector(
          onTap: () => setState(() => _showProfiles = !_showProfiles),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.devices_other_rounded, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppStrings.get('irManagement'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                if (_selectedProfile != null) Text(_selectedProfile!.name, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
              ])),
              AnimatedRotation(turns: _showProfiles ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, color: AppColors.textDim)),
            ]),
          ),
        ),
        if (_showProfiles) ...[
          const Divider(color: AppColors.cardBorder, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(AppStrings.get('activeProfile'), style: const TextStyle(fontSize: 11, color: AppColors.textDim, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DeviceProfile>(
                        value: _selectedProfile,
                        isExpanded: true,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        onChanged: _updateSelectedProfile,
                        items: _profiles.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _iconBtn(Icons.edit_outlined, _showEditProfileDialog),
                _iconBtn(Icons.add_rounded, _showAddProfileDialog),
                _iconBtn(Icons.delete_outline, () { if (_selectedProfile != null) _deleteProfile(_selectedProfile!); }, color: AppColors.danger),
              ]),
              const SizedBox(height: 14),
              Text(AppStrings.get('irPatternLabel'), style: const TextStyle(fontSize: 11, color: AppColors.textDim, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _irPatternController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '9000, 4500, 560, 560...',
                  hintStyle: const TextStyle(color: AppColors.textDim),
                  filled: true, fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testTransmit,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text(AppStrings.get('testSignal'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 40),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveChangesToCurrentProfile,
                  icon: const Icon(Icons.save_outlined, size: 16, color: Colors.black),
                  label: Text(AppStrings.get('saveChanges'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = AppColors.textSecondary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ── Xiaomi Card ───────────────────────────────────────────
  Widget _buildXiaomiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Text(AppStrings.get('xiaomiWarning'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning.withOpacity(0.9), fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(AppStrings.get('xiaomiDesc'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _openAutostart,
          child: Container(
            height: 36,
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.settings_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(AppStrings.get('openAutostart'), style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 11)),
            ]),
          ),
        ),
      ]),
    );
  }
}
