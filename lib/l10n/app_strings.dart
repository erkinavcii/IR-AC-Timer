// lib/l10n/app_strings.dart
// ─────────────────────────────────────────────────────────────
// Centralized localization strings for IR AC Timer.
//
// Architecture note:
//   Keeping all translations in one dedicated file is the
//   recommended approach for small/medium apps without the
//   overhead of ARB files or the flutter_localizations package.
//   If the app grows to 5+ languages, migrate to ARB + gen-l10n.
//
// Usage:
//   AppStrings.get('key')   → returns the string in current lang
//   AppStrings.setLang('en')
//   AppStrings.isTr         → bool shortcut
// ─────────────────────────────────────────────────────────────

class AppStrings {
  static String _lang = 'tr';
  static String get lang => _lang;
  static void setLang(String l) => _lang = l;
  static bool get isTr => _lang == 'tr';

  static final Map<String, Map<String, String>> _t = {
    // ── App header ─────────────────────────────────────────
    'appTitle':       {'tr': 'AC TIMER',                              'en': 'AC TIMER'},
    'appSubtitle':    {'tr': 'Ayarla & Unut · Klima Zamanlayıcı',    'en': 'Set & Forget · AC Scheduler'},

    // ── Status bar ─────────────────────────────────────────
    'irEmitter':      {'tr': 'Kızılötesi Verici',                     'en': 'IR Emitter'},
    'available':      {'tr': 'MEVCUT',                                'en': 'AVAILABLE'},
    'unavailable':    {'tr': 'YOK',                                   'en': 'NOT FOUND'},
    'exactAlarm':     {'tr': 'Hassas Zamanlama',                      'en': 'Exact Alarm'},
    'active':         {'tr': 'AKTİF',                                 'en': 'ACTIVE'},
    'grantPerm':      {'tr': 'İZİN VER',                              'en': 'GRANT'},
    'dozeBattery':    {'tr': 'Doze Modu',                             'en': 'Doze Mode'},
    'batteryExempt':  {'tr': 'MUAF',                                  'en': 'EXEMPT'},
    'disablePerm':    {'tr': 'KAPAT',                                 'en': 'DISABLE'},

    // ── Modes ──────────────────────────────────────────────
    'countdown':      {'tr': 'Geri Sayım',                            'en': 'Countdown'},
    'scheduled':      {'tr': 'Zamanlı',                               'en': 'Scheduled'},
    'cycle':          {'tr': 'Döngü',                                 'en': 'Cycle'},

    // ── Countdown picker ───────────────────────────────────
    'quickSelect':    {'tr': 'Hızlı Seçim',                           'en': 'Quick Select'},
    'customTime':     {'tr': 'Özel Süre',                             'en': 'Custom Time'},
    'hour':           {'tr': 'saat',                                  'en': 'hour'},
    'minute':         {'tr': 'dakika',                                'en': 'min'},

    // ── Controls ───────────────────────────────────────────
    'startTimer':     {'tr': 'ZAMANLAYICIYI BAŞLAT',                  'en': 'START TIMER'},
    'cancelTimer':    {'tr': 'İPTAL ET',                              'en': 'CANCEL'},

    // ── Active task display ────────────────────────────────
    'countdownActive':{'tr': 'GERİ SAYIM AKTİF',                     'en': 'COUNTDOWN ACTIVE'},
    'recurringActive':{'tr': 'GÜNLÜK ALARM AKTİF',                   'en': 'DAILY ALARM ACTIVE'},
    'cycleActive':    {'tr': 'DÖNGÜ AKTİF',                          'en': 'CYCLE ACTIVE'},
    'remaining':      {'tr': 'kalan süre',                            'en': 'remaining'},
    'everyDay':       {'tr': 'Her gün',                               'en': 'Every day'},
    'nextSignal':     {'tr': 'sonraki sinyal',                        'en': 'next signal'},
    'cycleUntil':     {'tr': 'Saat',                                  'en': 'Until'},

    // ── Scheduled (alarm) picker ───────────────────────────
    'scheduledTime':  {'tr': 'Kapatma Saati (Günlük Tekrarlar)',      'en': 'Shutdown Time (Daily Repeat)'},
    'scheduledDesc':  {'tr': 'Klima her gün belirlenen saatte kapanır.', 'en': 'AC shuts off daily at the set time.'},

    // ── Cycle picker ───────────────────────────────────────
    'cycleInterval':     {'tr': 'Tekrar Aralığı',                     'en': 'Repeat Interval'},
    'cycleIntervalDesc': {'tr': 'Her bu dakikada bir sinyal gönderilir', 'en': 'IR signal sent every this many minutes'},
    'cycleStart':        {'tr': 'Başlangıç Saati (Opsiyonel)',         'en': 'Start Time (Optional)'},
    'cycleStartDesc':    {'tr': 'Girilmezse şu an itibariyle başlar',  'en': 'If not set, starts from now'},
    'cycleStartEnabled': {'tr': 'Belirli bir saatten başlat',          'en': 'Start at a specific time'},
    'cycleEnd':          {'tr': 'Bitiş Saati (Opsiyonel)',             'en': 'End Time (Optional)'},
    'cycleEndDesc':      {'tr': 'Belirlenen saate kadar tekrarlar, sonra durur', 'en': 'Repeats until the set time, then stops'},
    'cycleNoEnd':        {'tr': 'Süresiz (iptal edilene kadar)',        'en': 'Indefinite (until cancelled)'},
    'cycleNoStart':      {'tr': 'Hemen şimdi başlar',                  'en': 'Starts immediately'},
    'cycleEvery':        {'tr': 'Her',                                 'en': 'Every'},
    'cycleMin':          {'tr': 'dakikada bir',                        'en': 'minutes'},
    'cycleQuick':        {'tr': 'Hızlı Seçim',                        'en': 'Quick Select'},

    // ── Device profile management ──────────────────────────
    'irManagement':   {'tr': 'Klima Profilleri',                      'en': 'AC Profiles'},
    'activeProfile':  {'tr': 'Aktif Profil',                          'en': 'Active Profile'},
    'irPatternLabel': {'tr': 'Ham IR Sinyal Kodları (μs)',             'en': 'Raw IR Signal Pattern (μs)'},
    'saveChanges':    {'tr': 'Kaydet',                                'en': 'Save'},
    'testSignal':     {'tr': 'SİNYALİ TEST ET',                       'en': 'TEST SIGNAL'},
    'addProfile':     {'tr': 'Yeni Profil Ekle',                      'en': 'Add New Profile'},
    'editProfile':    {'tr': 'Profili Düzenle',                       'en': 'Edit Profile'},
    'profileName':    {'tr': 'Profil Adı',                            'en': 'Profile Name'},
    'profileNameHint':{'tr': 'Örn: Yatak Odası Vestel',              'en': 'e.g. Bedroom Vestel'},
    'signalPattern':  {'tr': 'Kapatma Sinyal Kodu (Raw)',             'en': 'Off Signal Pattern (Raw)'},
    'cancel':         {'tr': 'İptal',                                 'en': 'Cancel'},
    'add':            {'tr': 'Ekle',                                  'en': 'Add'},
    'save':           {'tr': 'Kaydet',                                'en': 'Save'},

    // ── Xiaomi warning ─────────────────────────────────────
    'xiaomiWarning':  {'tr': 'Xiaomi / Redmi / Poco Uyarısı',        'en': 'Xiaomi / Redmi / Poco Warning'},
    'xiaomiDesc':     {'tr': 'Agresif güç yöneticisi arka plan görevlerini sonlandırabilir. Otomatik Başlatma listesine eklemeyi unutmayın.', 'en': 'Aggressive power management may kill background tasks. Add this app to Autostart list.'},
    'openAutostart':  {'tr': 'Otomatik Başlatma Ayarları',            'en': 'Open Autostart Settings'},

    // ── Feedback / snackbars ───────────────────────────────
    'timerSetOk':     {'tr': 'Zamanlayıcı başarıyla kuruldu!',        'en': 'Timer scheduled successfully!'},
    'alarmSetOk':     {'tr': 'Günlük alarm kuruldu!',                 'en': 'Daily alarm scheduled!'},
    'cycleSetOk':     {'tr': 'Döngü başarıyla başlatıldı!',          'en': 'Cycle started successfully!'},
    'timerCancelled': {'tr': 'Zamanlama iptal edildi.',               'en': 'Timer cancelled.'},
    'invalidPattern': {'tr': 'IR kodu geçersiz!',                     'en': 'Invalid IR pattern!'},
    'needExactAlarm': {'tr': 'Hassas Zamanlama izni gerekli.',        'en': 'Exact Alarm permission required.'},
    'needDuration':   {'tr': 'Süre 0\'dan büyük olmalı.',            'en': 'Duration must be greater than 0.'},
    'testSent':       {'tr': 'Test sinyali gönderildi!',              'en': 'Test signal sent!'},
    'testFailed':     {'tr': 'Gönderim başarısız!',                   'en': 'Transmission failed!'},
    'savedOk':        {'tr': 'Değişiklikler kaydedildi.',             'en': 'Changes saved.'},
    'profileExists':  {'tr': 'Bu isimde profil var.',                 'en': 'Profile name already exists.'},
    'minOneProfile':  {'tr': 'En az bir profil olmalı.',              'en': 'At least one profile required.'},
    'autostartFail':  {'tr': 'Ayarlar açılamadı. Manuel deneyin.',   'en': 'Could not open settings. Try manually.'},
  };

  static String get(String key) => _t[key]?[_lang] ?? _t[key]?['tr'] ?? key;
}
