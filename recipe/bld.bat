"%PYTHON%" -m pip install conda-src/ -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

REM Copy the published x64 and ARM64 launchers before conda init --install.
REM Released conda expects these files under conda/shell.
set "LAUNCHER_SRC=%PREFIX%\share\conda-launchers"
set "LAUNCHER_DST=%SP_DIR%\conda\shell"

for %%F in (cli-64.exe gui-64.exe cli-arm64.exe gui-arm64.exe) do (
    if not exist "%LAUNCHER_SRC%\%%F" (
        echo ERROR: missing %LAUNCHER_SRC%\%%F from conda-launchers
        exit /b 1
    )
    copy /Y "%LAUNCHER_SRC%\%%F" "%LAUNCHER_DST%\"
    if errorlevel 1 exit /b 1
)

"%PYTHON%" -m conda init --install
if errorlevel 1 exit /b 1
