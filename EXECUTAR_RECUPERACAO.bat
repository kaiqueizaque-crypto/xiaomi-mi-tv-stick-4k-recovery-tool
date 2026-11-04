@echo off
chcp 65001 >nul
title Mi TV Stick 4K Recovery Toolkit (Android 14)
cd /d "%~dp0"

:: Executa o assistente em PowerShell com bypass de politicas
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\recuperador.ps1"

if %errorlevel% neq 0 (
    echo.
    echo O programa foi finalizado.
    echo Pressione qualquer tecla para fechar esta janela...
    pause >nul
)
