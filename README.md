# Disable / Enable Essential Space / Отключение и включение Essential Space

<a id="contents"></a>
## Contents / Содержание

- [About / Описание](#about)
- [Features / Возможности](#features)
- [Quick Start (Windows) / Быстрый старт (Windows)](#quick-start-windows)
- [Quick Start (Linux) / Быстрый старт (Linux)](#quick-start-linux)
- [Manual Method / Ручной способ](#manual-method)
- [What Script Does / Что делает скрипт](#what-script-does)

<a id="about"></a>
## About / Описание

Simple bilingual CLI tool for Windows and Linux.  
Простой двуязычный CLI-инструмент для Windows и Linux.

<a id="features"></a>
## Features / Возможности

- Language selection: `Русский` / `English`
- Выбор действия через меню со стрелками (`↑/↓` + `Enter`) и указателем `→`
- Downloads official ADB (`platform-tools`) from Google
- Скачивает официальный ADB (`platform-tools`) с сайта Google
- Checks connected device via `adb devices`
- Проверяет подключенное устройство через `adb devices`
- Shows USB debugging instructions if device is not found
- Показывает инструкцию по USB-отладке, если устройство не найдено
- Runs only required ADB commands with quiet output (errors only)
- Выполняет только нужные ADB-команды без лишнего вывода (только ошибки)

<a id="quick-start-windows"></a>
## Quick Start (Windows) / Быстрый старт (Windows)

```powershell
irm https://raw.githubusercontent.com/AntonDevia/Disable-Essential-Space/main/essential-space.ps1 | iex
```

<a id="quick-start-linux"></a>
## Quick Start (Linux) / Быстрый старт (Linux)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AntonDevia/Disable-Essential-Space/main/essential-space.sh)
```

Or / Или:

```bash
wget -qO- https://raw.githubusercontent.com/AntonDevia/Disable-Essential-Space/main/essential-space.sh | bash
```

<a id="manual-method"></a>
## Manual Method / Ручной способ

Official Google links / Официальные ссылки Google:

- ADB commands and usage / Команды и использование ADB: [developer.android.com/tools/adb](https://developer.android.com/tools/adb)
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

<a id="what-script-does"></a>
## What Script Does / Что делает скрипт

1. Asks for language (`Русский` / `English`)  
   Спрашивает язык (`Русский` / `English`)
2. Asks what to do: disable or enable Essential Space  
   Спрашивает действие: отключить или включить Essential Space
3. Warns that ADB will be downloaded from official Google source (`Space` to continue)  
   Предупреждает о скачивании ADB с официального сайта Google (`Space` для продолжения)
4. Checks phone connection with `adb devices`  
   Проверяет подключение телефона через `adb devices`
5. If device is not found, shows Android developer mode + USB debugging instructions, then retry on `Space`  
   Если устройство не найдено, показывает инструкцию по режиму разработчика и USB-отладке, затем повтор по `Space`
6. Executes selected ADB commands and shows final success message  
   Выполняет выбранные ADB-команды и показывает финальное сообщение об успехе
