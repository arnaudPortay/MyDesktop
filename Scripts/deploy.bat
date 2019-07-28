REM Creating bin directory
mkdir ..\Installer_Data\packages\com.apy.mydesktop\bin

REM Deploy libaries
windeployqt --no-translations --no-angle --no-webkit2 --release --qmldir . --dir ..\Installer_Data\packages\com.apy.mydesktop\bin ..\..\MyDesktop-Release\release\MyDesktop.exe

REM Copy exe to release path
robocopy ..\..\MyDesktop-Release\release\ ..\Installer_Data\packages\com.apy.mydesktop\bin\ MyDesktop.exe

REM Zipping data
archivegen ..\Installer_Data\packages\com.apy.mydesktop\data\mydesktop.7z ..\Installer_Data\packages\com.apy.mydesktop\bin

REM Delete unzipped data
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin
REM Delete bin directory
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin

REM Delete previous installer
del /Q MyDesktopSetup.exe

REM Create installer
binarycreator.exe -f -p ..\Installer_Data\packages -c ..\Installer_Data\config\config.xml ..\MyDesktopSetup.exe
REM Delete zipped data
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\data\mydesktop.7z

if not "%~1" == "no_pause" pause