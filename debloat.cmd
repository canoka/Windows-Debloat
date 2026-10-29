<# : batch
@echo off
setlocal
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "iex ([IO.File]::ReadAllText('%~f0',[Text.Encoding]::UTF8))"
exit /b
#>

# =====================================================================
#  Debloat Tool  -  Windows 10 / 11 debloat tool (single file, no install)
#  Classic Windows XP style UI (Windows Forms, no extra dependencies)
# =====================================================================
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$ErrorActionPreference = 'SilentlyContinue'

# ---------------------------------------------------------------- OS detection
$os    = Get-CimInstance Win32_OperatingSystem
$build = [int]$os.BuildNumber
$cv    = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$disp  = $cv.DisplayVersion; if (-not $disp) { $disp = $cv.ReleaseId }
$osName = ($os.Caption -replace 'Microsoft ', '').Trim()
if ($build -lt 10240) {
    [void][Windows.Forms.MessageBox]::Show("Only Windows 10 / 11 supported.`nSadece Windows 10 / 11 desteklenir.`nSolo Windows 10 / 11.", 'Debloat Tool')
    exit
}
$ver = if ($build -ge 22000) { '11' } else { '10' }

# ---------------------------------------------------------------- language
$script:Lang = switch ([Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName) { 'tr' { 'tr' } 'es' { 'es' } default { 'en' } }

$S = @{
 en = @{ title='Debloat Tool'; detected='Detected'; file='&File'; exp='Export documentation...'; exit='E&xit'
         opts='&Options'; lang='Language'; help='&Help'; about='About'
         rec='Recommended'; all='Select all'; none='Clear'; apply='Apply'; rp='Create a restore point first'
         confirm='Apply {0} selected changes?'; nosel='Nothing selected.'; done='Done. Some changes need a restart.'
         running='Working...'; ready='Ready.'; expdone='Documentation saved to:'
         aboutTxt='Debloat Tool 1.0 - lightweight Windows 10/11 debloater.`nChanges registry, services, tasks and apps.`nA restore point is strongly recommended. Use at your own risk.'
         cats=@{ priv='Privacy & Telemetry'; apps='Apps'; ai='AI & Copilot'; search='Search'; ui='Taskbar & Start'; expl='Explorer'; perf='Performance'; svc='Services & Tasks'; edge='Edge & Updates' } }
 tr = @{ title='Debloat Tool'; detected='Algılanan'; file='&Dosya'; exp='Belgeyi dışa aktar...'; exit='&Çıkış'
         opts='&Seçenekler'; lang='Dil'; help='&Yardım'; about='Hakkında'
         rec='Önerilen'; all='Tümünü seç'; none='Temizle'; apply='Uygula'; rp='Önce geri yükleme noktası oluştur'
         confirm='Seçilen {0} değişiklik uygulansın mı?'; nosel='Hiçbir şey seçilmedi.'; done='Bitti. Bazı değişiklikler için yeniden başlatma gerekir.'
         running='Çalışıyor...'; ready='Hazır.'; expdone='Belge şuraya kaydedildi:'
         aboutTxt='Debloat Tool 1.0 - hafif Windows 10/11 debloat aracı.`nKayıt defterini, hizmetleri, görevleri ve uygulamaları değiştirir.`nGeri yükleme noktası önerilir. Kullanım sorumluluğu size aittir.'
         cats=@{ priv='Gizlilik ve Telemetri'; apps='Uygulamalar'; ai='Yapay Zeka ve Copilot'; search='Arama'; ui='Görev Çubuğu ve Başlat'; expl='Gezgin'; perf='Performans'; svc='Hizmetler ve Görevler'; edge='Edge ve Güncelleme' } }
 es = @{ title='Debloat Tool'; detected='Detectado'; file='&Archivo'; exp='Exportar documentación...'; exit='&Salir'
         opts='&Opciones'; lang='Idioma'; help='A&yuda'; about='Acerca de'
         rec='Recomendado'; all='Seleccionar todo'; none='Limpiar'; apply='Aplicar'; rp='Crear punto de restauración antes'
         confirm='¿Aplicar {0} cambios seleccionados?'; nosel='Nada seleccionado.'; done='Listo. Algunos cambios requieren reiniciar.'
         running='Trabajando...'; ready='Listo.'; expdone='Documentación guardada en:'
         aboutTxt='Debloat Tool 1.0 - optimizador ligero de Windows 10/11.`nModifica registro, servicios, tareas y aplicaciones.`nSe recomienda un punto de restauración. Úsalo bajo tu responsabilidad.'
         cats=@{ priv='Privacidad y Telemetría'; apps='Aplicaciones'; ai='IA y Copilot'; search='Búsqueda'; ui='Barra de tareas e Inicio'; expl='Explorador'; perf='Rendimiento'; svc='Servicios y tareas'; edge='Edge y Actualizaciones' } }
}
$CatOrder = 'priv','apps','ai','search','ui','expl','perf','svc','edge'

# ---------------------------------------------------------------- helpers used by tweaks
function R($p, $n, $v, $t = 'DWord') {
    if (!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
    New-ItemProperty -Path $p -Name $n -Value $v -PropertyType $t -Force | Out-Null
}
function Sv($names) { foreach ($n in $names) { Stop-Service $n -Force; Set-Service $n -StartupType Disabled } }
function Tk($path, $names) { foreach ($n in $names) { Disable-ScheduledTask -TaskPath $path -TaskName $n | Out-Null } }
function Rm($pat) {
    foreach ($p in ($pat -split ',')) {
        Get-AppxPackage -AllUsers -Name $p | Remove-AppxPackage -AllUsers
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $p } | Remove-AppxProvisionedPackage -Online | Out-Null
    }
}

$Tw = New-Object System.Collections.ArrayList
function New-Tw($id, $cat, $v, $rec, $en, $tr, $es, [scriptblock]$do) {
    [void]$Tw.Add([pscustomobject]@{ Id = $id; Cat = $cat; Ver = $v; Rec = $rec; N = @{ en = $en; tr = $tr; es = $es }; Do = $do })
}

# =====================================================================
#  1) PRIVACY & TELEMETRY
# =====================================================================
New-Tw 'tel' 'priv' '*' $true 'Disable telemetry & diagnostic data' 'Telemetri ve tanılama verilerini kapat' 'Desactivar telemetría y datos de diagnóstico' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
    R 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
}
New-Tw 'activity' 'priv' '*' $true 'Disable activity history / Timeline' 'Etkinlik geçmişini / Zaman çizelgesini kapat' 'Desactivar historial de actividad / Línea de tiempo' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0
}
New-Tw 'adid' 'priv' '*' $true 'Disable advertising ID' 'Reklam kimliğini kapat' 'Desactivar ID de publicidad' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
}
New-Tw 'tailored' 'priv' '*' $true 'Disable tailored experiences (diagnostic data)' 'Kişiselleştirilmiş deneyimleri kapat' 'Desactivar experiencias personalizadas' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
}
New-Tw 'trackprogs' 'priv' '*' $true 'Disable app-launch tracking' 'Uygulama başlatma takibini kapat' 'Desactivar seguimiento de inicio de apps' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs' 0
}
New-Tw 'location' 'priv' '*' $true 'Disable location services' 'Konum hizmetlerini kapat' 'Desactivar servicios de ubicación' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation' 1
    R 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' 'String'
}
New-Tw 'fmd' 'priv' '11' $true 'Disable Find My Device tracking' 'Cihazımı Bul konum takibini kapat' 'Desactivar Encontrar mi dispositivo' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice' 'AllowFindMyDevice' 0
    R 'HKLM:\SOFTWARE\Microsoft\Settings\FindMyDevice' 'LocationSyncEnabled' 0
}
New-Tw 'inking' 'priv' '*' $true 'Disable inking & typing personalization' 'Yazı/mürekkep kişiselleştirmesini kapat' 'Desactivar personalización de escritura' {
    R 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
    R 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
    R 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts' 0
    R 'HKCU:\Software\Microsoft\Personalization\Settings' 'AcceptedPrivacyPolicy' 0
}
New-Tw 'speech' 'priv' '*' $true 'Disable online speech recognition' 'Çevrimiçi konuşma tanımayı kapat' 'Desactivar reconocimiento de voz en línea' {
    R 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 0
}
New-Tw 'feedback' 'priv' '*' $true 'Disable feedback requests' 'Geri bildirim isteklerini kapat' 'Desactivar solicitudes de comentarios' {
    R 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
    R 'HKCU:\Software\Microsoft\Siuf\Rules' 'PeriodInNanoSeconds' 0
}
New-Tw 'clip' 'priv' '*' $true 'Disable cloud clipboard sync' 'Bulut pano eşitlemesini kapat' 'Desactivar sincronización del portapapeles' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard' 0
}
New-Tw 'sync' 'priv' '*' $false 'Disable settings sync with Microsoft account' 'Ayarların Microsoft hesabıyla eşitlenmesini kapat' 'Desactivar sincronización de configuración' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSync' 2
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSyncUserOverride' 1
}
New-Tw 'p2p' 'priv' '*' $true 'Disable Delivery Optimization (P2P updates)' 'Teslim Optimizasyonu (P2P güncelleme) kapat' 'Desactivar Optimización de entrega (P2P)' {
    R 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' 'DODownloadMode' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0
}
New-Tw 'consumer' 'priv' '*' $true 'Disable consumer features (auto-installed promo apps)' 'Tüketici özelliklerini kapat (otomatik reklam uygulamaları)' 'Desactivar características de consumidor (apps promocionales)' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableSoftLanding' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightFeatures' 1
}
New-Tw 'suggest' 'priv' '*' $true 'Disable tips, suggestions & ads (Start, Settings, lock screen)' 'İpuçları, öneriler ve reklamları kapat (Başlat, Ayarlar, kilit ekranı)' 'Desactivar consejos, sugerencias y anuncios' {
    $k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    foreach ($n in 'SubscribedContent-338387Enabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled','SubscribedContent-310093Enabled','SubscribedContent-338393Enabled','SubscribedContent-88000326Enabled','SilentInstalledAppsEnabled','SystemPaneSuggestionsEnabled','SoftLandingEnabled','RotatingLockScreenOverlayEnabled','ContentDeliveryAllowed','OemPreInstalledAppsEnabled','PreInstalledAppsEnabled','PreInstalledAppsEverEnabled','FeatureManagementEnabled') { R $k $n 0 }
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' 'ScoobeSystemSettingEnabled' 0
}
New-Tw 'ceip' 'priv' '*' $true 'Disable Customer Experience Improvement Program' 'Müşteri Deneyimi Geliştirme Programını kapat' 'Desactivar programa de mejora de la experiencia' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable' 0
}
New-Tw 'wer' 'priv' '*' $true 'Disable Windows Error Reporting' 'Windows Hata Raporlamayı kapat' 'Desactivar informe de errores de Windows' {
    R 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' 'Disabled' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled' 1
    Sv 'WerSvc'
}
New-Tw 'ink10' 'priv' '10' $true 'Disable Windows Ink Workspace' 'Windows Ink Çalışma Alanını kapat' 'Desactivar Windows Ink Workspace' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace' 'AllowWindowsInkWorkspace' 0
}
New-Tw 'remote' 'priv' '*' $false 'Disable Remote Assistance' 'Uzak Yardımı kapat' 'Desactivar Asistencia remota' {
    R 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' 0
}

