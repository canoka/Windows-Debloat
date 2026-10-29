<div align="center">

# 🪟 Debloat XP

**A tiny, one-file Windows 10 / 11 debloater with a classic Windows XP-style interface.**

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](#requirements)
[![PowerShell](https://img.shields.io/badge/Built%20with-PowerShell-5391FE?logo=powershell&logoColor=white)](#how-it-works)
[![Languages](https://img.shields.io/badge/Languages-EN%20%7C%20TR%20%7C%20ES-2ea44f)](#languages)

**English** · [Türkçe](README.tr.md) · [Español](README.es.md)

</div>

<!-- Add a screenshot at docs/screenshot.png and uncomment the next line:
<p align="center"><img src="docs/screenshot.png" alt="Debloat XP screenshot" width="560"></p>
-->

---

## ✨ Features

- **One file, one click.** Double-click `DebloatXP.cmd`, approve the admin prompt, done. No installer, no dependencies, nothing downloaded.
- **Knows your Windows.** Detects whether you run Windows 10 or 11 (plus version and build) and only shows the options that apply.
- **150+ options** across privacy, apps, AI, search, taskbar, Explorer, performance, services and updates.
- **Recommended preset** for a safe one-click clean-up, or pick everything yourself.
- **Restore point** creation before applying (on by default).
- **Documentation export:** `File → Export documentation` writes every option and the exact commands it runs to a text file on your desktop.
- **Lightweight:** native Windows Forms, classic XP look, starts instantly.
- **Languages:** English, Türkçe, Español (`Options → Language`).

## 🚀 Quick start

1. Download **`DebloatXP.cmd`** (from [Releases](../../releases) or the repository).
2. Double-click it and accept the UAC (administrator) prompt.
3. Pick a language if you like: `Options → Language`.
4. Press **Recommended**, or tick what you want in each tab.
5. Leave **Create a restore point first** checked and press **Apply**.
6. Restart Windows when it finishes.

## 🧹 What it covers

| Tab | Examples |
|---|---|
| **Privacy & Telemetry** | Telemetry & diagnostics, activity history, advertising ID, location, inking/typing data, speech recognition, error reporting, P2P updates, tips & ads, suggested content |
| **Apps** | ~55 preinstalled apps: Cortana, News, Solitaire, Teams, Clipchamp, Xbox apps, Skype, Feedback Hub, sponsored apps (Spotify, TikTok, Candy Crush…), optional OneDrive removal |
| **AI & Copilot** | Windows Copilot, Recall, Click to Do, AI features in Paint and Notepad |
| **Search** | Bing web results in Start, Cortana, search highlights, cloud search, search history, optional indexing off |
| **Taskbar & Start** | Widgets, News and Interests, Chat/Teams icon, People, Meet Now, Start recommendations, classic right-click menu, left-aligned taskbar |
| **Explorer** | File extensions, hidden files, open to This PC, Home & Gallery, 3D Objects, sync provider ads |
| **Performance** | Power plan, hibernation, Fast Startup, visual effects, Game DVR, background apps, SysMain, network throttling, temp-file cleanup |
| **Services & Tasks** | Telemetry and other unneeded services, telemetry scheduled tasks |
| **Edge & Updates** | Edge Startup Boost, shopping assistant, Edge AI features and telemetry, Windows Update auto-restart, driver updates, Insider builds |

Options that only make sense on one Windows version are shown only on that version.

## 🛡️ Safety

- Windows Defender is **never** touched.
- Microsoft Store and Microsoft Edge are **not** removed.
- Nothing is downloaded and no data is sent anywhere. The tool only changes local settings.
- Removed apps can be reinstalled from the Microsoft Store.
- Settings changes can be rolled back with the restore point. Use the exported documentation if you want to reverse a single setting by hand.
- Some policy-based settings have limited effect on Windows Home (for example, telemetry cannot be fully disabled).
- Some options are off by default for a reason: removing the Xbox apps can break Xbox/Minecraft sign-in, and the Print Spooler should only be disabled if you never print.

## 📋 Requirements

- Windows 10 or Windows 11
- Administrator rights
- Windows PowerShell 5.1 (included with Windows)

## ⚙️ How it works

`DebloatXP.cmd` is a single file that is both a batch script and a PowerShell script. The batch part asks for administrator rights and launches the PowerShell part, which draws the Windows Forms interface. Every option is a small block of registry, service, scheduled-task or app-removal commands. You can open the file in any text editor and read exactly what it does.

## ❓ FAQ

**Windows SmartScreen or my antivirus warns me.**
The file is an unsigned script that changes system settings, which security tools often flag. It is plain text, so read it before running it. If you are unsure, do not run it.

**How do I undo changes?**
Restore the restore point created before applying, or reinstall removed apps from the Microsoft Store.

**Why is the console window flashing at start?**
That is the launcher starting PowerShell. It closes immediately.

## ⚠️ Disclaimer

This tool modifies system settings. Use it at your own risk and create a restore point or backup first. The authors are not responsible for any damage or data loss.

## 🙏 Credits

Feature ideas come from publicly documented Windows tweaks and projects such as [Win11Debloat](https://github.com/Raphire/Win11Debloat).
