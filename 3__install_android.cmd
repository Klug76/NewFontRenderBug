@title %~n0
@echo off
@set PAUSE_ERRORS=1

@call bat/SetupSDK.bat

cd "dist"

adb install -r ./NewFontRenderBug-rc.apk

cd ..