# =====================================================================
#  2) APPS (AppX removal)  -  pattern|name|version|recommended
# =====================================================================
$apps = @'
Microsoft.549981C3F5F10|Cortana|*|1
Microsoft.BingNews|Microsoft News|*|1
Microsoft.BingWeather|Weather|*|1
Microsoft.BingFinance|Microsoft Money (Bing Finance)|10|1
Microsoft.BingSports|Microsoft Sports (Bing Sports)|10|1
Microsoft.BingSearch|Bing Search|11|1
Microsoft.GetHelp|Get Help|*|1
Microsoft.Getstarted|Tips|*|1
Microsoft.MicrosoftOfficeHub|Microsoft 365 (Office hub)|*|1
Microsoft.Office.OneNote|OneNote (UWP)|*|0
Microsoft.MicrosoftSolitaireCollection|Solitaire Collection|*|1
Microsoft.MixedReality.Portal|Mixed Reality Portal|*|1
Microsoft.People|People|*|1
Microsoft.SkypeApp|Skype|*|1
Microsoft.WindowsFeedbackHub|Feedback Hub|*|1
Microsoft.WindowsMaps|Maps|*|1
Microsoft.YourPhone|Phone Link (Your Phone)|*|0
Microsoft.ZuneMusic|Groove Music / Media Player|*|0
Microsoft.ZuneVideo|Movies & TV|*|1
Microsoft.3DBuilder|3D Builder|10|1
Microsoft.Microsoft3DViewer|3D Viewer|*|1
Microsoft.Print3D|Print 3D|10|1
Microsoft.windowscommunicationsapps|Mail & Calendar|*|0
Microsoft.Todos|Microsoft To Do|*|0
Microsoft.PowerAutomateDesktop|Power Automate|11|1
Clipchamp.Clipchamp|Clipchamp|11|1
MicrosoftTeams,MSTeams|Microsoft Teams (personal)|*|1
Microsoft.Copilot|Copilot app|*|1
Microsoft.OutlookForWindows|New Outlook|11|1
Microsoft.Windows.DevHome|Dev Home|11|1
Microsoft.Xbox*,Microsoft.GamingApp|Xbox apps & Game Bar|*|0
MicrosoftCorporationII.QuickAssist|Quick Assist|*|0
MicrosoftCorporationII.MicrosoftFamily|Microsoft Family|11|1
Microsoft.MicrosoftJournal|Journal|*|1
Microsoft.Whiteboard|Whiteboard|*|1
Microsoft.Wallet|Microsoft Pay (Wallet)|*|1
Microsoft.OneConnect|Mobile Plans|*|1
Microsoft.NetworkSpeedTest|Network Speed Test|10|1
Microsoft.MicrosoftStickyNotes|Sticky Notes|*|0
Microsoft.WindowsAlarms|Alarms & Clock|*|0
Microsoft.WindowsSoundRecorder|Sound Recorder|*|0
*Disney*|Disney+|*|1
*Spotify*|Spotify|*|1
*Netflix*|Netflix|*|1
*Facebook*|Facebook|*|1
*Instagram*|Instagram|*|1
*TikTok*|TikTok|*|1
*Twitter*|Twitter / X|*|1
*LinkedIn*|LinkedIn|*|1
*CandyCrush*|Candy Crush games|*|1
*PrimeVideo*|Amazon Prime Video|*|1
*Hulu*|Hulu|*|1
*McAfee*|McAfee trial|*|1
*Duolingo*|Duolingo|*|1
*Pandora*|Pandora|*|1
*Flipboard*|Flipboard|*|1
*EclipseManager*|Eclipse Manager|*|1
*ActiproSoftware*|Actipro Software|*|1
*AdobeCreativeCloudExpress*|Adobe Express|*|1
'@ -split "`r?`n"
foreach ($l in $apps) {
    if (-not $l.Trim()) { continue }
    $a = $l.Split('|')
    New-Tw ('app_' + $a[0]) 'apps' $a[2] ([bool][int]$a[3]) $a[1] $a[1] $a[1] ([scriptblock]::Create("Rm '$($a[0])'"))
}
New-Tw 'onedrive' 'apps' '*' $false 'Uninstall OneDrive (your files stay in the folder)' 'OneDrive''ı kaldır (dosyalarınız klasörde kalır)' 'Desinstalar OneDrive (tus archivos permanecen)' {
    Stop-Process -Name OneDrive -Force
    $s = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"; if (!(Test-Path $s)) { $s = "$env:SystemRoot\System32\OneDriveSetup.exe" }
    Start-Process $s '/uninstall' -Wait
}

