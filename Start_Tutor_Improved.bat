@echo off
setlocal enabledelayedexpansion
:: UTF-8 support for better character handling
chcp 65001 >nul 2>&1
title AI Tutor Launcher
cd /d "%~dp0"

:: --- COLOR SUPPORT (Windows 10+) ---
:: Enable ANSI escape sequences for colored output
reg query "HKCU\Console" /v VirtualTerminalLevel >nul 2>&1
if %errorlevel% equ 0 (
    set "ESC="
    set "GREEN=[92m"
    set "YELLOW=[93m"
    set "RED=[91m"
    set "CYAN=[96m"
    set "RESET=[0m"
) else (
    set "GREEN="
    set "YELLOW="
    set "RED="
    set "CYAN="
    set "RESET="
)

:: --- PRE-FLIGHT CHECKS ---
echo %CYAN%Checking system requirements...%RESET%
echo.

if not exist "engine\llama-cli.exe" (
    echo %RED%[ERROR] Could not find 'engine\llama-cli.exe'%RESET%
    echo Please ensure the engine folder contains llama-cli.exe
    echo.
    pause
    exit /b 1
)

if not exist "models" (
    echo %RED%[ERROR] 'models' folder not found%RESET%
    echo Please create a 'models' folder and add .gguf files
    echo.
    pause
    exit /b 1
)

:menu
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%         AVAILABLE AI MODELS%RESET%
echo %CYAN%========================================%RESET%
echo.

set count=0
set models_found=0

for %%f in ("models\*.gguf") do (
    set /a count+=1
    set /a models_found=1
    set "model!count!=%%~nxf"
    set "modelsize!count!=%%~zf"
    
    :: Calculate size in MB
    set /a sizeMB=%%~zf/1048576
    
    echo %GREEN%[!count!]%RESET% %%~nxf %YELLOW%(~!sizeMB! MB)%RESET%
)

if !models_found! equ 0 (
    echo %RED%[ERROR] No .gguf files found in 'models' folder.%RESET%
    echo.
    echo Please add at least one .gguf model file to the 'models' folder.
    echo.
    pause
    exit /b 1
)

echo.
echo %CYAN%========================================%RESET%
echo.
set "choice="
set /p choice="Select model # (or 'q' to quit): "

if /i "%choice%"=="q" (
    echo.
    echo Goodbye!
    timeout /t 2 >nul
    exit /b 0
)

:: Improved validation: Check if input is numeric
set "valid=0"
for /l %%i in (1,1,!count!) do (
    if "!choice!"=="%%i" set "valid=1"
)

if !valid! equ 0 (
    echo %RED%Invalid selection. Please choose a number between 1 and !count!%RESET%
    timeout /t 2 >nul
    goto menu
)

set "MODEL_NAME=!model%choice%!"
set "MODEL_SIZE_BYTES=!modelsize%choice%!"
set /a MODEL_SIZE_MB=!MODEL_SIZE_BYTES!/1048576

:: --- PERFORMANCE SELECTION ---
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        PERFORMANCE LEVEL%RESET%
echo %CYAN%========================================%RESET%
echo.
echo %YELLOW%Selected Model:%RESET% !MODEL_NAME! (~!MODEL_SIZE_MB! MB)
echo.
echo %CYAN%Performance Modes:%RESET%
echo.
echo %GREEN%[L] LOW%RESET%      - 1 CPU core, ~350 words memory, Low priority
echo                 Estimated RAM: ~!MODEL_SIZE_MB! MB + 100 MB = ~%YELLOW%!MODEL_SIZE_MB!00 MB%RESET%
echo                 %CYAN%Best for:%RESET% Older PCs, 4GB RAM systems
echo.
echo %GREEN%[M] MEDIUM%RESET%   - 2 CPU cores, ~750 words memory, Normal priority
echo                 Estimated RAM: ~!MODEL_SIZE_MB! MB + 250 MB = ~%YELLOW%!MODEL_SIZE_MB!50 MB%RESET%
echo                 %CYAN%Best for:%RESET% Standard Q^&A, balanced performance
echo.
echo %GREEN%[H] HIGH%RESET%     - 4 CPU cores, ~1500 words memory, High priority
echo                 Estimated RAM: ~!MODEL_SIZE_MB! MB + 600 MB = ~%YELLOW%!MODEL_SIZE_MB!00 MB%RESET%
echo                 %CYAN%Best for:%RESET% Complex tasks, longer conversations
echo.
echo %RED%Note:%RESET% Total RAM = Model Size + Context Memory
echo.

