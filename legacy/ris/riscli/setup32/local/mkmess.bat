@echo off
rem Do not alter this SPC information: $Revision: 1.4.41.1 $
rem This program is used to compile the RIS Messages. It requires no
rem editing by the user.
rem
rem

@echo Starting to compile the RIS message files
set _LOG=mess.log
@echo Starting mkmess >%_LOG%

rem =====================================================
rem set the environment variables
rem =====================================================
call _DOIT _echo Setting environment variables
call setval

rem =====================================================
rem set my environment
rem =====================================================
rem
rem

call _DOIT _passthru %_RISDP_DIR%\bin\risumscc -m %_LOCAL_DIR%\%_RIS_IN%\messages\net.msg %_LOCAL_DIR%\%_RIS_IN%\messages\net.txt
call _DOIT _passthru %_RISDP_DIR%\bin\risumscc -m %_LOCAL_DIR%\%_RIS_IN%\messages\ris.msg %_LOCAL_DIR%\%_RIS_IN%\messages\ris.txt
call _DOIT _passthru %_RISDP_DIR%\bin\risumscc -m %_LOCAL_DIR%\%_RIS_IN%\messages\utl.msg %_LOCAL_DIR%\%_RIS_IN%\messages\utl.txt

if exist %_LOCAL_DIR%\%_RIS_IN%\messages\*.h call _DOIT _passthru del %_LOCAL_DIR%\%_RIS_IN%\messages\*.h
if exist %_LOCAL_DIR%\%_RIS_IN%\messages\*.log call _DOIT _passthru del %_LOCAL_DIR%\%_RIS_IN%\messages\*.log
if exist umscomp.log call _DOIT _passthru del umscomp.log


set _UMSDIR=
