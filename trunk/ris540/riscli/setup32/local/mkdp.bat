@echo off
rem Do not alter this SPC information: $Revision: 1.10.39.1 $
rem This program is used to re-package the RISDP product. It requires no
rem editing by the user.
rem
rem

@echo Starting to re-package RISDP product
set _LOG=risdp.log
@echo Starting mkdp >%_LOG%

rem =====================================================
rem set the environment variables
rem =====================================================
call _DOIT _echo Setting environment variables
call setval

rem =====================================================
rem set my environment
rem =====================================================
rem RIS output shared version dir as in locris\ris\shared\ris05.03
set _SC_SHARE=%_RIS_OUTPUT_DIR%\shared\ris%_RISVER%

rem RISDP output dir as in locrisdp\risdp
set _OUTPUT_DP=%_RISDP_OUTPUT_DIR%\risdp

rem RISDP output shared dir as in locrisdp\risdp\shared
set _DP_SHARE=%_OUTPUT_DP%\shared

rem RISDP output compressed dir
set _OUTPUT_COMP=%_RISDP_OUTPUT_DIR%\compress

rem RISDP output delivery dir
set _OUTPUT_DELIV=%_RISDP_OUTPUT_DIR%\deliv

rem =====================================================
rem make new dirs
rem =====================================================
call _DOIT _echo Making Directories
call _DOIT _md %_RISDP_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\bin
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\lib
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\include
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\samples
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\config\english\help
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\config\%_LANG%\help
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DP%\deliv
if not "%_ERROR%" =="" goto error
call _DOIT _md %_DP_SHARE%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DELIV%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_COMP%
if not "%_ERROR%" =="" goto error

call _DOIT _echo Deleting all files under %_RISDP_OUTPUT_DIR%
call _DOIT _deldir %_RISDP_OUTPUT_DIR%\*.*

rem =====================================================
rem Copying RIS Share Files
rem =====================================================
call _DOIT _echo Copying RIS Share Files from %_RIS_OUTPUT_DIR%\shared to %_OUTPUT_DP%\shared
call _DOIT _xcopysubs %_RIS_OUTPUT_DIR%\shared\*.* %_OUTPUT_DP%\shared %_OUTPUT_DP%\shared\*.*
if not "%_ERROR%" =="" goto error

rem =====================================================
rem Copying RISDP deliverable files under %_OUTPUT_DP%
rem =====================================================
call _DOIT _echo Copying RISDP deliverable files under %_OUTPUT_DP%
call _DOIT _copy settings.ini %_OUTPUT_DP% %_OUTPUT_DP%\settings.ini
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\config\english\help\risdp.hlp %_OUTPUT_DP%\config\english\help %_OUTPUT_DP%\config\english\help\risdp.hlp
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\bin\*.exe %_OUTPUT_DP%\bin %_OUTPUT_DP%\bin\*.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\lib\*.lib %_OUTPUT_DP%\lib %_OUTPUT_DP%\lib\*.lib
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\include\*.h %_OUTPUT_DP%\include %_OUTPUT_DP%\include\*.h
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\include\*.prt %_OUTPUT_DP%\include %_OUTPUT_DP%\include\*.prt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\samples\*.* %_OUTPUT_DP%\samples %_OUTPUT_DP%\samples\*.*
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\manifest.txt %_OUTPUT_DP% %_OUTPUT_DP%\manifest.txt
if not "%_ERROR%" =="" goto error
call _DOIT _copy readme.dp %_OUTPUT_DP% %_OUTPUT_DP%\readme.dp
if not "%_ERROR%" =="" goto error
call _DOIT _copy prod.ini %_OUTPUT_DP% %_OUTPUT_DP%\prod.ini
if not "%_ERROR%" =="" goto error

call _DOIT _echo Update-ing version and date macros ...
set LAYOUT_DIR=%_OUTPUT_DP%
call _DOIT _perl readprod.pl
set LAYOUT_DIR=

