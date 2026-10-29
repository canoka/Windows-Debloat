<div align="center">

# 🪟 Debloat XP

**Klasik Windows XP tarzı arayüze sahip, tek dosyalık minik Windows 10 / 11 debloat aracı.**

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](#gereksinimler)
[![PowerShell](https://img.shields.io/badge/PowerShell-ile%20yap%C4%B1ld%C4%B1-5391FE?logo=powershell&logoColor=white)](#nasıl-çalışır)
[![Diller](https://img.shields.io/badge/Diller-EN%20%7C%20TR%20%7C%20ES-2ea44f)](#️-özellikler)

[English](README.md) · **Türkçe** · [Español](README.es.md)

</div>

<!-- docs/screenshot.png yoluna bir ekran görüntüsü ekleyip sonraki satırın yorumunu kaldırın:
<p align="center"><img src="docs/screenshot.png" alt="Debloat XP ekran görüntüsü" width="560"></p>
-->

---

## ✨ Özellikler

- **Tek dosya, tek tık.** `DebloatXP.cmd` dosyasına çift tıklayın, yönetici iznini onaylayın, bitti. Kurulum yok, bağımlılık yok, hiçbir şey indirilmez.
- **Windows'unuzu tanır.** Windows 10 mu 11 mi kullandığınızı (sürüm ve build ile birlikte) algılar ve yalnızca size uygun seçenekleri gösterir.
- Gizlilik, uygulamalar, yapay zeka, arama, görev çubuğu, Gezgin, performans, hizmetler ve güncellemeler alanlarında **150'den fazla seçenek**.
- Güvenli tek tıkla temizlik için **Önerilen** ön ayarı; isterseniz her şeyi kendiniz seçin.
- Uygulamadan önce **geri yükleme noktası** oluşturma (varsayılan olarak açık).
- **Belge dışa aktarma:** `Dosya → Belgeyi dışa aktar`, tüm seçenekleri ve çalıştırdıkları komutları masaüstünüze bir metin dosyası olarak yazar.
- **Hafif:** yerel Windows Forms, klasik XP görünümü, anında açılır.
- **Diller:** English, Türkçe, Español (`Seçenekler → Dil`).

## 🚀 Hızlı başlangıç

1. **`DebloatXP.cmd`** dosyasını indirin ([Releases](../../releases) bölümünden veya depodan).
2. Çift tıklayın ve UAC (yönetici) isteğini onaylayın.
3. İsterseniz dili seçin: `Seçenekler → Dil`.
4. **Önerilen** düğmesine basın veya her sekmede istediklerinizi işaretleyin.
5. **Önce geri yükleme noktası oluştur** kutusunu işaretli bırakıp **Uygula**'ya basın.
6. İşlem bitince Windows'u yeniden başlatın.

## 🧹 Neleri kapsıyor

| Sekme | Örnekler |
|---|---|
| **Gizlilik ve Telemetri** | Telemetri ve tanılama, etkinlik geçmişi, reklam kimliği, konum, yazı/mürekkep verileri, konuşma tanıma, hata raporlama, P2P güncelleme, ipuçları ve reklamlar, önerilen içerik |
| **Uygulamalar** | Yaklaşık 55 hazır uygulama: Cortana, Haberler, Solitaire, Teams, Clipchamp, Xbox uygulamaları, Skype, Geri Bildirim Merkezi, sponsorlu uygulamalar (Spotify, TikTok, Candy Crush…), isteğe bağlı OneDrive kaldırma |
| **Yapay Zeka ve Copilot** | Windows Copilot, Recall, Click to Do, Paint ve Not Defteri yapay zeka özellikleri |
| **Arama** | Başlat'ta Bing web sonuçları, Cortana, arama öne çıkanları, bulut araması, arama geçmişi, isteğe bağlı dizinleme kapatma |
| **Görev Çubuğu ve Başlat** | Widgets, Haberler ve İlgi Alanları, Sohbet/Teams simgesi, Kişiler, Şimdi Toplan, Başlat önerileri, klasik sağ tık menüsü, sola hizalı görev çubuğu |
| **Gezgin** | Dosya uzantıları, gizli dosyalar, Bu Bilgisayar ile açma, Ana Sayfa ve Galeri, 3B Nesneler, eşitleme sağlayıcı reklamları |
| **Performans** | Güç planı, hazırda bekletme, Hızlı Başlatma, görsel efektler, Game DVR, arka plan uygulamaları, SysMain, ağ kısıtlaması, geçici dosya temizliği |
| **Hizmetler ve Görevler** | Telemetri ve diğer gereksiz hizmetler, telemetri zamanlanmış görevleri |
| **Edge ve Güncelleme** | Edge Başlangıç Hızlandırma, alışveriş asistanı, Edge yapay zeka ve telemetri, Windows Update otomatik yeniden başlatma, sürücü güncellemeleri, Insider sürümleri |

Yalnızca tek bir Windows sürümünde anlamlı olan seçenekler sadece o sürümde gösterilir.

## 🛡️ Güvenlik

- Windows Defender'a **asla** dokunulmaz.
- Microsoft Store ve Microsoft Edge **kaldırılmaz**.
- Hiçbir şey indirilmez ve hiçbir veri bir yere gönderilmez. Araç yalnızca yerel ayarları değiştirir.
- Kaldırılan uygulamalar Microsoft Store'dan yeniden yüklenebilir.
- Ayar değişiklikleri geri yükleme noktasıyla geri alınabilir. Tek bir ayarı elle geri almak isterseniz dışa aktarılan belgeyi kullanın.
- Bazı politika tabanlı ayarlar Windows Home'da sınırlı etki eder (örneğin telemetri tamamen kapatılamaz).
- Bazı seçenekler bilerek varsayılan olarak kapalıdır: Xbox uygulamalarını kaldırmak Xbox/Minecraft girişini bozabilir, Yazdırma Biriktiricisi ise yalnızca hiç yazdırmıyorsanız kapatılmalıdır.

## 📋 Gereksinimler

- Windows 10 veya Windows 11
- Yönetici hakları
- Windows PowerShell 5.1 (Windows ile birlikte gelir)

## ⚙️ Nasıl çalışır

`DebloatXP.cmd` hem toplu iş (batch) hem de PowerShell betiği olan tek bir dosyadır. Batch kısmı yönetici hakları ister ve Windows Forms arayüzünü çizen PowerShell kısmını başlatır. Her seçenek; kayıt defteri, hizmet, zamanlanmış görev veya uygulama kaldırma komutlarından oluşan küçük bir bloktur. Dosyayı herhangi bir metin düzenleyicide açıp tam olarak ne yaptığını okuyabilirsiniz.

## ❓ SSS

**Windows SmartScreen veya antivirüsüm uyarı veriyor.**
Dosya, sistem ayarlarını değiştiren imzasız bir betiktir ve güvenlik araçları bunu sık sık işaretler. Düz metindir, çalıştırmadan önce okuyun. Emin değilseniz çalıştırmayın.

**Değişiklikleri nasıl geri alırım?**
Uygulamadan önce oluşturulan geri yükleme noktasına dönün veya kaldırılan uygulamaları Microsoft Store'dan yeniden yükleyin.

**Açılışta konsol penceresi neden kısa süre görünüyor?**
Başlatıcı PowerShell'i açıyor, pencere hemen kapanır.

## ⚠️ Sorumluluk reddi

Bu araç sistem ayarlarını değiştirir. Kullanım sorumluluğu size aittir; önce geri yükleme noktası veya yedek oluşturun. Yazarlar herhangi bir zarar veya veri kaybından sorumlu değildir.

## 🙏 Katkıda bulunanlar

Özellik fikirleri, herkese açık belgelenmiş Windows ayarlarından ve [Win11Debloat](https://github.com/Raphire/Win11Debloat) gibi projelerden gelmektedir.
