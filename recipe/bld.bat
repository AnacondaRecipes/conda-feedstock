"%PYTHON%" -m pip install conda-src/ -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

REM win-arm64 only: copy the Anaconda-signed launchers before
REM `conda init --install`. The patched WINDOWS_LAUNCHER_STUB_PATH points
REM win-arm64 at shell/cli-arm64.exe, which is not in the upstream sdist;
REM without this copy, make_entry_point_exe fails and conda reports the
REM misleading "elevated permissions" error. win-64 keeps the launcher
REM stubs shipped in the upstream sdist.
set "LAUNCHER_SRC=%PREFIX%\share\conda-launchers"
set "LAUNCHER_DST=%SP_DIR%\conda\shell"

if "%SUBDIR%"=="win-arm64" (
    for %%F in (cli-64.exe gui-64.exe cli-arm64.exe gui-arm64.exe) do (
        if not exist "%LAUNCHER_SRC%\%%F" (
            echo ERROR: missing %LAUNCHER_SRC%\%%F from conda-launchers
            exit /b 1
        )
        copy /Y "%LAUNCHER_SRC%\%%F" "%LAUNCHER_DST%\"
        if errorlevel 1 exit /b 1
    )
)

"%PYTHON%" -m conda init --install
if errorlevel 1 exit /b 1
