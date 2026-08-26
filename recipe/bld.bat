"%PYTHON%" -m pip install conda-src/ -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

REM Copy the full launcher set before `conda init --install`. conda-launchers
REM always ships Anaconda-signed cli-/gui- launchers for x64 and arm64. 
REM WINDOWS_LAUNCHER_STUB_PATH points at shell/cli-*.exe, which is not in
REM the upstream sdist; without this copy, make_entry_point_exe fails and conda
REM reports the misleading "elevated permissions" error. Every Windows subdir
REM gets the full set so the x64 stubs are the Anaconda-signed builds and
REM arm64/x64 cross-targeting works from either subdir.
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
