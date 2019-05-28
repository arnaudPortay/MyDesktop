REM Deploy libaries
windeployqt --no-translations --no-angle --no-webkit2 --release --qmldir . --dir ..\MyDesktop_Package\ ..\MyDesktop-Release\release\MyDesktop.exe
REM Copy exe to release path
robocopy ..\MyDesktop-Release\release\ ..\MyDesktop_Package\ MyDesktop.exe