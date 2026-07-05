# 🚀 IR AC Timer — Yol Haritası & Geliştirme Fikirleri (Roadmap & Future Enhancements)

Bu doküman, **IR AC Timer** projesi için planlanan gelecekteki olası geliştirmeleri, mimari fikirleri ve topluluk önerilerini listeler.

---

## 🇹🇷 Türkçe Yol Haritası

### 1. 🌡️ Sıcaklık ve Mod Bazlı Akıllı Açma/Kapatma (Stateful Scheduling)
* **Klima IR Sinyal Mantığı:** Klimalar TV'ler gibi tek bir "Power Toggle" komutuyla çalışmaz; her tuşa basıldığında *Güç + Sıcaklık + Mod + Fan Hızı* bilgilerinin tamamı uzun bir paket olarak gönderilir.
* **Geliştirme Fikri:** Kullanıcının sadece klimayı kapatmasını değil, sabah uyanmadan önce veya işten eve dönmeden önce klimayı **belirli bir sıcaklıkta (Örn: 24°C), belirli bir modda (Soğutma/Isıtma) ve fan hızında otomatik olarak AÇMASINI** sağlayan zamanlama desteği eklemek.
* **Akıllı Senaryolar:** "Gece 02:00'de klimayı kapat, sabah 07:30'da 25°C Soğutma modunda tekrar aç."