set /p pwr="Select working mode [L/M/H] (press Enter for Medium): "

:: Default to Medium if empty
if "!pwr!"=="" set "pwr=M"

:: Set defaults (Medium)
set final_threads=2
set final_context=1024
set final_prio=1
set mode=MEDIUM
set mode_color=%GREEN%

if /i "%pwr%"=="l" (
    set final_threads=1
    set final_context=512
    set final_prio=-1
    set mode=LOW
    set mode_color=%YELLOW%
)
if /i "%pwr%"=="m" (
    set final_threads=2
    set final_context=1024
    set final_prio=1
    set mode=MEDIUM
    set mode_color=%GREEN%
)
if /i "%pwr%"=="h" (
    set final_threads=4
    set final_context=2048
    set final_prio=3
    set mode=HIGH
    set mode_color=%CYAN%
)

:: Validate input
if not "!mode!"=="LOW" if not "!mode!"=="MEDIUM" if not "!mode!"=="HIGH" (
    echo %RED%Invalid performance mode. Using MEDIUM as default.%RESET%
    set final_threads=2
    set final_context=1024
    set final_prio=1
    set mode=MEDIUM
    timeout /t 2 >nul
)

:: --- SYSTEM PROMPT CUSTOMIZATION ---
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        AI PERSONALITY%RESET%
echo %CYAN%========================================%RESET%
echo.
echo Choose the AI's role:
echo.
echo [1] Excel ^& Python Tutor (concise, technical)
echo [2] General Assistant (helpful, conversational)
echo [3] Code Expert (detailed explanations)
echo [4] Custom (you write the prompt)
echo.

set /p prompt_choice="Select personality [1-4] (press Enter for default): "

if "!prompt_choice!"=="" set "prompt_choice=1"

set "SYSTEM_PROMPT=You are a concise Excel and Python tutor. Answer briefly."

if "!prompt_choice!"=="2" (
    set "SYSTEM_PROMPT=You are a helpful AI assistant. Provide clear, accurate answers."
)
if "!prompt_choice!"=="3" (
    set "SYSTEM_PROMPT=You are a programming expert. Provide detailed code explanations with examples."
)
if "!prompt_choice!"=="4" (
    echo.
    set /p "SYSTEM_PROMPT=Enter your custom system prompt: "
)

:: --- LAUNCH CONFIRMATION ---
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        LAUNCH SUMMARY%RESET%
echo %CYAN%========================================%RESET%
echo.
echo %YELLOW%Model:%RESET%       !MODEL_NAME!
echo %YELLOW%Mode:%RESET%        !mode_color!!mode!%RESET%
echo %YELLOW%Threads:%RESET%     !final_threads! CPU cores
echo %YELLOW%Context:%RESET%     !final_context! tokens (~!final_context! words)
echo %YELLOW%Priority:%RESET%    !final_prio!
echo %YELLOW%Prompt:%RESET%      !SYSTEM_PROMPT!
echo.
echo %GREEN%Starting AI in 3 seconds...%RESET%
echo %CYAN%(Press Ctrl+C to cancel)%RESET%
echo.
timeout /t 3 >nul

:: --- LAUNCH ---
echo %CYAN%Initializing AI model...%RESET%
echo.

"engine\llama-cli.exe" ^
  -m "models\!MODEL_NAME!" ^
  -cnv ^
  -t !final_threads! ^
  -c !final_context! ^
  --prio !final_prio! ^
  -p "!SYSTEM_PROMPT!"

:: --- POST-EXECUTION ---
echo.
echo %YELLOW%[STATUS] AI session ended.%RESET%
echo.
echo Press any key to return to model selection...
pause >nul
goto menu
