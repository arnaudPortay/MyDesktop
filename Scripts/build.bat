REM Creating build directories
mkdir ..\..\MyDesktop-Release

REM Moving to build directory
cd ..\..\MyDesktop-Release

REM Empty Build Dir
del /Q *
del /Q release\*

REM Running QMake
qmake.exe "..\MyDesktop\MyDesktop.pro" -spec win32-g++ "CONFIG+=qtquickcompiler"

REM Running QMake_All
mingw32-make.exe -f Makefile qmake_all

REM Building
mingw32-make.exe -j6

cd ..\MyDesktop\Scripts

if not "%~1" == "no_pause" pause

