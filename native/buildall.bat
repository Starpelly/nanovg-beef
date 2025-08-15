@echo off
set SRC_DIR=.
set BUILD_DIR=%SRC_DIR%\build

REM ---- Static library ----
cmake -S %SRC_DIR% -B %BUILD_DIR% -DBUILD_STATIC=ON -G "Visual Studio 17 2022"
cmake --build %BUILD_DIR% --config Debug
cmake --build %BUILD_DIR% --config Release

REM ---- Shared library ----
cmake -S %SRC_DIR% -B %BUILD_DIR% -DBUILD_STATIC=OFF -G "Visual Studio 17 2022"
cmake --build %BUILD_DIR% --config Debug
cmake --build %BUILD_DIR% --config Release
