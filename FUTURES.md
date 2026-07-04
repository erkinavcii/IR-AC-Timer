# 🚀 IR AC Timer — Yol Haritası & Geliştirme Fikirleri (Roadmap & Future Enhancements)

Bu doküman, **IR AC Timer** projesi için planlanan gelecekteki olası geliştirmeleri, mimari fikirleri ve topluluk önerilerini listeler.

---

## 🇹🇷 Türkçe Yol Haritası

### 1. 🌡️ Sıcaklık ve Mod Bazlı Akıllı Açma/Kapatma (Stateful Scheduling)
* **Klima IR Sinyal Mantığı:** Klimalar TV'ler gibi tek bir "Power Toggle" komutuyla çalışmaz; her tuşa basıldığında *Güç + Sıcaklık + Mod + Fan Hızı* bilgilerinin tamamı uzun bir paket olarak gönderilir.
* **Geliştirme Fikri:** Kullanıcının sadece klimayı kapatmasını değil, sabah uyanmadan önce veya işten eve dönmeden önce klimayı **belirli bir sıcaklıkta (Örn: 24°C), belirli bir modda (Soğutma/Isıtma) ve fan hızında otomatik olarak AÇMASINI** sağlayan zamanlama desteği eklemek.
* **Akıllı Senaryolar:** "Gece 02:00'de klimayı kapat, sabah 07:30'da 25°C Soğutma modunda tekrar aç."

### 2. ☁️ Bulut ve Topluluk IR Veritabanı (Community IR Library)
* Kullanıcıların kendi klima kumandalarından veya farklı kaynaklardan ([IRDB](https://github.com/probonopd/irdb) vb.) elde ettikleri ham (raw) mikrosaniye IR sinyal dizilerini uygulama üzerinden buluta yüklemesi ve diğer kullanıcılarla paylaşabilmesi.
* Marka/model arama motoru ile tek dokunuşla hazır profil indirme.

### 3. ⌚ Akıllı Saat (Wear OS) & Ana Ekran Widget'ları
* Android ana ekranına eklenebilen "Hızlı Geri Sayım" (Örn: 30 Dk Kapat, 1 Saat Kapat) widget'ları.
* Akıllı saat üzerinden telefonu çıkarmadan tek dokunuşla klima zamanlayıcısını başlatma ve durdurma.

### 4. 📊 Sıcaklık & Güç Tüketimi Tahminlemesi
* Klimanın açık kaldığı süreleri loglayarak haftalık/aylık çalışma istatistikleri ve tahmini enerji tasarrufu grafikleri sunmak.

---
---

## 🇬🇧 English Roadmap

### 1. 🌡️ Stateful Temperature & Mode Scheduling (Power ON/OFF Control)
* **AC IR Protocol Dynamics:** Unlike TV remotes that use simple "Power Toggle" pulses, AC remotes transmit the complete state (*Power + Temp + Mode + Fan Speed*) as a lengthy packet on every button press.
* **Feature Concept:** Enabling users to schedule automatic **Power ON** events with specific target temperatures (e.g., 24°C), operating modes (Cool/Heat), and fan speeds.
* **Smart Routines:** "Shut off AC at 2:00 AM, then turn it back on at 7:30 AM set to 25°C Cool mode."

### 2. ☁️ Cloud & Community IR Database
* An online repository where users can upload, share, and import verified raw μs signal patterns for regional or obscure AC brands.
* Instant search and one-tap profile download by AC brand/model.

### 3. ⌚ Home Screen Widgets & Wear OS Support
* Interactive Android home screen widgets for instant one-tap countdown triggers (e.g., "30m Sleep Timer", "1h Timer").
* Wear OS companion app to trigger or cancel AC timers directly from your smartwatch.

### 4. 📊 Usage Statistics & Energy Saving Insights
* Tracking active timer durations to provide weekly/monthly charts of AC runtime and estimated electricity savings.
