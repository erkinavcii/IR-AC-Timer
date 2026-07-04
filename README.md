# IR AC Timer

> **Ayarla & Unut** — Kızılötesi vericili Android cihazlar için hafif, güvenilir klima kapatma zamanlayıcısı.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-7.0%2B-3DDC84?logo=android)](https://developer.android.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## İçindekiler

- [Genel Bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Nasıl Çalışır](#nasıl-çalışır)
- [Gereksinimler](#gereksinimler)
- [Kurulum ve Derleme](#kurulum-ve-derleme)
- [Proje Yapısı](#proje-yapısı)
- [Zamanlama Modları](#zamanlama-modları)
- [Klima Profilleri (IR Kodları)](#klima-profilleri-ir-kodları)
- [İzin Yönetimi](#i̇zin-yönetimi)
- [Xiaomi / MIUI / HyperOS Uyarısı](#xiaomi--miui--hyperos-uyarısı)
- [Mimari Kararlar](#mimari-kararlar)
- [Yerelleştirme (TR / EN)](#yerelleştirme-tr--en)
- [Bilinen Kısıtlamalar](#bilinen-kısıtlamalar)
- [Katkıda Bulunma](#katkıda-bulunma)

---

## Genel Bakış

**IR AC Timer**, uyurken ya da odayı terk ederken klimanızı otomatik olarak kapatmak için tasarlanmış "Set & Forget" (Ayarla ve Unut) bir Android uygulamasıdır. Çalışma prensibi son derece basittir:

1. Telefonunuzu klimanın karşısına IR (kızılötesi) vericisi yönlenecek şekilde koyun.
2. Uygulamada kapatma süresini veya saatini ayarlayın.
3. **Başlat**'a basın, telefonu bırakın.

Telefon derin uyku (Doze Mode) moduna geçse bile, Android'in `AlarmManager.setExactAndAllowWhileIdle()` API'si sayesinde IR sinyali tam zamanında gönderilir.

---

## Özellikler

| Özellik | Açıklama |
|---------|----------|
| 🕐 **Geri Sayım Modu** | "X dakika/saat sonra kapat" — tek seferlik |
| ⏰ **Zamanlı (Tekrarlı) Mod** | Her gün belirli bir saatte klima kapatır |
| 🔁 **Döngü Modu** | Her X dakikada bir sinyal gönderir, opsiyonel başlangıç ve bitiş saati desteğiyle |
| 📱 **Persistent Bildirim** | Sonsuz döngü aktifken bildirim panelinde görünür uyarı |
| 📡 **Çoklu Klima Profili** | LG/Beko/Arçelik, Samsung, Daikin ve özel profiller |
| ✏️ **Ham IR Kodu Düzenleme** | Her profil için raw μs sinyal dizisi düzenlenebilir |
| 🧪 **Test Modu** | Kaydetmeden önce sinyali anlık olarak test edin |
| 🌍 **TR / EN Dil Desteği** | Anlık dil geçişi, yeniden başlatma gerektirmez |
| 🔋 **Doze Mode Uyumlu** | `setExactAndAllowWhileIdle` + `RECEIVE_BOOT_COMPLETED` |
| 🔄 **Yeniden Başlatma Sonrası Geri Yükleme** | Telefon yeniden başlasa bile aktif görev devam eder |
| 🌑 **AMOLED Koyu Tema** | Saf siyah arka plan, düşük pil tüketimi |

---

## Nasıl Çalışır

```
Flutter UI (Dart)
      │
      │  MethodChannel  "com.example.ir_ac_timer/ir"
      ▼
MainActivity.kt
  ├── scheduleTask()   →  AlarmManager.setExactAndAllowWhileIdle()
  ├── cancelTask()     →  AlarmManager.cancel() + Bildirim temizleme
  └── transmitIr()    →  ConsumerIrManager.transmit(38kHz, pattern[])

AlarmManager (System)
      │ Doze Mode'da bile tetiklenir
      ▼
AlarmReceiver.kt (BroadcastReceiver)
  ├── ConsumerIrManager.transmit() → IR sinyali gönder
  ├── mode == "countdown"  → SharedPreferences temizle
  ├── mode == "recurring"  → Ertesi güne yeniden planla
  └── mode == "cycle"
        ├── endEpoch == 0   → Süresiz: yeniden planla + bildirim güncelle
        └── endEpoch > now  → Zaman doldu: temizle + bildirim kapat

BootReceiver.kt (BOOT_COMPLETED)
  └── SharedPreferences'tan görevi oku → AlarmManager'a geri yükle
```

---

## Gereksinimler

### Donanım
- **IR Verici (blaster)** olan bir Android cihaz gereklidir.
  - Xiaomi Redmi Note serileri ✅
  - Huawei P/Mate serileri ✅
  - Samsung Galaxy S4-S6 ✅ (sonraki modellerde kaldırıldı)
  - OnePlus 2, HTC One serileri ✅

> ⚠️ Cihazınızın IR vericisi olup olmadığını uygulama açılışında otomatik kontrol eder. "IR Emitter: YOK" görünüyorsa cihaz desteklenmiyordur.

### Yazılım
| Bileşen | Minimum Versiyon |
|---------|-----------------|
| Android SDK | API 24 (Android 7.0) |
| Flutter SDK | 3.0+ |
| Kotlin | 1.8+ |
| Gradle | 8.x |

---

## Kurulum ve Derleme

### 1. Repo'yu Klonla

```bash
git clone https://github.com/kullaniciadi/IR-AC-Timer.git
cd IR-AC-Timer
```

### 2. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 3. Debug APK Derle

```bash
flutter build apk --debug
# Çıktı: build/app/outputs/flutter-apk/app-debug.apk
```

### 4. Release APK Derle (imzalama gerektirir)

```bash
flutter build apk --release
```

### 5. Bağlı Cihaza Yükle

```bash
flutter run
```

---

## Proje Yapısı

```
IR-AC-Timer/
├── lib/
│   ├── main.dart                    # UI, state management, MethodChannel çağrıları
│   └── l10n/
│       └── app_strings.dart         # Tüm TR/EN çeviriler (tek dosya)
│
├── android/app/src/main/
│   ├── AndroidManifest.xml          # İzinler ve receiver tanımları
│   └── kotlin/com/example/ir_ac_timer/ir_ac_timer/
│       ├── MainActivity.kt          # MethodChannel handler, scheduleTask, cancelTask
│       ├── AlarmReceiver.kt         # IR tetikleyici, döngü/recurring yeniden planlama
│       ├── BootReceiver.kt          # Reboot sonrası görev geri yükleme
│       └── NotificationHelper.kt   # Sonsuz döngü bildirimi yönetimi
│
└── README.md
```

---

## Zamanlama Modları

### 1. Geri Sayım Modu (`countdown`)

Belirtilen süre sonunda tek bir IR sinyali gönderir ve görev tamamlanır.

**Kullanım:**
- Hızlı seçim: 15m, 30m, 1s, 1.5s, 2s, 3s, 4s
- Özel süre: Saat + Dakika tekerleği ile

**Örnek senaryo:** "30 dakika sonra klimayı kapat, uyumak istiyorum."

---

### 2. Zamanlı Mod (`recurring`)

Her gün belirli bir saatte IR sinyali gönderir. Siz iptal edene kadar tekrarlar.

**Kullanım:** Saat:Dakika tekerleğiyle kapatma saati seç.

**Örnek senaryo:** "Klima her gece 03:00'da kapansın."

**Not:** Sinyal saati geçmişse ertesi güne planlanır.

---

### 3. Döngü Modu (`cycle`)

Belirli aralıklarla tekrarlayan IR sinyalleri gönderir.

**Parametreler:**

| Parametre | Açıklama | Varsayılan |
|-----------|----------|-----------|
| **Aralık** | Kaç dakikada bir sinyal (1-120 dk) | 30 dk |
| **Başlangıç Saati** | Opsiyonel — girilmezse hemen başlar | Şu an |
| **Bitiş Saati** | Opsiyonel — girilmezse sonsuz tekrar | Süresiz |

**Örnek senaryolar:**

| Senaryo | Ayar |
|---------|------|
| "Şimdi başla, 30dk'da bir kapat, sabah 9'a kadar" | Aralık: 30m · Başlangıç: kapalı · Bitiş: 09:00 |
| "Gece 23:00'dan itibaren her saatte bir kapat" | Aralık: 60m · Başlangıç: 23:00 · Bitiş: kapalı |
| "Hemen başla, sonsuz tekrar et" | Aralık: 30m · İkisi de kapalı |

**Sonsuz döngü bildirimi:**
> Bitiş saati belirtilmeden başlatılan döngülerde bildirim panelinde kalıcı bir uyarı görünür. Uygulamayı açmadan hatırlatma sağlar.

---

## Klima Profilleri (IR Kodları)

Uygulama, ham IR sinyal dizisi (raw μs pattern) kullanır. Her sinyal `[HIGH, LOW, HIGH, LOW, ...]` formatında mikrosaniye değerlerinden oluşur ve 38 kHz taşıyıcı frekansıyla iletilir.

### Dahili Ön Ayarlar

| Marka | Durum |
|-------|-------|
| LG / Beko / Arçelik | ✅ Dahili |
| Samsung | ✅ Dahili |
| Daikin | ✅ Dahili |
| Dummy / Test | ✅ Dahili (kısa test sinyali) |

> ⚠️ Bu kodlar yalnızca **KAPATMA (OFF)** sinyali içindir. Klimanızın tam olarak kapanması için doğru sinyal kodunu kullanmanız gerekir.

### Kendi IR Kodunuzu Eklemek

1. Klimanızın model numarasıyla [IRDB](https://github.com/probonopd/irdb) veya [LIRC Remote](http://lirc-remotes.sourceforge.net/) sitelerinden `.lircd` formatında kodu bulun.
2. Raw μs değerlerini virgülle ayrılmış formata dönüştürün.
3. Uygulamada **Klima Profilleri → Yeni Profil Ekle** ile girin.
4. **Sinyali Test Et** butonuyla klimanızın kapandığını doğrulayın.
5. **Kaydet** ile aktif profil olarak ayarlayın.

### Ham Kod Formatı

```
9000, 4500, 560, 560, 560, 1680, 560, 560, ...
```

- Pozitif değerler = IR LED açık süresi (μs)  
- Tüm değerler pozitif — HIGH/LOW sıralaması codec tarafından otomatik yapılır
- Minimum 4, maksimum birkaç yüz değer

---

## İzin Yönetimi

Uygulama açılışında üç kritik izni kontrol eder:

### 1. Hassas Zamanlama (`SCHEDULE_EXACT_ALARM`)

Android 12+ (API 31+) için gerekli. Bu izin olmadan `setExactAndAllowWhileIdle()` `SecurityException` fırlatır.

**Kontrol:** `AlarmManager.canScheduleExactAlarms()`  
**Yönlendirme:** Ayarlar → Uygulamalar → IR AC Timer → Alarmlar ve hatırlatıcılar

### 2. Pil Optimizasyonundan Muafiyet (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`)

Doze Mode'da `AlarmReceiver`'ın arka planda tetiklenebilmesi için gerekli.

**Kontrol:** `PowerManager.isIgnoringBatteryOptimizations()`  
**Yönlendirme:** Sistem diyaloğu otomatik açılır

### 3. Bildirim İzni (`POST_NOTIFICATIONS`)

Android 13+ (API 33+) için, sonsuz döngü bildirimini gösterebilmek için gerekli.

**Not:** Bu izin olmadan sonsuz döngü çalışmaya devam eder, yalnızca bildirim gösterilmez.

### İzin Durumu Göstergesi

Ana ekranın üst kısmındaki 3 kutucuk izin durumlarını gösterir. Turuncu renkli kutu bir eksiklik var demektir; üstüne dokunarak ilgili ayar sayfası açılır.

---

## Xiaomi / MIUI / HyperOS Uyarısı

Xiaomi cihazları (Redmi, POCO dahil) agresif bir pil yöneticisi kullanır. Sistem izinleri tam verilmiş olsa bile arka plan görevleri sonlandırılabilir.

**Yapılması gerekenler:**

1. **Otomatik Başlatma:** Ayarlar → Pil → Otomatik Başlatma → IR AC Timer: **Açık**
2. **Pil Tasarrufu:** Ayarlar → Pil → Pil Tasarrufu → IR AC Timer: **Kısıtlama yok**
3. **Arka Plan Etkinliği:** Uygulama Bilgisi → Pil → Arka Plan kısıtlaması: **Yok**

Uygulama içinde **"Otomatik Başlatma Ayarları"** butonuna dokunarak MIUI'nin ilgili ekranına doğrudan yönlendirilebilirsiniz.

---

## Mimari Kararlar

### Neden Flutter + Native Kotlin?

| Kısım | Teknoloji | Gerekçe |
|-------|-----------|---------|
| UI | Flutter (Dart) | Hızlı geliştirme, platform bağımsız |
| IR iletimi | Kotlin (ConsumerIrManager) | Flutter'da doğrudan API erişimi yok |
| Zamanlama | Kotlin (AlarmManager) | WorkManager Doze Mode'da güvenilir değil |
| Depolama | Android SharedPreferences | Minimal, process ölümünden sonra hayatta kalır |

### Neden WorkManager değil AlarmManager?

`WorkManager`'ın `PeriodicWorkRequest` sınıfı 15 dakika minimum aralık kısıtlaması ve Doze Mode gecikmesi içerir. `AlarmManager.setExactAndAllowWhileIdle()` ise zaman hassasiyetini garanti eder — bu uygulama için kritiktir.

### Döngü Modunun Çalışma Prensibi

Döngü modu bir `setInterval` değil, **kendi kendini yeniden planlayan** tek alarmlar zinciridir:

```
[Alarm tetiklenir]
      │
      ├── IR sinyali gönder
      ├── Bitiş zamanı kontrol et
      │     ├── Geçti → SharedPreferences temizle, bildirim kapat
      │     └── Geçmedi → now + interval için yeni alarm kur, bildirim güncelle
      └── [döngü devam eder]
```

Bu yaklaşım, sistem tarafından `setRepeating()` veya `PeriodicWorkRequest`'ten çok daha güvenilir şekilde handle edilir.

---

## Yerelleştirme (TR / EN)

Tüm kullanıcıya görünen metinler `lib/l10n/app_strings.dart` dosyasında merkezileştirilmiştir.

```dart
// Kullanım
AppStrings.get('startTimer')  // → "ZAMANLAYICIYI BAŞLAT" veya "START TIMER"

// Dil değiştirme (anlık, yeniden başlatma gerektirmez)
MyApp.langNotifier.value = 'en';
```

**Mimari not:** Küçük/orta ölçekli uygulamalar için ARB + `flutter_localizations` paketinin ek karmaşıklığı yerine tek dosya yaklaşımı tercih edilmiştir. 5'ten fazla dil eklenmesi gerektiğinde `gen-l10n` altyapısına geçiş önerilir.

Yeni çeviri eklemek için `app_strings.dart` dosyasındaki `_t` map'ine satır eklemeniz yeterlidir:

```dart
'myNewKey': {'tr': 'Türkçe metin', 'en': 'English text'},
```

---

## Bilinen Kısıtlamalar

| Kısıtlama | Neden | Geçici Çözüm |
|-----------|-------|-------------|
| Yalnızca **KAPATMA** sinyali | Klima durumuna göre değişen kompleks state yönetimi gerektirir | Sinyal kodu olarak klimanızın kapatma kodunu girin |
| ESP32 / Wi-Fi IR desteklenmiyor | Ağ yığını ve gecikme yönetimi ekler, farklı proje gerektirir | Yalnızca dahili IR blaster kullanılır |
| Maksimum döngü aralığı 120 dk | UI kısıtı — Kotlin tarafı herhangi bir değeri kabul eder | Kod düzenlenerek arttırılabilir |
| iOS desteklenmiyor | iOS'ta `ConsumerIrManager` eşdeğeri yok | — |

---

## Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun: `git checkout -b feature/yeni-ozellik`
3. Değişikliklerinizi commit edin: `git commit -m 'feat: yeni özellik ekle'`
4. Push edin: `git push origin feature/yeni-ozellik`
5. Pull Request açın

### Klima IR Kodu Katkısı

Kendi klimanızın doğru çalışan kapatma kodunu bulduyasanız lütfen `android/app/src/main/kotlin/.../MainActivity.kt` dosyasındaki `_defaultPresets` listesine ekleme önerisiyle PR açın.

---

## Lisans

MIT License — Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.

---

*Bu proje ESP32 veya herhangi bir harici donanım gerektirmez. Yalnızca dahili IR vericisi olan Android cihazlarda çalışır.*
