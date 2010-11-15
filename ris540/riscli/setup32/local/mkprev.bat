@echo off
rem Do not alter this SPC information: $Revision: 1.1.39.1 $
rem This program copies the files used in localizing the RIS Setup files
rem from the saved directory to the current localize directory.
rem
rem

set _LOG=prev.log
@echo Starting mkprev >%_LOG%

rem =====================================================
rem set the environment variables
rem =====================================================
call _DOIT _echo Setting environment variables
call setenv
call setval

if not exist %_OLD_DIR% echo ** ERROR ** %_OLD_DIR% not found
if not exist %_OLD_DIR% goto end


rem copy RIS Messages
call _DOIT _copy %_OLD_DIR%\%_RIS_IN%\messages\*.txt %_LOCAL_DIR%\%_RIS_IN%\messages %_LOCAL_DIR%\%_RIS_IN%\messages\*.txt
if not "%_ERROR%" =="" goto error

rem copy RIS Forms
call _DOIT _copy %_OLD_DIR%\%_RIS_IN%\forms\*.frm %_LOCAL_DIR%\%_RIS_IN%\forms %_LOCAL_DIR%\%_RIS_IN%\forms\*.frm
if not "%_ERROR%" =="" goto error

rem copy RIS Help
call _DOIT _copy %_OLD_DIR%\%_RIS_IN%\help\*.* %_LOCAL_DIR%\%_RIS_IN%\help %_LOCAL_DIR%\%_RIS_IN%\help\*.hlp
if not "%_ERROR%" =="" goto error

rem copy RISDP Help
call _DOIT _copy %_OLD_DIR%\%_RISDP_IN%\*.hlp %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\*.hlp
if not "%_ERROR%" =="" goto error



rem copy RIS Projects
xcopy %_OLD_DIR%\*.mpj %_LOCAL_DIR%\ /i/s >NUL
xcopy %_OLD_DIR%\*.mtk %_LOCAL_DIR%\ /i/s >NUL
xcopy %_OLD_DIR%\*.prj %_LOCAL_DIR%\ /i/s >NUL
xcopy %_OLD_DIR%\*.tok %_LOCAL_DIR%\ /i/s >NUL

:end