# =====================================================================
#  3) AI & COPILOT
# =====================================================================
New-Tw 'copilot' 'ai' '*' $true 'Disable Windows Copilot & hide its button' 'Windows Copilot''ı kapat ve düğmesini gizle' 'Desactivar Windows Copilot y ocultar su botón' {
    R 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0
}
New-Tw 'recall' 'ai' '11' $true 'Disable Windows Recall (AI snapshots)' 'Windows Recall''ı (yapay zeka ekran görüntüleri) kapat' 'Desactivar Windows Recall (capturas IA)' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
    R 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
    Disable-WindowsOptionalFeature -Online -FeatureName Recall -NoRestart | Out-Null
}
New-Tw 'clicktodo' 'ai' '11' $false 'Disable Click to Do' 'Click to Do özelliğini kapat' 'Desactivar Click to Do' {
    R 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableClickToDo' 1
}
New-Tw 'paintai' 'ai' '11' $true 'Disable AI features in Paint' 'Paint''teki yapay zeka özelliklerini kapat' 'Desactivar funciones de IA en Paint' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Paint' 'DisableCocreator' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Paint' 'DisableGenerativeFill' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Paint' 'DisableImageCreator' 1
}
New-Tw 'notepadai' 'ai' '11' $true 'Disable AI features in Notepad' 'Not Defteri''ndeki yapay zeka özelliklerini kapat' 'Desactivar funciones de IA en Bloc de notas' {
    R 'HKLM:\SOFTWARE\Policies\WindowsNotepad' 'DisableAIFeatures' 1
}

