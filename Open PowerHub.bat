@echo off
setlocal
cd /d "%~dp0"

rem TODO: replace with your actual GitHub username/repo once it exists, e.g.
rem https://raw.githubusercontent.com/yourusername/powerhub/main/index.html
set "RAW_URL=https://raw.githubusercontent.com/ptogias/powerhub/main/index.html"
set "TMP_FILE=%TEMP%\powerhub_update.html"

if exist "%TMP_FILE%" del "%TMP_FILE%" >nul 2>&1

powershell -NoProfile -Command "try { Invoke-WebRequest -Uri '%RAW_URL%' -OutFile '%TMP_FILE%' -TimeoutSec 5 -UseBasicParsing } catch { exit 1 }" >nul 2>&1

if exist "%TMP_FILE%" (
    for %%A in ("%TMP_FILE%") do if %%~zA GTR 0 (
        copy /y "%TMP_FILE%" "index.html" >nul
    )
    del "%TMP_FILE%" >nul 2>&1
)

start "" "index.html"
endlocal
