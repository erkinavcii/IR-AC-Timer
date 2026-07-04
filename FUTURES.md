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

### 3. ☁️ Cloud & Community IR Database
* An online repository where users can upload, share, and import verified raw μs signal patterns for regional or obscure AC brands.
* Instant search and one-tap profile download by AC brand/model.

### 4. ⌚ Home Screen Widgets & Wear OS Support
* Interactive Android home screen widgets for instant one-tap countdown triggers (e.g., "30m Sleep Timer", "1h Timer").
* Wear OS companion app to trigger or cancel AC timers directly from your smartwatch.

### 5. 📊 Usage Statistics & Energy Saving Insights
* Tracking active timer durations to provide weekly/monthly charts of AC runtime and estimated electricity savings.