# =====================================================================
#  4) SEARCH
# =====================================================================
New-Tw 'bing' 'search' '*' $true 'Disable Bing web results in Start search' 'Başlat aramasında Bing web sonuçlarını kapat' 'Desactivar resultados web de Bing en Inicio' {
    R 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWeb' 0
}
New-Tw 'cortana' 'search' '*' $true 'Disable Cortana in search' 'Aramada Cortana''yı kapat' 'Desactivar Cortana en la búsqueda' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'CortanaConsent' 0
}
New-Tw 'highlights' 'search' '*' $true 'Disable search highlights' 'Arama öne çıkanlarını kapat' 'Desactivar destacados de búsqueda' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsDynamicSearchBoxEnabled' 0
}
New-Tw 'cloudsearch' 'search' '*' $true 'Disable cloud content search (work/school & Microsoft account)' 'Bulut içerik aramasını kapat' 'Desactivar búsqueda de contenido en la nube' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsAADCloudSearchEnabled' 0
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsMSACloudSearchEnabled' 0
}
New-Tw 'searchhist' 'search' '*' $true 'Disable device search history' 'Cihaz arama geçmişini kapat' 'Desactivar historial de búsqueda del dispositivo' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsDeviceSearchHistoryEnabled' 0
}
New-Tw 'searchbox' 'search' '*' $false 'Hide search box on taskbar' 'Görev çubuğundaki arama kutusunu gizle' 'Ocultar cuadro de búsqueda de la barra de tareas' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0
}
New-Tw 'wsearch' 'search' '*' $false 'Disable Windows Search indexing service (SSD users)' 'Windows Arama dizinleme hizmetini kapat (SSD)' 'Desactivar indexado de Windows Search (SSD)' {
    Sv 'WSearch'
}

# =====================================================================
#  5) TASKBAR & START
# =====================================================================
New-Tw 'widgets' 'ui' '11' $true 'Disable Widgets' 'Pencere öğelerini (Widgets) kapat' 'Desactivar Widgets' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
}
New-Tw 'news10' 'ui' '10' $true 'Disable News and Interests' 'Haberler ve İlgi Alanlarını kapat' 'Desactivar Noticias e intereses' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 'EnableFeeds' 0
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds' 'ShellFeedsTaskbarViewMode' 2
}
New-Tw 'chat' 'ui' '11' $true 'Disable Chat / Teams icon on taskbar' 'Görev çubuğundaki Sohbet / Teams simgesini kapat' 'Desactivar icono de Chat / Teams' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat' 'ChatIcon' 3
}
New-Tw 'people' 'ui' '10' $true 'Hide People icon' 'Kişiler simgesini gizle' 'Ocultar icono Contactos' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' 'PeopleBand' 0
}
New-Tw 'meetnow' 'ui' '10' $true 'Hide Meet Now icon' 'Şimdi Toplan simgesini gizle' 'Ocultar icono Reunirse ahora' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'HideSCAMeetNow' 1
}
New-Tw 'taskview' 'ui' '*' $false 'Hide Task View button' 'Görev Görünümü düğmesini gizle' 'Ocultar botón Vista de tareas' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' 0
}
New-Tw 'tbleft' 'ui' '11' $false 'Align taskbar icons to the left' 'Görev çubuğu simgelerini sola hizala' 'Alinear iconos de la barra a la izquierda' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0
}
New-Tw 'classicmenu' 'ui' '11' $false 'Classic right-click menu' 'Klasik sağ tık menüsü' 'Menú contextual clásico' {
    $p = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    New-Item -Path $p -Force | Out-Null
    Set-ItemProperty -Path $p -Name '(default)' -Value ''
}
New-Tw 'startrec' 'ui' '11' $true 'Disable Start recommendations & account notifications' 'Başlat önerilerini ve hesap bildirimlerini kapat' 'Desactivar recomendaciones y avisos de cuenta en Inicio' {
    $k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    R $k 'Start_IrisRecommendations' 0
    R $k 'Start_AccountNotifications' 0
    R $k 'Start_TrackDocs' 0
}
New-Tw 'startpins' 'ui' '11' $false 'Start menu: show more pins' 'Başlat: daha fazla sabitlenmiş öğe göster' 'Inicio: mostrar más anclados' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_Layout' 1
}
New-Tw 'recentapps' 'ui' '*' $false 'Hide recently added apps in Start' 'Başlat''ta son eklenen uygulamaları gizle' 'Ocultar apps agregadas recientemente' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecentlyAddedApps' 1
}
New-Tw 'spotdesk' 'ui' '11' $true 'Disable Windows Spotlight on desktop' 'Masaüstünde Windows Spotlight''ı kapat' 'Desactivar Windows Spotlight en el escritorio' {
    R 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' 'DisableSpotlightCollectionOnDesktop' 1
}
New-Tw 'sticky' 'ui' '*' $true 'Disable Sticky/Filter/Toggle keys shortcuts' 'Yapışkan/Filtre/Geçiş tuşları kısayollarını kapat' 'Desactivar atajos de teclas especiales' {
    R 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' '506' 'String'
    R 'HKCU:\Control Panel\Accessibility\Keyboard Response' 'Flags' '122' 'String'
    R 'HKCU:\Control Panel\Accessibility\ToggleKeys' 'Flags' '58' 'String'
}

# =====================================================================
#  6) EXPLORER
# =====================================================================
New-Tw 'ext' 'expl' '*' $true 'Show file extensions' 'Dosya uzantılarını göster' 'Mostrar extensiones de archivo' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0
}
New-Tw 'hidden' 'expl' '*' $false 'Show hidden files' 'Gizli dosyaları göster' 'Mostrar archivos ocultos' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' 1
}
New-Tw 'thispc' 'expl' '*' $true 'Open Explorer to This PC' 'Gezgin''i Bu Bilgisayar ile aç' 'Abrir el Explorador en Este equipo' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1
}
New-Tw 'recent' 'expl' '*' $false 'Disable recent/frequent files in Quick access' 'Hızlı erişimde son/sık dosyaları kapat' 'Desactivar archivos recientes en Acceso rápido' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' 0
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0
}
New-Tw 'syncnotif' 'expl' '*' $true 'Disable sync provider (OneDrive) ads in Explorer' 'Gezgin''deki eşitleme sağlayıcı (OneDrive) reklamlarını kapat' 'Desactivar anuncios de proveedores de sincronización' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' 0
}
New-Tw 'homegallery' 'expl' '11' $false 'Remove Home & Gallery from navigation pane' 'Gezinti bölmesinden Ana Sayfa ve Galeri''yi kaldır' 'Quitar Inicio y Galería del panel de navegación' {
    R 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' 'System.IsPinnedToNameSpaceTree' 0
    R 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0
}
New-Tw 'obj3d' 'expl' '10' $true 'Remove 3D Objects folder from This PC' '3B Nesneler klasörünü Bu Bilgisayar''dan kaldır' 'Quitar carpeta Objetos 3D de Este equipo' {
    Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -Recurse -Force
    Remove-Item 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -Recurse -Force
}
New-Tw 'shake' 'expl' '*' $false 'Disable Aero Shake (minimize others)' 'Aero Shake özelliğini kapat' 'Desactivar Aero Shake' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisallowShaking' 1
}

