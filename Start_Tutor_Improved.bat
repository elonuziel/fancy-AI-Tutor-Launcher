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

set "engine_found=0"
for /d %%d in (engine-*) do (
    if exist "%%d\llama-cli.exe" set "engine_found=1"
    if exist "%%d\llama-server.exe" set "engine_found=1"
)

if "!engine_found!"=="0" (
    echo %RED%[ERROR] Could not find any engine files!%RESET%
    echo Please ensure you have extracted the engine to a folder starting with 'engine-'
    echo Examples: 'engine-cpu', 'engine-vulkan', 'engine-cuda', 'engine-sycl'
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
    
    :: Calculate size in MB (approximate using string length to avoid 32-bit limit)
    set "bytes=%%~zf"
    set "sizeMB=!bytes:~0,-6!"
    if "!sizeMB!"=="" set "sizeMB=0"
    
    :: Calculate GB for display
    set /a sizeGB_i=!sizeMB! / 1000
    set /a sizeGB_f=!sizeMB! %% 1000 / 100
    
    echo %GREEN%[!count!]%RESET% %%~nxf %YELLOW%(~!sizeGB_i!.!sizeGB_f! GB)%RESET%
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
set "MODEL_SIZE_MB=!MODEL_SIZE_BYTES:~0,-6!"
if "!MODEL_SIZE_MB!"=="" set "MODEL_SIZE_MB=0"
set /a MODEL_SIZE_GB_i=!MODEL_SIZE_MB! / 1000
set /a MODEL_SIZE_GB_f=(!MODEL_SIZE_MB! %% 1000) / 100

:: --- COMPUTE ENGINE SELECTION ---
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        COMPUTE ENGINE%RESET%
echo %CYAN%========================================%RESET%
echo.
echo Detected engines:
echo.

set engine_count=0

for /d %%d in (engine-*) do (
    set "has_engine=0"
    if exist "%%d\llama-cli.exe" set "has_engine=1"
    if exist "%%d\llama-server.exe" set "has_engine=1"
    if "!has_engine!"=="1" (
        set /a engine_count+=1
        set "engine_dir!engine_count!=%%d"
        
        :: Format the name cleanly
        set "engine_n=%%d"
        set "engine_n=!engine_n:engine-=!"
        
        echo %GREEN%[!engine_count!]%RESET% !engine_n!
    )
)

echo.
set /p engine_choice="Select compute engine [1-!engine_count!] (press Enter for 1): "
if "!engine_choice!"=="" set "engine_choice=1"

:: Validate input
set "valid=0"
for /l %%i in (1,1,!engine_count!) do (
    if "!engine_choice!"=="%%i" set "valid=1"
)

if !valid! equ 0 (
    echo %RED%Invalid selection. Defaulting to 1.%RESET%
    set "engine_choice=1"
    timeout /t 2 >nul
)

set "selected_engine_dir=!engine_dir%engine_choice%!"
set "engine_name=!selected_engine_dir:engine-=!"

:: --- ENGINE PARAMETER SETUP ---
:: Initialize parameters
set "ngl_param="
set "flash_attn_param="

:: Only show GPU settings if NOT using pure CPU engine
if /i "!engine_name!"=="cpu" goto skip_gpu_config

:: --- GPU CONFIGURATION ---
set "ngl_param=-ngl 99"
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        GPU LAYER OFFLOADING%RESET%
echo %CYAN%========================================%RESET%
echo.
echo By default, all layers are offloaded to the GPU for maximum speed.
echo If your GPU lacks memory ^(VRAM^), you can specify exactly how many 
echo layers to offload ^(e.g., 10, 15, 20^). 
echo.
set "ngl_input="
set /p "ngl_input=Enter number of layers to offload (press Enter to offload ALL): "
if not "!ngl_input!"=="" (
    set "ngl_param=-ngl !ngl_input!"
)

:: Ask for Flash Attention
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        ADVANCED OPTIMIZATIONS%RESET%
echo %CYAN%========================================%RESET%
echo.
echo %YELLOW%Flash Attention%RESET% significantly reduces VRAM usage and speeds up processing,
echo but it requires a modern GPU ^(e.g., NVIDIA RTX series, newer AMD, Apple Silicon^).
echo %RED%Warning:%RESET% Older GPUs may crash or fail to generate text if this is enabled!
echo.
set "use_fa=N"
set /p use_fa="Enable Flash Attention? [Y/N] (Press Enter for N): "
if /i "!use_fa!"=="y" (
    set "flash_attn_param=--flash-attn"
)

:skip_gpu_config

:: --- PERFORMANCE SELECTION ---
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        PERFORMANCE LEVEL%RESET%
echo %CYAN%========================================%RESET%
echo.
echo %YELLOW%Selected Model:%RESET% !MODEL_NAME! (~!MODEL_SIZE_GB_i!.!MODEL_SIZE_GB_f! GB)
echo.
echo %CYAN%Performance Modes:%RESET%
echo.
set /a ram_low=!MODEL_SIZE_MB! + 200
set /a ram_low_i=!ram_low! / 1000
set /a ram_low_f=(!ram_low! %% 1000) / 100

set /a ram_med=!MODEL_SIZE_MB! + 400
set /a ram_med_i=!ram_med! / 1000
set /a ram_med_f=(!ram_med! %% 1000) / 100

set /a ram_high=!MODEL_SIZE_MB! + 800
set /a ram_high_i=!ram_high! / 1000
set /a ram_high_f=(!ram_high! %% 1000) / 100

set /a ram_ultra=!MODEL_SIZE_MB! + 3000
set /a ram_ultra_i=!ram_ultra! / 1000
set /a ram_ultra_f=(!ram_ultra! %% 1000) / 100

echo %GREEN%[L] LOW%RESET%      - 1 CPU core, ~1500 words memory, Low priority
echo                 Estimated RAM: ~!MODEL_SIZE_GB_i!.!MODEL_SIZE_GB_f! GB + 0.2 GB = ~%YELLOW%!ram_low_i!.!ram_low_f! GB%RESET%
echo                 %CYAN%Best for:%RESET% Older PCs, low RAM systems, text only
echo.
echo %GREEN%[M] MEDIUM%RESET%   - 2 CPU cores, ~3000 words memory, Normal priority
echo                 Estimated RAM: ~!MODEL_SIZE_GB_i!.!MODEL_SIZE_GB_f! GB + 0.4 GB = ~%YELLOW%!ram_med_i!.!ram_med_f! GB%RESET%
echo                 %CYAN%Best for:%RESET% Standard Q^&A, balanced performance, mostly text
echo.
echo %GREEN%[H] HIGH%RESET%     - 4 CPU cores, ~6000 words memory, High priority
echo                 Estimated RAM: ~!MODEL_SIZE_GB_i!.!MODEL_SIZE_GB_f! GB + 0.8 GB = ~%YELLOW%!ram_high_i!.!ram_high_f! GB%RESET%
echo                 %CYAN%Best for:%RESET% Complex tasks, file uploads, small vision
echo.
echo %RED%[U] ULTRA%RESET%    - 6 CPU cores, ~24000 words memory (32k), High priority
echo                 Estimated RAM: ~!MODEL_SIZE_GB_i!.!MODEL_SIZE_GB_f! GB + 3.0 GB = ~%YELLOW%!ram_ultra_i!.!ram_ultra_f! GB%RESET%
echo                 %CYAN%Best for:%RESET% Books, massive codebases, powerful PCs only!
echo.
echo %RED%Note:%RESET% Total RAM = Model Size + Context Memory
echo.

set /p pwr="Select working mode [L/M/H/U] (press Enter for Medium): "

:: Default to Medium if empty
if "!pwr!"=="" set "pwr=M"

:: Set defaults (Medium)
set final_threads=2
set final_context=4096
set final_prio=1
set mode=MEDIUM
set mode_color=%GREEN%
set "adv_params=--min-p 0.05"

if /i "%pwr%"=="l" (
    set final_threads=1
    set final_context=2048
    set final_prio=-1
    set mode=LOW
    set mode_color=%YELLOW%
    set "adv_params=--min-p 0.05"
)
if /i "%pwr%"=="m" (
    set final_threads=2
    set final_context=4096
    set final_prio=1
    set mode=MEDIUM
    set mode_color=%GREEN%
    set "adv_params=--min-p 0.05"
)
if /i "%pwr%"=="h" (
    set final_threads=4
    set final_context=8192
    set final_prio=3
    set mode=HIGH
    set mode_color=%CYAN%
    set "adv_params=--min-p 0.05 --cache-type-k q8_0 --cache-type-v q8_0"
)
if /i "%pwr%"=="u" (
    set final_threads=6
    set final_context=32768
    set final_prio=3
    set mode=ULTRA
    set mode_color=%RED%
    set "adv_params=--min-p 0.05 --cache-type-k q4_0 --cache-type-v q4_0"
)

:: Validate input
if not "!mode!"=="LOW" if not "!mode!"=="MEDIUM" if not "!mode!"=="HIGH" if not "!mode!"=="ULTRA" (
    echo %RED%Invalid performance mode. Using MEDIUM as default.%RESET%
    set final_threads=2
    set final_context=4096
    set final_prio=1
    set mode=MEDIUM
    set "adv_params=--min-p 0.05"
    timeout /t 2 >nul
)

:: --- INTERFACE SELECTION ---
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        INTERFACE SELECTION%RESET%
echo %CYAN%========================================%RESET%
echo.
echo %GREEN%[1] Terminal Mode%RESET% - Clean, text-based CLI chat
echo %YELLOW%[2] Browser Mode%RESET%  - Premium Web UI with image support ^& features
echo.
set /p interface_choice="Select interface [1-2] (press Enter for Terminal): "

if "!interface_choice!"=="" set "interface_choice=1"

set "INTERFACE_MODE=TERMINAL"
if "!interface_choice!"=="2" set "INTERFACE_MODE=BROWSER"

if "!INTERFACE_MODE!"=="BROWSER" (
    set "SYSTEM_PROMPT=Configured via Web UI"
    goto webui_setup
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

if "!prompt_choice!"=="" set "prompt_choice=2"

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

goto skip_personality

:webui_setup
cls
echo.
echo %CYAN%========================================%RESET%
echo %CYAN%        WEB UI CONFIGURATION%RESET%
echo %CYAN%========================================%RESET%
echo.

:: 1. Alias
set "webui_alias=AI Tutor"
set /p webui_alias="Enter a name for your AI (Press Enter for 'AI Tutor'): "
set "alias_param=--alias "!webui_alias!""

:: 2. Vision Limit explanation & prompt
echo.
echo %CYAN%--- Vision Support (Image Uploads) ---%RESET%
echo Vision allows the AI to "see" images you upload in the Web UI.
echo %YELLOW%Limitations:%RESET% Vision requires a special 'mmproj' file that matches your model.
echo %YELLOW%Speed:%RESET% Vision processing is very slow on older PCs and uses extra RAM.
echo.
set "use_vision=N"
set /p use_vision="Do you want to enable Vision? [Y/N] (Press Enter for N): "
set "mmproj_param="
if /i "!use_vision!"=="y" (
    set mm_count=0
    for %%f in ("models\*mmproj*.gguf") do (
        set /a mm_count+=1
        set "mm_file!mm_count!=%%~nxf"
        echo %GREEN%[!mm_count!]%RESET% %%~nxf
    )
    if !mm_count! equ 0 (
        echo %RED%No files with 'mmproj' found in models folder. Vision disabled.%RESET%
        timeout /t 3 >nul
    ) else (
        set "mm_choice=1"
        set /p mm_choice="Select mmproj file [1-!mm_count!] (Press Enter for 1): "
        set "selected_mm="
        for /l %%i in (1,1,!mm_count!) do (
            if "!mm_choice!"=="%%i" set "selected_mm=!mm_file%%i!"
        )
        if "!selected_mm!"=="" set "selected_mm=!mm_file1!"
        set "mmproj_param=--mmproj "models\!selected_mm!""
        echo Selected: !selected_mm!
    )
)

:: 3. Network Sharing
echo.
echo %CYAN%--- Network Sharing ---%RESET%
echo This allows other devices on your Wi-Fi (like your phone) to connect to the Tutor.
set "share_net=N"
set /p share_net="Enable Network Sharing? [Y/N] (Press Enter for N): "
set "host_param=127.0.0.1"
set "api_key_param="

if /i "!share_net!"=="y" (
    set "host_param=0.0.0.0"
    echo.
    echo %YELLOW%Security Warning:%RESET% Anyone on your network can access the AI.
    set /p api_key="Set an optional API Key for security (Press Enter for none): "
    if not "!api_key!"=="" (
        set "api_key_param=--api-key "!api_key!""
    )
)

:skip_personality

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
echo %YELLOW%Engine:%RESET%      !engine_name!
echo %YELLOW%Context:%RESET%     !final_context! tokens (~!final_context! words)
echo %YELLOW%Priority:%RESET%    !final_prio!
echo %YELLOW%Prompt:%RESET%      !SYSTEM_PROMPT!
echo %YELLOW%Interface:%RESET%   !INTERFACE_MODE!
echo.
echo %GREEN%Starting AI in 3 seconds...%RESET%
echo %CYAN%(Press Ctrl+C to cancel)%RESET%
echo.
timeout /t 3 >nul

:: --- LAUNCH ---
echo %CYAN%Initializing AI model...%RESET%
echo.

if "!INTERFACE_MODE!"=="BROWSER" (
    set "ENGINE_EXE=!selected_engine_dir!\llama-server.exe"
    if not exist "!ENGINE_EXE!" (
        echo %RED%[ERROR] llama-server.exe not found in !selected_engine_dir!%RESET%
        echo Cannot start Web UI. Falling back to Terminal.
        timeout /t 3 >nul
        goto fallback_terminal
    )
    echo %YELLOW%Waiting for the server to start...%RESET%
    echo %CYAN%Your browser will open automatically.%RESET%
    
    :: Use 'start /b' to run the async timer without a new window for the timeout
    start /b "" cmd /c "timeout /t 2 >nul & start http://127.0.0.1:8080"
    
    "!ENGINE_EXE!" ^
      -m "models\!MODEL_NAME!" ^
      !ngl_param! ^
      !flash_attn_param! ^
      -t !final_threads! ^
      -c !final_context! ^
      --prio !final_prio! ^
      !adv_params! ^
      --host !host_param! ^
      --port 8080 ^
      !alias_param! ^
      !mmproj_param! ^
      !api_key_param! ^
      --jinja
      
    goto session_end
)

:fallback_terminal
set "ENGINE_EXE=!selected_engine_dir!\llama-cli.exe"
if not exist "!ENGINE_EXE!" (
     echo %RED%[ERROR] llama-cli.exe not found in !selected_engine_dir!%RESET%
     pause
     goto menu
)

"!ENGINE_EXE!" ^
  -m "models\!MODEL_NAME!" ^
  !ngl_param! ^
  !flash_attn_param! ^
  -cnv ^
  -t !final_threads! ^
  -c !final_context! ^
  --prio !final_prio! ^
  !adv_params! ^
  -p "!SYSTEM_PROMPT!"

:session_end

:: --- POST-EXECUTION ---
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo %RED%========================================%RESET%
    echo %RED%           CRASH DETECTED%RESET%
    echo %RED%========================================%RESET%
    echo %YELLOW%The AI engine closed unexpectedly.%RESET%
    echo.
    echo %CYAN%Did you see an "ErrorOutOfDeviceMemory" or "failed to allocate" error?%RESET%
    echo This means your graphics card ran out of VRAM. To fix this:
    echo  1. Run again and type a smaller number for GPU offloaded layers ^(e.g., 10 or 15^).
    echo  2. Or, choose the [L] LOW performance mode to reduce context memory.
    echo  3. Or, switch to the CPU engine instead of Vulkan/CUDA.
    echo %RED%========================================%RESET%
    echo.
)

echo %YELLOW%[STATUS] AI session ended.%RESET%
echo.
echo Press any key to return to model selection...
pause >nul
goto menu
