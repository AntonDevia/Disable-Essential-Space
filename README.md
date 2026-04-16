# Disable / Enable Essential Space / Отключение и включение Essential Space

<a id="contents"></a>
## Contents / Содержание

- [About / Описание](#about)
- [Features / Возможности](#features)
- [Quick Start (Windows) / Быстрый старт (Windows)](#quick-start-windows)
- [Manual Method / Ручной способ](#manual-method)

<a id="about"></a>
## About / Описание

Simple bilingual CLI tool for Windows.  
Простой двуязычный CLI-инструмент для Windows.

<a id="features"></a>
## Features / Возможности

- Downloads official ADB (`platform-tools`) from Google / Скачивает официальный ADB (`platform-tools`) с сайта Google
- Checks connected device via `adb devices` / Проверяет подключенное устройство через `adb devices`
- Shows USB debugging instructions if device is not found / Показывает инструкцию по USB-отладке, если устройство не найдено
- Disables or enables Essential Space / Отключает или включает Essential Space

<a id="quick-start-windows"></a>
## Quick Start (Windows) / Быстрый старт (Windows)

```powershell
irm https://raw.githubusercontent.com/AntonDevia/Disable-Essential-Space/main/essential-space.ps1 | iex
```

<a id="manual-method"></a>
## Manual Method / Ручной способ

Official Google link ADB / Официальные ссылки на ADB:

- SDK Platform-Tools (official ADB package) / SDK Platform-Tools (официальный пакет ADB): [developer.android.com/tools/releases/platform-tools](https://developer.android.com/tools/releases/platform-tools)
- Enable Developer options + USB debugging / Включение режима разработчика и USB-отладки: [developer.android.com/studio/debug/dev-options](https://developer.android.com/studio/debug/dev-options)

Disable Essential Space / Отключить Essential Space:

```bash
adb devices
adb shell settings put secure nt_block_essential_key 1
adb shell pm disable-user --user 0 com.nothing.ntessentialspace
adb shell pm disable-user --user 0 com.nothing.ntessentialrecorder
```

Enable Essential Space / Включить Essential Space:

```bash
adb devices
adb shell settings put secure nt_block_essential_key 0
adb shell pm enable --user 0 com.nothing.ntessentialspace
adb shell pm enable --user 0 com.nothing.ntessentialrecorder
```