# =====================================================================
#  7) PERFORMANCE
# =====================================================================
New-Tw 'power' 'perf' '*' $false 'Use Ultimate / High performance power plan' 'Üst düzey / Yüksek performans güç planını kullan' 'Usar plan de energía de máximo rendimiento' {
    $o = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    $m = [regex]::Match(($o | Out-String), '[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}')
    if ($m.Success) { powercfg /setactive $m.Value } else { powercfg /setactive SCHEME_MIN }
}
New-Tw 'hiber' 'perf' '*' $false 'Disable hibernation (frees disk space)' 'Hazırda bekletmeyi kapat (disk alanı kazandırır)' 'Desactivar hibernación (libera espacio)' {
    powercfg /h off
}
New-Tw 'faststart' 'perf' '*' $false 'Disable Fast Startup' 'Hızlı Başlatma''yı kapat' 'Desactivar inicio rápido' {
    R 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
}
New-Tw 'visualfx' 'perf' '*' $false 'Best performance visual effects & no animations' 'En iyi performans görsel efektleri, animasyonsuz' 'Efectos visuales de máximo rendimiento' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 2
    R 'HKCU:\Control Panel\Desktop' 'UserPreferencesMask' ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) 'Binary'
    R 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' '0' 'String'
    R 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' '0' 'String'
}
New-Tw 'transp' 'perf' '*' $false 'Disable transparency effects' 'Saydamlık efektlerini kapat' 'Desactivar efectos de transparencia' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'EnableTransparency' 0
}
New-Tw 'gamedvr' 'perf' '*' $true 'Disable Game DVR / Game Bar capture' 'Game DVR / Game Bar kaydını kapat' 'Desactivar Game DVR / captura de Game Bar' {
    R 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
    R 'HKCU:\Software\Microsoft\GameBar' 'UseNexusForGameBarEnabled' 0
}
New-Tw 'bgapps' 'perf' '*' $false 'Disable background apps' 'Arka plan uygulamalarını kapat' 'Desactivar aplicaciones en segundo plano' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsRunInBackground' 2
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
}
New-Tw 'sysmain' 'perf' '*' $false 'Disable SysMain / Superfetch (SSD users)' 'SysMain / Superfetch kapat (SSD)' 'Desactivar SysMain / Superfetch (SSD)' {
    Sv 'SysMain'
}
New-Tw 'startdelay' 'perf' '*' $true 'Remove startup apps delay' 'Başlangıç uygulamaları gecikmesini kaldır' 'Quitar retraso de apps de inicio' {
    R 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0
}
New-Tw 'lastaccess' 'perf' '*' $true 'Disable NTFS last-access timestamp' 'NTFS son erişim zaman damgasını kapat' 'Desactivar marca de último acceso NTFS' {
    fsutil behavior set disablelastaccess 1 | Out-Null
}
New-Tw 'reserved' 'perf' '*' $false 'Disable Reserved Storage' 'Ayrılmış Depolama''yı kapat' 'Desactivar almacenamiento reservado' {
    DISM /Online /Set-ReservedStorageState /State:Disabled | Out-Null
}
New-Tw 'nethrottle' 'perf' '*' $false 'Disable network throttling (multimedia)' 'Ağ kısıtlamasını kapat (multimedya)' 'Desactivar limitación de red (multimedia)' {
    R 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex' -1
    R 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'SystemResponsiveness' 0
}
New-Tw 'temp' 'perf' '*' $true 'Clean temporary files' 'Geçici dosyaları temizle' 'Limpiar archivos temporales' {
    Remove-Item "$env:TEMP\*" -Recurse -Force
    Remove-Item "$env:SystemRoot\Temp\*" -Recurse -Force
}

