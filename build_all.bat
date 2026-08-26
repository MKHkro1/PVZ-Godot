@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

rem ============================================================
rem  PVZ-Godot 一键构建: Windows EXE + ZIP + Android APK
rem  双击运行即可。可通过环境变量 GODOT_EXE 覆盖 Godot 路径。
rem ============================================================

set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

if not defined GODOT_EXE (
    set "GODOT_EXE=D:\Web\sts2\.Godot_v4.5.1-stable_mono_win64\Godot_v4.5.1-stable_mono_win64_console.exe"
)

set "WIN_EXE=%PROJECT_DIR%\pvz_godot开源版.exe"
set "WIN_PCK=%PROJECT_DIR%\pvz_godot开源版.pck"
set "WIN_ZIP=%PROJECT_DIR%\pvz_godot开源版_win64.zip"
set "APK_OUT=%PROJECT_DIR%\pvz_godot.apk"

set "EXPORT_WIN=Windows Desktop"
set "EXPORT_APK=Android"

echo.
echo ========================================
echo   PVZ-Godot 一键构建
echo ========================================
echo 项目目录: %PROJECT_DIR%
echo Godot:    %GODOT_EXE%
echo.

if not exist "%GODOT_EXE%" (
    echo [错误] 找不到 Godot 可执行文件:
    echo   %GODOT_EXE%
    echo.
    echo 请修改本 bat 顶部的 GODOT_EXE 路径，或设置环境变量 GODOT_EXE。
    goto :fail
)

if not exist "%PROJECT_DIR%\project.godot" (
    echo [错误] 当前目录不是 Godot 项目根目录（缺少 project.godot）。
    goto :fail
)

cd /d "%PROJECT_DIR%"

rem 自愈：若上次构建中断遗留了 project.godot 备份，先还原插件列表
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%\.tools\set_plugins.ps1" -Recover

echo [0/3] 临时禁用编辑器插件（消除无头导出退出时的 RID/ObjectDB 泄漏噪音）...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%\.tools\set_plugins.ps1" -Off
if errorlevel 1 echo [提示] 插件开关失败，将按原配置导出。

echo [1/3] 导出 Windows EXE ...
"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --export-release "%EXPORT_WIN%" "%WIN_EXE%"
if errorlevel 1 (
    echo [错误] Windows 导出失败。
    goto :fail
)

if not exist "%WIN_EXE%" (
    echo [错误] 未找到导出文件: %WIN_EXE%
    goto :fail
)

echo [完成] %WIN_EXE%
if exist "%WIN_PCK%" (
    echo [完成] %WIN_PCK%
) else (
    echo [提示] 未找到独立 PCK 文件（可能已嵌入 EXE）。
)

echo.
echo [2/3] 打包 Windows ZIP ...
if exist "%WIN_ZIP%" del /f /q "%WIN_ZIP%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$items = @();" ^
    "if (Test-Path -LiteralPath '%WIN_EXE%') { $items += (Get-Item -LiteralPath '%WIN_EXE%') };" ^
    "if (Test-Path -LiteralPath '%WIN_PCK%') { $items += (Get-Item -LiteralPath '%WIN_PCK%') };" ^
    "if ($items.Count -eq 0) { Write-Error '没有可打包的文件'; exit 1 };" ^
    "Compress-Archive -LiteralPath $items.FullName -DestinationPath '%WIN_ZIP%' -Force"
if errorlevel 1 (
    echo [错误] ZIP 打包失败。
    goto :fail
)

echo [完成] %WIN_ZIP%

echo.
echo [3/3] 导出 Android APK ...
"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --export-release "%EXPORT_APK%" "%APK_OUT%"
if errorlevel 1 (
    echo [错误] Android 导出失败（请检查 Android SDK / JDK 配置）。
    goto :fail
)

if not exist "%APK_OUT%" (
    echo [错误] 未找到导出文件: %APK_OUT%
    goto :fail
)

echo [完成] %APK_OUT%

echo.
echo 恢复编辑器插件配置 ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%\.tools\set_plugins.ps1" -On

echo.
echo ========================================
echo   全部构建成功
echo ========================================
echo   %WIN_EXE%
if exist "%WIN_PCK%" echo   %WIN_PCK%
echo   %WIN_ZIP%
echo   %APK_OUT%
echo ========================================
echo.
pause
exit /b 0

:fail
echo.
rem 无论失败在哪一步，都尝试还原编辑器插件配置
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%\.tools\set_plugins.ps1" -On
echo 构建未完成，请查看上方错误信息。
echo.
pause
exit /b 1