### 2. 🪄 Akıllı Eşleştirme Sihirbazı & Evrensel Kumanda Entegrasyonu (Interactive Setup Wizard)
* **Mi Kumanda / Universal Remote Çalışma Mantığı:** Mi Kumanda gibi uygulamalar arka planda devasa IR kod kütüphaneleri (LIRC, Pronto, üretici kod setleri) kullanır. Bu kütüphanelerde kodlar tek tek değil, **"Kod Setleri / Kumanda Aileleri" (Code Sets)** halinde gruplandırılmıştır (Örn: LG için 14 farklı kumanda seti vardır; her setin içinde Kapatma, Açma, + / -, Mod ve Fan hızı kodlarının tamamı tanımlıdır).
* **Eşleştirme Sihirbazı (1/14 Deneme Yöntemi):** Kullanıcı marka seçtiğinde (Örn: LG veya Beko), sihirbaz 1. setin "Kapatma" veya "Açma" sinyalini klimaya fırlatır ve sorar: *"Klimanız tepki verdi mi?"*. Kullanıcı "Hayır" derse 2. sete geçer. Kullanıcı *"Evet, tepki verdi!"* dediği an, uygulama klimanın hangi kumanda ailesine (Örn: Set #7) ait olduğunu tespit eder ve **o setin içindeki tüm tuşların (Açma, Kapatma, Derece +/-, Mod, Fan, Uyku) kilidini tek seferde açar!**
* **Geliştirme Fikri (Neden Biz de Yapmalıyız?):** Kullanıcıları ham (raw) mikrosaniye sayılarıyla uğraştırmak yerine; uygulamamıza bir **"Marka Seç & Eşleştir Sihirbazı"** eklemek. Kullanıcı markasını seçecek, 3-5 denemede klimasını eşleştirecek ve uygulama o klimanın sadece kapatma değil; tüm sıcaklık ve mod zamanlamalarını otomatik olarak yapabilir hale gelecek. Bu adım, projemizi basit bir zamanlayıcıdan **"Evrensel Akıllı Klima Otomasyon Platformu"**na dönüştürecektir.
* **🛠️ Uygulama ve Kodlama Planı (Execution Plan - v2.0):**
  1. **v1.5 Akıllı Kapatma Eşleştirmesi & Dürüst Sinyal Yönetimi (Smart Off-Mapping & Honest Missing-OFF Handling - BAŞARIYLA UYGULANDI):**
     - Sihirbazdaki her bir sete `family` (Marka ailesi) ve `signalType` (`off`, `mode`, `power_toggle`) metaverileri eklenerek, kullanıcının sadece "tepki aldım" demesiyle yanlış bir mod/derece sinyalinin "Kapatma Sinyali" olarak kaydedilmesinin önüne geçildi.
     - **Doğrulanmış Kapatma Kodu Olan Aileler (Örn: LG / Beko / Arçelik):** Kullanıcı bir mod sinyaliyle (Örn: 24°C Soğutma) klimasını tetikleyip eşleştirse bile, sistem arka planda o ailenin %100 doğrulanmış "Power OFF (`0x88C0051`)" kodunu otomatik olarak bağlar ve zamanlayıcının gece klimayı kesin olarak kapatmasını garanti eder.
     - **Doğrulanmış Kapatma Kodu Olmayan Aileler (Örn: Vestel, Midea, Samsung):** Kullanıcı bir mod sinyaliyle tepki aldığında, uygulama sessizce yanlış sinyali kaydetmez. Bunun yerine şeffaf bir uyarı göstererek *"Marka aileniz tespit edildi ancak elimizde henüz doğrulanmış kesin bir Kapatma (OFF) kodu yok. Lütfen Ham IR Kodu Düzenleme ekranından veya ESP32 Sniffer ile kendi kapatma kodunuzu ekleyin"* diyerek dürüst ve güvenli bir duruş sergiler.
     - **v2.0 Motoruna Hazırlık:** Bu metaveri mimarisi (`family` + `signalType` + `offPattern`), v2.0'da kurulacak olan **Durum Bilgili (Stateful) Sinyal Üretici Motoru (`IRCodeGenerator.buildSignal`)** için doğrudan bir alt katman olarak tasarlanmıştır.
  2. **Veri Mimarisi (Hibrit JSON + Bulut):** En çok kullanılan Top 20 klima markasının temel kod setleri uygulamanın içinde (`assets/ir_sets.json`) offline olarak saklanacak. Diğer binlerce model için GitHub/Firebase üzerindeki bulut kütüphanesinden marka seçildiği an REST API ile ilgili markanın set listesi indirilecek.
  3. **UI/UX (Eşleştirme Sihirbazı Ekranı):**
     - `BrandSelectScreen`: Marka arama çubuğu (Örn: "LG", "Beko", "Samsung", "Vestel").
     - `WizardTestScreen`: "Set 1/14 Deneniyor -> [Kapatma Sinyalini Gönder] -> Klimanız tepki verdi mi? [Evet] / [Hayır]".
     - "Evet" dendiği an seçilen set ID'si (`selected_set_id`) profil olarak kaydedilecek.
  4. **Durum Bilgili (Stateful) Sinyal Üretici Motoru:** Klima profili artık sabit bir string değil, akıllı bir nesne olacak: `ACProfile(brand: 'LG', setId: 7, lastTemp: 24, lastMode: 'cool')`. Zamanlayıcı tetiklendiğinde `IRCodeGenerator.buildSignal(setId, temp: 24, mode: 'cool', power: true)` fonksiyonu o anki hedef sıcaklığa uygun raw mikrosaniye dizisini dinamik olarak üretip kızılötesi vericisine besleyecek!

### 3. ☁️ Bulut ve Topluluk IR Veritabanı (Community IR Library)
* Kullanıcıların kendi klima kumandalarından veya farklı kaynaklardan ([IRDB](https://github.com/probonopd/irdb) vb.) elde ettikleri ham (raw) mikrosaniye IR sinyal dizilerini uygulama üzerinden buluta yüklemesi ve diğer kullanıcılarla paylaşabilmesi.
* Marka/model arama motoru ile tek dokunuşla hazır profil indirme.

### 4. ⌚ Akıllı Saat (Wear OS) & Ana Ekran Widget'ları
* Android ana ekranına eklenebilen "Hızlı Geri Sayım" (Örn: 30 Dk Kapat, 1 Saat Kapat) widget'ları.
* Akıllı saat üzerinden telefonu çıkarmadan tek dokunuşla klima zamanlayıcısını başlatma ve durdurma.

### 5. 📊 Sıcaklık & Güç Tüketimi Tahminlemesi
* Klimanın açık kaldığı süreleri loglayarak haftalık/aylık çalışma istatistikleri ve tahmini enerji tasarrufu grafikleri sunmak.

---
---

## 🇬🇧 English Roadmap

### 1. 🌡️ Stateful Temperature & Mode Scheduling (Power ON/OFF Control)
* **AC IR Protocol Dynamics:** Unlike TV remotes that use simple "Power Toggle" pulses, AC remotes transmit the complete state (*Power + Temp + Mode + Fan Speed*) as a lengthy packet on every button press.
* **Feature Concept:** Enabling users to schedule automatic **Power ON** events with specific target temperatures (e.g., 24°C), operating modes (Cool/Heat), and fan speeds.
* **Smart Routines:** "Shut off AC at 2:00 AM, then turn it back on at 7:30 AM set to 25°C Cool mode."

### 2. 🪄 Interactive Setup Wizard & Universal Remote Integration
* **How Mi Remote / Universal Apps Work:** Applications like Mi Remote leverage massive IR code libraries (LIRC, Pronto, manufacturer databases) where IR signals are bundled into **"Code Sets" (Protocol Families)**. For example, a brand like LG might have 14 distinct code sets, each containing the complete mapping of Power ON, Power OFF, Temp +/-, Mode, and Fan Speed commands for a specific AC generation.
* **The "Test 1 of 14" Pairing Wizard:** When a user selects a brand, the wizard transmits a test command (e.g., Power OFF) from Set #1 and asks: *"Did your AC respond?"*. If the user taps "No", it advances to Set #2. As soon as the user confirms *"Yes, it responded!"*, the app identifies the exact protocol family (e.g., Set #7) and **instantly unlocks the entire virtual remote control mapping (Power ON/OFF, Temperature adjustments, Modes, Swing, and Fan speeds) in a single step!**
* **Feature Concept (Why We Should Adopt This):** Instead of requiring users to manually paste raw microsecond arrays, we can implement an **"Interactive Brand Pairing Wizard"**. Users select their AC brand, test a few preset signals, and instantly unlock full stateful automation. This architectural leap will transform IR AC Timer from a simple countdown tool into an **"All-in-One Universal Smart AC Automation Platform"**.
* **🛠️ Technical Execution Plan (v2.0 Architecture):**
  1. **v1.5 Smart Off-Mapping & Honest Missing-OFF Handling (SUCCESSFULLY IMPLEMENTED):**
     - Added `family` (Brand family) and `signalType` (`off`, `mode`, `power_toggle`) metadata to each of the wizard sets, preventing incorrect mode/temp signals from being blindly saved as "Turn OFF" codes.
     - **Families with Verified OFF Codes (e.g., LG / Beko / Arçelik):** Even if a user tests and confirms a mode signal (e.g., 24°C Cool), the app automatically binds the verified "Power OFF (`0x88C0051`)" code in the background, guaranteeing reliable shutdown when timers trigger.
     - **Families without Verified OFF Codes (e.g., Vestel, Midea, Samsung):** When confirmed via a mode signal, the app refuses to silently save a wrong code. Instead, it displays a transparent warning advising the user to add their own verified OFF code via Raw IR Editor or ESP32 Sniffer.
     - **Foundation for v2.0 Engine:** This metadata architecture (`family` + `signalType` + `offPattern`) serves as the direct underlying data layer for the upcoming **Stateful IR Signal Generator Engine (`IRCodeGenerator.buildSignal`)** in v2.0.
  2. **Hybrid Data Architecture (Offline JSON + Cloud):** Store the Top 20 most popular AC brand protocol families offline inside `assets/ir_sets.json` for instant zero-latency access. For thousands of secondary brands, fetch protocol matrices on-demand via REST API from a lightweight cloud repository (GitHub Raw / Firebase).
  3. **UI/UX (Interactive Pairing Wizard):**
     - `BrandSelectScreen`: Searchable brand catalog (e.g., "LG", "Beko", "Samsung", "Gree").
     - `WizardTestScreen`: "Testing Set 1/14 -> [Transmit Test Pulse] -> Did your AC respond? [Yes] / [No]".
     - Upon tapping "Yes", the matched protocol set ID (`selected_set_id`) is permanently linked to the room profile.
  4. **Stateful IR Signal Generator Engine:** Evolve profiles from static raw strings into dynamic stateful objects: `ACProfile(brand: 'LG', setId: 7, targetTemp: 24, mode: 'cool')`. When a background timer fires, an automated engine (`IRCodeGenerator.buildSignal(...)`) dynamically constructs the exact microsecond array for the desired temperature and mode on-the-fly!

### 3. ☁️ Cloud & Community IR Database
* An online repository where users can upload, share, and import verified raw μs signal patterns for regional or obscure AC brands.
* Instant search and one-tap profile download by AC brand/model.

### 4. ⌚ Home Screen Widgets & Wear OS Support
* Interactive Android home screen widgets for instant one-tap countdown triggers (e.g., "30m Sleep Timer", "1h Timer").
* Wear OS companion app to trigger or cancel AC timers directly from your smartwatch.

### 5. 📊 Usage Statistics & Energy Saving Insights
* Tracking active timer durations to provide weekly/monthly charts of AC runtime and estimated electricity savings.