# =====================================================================
#  8) SERVICES & SCHEDULED TASKS
# =====================================================================
New-Tw 'svc_tel' 'svc' '*' $true 'Service: Connected User Experiences & Telemetry (DiagTrack, dmwappushservice)' 'Hizmet: Telemetri (DiagTrack, dmwappushservice)' 'Servicio: Telemetría (DiagTrack, dmwappushservice)' { Sv 'DiagTrack','dmwappushservice' }
New-Tw 'svc_fax' 'svc' '*' $true 'Service: Fax' 'Hizmet: Faks' 'Servicio: Fax' { Sv 'Fax' }
New-Tw 'svc_retail' 'svc' '*' $true 'Service: Retail Demo' 'Hizmet: Perakende Demo' 'Servicio: Demo comercial' { Sv 'RetailDemo' }
New-Tw 'svc_maps' 'svc' '*' $true 'Service: Downloaded Maps Manager' 'Hizmet: İndirilen Haritalar Yöneticisi' 'Servicio: Mapas descargados' { Sv 'MapsBroker' }
New-Tw 'svc_geo' 'svc' '*' $true 'Service: Geolocation' 'Hizmet: Coğrafi Konum' 'Servicio: Geolocalización' { Sv 'lfsvc' }
New-Tw 'svc_remreg' 'svc' '*' $true 'Service: Remote Registry' 'Hizmet: Uzak Kayıt Defteri' 'Servicio: Registro remoto' { Sv 'RemoteRegistry' }
New-Tw 'svc_wmp' 'svc' '*' $true 'Service: Windows Media Player Network Sharing' 'Hizmet: WMP Ağ Paylaşımı' 'Servicio: Uso compartido de WMP' { Sv 'WMPNetworkSvc' }
New-Tw 'svc_parent' 'svc' '*' $true 'Service: Parental Controls' 'Hizmet: Ebeveyn Denetimleri' 'Servicio: Control parental' { Sv 'WpcMonSvc' }
New-Tw 'svc_insider' 'svc' '*' $true 'Service: Windows Insider' 'Hizmet: Windows Insider' 'Servicio: Windows Insider' { Sv 'wisvc' }
New-Tw 'svc_phone' 'svc' '*' $true 'Service: Phone Service' 'Hizmet: Telefon Hizmeti' 'Servicio: Teléfono' { Sv 'PhoneSvc' }
New-Tw 'svc_xbox' 'svc' '*' $false 'Services: Xbox (Auth, Game Save, Network, Accessory)' 'Hizmetler: Xbox (Kimlik, Oyun Kaydı, Ağ, Aksesuar)' 'Servicios: Xbox' { Sv 'XblAuthManager','XblGameSave','XboxNetApiSvc','XboxGipSvc' }
New-Tw 'svc_hotspot' 'svc' '*' $false 'Service: Mobile Hotspot' 'Hizmet: Mobil Etkin Nokta' 'Servicio: Zona móvil' { Sv 'icssvc' }
New-Tw 'svc_spool' 'svc' '*' $false 'Service: Print Spooler (only if you never print)' 'Hizmet: Yazdırma Biriktiricisi (yazıcı kullanmıyorsanız)' 'Servicio: Cola de impresión (si no imprimes)' { Sv 'Spooler' }
New-Tw 'svc_scard' 'svc' '*' $false 'Services: Smart Card' 'Hizmetler: Akıllı Kart' 'Servicios: Tarjeta inteligente' { Sv 'SCardSvr','ScDeviceEnum','SCPolicySvc' }
New-Tw 'svc_trk' 'svc' '*' $false 'Service: Distributed Link Tracking' 'Hizmet: Dağıtılmış Bağlantı İzleme' 'Servicio: Seguimiento de vínculos' { Sv 'TrkWks' }
New-Tw 'tk_appexp' 'svc' '*' $true 'Tasks: Application Experience (Compatibility Appraiser...)' 'Görevler: Uygulama Deneyimi (Uyumluluk Değerlendirici...)' 'Tareas: Experiencia de aplicaciones' {
    Tk '\Microsoft\Windows\Application Experience\' 'Microsoft Compatibility Appraiser','ProgramDataUpdater','StartupAppTask','PcaPatchDbTask'
}
New-Tw 'tk_ceip' 'svc' '*' $true 'Tasks: Customer Experience Improvement Program' 'Görevler: Müşteri Deneyimi Geliştirme Programı' 'Tareas: Programa de mejora de experiencia' {
    Tk '\Microsoft\Windows\Customer Experience Improvement Program\' 'Consolidator','UsbCeip','KernelCeipTask','BthSQM'
}
New-Tw 'tk_siuf' 'svc' '*' $true 'Tasks: Feedback (Siuf)' 'Görevler: Geri Bildirim (Siuf)' 'Tareas: Comentarios (Siuf)' {
    Tk '\Microsoft\Windows\Feedback\Siuf\' 'DmClient','DmClientOnScenarioDownload'
}
New-Tw 'tk_misc' 'svc' '*' $true 'Tasks: Error reporting, Maps, Disk diagnostics, Network trace' 'Görevler: Hata raporlama, Haritalar, Disk tanılama, Ağ izleme' 'Tareas: Informe de errores, mapas, diagnóstico' {
    Tk '\Microsoft\Windows\Windows Error Reporting\' 'QueueReporting'
    Tk '\Microsoft\Windows\Maps\' 'MapsToastTask','MapsUpdateTask'
    Tk '\Microsoft\Windows\DiskDiagnostic\' 'Microsoft-Windows-DiskDiagnosticDataCollector'
    Tk '\Microsoft\Windows\NetTrace\' 'GatherNetworkInfo'
}

# =====================================================================
#  9) EDGE & WINDOWS UPDATE
# =====================================================================
New-Tw 'edge_boost' 'edge' '*' $true 'Edge: disable Startup Boost & background running' 'Edge: Başlangıç Hızlandırma ve arka planda çalışmayı kapat' 'Edge: desactivar inicio acelerado y segundo plano' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'StartupBoostEnabled' 0
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'BackgroundModeEnabled' 0
}
New-Tw 'edge_first' 'edge' '*' $true 'Edge: hide first-run experience' 'Edge: ilk çalıştırma ekranını gizle' 'Edge: ocultar pantalla de bienvenida' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'HideFirstRunExperience' 1
}
New-Tw 'edge_shop' 'edge' '*' $true 'Edge: disable shopping assistant, rewards & recommendations' 'Edge: alışveriş asistanı, ödüller ve önerileri kapat' 'Edge: desactivar asistente de compras y recomendaciones' {
    $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    R $k 'EdgeShoppingAssistantEnabled' 0
    R $k 'ShowMicrosoftRewards' 0
    R $k 'ShowRecommendationsEnabled' 0
    R $k 'PersonalizationReportingEnabled' 0
    R $k 'EdgeFollowEnabled' 0
}
New-Tw 'edge_ai' 'edge' '*' $true 'Edge: disable Copilot / sidebar AI features' 'Edge: Copilot / kenar çubuğu yapay zeka özelliklerini kapat' 'Edge: desactivar Copilot / barra lateral IA' {
    $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    R $k 'HubsSidebarEnabled' 0
    R $k 'CopilotCDPPageContext' 0
    R $k 'Microsoft365CopilotChatIconEnabled' 0
}
New-Tw 'edge_tel' 'edge' '*' $true 'Edge: disable telemetry & feedback' 'Edge: telemetri ve geri bildirimi kapat' 'Edge: desactivar telemetría y comentarios' {
    $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    R $k 'MetricsReportingEnabled' 0
    R $k 'UserFeedbackAllowed' 0
    R $k 'SpotlightExperiencesAndRecommendationsEnabled' 0
}
New-Tw 'wu_norestart' 'edge' '*' $true 'Windows Update: no auto-restart while signed in' 'Windows Update: oturum açıkken otomatik yeniden başlatma yok' 'Windows Update: sin reinicio automático' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' 1
}
New-Tw 'wu_driver' 'edge' '*' $false 'Windows Update: do not install drivers automatically' 'Windows Update: sürücüleri otomatik yükleme' 'Windows Update: no instalar controladores automáticamente' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' 1
    R 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata' 'PreventDeviceMetadataFromNetwork' 1
}
New-Tw 'wu_insider' 'edge' '*' $true 'Windows Update: disable Insider preview builds' 'Windows Update: Insider önizleme sürümlerini kapat' 'Windows Update: desactivar compilaciones Insider' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'AllowBuildPreview' 0
}
New-Tw 'wu_mrt' 'edge' '*' $false 'Windows Update: do not offer Malicious Software Removal Tool' 'Windows Update: Kötü Amaçlı Yazılım Kaldırma Aracı sunma' 'Windows Update: no ofrecer herramienta MSRT' {
    R 'HKLM:\SOFTWARE\Policies\Microsoft\MRT' 'DontOfferThroughWUAU' 1
}

