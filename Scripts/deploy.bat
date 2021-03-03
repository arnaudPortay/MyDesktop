REM Creating bin directory
mkdir ..\Installer_Data\packages\com.apy.mydesktop\bin

REM Deploy libaries
windeployqt --no-translations --no-angle --no-webkit2 --no-virtualkeyboard --qmldir .. --dir ..\Installer_Data\packages\com.apy.mydesktop\bin ..\..\MyDesktop-Release\release\MyDesktop.exe

REM Deleting uneeded stuff
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin\QtQuick\Controls.2\Fusion
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin\QtQuick\Controls.2\Imagine
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin\QtQuick\Controls.2\Universal
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin\bearer
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin\qmltooling

del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qgif.dll
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qicns.dll
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qjpeg.dll
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qtga.dll
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qtiff.dll
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qwbmp.dll
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\bin\imageformats\qwebp.dll

REM Copy exe to release path
robocopy ..\..\MyDesktop-Release\release\ ..\Installer_Data\packages\com.apy.mydesktop\bin\ MyDesktop.exe

REM Zipping data
archivegen ..\Installer_Data\packages\com.apy.mydesktop\data\mydesktop.7z ..\Installer_Data\packages\com.apy.mydesktop\bin

REM Delete bin directory
rmdir /q /s ..\Installer_Data\packages\com.apy.mydesktop\bin

REM Delete previous installer
del /Q MyDesktopSetup.exe

REM Create installer
binarycreator.exe -f -p ..\Installer_Data\packages -c ..\Installer_Data\config\config.xml ..\MyDesktopSetup.exe
REM Delete zipped data
del /q /f ..\Installer_Data\packages\com.apy.mydesktop\data\mydesktop.7z

if not "%~1" == "no_pause" pause