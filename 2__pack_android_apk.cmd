@title %~n0
@set PAUSE_ERRORS=1

@call bat/SetupSDK.bat
@call bat/SetupApp.bat

set PLATFORM=android
set OPTIONS=-arch x64
call bat/Packager.bat