# =====================================================================
#  UI  (classic XP look)
# =====================================================================
$beige = [Drawing.Color]::FromArgb(236, 233, 216)
$blue  = [Drawing.Color]::FromArgb(0, 84, 227)
$script:Chk = @{}
$script:Lists  = @{}
$script:Pages  = @{}

$f = New-Object Windows.Forms.Form
$f.ClientSize = New-Object Drawing.Size(640, 560)
$f.FormBorderStyle = 'FixedSingle'; $f.MaximizeBox = $false
$f.StartPosition = 'CenterScreen'
$f.BackColor = $beige
$f.Font = New-Object Drawing.Font('Tahoma', 8.25)

$hd = New-Object Windows.Forms.Panel
$hd.SetBounds(0, 0, 640, 50); $hd.BackColor = $blue
$l1 = New-Object Windows.Forms.Label
$l1.SetBounds(10, 5, 400, 22); $l1.ForeColor = 'White'; $l1.BackColor = $blue
$l1.Font = New-Object Drawing.Font('Tahoma', 12, [Drawing.FontStyle]::Bold)
$l2 = New-Object Windows.Forms.Label
$l2.SetBounds(10, 29, 620, 16); $l2.ForeColor = 'White'; $l2.BackColor = $blue
$hd.Controls.AddRange(@($l1, $l2)); $f.Controls.Add($hd)

$tc = New-Object Windows.Forms.TabControl
$tc.SetBounds(8, 56, 624, 300)
foreach ($c in $CatOrder) {
    $tp = New-Object Windows.Forms.TabPage; $tp.BackColor = $beige
    $lb = New-Object Windows.Forms.CheckedListBox
    $lb.Dock = 'Fill'; $lb.CheckOnClick = $true; $lb.HorizontalScrollbar = $true; $lb.IntegralHeight = $false
    $tp.Controls.Add($lb); $tc.TabPages.Add($tp)
    $script:Lists[$c] = $lb; $script:Pages[$c] = $tp
}
$f.Controls.Add($tc)

$cbRP = New-Object Windows.Forms.CheckBox
$cbRP.SetBounds(10, 360, 400, 20); $cbRP.Checked = $true; $f.Controls.Add($cbRP)

$tb = New-Object Windows.Forms.TextBox
$tb.SetBounds(8, 384, 624, 96); $tb.Multiline = $true; $tb.ReadOnly = $true; $tb.ScrollBars = 'Vertical'
$tb.BackColor = 'White'; $tb.Font = New-Object Drawing.Font('Lucida Console', 8)
$f.Controls.Add($tb)

$pb = New-Object Windows.Forms.ProgressBar
$pb.SetBounds(8, 486, 624, 14); $f.Controls.Add($pb)
$st = New-Object Windows.Forms.Label
$st.SetBounds(8, 504, 624, 16); $f.Controls.Add($st)

function New-Btn($x, $w) { $b = New-Object Windows.Forms.Button; $b.SetBounds($x, 524, $w, 26); $b.FlatStyle = 'Standard'; $f.Controls.Add($b); $b }
$bRec = New-Btn 8 120; $bAll = New-Btn 134 100; $bNone = New-Btn 240 100
$bApply = New-Btn 502 130; $bApply.Font = New-Object Drawing.Font('Tahoma', 8.25, [Drawing.FontStyle]::Bold)

# menu
$mm = New-Object Windows.Forms.MainMenu
$mFile = New-Object Windows.Forms.MenuItem; $mExp = New-Object Windows.Forms.MenuItem; $mExit = New-Object Windows.Forms.MenuItem
$mFile.MenuItems.AddRange(@($mExp, $mExit))
$mOpt = New-Object Windows.Forms.MenuItem; $mLang = New-Object Windows.Forms.MenuItem
$mEn = New-Object Windows.Forms.MenuItem; $mTr = New-Object Windows.Forms.MenuItem; $mEs = New-Object Windows.Forms.MenuItem
$mEn.Text = '1 - English'; $mTr.Text = '2 - Türkçe'; $mEs.Text = '3 - Español'
foreach ($m in $mEn, $mTr, $mEs) { $m.RadioCheck = $true }
$mLang.MenuItems.AddRange(@($mEn, $mTr, $mEs)); $mOpt.MenuItems.Add($mLang) | Out-Null
$mHelp = New-Object Windows.Forms.MenuItem; $mAbout = New-Object Windows.Forms.MenuItem
$mHelp.MenuItems.Add($mAbout) | Out-Null
$mm.MenuItems.AddRange(@($mFile, $mOpt, $mHelp)); $f.Menu = $mm

