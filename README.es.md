<div align="center">

# 🪟 Debloat XP

**Un optimizador diminuto de Windows 10 / 11 en un solo archivo, con una interfaz clásica al estilo Windows XP.**

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](#requisitos)
[![PowerShell](https://img.shields.io/badge/Hecho%20con-PowerShell-5391FE?logo=powershell&logoColor=white)](#cómo-funciona)
[![Idiomas](https://img.shields.io/badge/Idiomas-EN%20%7C%20TR%20%7C%20ES-2ea44f)](#️-características)

[English](README.md) · [Türkçe](README.tr.md) · **Español**

</div>

<!-- Añade una captura en docs/screenshot.png y descomenta la siguiente línea:
<p align="center"><img src="docs/screenshot.png" alt="Captura de Debloat XP" width="560"></p>
-->

---

## ✨ Características

- **Un archivo, un clic.** Haz doble clic en `DebloatXP.cmd`, acepta el aviso de administrador y listo. Sin instalador, sin dependencias, no se descarga nada.
- **Conoce tu Windows.** Detecta si usas Windows 10 u 11 (con versión y compilación) y solo muestra las opciones que corresponden.
- **Más de 150 opciones** en privacidad, aplicaciones, IA, búsqueda, barra de tareas, Explorador, rendimiento, servicios y actualizaciones.
- **Preajuste recomendado** para una limpieza segura con un clic, o elige todo tú mismo.
- Creación de un **punto de restauración** antes de aplicar (activado por defecto).
- **Exportar documentación:** `Archivo → Exportar documentación` escribe todas las opciones y los comandos exactos que ejecutan en un archivo de texto en tu escritorio.
- **Ligero:** Windows Forms nativo, aspecto XP clásico, se abre al instante.
- **Idiomas:** English, Türkçe, Español (`Opciones → Idioma`).

## 🚀 Inicio rápido

1. Descarga **`DebloatXP.cmd`** (desde [Releases](../../releases) o el repositorio).
2. Haz doble clic y acepta el aviso UAC (administrador).
3. Si quieres, elige el idioma: `Opciones → Idioma`.
4. Pulsa **Recomendado**, o marca lo que quieras en cada pestaña.
5. Deja marcada la casilla **Crear punto de restauración antes** y pulsa **Aplicar**.
6. Reinicia Windows cuando termine.

## 🧹 Qué cubre

| Pestaña | Ejemplos |
|---|---|
| **Privacidad y Telemetría** | Telemetría y diagnóstico, historial de actividad, ID de publicidad, ubicación, datos de escritura/tinta, reconocimiento de voz, informe de errores, actualizaciones P2P, consejos y anuncios, contenido sugerido |
| **Aplicaciones** | ~55 aplicaciones preinstaladas: Cortana, Noticias, Solitario, Teams, Clipchamp, apps de Xbox, Skype, Centro de opiniones, apps patrocinadas (Spotify, TikTok, Candy Crush…), eliminación opcional de OneDrive |
| **IA y Copilot** | Windows Copilot, Recall, Click to Do, funciones de IA en Paint y Bloc de notas |
| **Búsqueda** | Resultados web de Bing en Inicio, Cortana, destacados de búsqueda, búsqueda en la nube, historial de búsqueda, desactivar indexado (opcional) |
| **Barra de tareas e Inicio** | Widgets, Noticias e intereses, icono de Chat/Teams, Contactos, Reunirse ahora, recomendaciones de Inicio, menú contextual clásico, barra de tareas a la izquierda |
| **Explorador** | Extensiones de archivo, archivos ocultos, abrir en Este equipo, Inicio y Galería, Objetos 3D, anuncios de proveedores de sincronización |
| **Rendimiento** | Plan de energía, hibernación, inicio rápido, efectos visuales, Game DVR, apps en segundo plano, SysMain, limitación de red, limpieza de temporales |
| **Servicios y tareas** | Telemetría y otros servicios innecesarios, tareas programadas de telemetría |
| **Edge y Actualizaciones** | Inicio acelerado de Edge, asistente de compras, IA y telemetría de Edge, reinicio automático de Windows Update, actualizaciones de controladores, compilaciones Insider |

Las opciones que solo tienen sentido en una versión de Windows se muestran únicamente en esa versión.

## 🛡️ Seguridad

- Windows Defender **nunca** se toca.
- Microsoft Store y Microsoft Edge **no** se eliminan.
- No se descarga nada ni se envían datos a ningún sitio. La herramienta solo cambia ajustes locales.
- Las aplicaciones eliminadas se pueden reinstalar desde Microsoft Store.
- Los cambios de configuración se pueden revertir con el punto de restauración. Usa la documentación exportada si quieres deshacer un ajuste concreto a mano.
- Algunos ajustes basados en directivas tienen efecto limitado en Windows Home (por ejemplo, la telemetría no se puede desactivar del todo).
- Algunas opciones están desactivadas por defecto por una razón: quitar las apps de Xbox puede romper el inicio de sesión de Xbox/Minecraft, y la cola de impresión solo debe desactivarse si nunca imprimes.

## 📋 Requisitos

- Windows 10 o Windows 11
- Permisos de administrador
- Windows PowerShell 5.1 (incluido en Windows)

## ⚙️ Cómo funciona

`DebloatXP.cmd` es un único archivo que es a la vez un script por lotes y un script de PowerShell. La parte por lotes pide permisos de administrador y lanza la parte de PowerShell, que dibuja la interfaz de Windows Forms. Cada opción es un pequeño bloque de comandos de registro, servicios, tareas programadas o eliminación de aplicaciones. Puedes abrir el archivo en cualquier editor de texto y leer exactamente qué hace.

## ❓ Preguntas frecuentes

**Windows SmartScreen o mi antivirus me avisa.**
El archivo es un script sin firmar que cambia ajustes del sistema, algo que las herramientas de seguridad suelen marcar. Es texto plano: léelo antes de ejecutarlo. Si tienes dudas, no lo ejecutes.

**¿Cómo deshago los cambios?**
Restaura el punto de restauración creado antes de aplicar, o reinstala las aplicaciones eliminadas desde Microsoft Store.

**¿Por qué aparece brevemente una ventana de consola al iniciar?**
Es el lanzador abriendo PowerShell. Se cierra enseguida.

## ⚠️ Aviso legal

Esta herramienta modifica ajustes del sistema. Úsala bajo tu propia responsabilidad y crea antes un punto de restauración o una copia de seguridad. Los autores no se hacen responsables de daños ni pérdida de datos.

## 🙏 Créditos

Las ideas de funciones provienen de ajustes de Windows documentados públicamente y de proyectos como [Win11Debloat](https://github.com/Raphire/Win11Debloat).
