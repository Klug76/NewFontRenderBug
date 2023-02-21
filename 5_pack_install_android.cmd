call 0_clear_swf_apk.cmd
call 1__compile_swf.cmd
@if errorlevel 1 goto error
call 2__pack_android_apk.cmd
@if errorlevel 1 goto error
call 3__install_android.cmd
:error
@pause
