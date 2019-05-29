REM Creating bin directory
mkdir .\Installer_Data\packages\com.apy.mydesktop\bin
REM Deploy libaries
windeployqt --no-translations --no-angle --no-webkit2 --release --qmldir . --dir .\Installer_Data\packages\com.apy.mydesktop\bin ..\MyDesktop-Release\release\MyDesktop.exe
REM Copy exe to release path
robocopy .\Installer_Data\packages\com.apy.mydesktop\bin ..\MyDesktop_Package\ MyDesktop.exe
REM Zipping data
archivegen .\Installer_Data\packages\com.apy.mydesktop\data\mydesktop.7z .\Installer_Data\packages\com.apy.mydesktop\bin
REM Delete unzipped data
del /q /f .\Installer_Data\packages\com.apy.mydesktop\bin
REM Delete bin directory
rmdir /q /s .\Installer_Data\packages\com.apy.mydesktop\bin
REM Create installer
binarycreator.exe -f -p .\Installer_Data\packages -c .\Installer_Data\config\config.xml MyDesktopSetup.exe
REM Delete zipped data
del /q /f .\Installer_Data\packages\com.apy.mydesktop\data\mydesktop.7z