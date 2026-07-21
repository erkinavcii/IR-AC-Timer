import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';
import '../controllers/task_controller.dart';
import '../l10n/app_strings.dart';
import '../main.dart';
import '../services/ir_platform_service.dart';
import '../theme/app_colors.dart';
import '../utils/ir_pattern.dart';
import '../utils/wizard_off_mapping.dart';
import '../widgets/active_task_view.dart';
import '../widgets/find_my_ac_wizard.dart';
import '../widgets/profiles_section.dart';
import '../widgets/setup_view.dart';
import '../widgets/status_row.dart';
import '../widgets/xiaomi_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final IrPlatformService _service = IrPlatformService();
  late final ProfileController _profileController = ProfileController(_service);
  late final TaskController _taskController = TaskController(_service);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    _profileController.load();
    _taskController.startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _profileController.dispose();
    _taskController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _taskController.refresh();
  }

  // ── Actions ───────────────────────────────────────────────
  Future<void> _startTimer(TaskSetupData data) async {
    if (!_taskController.exactAlarmGranted) {
      _snack(AppStrings.get('needExactAlarm'), AppColors.warning);
      return;
    }
    final pattern = _profileController.parseCurrentPattern();
    if (pattern == null) {
      _snack(AppStrings.get('invalidPattern'), AppColors.danger);
      return;
    }
    if (data.mode == 'countdown' && data.durationMinutes <= 0) {
      _snack(AppStrings.get('needDuration'), AppColors.warning);
      return;
    }
    try {
      final ok = await _taskController.schedule(data, pattern,
          frequency: _profileController.currentFrequency);
      if (ok) {
        final successMsg = switch (data.mode) {
          'recurring' => AppStrings.get('alarmSetOk'),
          'cycle' => AppStrings.get('cycleSetOk'),
          _ => AppStrings.get('timerSetOk'),
        };
        _snack(successMsg, AppColors.success);
      }
    } catch (e) {
      _snack('Error: $e', AppColors.danger);
    }
  }

  Future<void> _cancelActiveTask() async {
    try {
      await _taskController.cancelActiveTask();
      _snack(AppStrings.get('timerCancelled'), AppColors.danger);
    } catch (e) {
      debugPrint('Cancel error: $e');
    }
  }

  Future<void> _testTransmit() async {
    final pattern = _profileController.parseCurrentPattern();
    if (pattern == null) {
      _snack(AppStrings.get('invalidPattern'), AppColors.danger);
      return;
    }
    await _transmitWithFeedback(pattern);
  }

  Future<void> _transmitWithFeedback(List<int> pattern) async {
    try {
      final ok = await _taskController.transmit(pattern,
          frequency: _profileController.currentFrequency);
      _snack(ok ? AppStrings.get('testSent') : AppStrings.get('testFailed'),
          ok ? AppColors.success : AppColors.danger);
    } catch (e) {
      _snack('Error: $e', AppColors.danger);
    }
  }

  Future<void> _requestExactAlarm() => _service.requestExactAlarmPermission();
  Future<void> _requestIgnoreBattery() => _service.requestIgnoreBatteryOptimizations();
  Future<void> _openAutostart() async {
    final ok = await _service.openAutostartSettings();
    if (!ok && mounted) _snack(AppStrings.get('autostartFail'), AppColors.warning);
  }

  // ── Wizard callbacks ──────────────────────────────────────
  Future<void> _testWizardSignal(String patternStr) async {
    final pattern = tryParseIrPattern(patternStr);
    if (pattern == null) return;
    await _transmitWithFeedback(pattern);
  }

  Future<void> _saveWizardResult(Map<String, String> set) async {
    final resolution = resolveWizardSave(set);

    if (resolution.kind == WizardSaveKind.missingOff) {
      _showInfoDialog(
        titleKey: 'missingOffTitle',
        bodyKey: 'missingOffBody',
        buttonKey: 'missingOffBtn',
        titleColor: AppColors.warning,
      );
      return;
    }

    final pattern = tryParseIrPattern(resolution.patternStr);
    if (pattern == null) return;
    await _profileController.upsert(resolution.profileName, pattern);

    if (resolution.kind == WizardSaveKind.mappedToOff) {
      _showInfoDialog(
        titleKey: 'smartOffTitle',
        bodyKey: 'smartOffBody',
        buttonKey: 'smartOffBtn',
        titleColor: AppColors.success,
      );
    } else {
      _snack('${AppStrings.get("wizardSaved")} ${resolution.profileName}', AppColors.success);
    }
  }

  void _showInfoDialog({
    required String titleKey,
    required String bodyKey,
    required String buttonKey,
    required Color titleColor,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.get(titleKey), style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
        content: Text(AppStrings.get(bodyKey), style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get(buttonKey), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _taskController,
          builder: (context, _) {
            final activeTask = _taskController.activeTask;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  StatusRow(
                    hasIr: _taskController.hasIr,
                    exactAlarmGranted: _taskController.exactAlarmGranted,
                    batteryOptimizationIgnored: _taskController.batteryOptimizationIgnored,
                    onRequestExactAlarm: _requestExactAlarm,
                    onRequestIgnoreBattery: _requestIgnoreBattery,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: activeTask != null
                        ? ActiveTaskView(
                            key: const ValueKey('active'),
                            task: activeTask,
                            timeRemainingStr: _taskController.timeRemainingStr,
                            progress: _taskController.countdownProgress,
                            pulseAnimation: _pulseAnimation,
                            onCancel: _cancelActiveTask,
                          )
                        : SetupView(key: const ValueKey('setup'), onStart: _startTimer),
                  ),
                  const SizedBox(height: 24),
                  ProfilesSection(
                    controller: _profileController,
                    onTestTransmit: _testTransmit,
                    onSnack: _snack,
                  ),
                  const SizedBox(height: 16),
                  if (activeTask == null) ...[
                    FindMyAcCard(
                      onTestSignal: _testWizardSignal,
                      onSaveResult: _saveWizardResult,
                    ),
                    const SizedBox(height: 16),
                    XiaomiCard(onOpenAutostart: _openAutostart),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
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
            _service.setLanguage(next);
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
}