rem =====================================================
rem Copying RISDP setup files to %_OUTPUT_DP%
rem =====================================================
call _DOIT _echo Copying RISDP setup files to %_OUTPUT_DP%
call _DOIT _copy %WINDIR%\system32\msvcrt20.dll %_OUTPUT_DP% %_OUTPUT_DP%\msvcrt20.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\setup.dp %_OUTPUT_DP%\setup.lst %_OUTPUT_DP%\setup.lst
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\risdp.ws %_OUTPUT_DP% %_OUTPUT_DP%\risdp.ws
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\setup.exe %_OUTPUT_DP% %_OUTPUT_DP%\setup.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\risdp.exe %_OUTPUT_DP% %_OUTPUT_DP%\risdp.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msdetstf.dll %_OUTPUT_DP% %_OUTPUT_DP%\msdetstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msuilstf.dll %_OUTPUT_DP% %_OUTPUT_DP%\msuilstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\mscomstf.dll %_OUTPUT_DP% %_OUTPUT_DP%\mscomstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msinsstf.dll %_OUTPUT_DP% %_OUTPUT_DP%\msinsstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msshlstf.dll %_OUTPUT_DP% %_OUTPUT_DP%\msshlstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\risdp.dll %_OUTPUT_DP% %_OUTPUT_DP%\risdp.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\ingrstf.dll %_OUTPUT_DP% %_OUTPUT_DP%\ingrstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\risdp.hlp %_OUTPUT_DP%\config\%_LANG%\help\risdp.hhh %_OUTPUT_DP%\config\%_LANG%\help\risdp.hhh
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\remove.exe %_OUTPUT_DP%\bin\removedp.exe %_OUTPUT_DP%\bin\removedp.exe
if not "%_ERROR%" =="" goto error

rem =====================================================
rem Generating ris.lyt file and disklayt2-ing files to %_OUTPUT_DELIV%
rem =====================================================
call _DOIT _echo Generating ris.lyt file and disklayt2-ing files to %_OUTPUT_DELIV%
call _DOIT _echofile HEADER~ %_OUTPUT_DP%\ris.lyt
@echo HEADER> %_OUTPUT_DP%\ris.lyt
call _DOIT _echofile SRC = %_OUTPUT_DP%~~ %_OUTPUT_DP%\ris.lyt
@echo SRC = %_OUTPUT_DP%>> %_OUTPUT_DP%\ris.lyt
call _DOIT _typea risdp.lyt %_OUTPUT_DP%\ris.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _echo Process rissetup.lyt
call _DOIT _typea %_SC_SHARE%\rissetup.lyt %_OUTPUT_DP%\ris.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _perlpass "s/!language!/%_LANG%/g" risdplan.lyt risdpla1.lyt risdpla1.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea risdpla1.lyt %_OUTPUT_DP%\ris.lyt
if not "%_ERROR%" =="" goto error

call _DOIT _echo Process rispack.lyt
call _DOIT _typea %_SC_SHARE%\rispack.lyt %_OUTPUT_DP%\ris.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _echofile REMOVE~~ %_OUTPUT_DP%\ris.lyt
@echo REMOVE>> %_OUTPUT_DP%\ris.lyt

call _DOIT _dsklayt2 %_OUTPUT_DP%\ris.lyt %_OUTPUT_DELIV%\risdp.inf
if not "%_ERROR%" =="" goto error
call _DOIT _copy settings.ini %_OUTPUT_DELIV% %_OUTPUT_DELIV%\settings.ini
if not "%_ERROR%" =="" goto error
goto ok

rem =====================================================
rem End Routine
rem =====================================================

:error
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@echo There was errors during this process
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@echo error >riserr.err
goto quit

:ok
@echo Re-Packaging RIS Development Platformt is complete
@echo Your delivery files are located in %_OUTPUT_DELIV%

:end
rem delete temporary files
if exist risdplan1.lyt del risdpla1.lyt

rem clear the environment variables
set _SC_SHARE=
set _OUTPUT_DP=
set _DP_SHARE=
set _OUTPUT_COMP=
set _OUTPUT_DELIV=

:quit
