@title %~n0
@set PAUSE_ERRORS=1

@call bat/SetupSDK.bat

"%PROGRAMFILES(X86)%/FlashDevelop/Tools/fdbuild/fdbuild.exe" ./NewFontRenderBug.as3proj -compiler %FLEX_SDK%