# ---------------------------------------------------------------- logic
function Log($m) { $tb.AppendText("$m`r`n"); [Windows.Forms.Application]::DoEvents() }
function Visible-Tw($c) { @($Tw | Where-Object { $_.Cat -eq $c -and ($_.Ver -eq '*' -or $_.Ver -eq $ver) }) }
function Save-Checks { foreach ($c in $CatOrder) { $lb = $script:Lists[$c]; $it = $lb.Tag; for ($i = 0; $i -lt $lb.Items.Count; $i++) { $script:Chk[$it[$i].Id] = $lb.GetItemChecked($i) } } }
function Fill {
    foreach ($c in $CatOrder) {
        $lb = $script:Lists[$c]; $items = Visible-Tw $c
        $lb.BeginUpdate(); $lb.Items.Clear()
        foreach ($t in $items) { [void]$lb.Items.Add($t.N[$script:Lang], [bool]$script:Chk[$t.Id]) }
        $lb.Tag = $items; $lb.EndUpdate()
    }
}
function Apply-Lang {
    $L = $S[$script:Lang]
    $f.Text = $L.title
    $l1.Text = $L.title
    $l2.Text = "$($L.detected): $osName  |  $disp  |  Build $build"
    $mFile.Text = $L.file; $mExp.Text = $L.exp; $mExit.Text = $L.exit
    $mOpt.Text = $L.opts; $mLang.Text = $L.lang; $mHelp.Text = $L.help; $mAbout.Text = $L.about
    $mEn.Checked = ($script:Lang -eq 'en'); $mTr.Checked = ($script:Lang -eq 'tr'); $mEs.Checked = ($script:Lang -eq 'es')
    foreach ($c in $CatOrder) { $script:Pages[$c].Text = $L.cats[$c] }
    $cbRP.Text = $L.rp
    $bRec.Text = $L.rec; $bAll.Text = $L.all; $bNone.Text = $L.none; $bApply.Text = $L.apply
    $st.Text = $L.ready
    Fill
}
function Set-Lang($code) { Save-Checks; $script:Lang = $code; Apply-Lang }
function SetAll($mode) {
    foreach ($c in $CatOrder) {
        $lb = $script:Lists[$c]; $it = $lb.Tag
        for ($i = 0; $i -lt $lb.Items.Count; $i++) {
            $v = switch ($mode) { 'rec' { [bool]$it[$i].Rec } 'all' { $true } default { $false } }
            $lb.SetItemChecked($i, $v)
        }
    }
}
function Export-Doc {
    Save-Checks
    $p = Join-Path ([Environment]::GetFolderPath('Desktop')) 'DebloatXP-Documentation.txt'
    $o = New-Object Text.StringBuilder
    [void]$o.AppendLine("Debloat Tool - documentation ($osName $disp, build $build)")
    foreach ($c in $CatOrder) {
        [void]$o.AppendLine("`r`n=== $($S[$script:Lang].cats[$c]) ===")
        foreach ($t in ($Tw | Where-Object { $_.Cat -eq $c })) {
            $rec = if ($t.Rec) { 'recommended' } else { 'optional' }
            [void]$o.AppendLine("`r`n[Win $($t.Ver)] $($t.N[$script:Lang])  ($rec)")
            foreach ($line in ($t.Do.ToString().Trim() -split "`r?`n")) { [void]$o.AppendLine('    ' + $line.Trim()) }
        }
    }
    [IO.File]::WriteAllText($p, $o.ToString(), (New-Object Text.UTF8Encoding $true))
    [void][Windows.Forms.MessageBox]::Show("$($S[$script:Lang].expdone)`n$p", $S[$script:Lang].title)
}

$mEn.Add_Click({ Set-Lang 'en' }); $mTr.Add_Click({ Set-Lang 'tr' }); $mEs.Add_Click({ Set-Lang 'es' })
$mExit.Add_Click({ $f.Close() })
$mExp.Add_Click({ Export-Doc })
$mAbout.Add_Click({ [void][Windows.Forms.MessageBox]::Show(($S[$script:Lang].aboutTxt -replace '`n', [Environment]::NewLine), $S[$script:Lang].title) })
$bRec.Add_Click({ SetAll 'rec' }); $bAll.Add_Click({ SetAll 'all' }); $bNone.Add_Click({ SetAll 'none' })

$bApply.Add_Click({
    Save-Checks
    $L = $S[$script:Lang]
    $sel = @($Tw | Where-Object { $script:Chk[$_.Id] -and ($_.Ver -eq '*' -or $_.Ver -eq $ver) })
    if ($sel.Count -eq 0) { [void][Windows.Forms.MessageBox]::Show($L.nosel, $L.title); return }
    if ([Windows.Forms.MessageBox]::Show(($L.confirm -f $sel.Count), $L.title, 'YesNo', 'Question') -ne 'Yes') { return }
    $f.Enabled = $false; $tb.Clear(); $pb.Maximum = $sel.Count; $pb.Value = 0; $st.Text = $L.running
    if ($cbRP.Checked) {
        Log '* Restore point...'
        Enable-ComputerRestore -Drive "$env:SystemDrive\"
        Checkpoint-Computer -Description 'DebloatXP' -RestorePointType MODIFY_SETTINGS
    }
    $i = 0
    foreach ($t in $sel) {
        $i++; $st.Text = "$($L.running) $i / $($sel.Count)"
        Log "[$i/$($sel.Count)] $($t.N[$script:Lang])"
        try { & $t.Do } catch { Log "    ! $($_.Exception.Message)" }
        $pb.Value = $i
        [Windows.Forms.Application]::DoEvents()
    }
    Stop-Process -Name explorer -Force
    $st.Text = $L.done; Log "* $($L.done)"
    $f.Enabled = $true
    [void][Windows.Forms.MessageBox]::Show($L.done, $L.title, 'OK', 'Information')
})

Apply-Lang
SetAll 'rec'
[void]$f.ShowDialog()