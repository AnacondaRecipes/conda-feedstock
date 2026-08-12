"%PYTHON%" -m pip install conda-src/ -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

REM Copy launchers before `conda init --install`. On win-arm64 the patched
REM WINDOWS_LAUNCHER_STUB_PATH points at shell/cli-arm64.exe, which is not in
REM the upstream sdist; without this copy, make_entry_point_exe fails and conda
REM reports the misleading "elevated permissions" error.
set "ARCH_SUFFIX=64"
if "%SUBDIR%"=="win-arm64" set "ARCH_SUFFIX=arm64"
if "%SUBDIR%"=="win-32" set "ARCH_SUFFIX=32"

set "LAUNCHER_SRC=%PREFIX%\share\conda-launchers"
set "LAUNCHER_DST=%SP_DIR%\conda\shell"

if not exist "%LAUNCHER_SRC%\cli-%ARCH_SUFFIX%.exe" (
    echo ERROR: missing %LAUNCHER_SRC%\cli-%ARCH_SUFFIX%.exe from conda-launchers
    exit /b 1
)

copy /Y "%LAUNCHER_SRC%\cli-%ARCH_SUFFIX%.exe" "%LAUNCHER_DST%\"
if errorlevel 1 exit /b 1

REM win-64 builds also ship the native ARM64 launcher for cross-targeting.
if "%SUBDIR%"=="win-64" (
    if exist "%LAUNCHER_SRC%\cli-arm64.exe" (
        copy /Y "%LAUNCHER_SRC%\cli-arm64.exe" "%LAUNCHER_DST%\"
        if errorlevel 1 exit /b 1
    )
)

"%PYTHON%" -m conda init --install
if errorlevel 1 exit /b 1
