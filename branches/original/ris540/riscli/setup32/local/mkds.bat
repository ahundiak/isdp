@echo off
rem Do not alter this SPC information: $Revision: 1.2.39.1 $
rem This program is used to re-package the Data Server products. It
rem requires no editing by the user.
rem
rem

rem check for which data server
if "%1" =="" @echo No Data Server defined
if "%1" =="" goto error
if %1 == risorads goto passed
if %1 == rissybds goto passed
if %1 == risdb2ds goto passed
if %1 == rismsfds goto passed
if %1 == risingds goto passed
if %1 == risinfds goto passed
if %1 == risorans goto passed
if %1 == risinfns goto passed
@echo Invalid Data Server
goto error

:passed
@echo Starting to re-package %1 Data Server product
set _LOG=%1.log
@echo Starting mkds >%_LOG%

rem =====================================================
rem set the environment variables
rem =====================================================
call _DOIT _echo Setting environment variables
call setval

set _PRODUCT=%1
if %1 == risorads goto oracle_setup
if %1 == rissybds goto sybase_setup
if %1 == risdb2ds goto db2_setup
if %1 == risingds goto ing_setup
if %1 == risinfds goto inf_setup
if %1 == rismsfds goto msf_setup
if %1 == risinfns goto infn_setup
if %1 == risorans goto oran_setup

:oracle_setup
rem Data Server output shared version dir as in locora\shared\ris05.03
set _OUTPUT_SC=%_RISORADS_OUTPUT_DIR%\shared\ris%_RISVER%

rem Data Server output dir as in locora
set _OUTPUT_DIR=%_RISORADS_OUTPUT_DIR%

rem Data Server product dir as in win32app\ingr\risorads
set _PRODUCTDIR=%_RISORADS_DIR%

set _IN_DIR=%_RIS_ORA_IN%
set _PRODNAME=Oracle Data Server
set _EXT=ora
goto env_set

:sybase_setup
set _OUTPUT_SC=%_RISSYBDS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISSYBDS_OUTPUT_DIR%
set _IN_DIR=%_RIS_SYB_IN%
set _PRODNAME=Sybase Data Server
set _EXT=syb
set _PRODUCTDIR=%_RISSYBDS_DIR%
goto env_set


:db2_setup
set _OUTPUT_SC=%_RISDB2DS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISDB2DS_OUTPUT_DIR%
set _IN_DIR=%_RIS_DB2_IN%
set _PRODNAME=DB2 Data Server
set _EXT=db2
set _PRODUCTDIR=%_RISDB2DS_DIR%
goto env_set

:ing_setup
set _OUTPUT_SC=%_RISINGDS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISINGDS_OUTPUT_DIR%
set _IN_DIR=%_RIS_INGRES_IN%
set _PRODNAME=Ingres Data Server
set _EXT=igs
set _PRODUCTDIR=%_RISINGDS_DIR%
goto env_set


:msf_setup
set _OUTPUT_SC=%_RISMSFDS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISMSFDS_OUTPUT_DIR%
set _IN_DIR=%_RIS_MSSQL_IN%
set _PRODNAME=MS SQL Data Server
set _EXT=msf
set _PRODUCTDIR=%_RISMSFDS_DIR%
goto env_set


:inf_setup
set _OUTPUT_SC=%_RISINFDS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISINFDS_OUTPUT_DIR%
set _IN_DIR=%_RIS_INF_IN%
set _PRODNAME=Informix Data Server
set _EXT=ifx
set _PRODUCTDIR=%_RISINFDS_DIR%
goto env_set


:infn_setup
set _OUTPUT_SC=%_RISINFNS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISINFNS_OUTPUT_DIR%
set _IN_DIR=%_RIS_INFN_IN%
set _PRODNAME=Informix Net Server
set _EXT=ifx
set _PRODUCTDIR=%_RISINFNS_DIR%
goto env_set


:oran_setup
set _OUTPUT_SC=%_RISORANS_OUTPUT_DIR%\shared\ris%_RISVER%
set _OUTPUT_DIR=%_RISORANS_OUTPUT_DIR%
set _IN_DIR=%_RIS_ORAN_IN%
set _PRODNAME=Oracle Net Server
set _EXT=ora
set _PRODUCTDIR=%_RISORANS_DIR%
goto env_set


:env_set
rem =====================================================
rem set my environment
rem =====================================================
rem Data Server output shared dir as in locora\shared
set _OUTPUT_SHARED=%_OUTPUT_DIR%\shared

rem Data Server output compressed dir
set _OUTPUT_COMP=%_OUTPUT_DIR%\compress

rem Data Server output delivery dir
set _OUTPUT_DELIV=%_OUTPUT_DIR%\deliv

:make_dirs
rem =====================================================
rem make output sub dirs
rem =====================================================
call _DOIT _echo Making Localized Output Sub-directories
call _DOIT _md %_OUTPUT_DIR%\bin
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DIR%\config
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_SHARED%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_SC%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_COMP%
if not "%_ERROR%" =="" goto error
call _DOIT _md %_OUTPUT_DELIV%
if not "%_ERROR%" =="" goto error

call _DOIT _echo Deleting all files under %_OUTPUT_SHARED%
call _DOIT _deldir %_OUTPUT_DIR%\*.*

rem =====================================================
rem copy files to output area
rem =====================================================
call _DOIT _echo Copying RIS shared files
call _DOIT _xcopysubs %_RIS_OUTPUT_DIR%\shared\*.* %_OUTPUT_SHARED% %_OUTPUT_SHARED%\*.*
if not "%_ERROR%" =="" goto error
call _DOIT _copy %WINDIR%\system32\msvcrt20.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\msvcrt20.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo Copying setup files
call _DOIT _copy %_PRODUCT%.set %_OUTPUT_DIR%\settings.ini %_OUTPUT_DIR%\settings.ini
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCT%.lyt %_OUTPUT_DIR% %_OUTPUT_DIR%\%_PRODUCT%.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCT%.lst %_OUTPUT_DIR%\setup.lst %_OUTPUT_DIR%\setup.lst
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\setup.exe %_OUTPUT_DIR% %_OUTPUT_DIR%\setup.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\mscomstf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\mscomstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msinsstf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\msinsstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msshlstf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\msshlstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\ingrstf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\ingrstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msdetstf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\msdetstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\msuilstf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\msuilstf.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo Copying Shamrock files
call _DOIT _copy %_RIS_OUTPUT_DIR%\shared\i9shamr1.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\i9shamr1.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\shared\i9shamr2.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\i9shamr2.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo Copying UMS files
call _DOIT _copy %_RIS_OUTPUT_DIR%\shared\i9ums1.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\i9ums1.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\shared\i9ums2.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\i9ums2.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_OUTPUT_DIR%\shared\i9risu.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\i9risu.dll
if not "%_ERROR%" =="" goto error


call _DOIT _echo Copying files under %_PRODUCTDIR%
call _DOIT _copy %_PRODUCTDIR%\readme.txt %_OUTPUT_DIR% %_OUTPUT_DIR%\readme.txt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\manifest.txt %_OUTPUT_DIR% %_OUTPUT_DIR%\manifest.txt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\prod.ini %_OUTPUT_DIR% %_OUTPUT_DIR%\prod.ini
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\bin\%_PRODUCT%.exe %_OUTPUT_DIR%\bin %_OUTPUT_DIR%\bin\%_PRODUCT%.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\bin\brander.exe %_OUTPUT_DIR%\bin %_OUTPUT_DIR%\bin\brander.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\bin\cre_sch.exe %_OUTPUT_DIR%\bin %_OUTPUT_DIR%\bin\cre_sch.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\config\*.%_EXT% %_OUTPUT_DIR%\config %_OUTPUT_DIR%\config\*.%_EXT%
if not "%_ERROR%" =="" goto error

if %_PRODUCT% ===risinfds goto special
if %_PRODUCT% ===risinfns goto special
goto finish

:special
call _DOIT _copy %_PRODUCTDIR%\inetwsok.dll %_OUTPUT_DIR%\bin %_OUTPUT_DIR%\bin\inetwsok.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\isqli501.dll %_OUTPUT_DIR%\bin %_OUTPUT_DIR%\bin\isqli501.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_PRODUCTDIR%\winetman.dll %_OUTPUT_DIR%\bin %_OUTPUT_DIR%\bin\winetman.dll
if not "%_ERROR%" =="" goto error


:finish
call _DOIT _echo Copying localized files under %_LOCAL_DIR%\%_IN_DIR%
call _DOIT _copy %_LOCAL_DIR%\%_IN_DIR%\risds.exe %_OUTPUT_DIR% %_OUTPUT_DIR%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_IN_DIR%\mscuistf.dll %_OUTPUT_DIR% %_OUTPUT_DIR%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_IN_DIR%\removeds.exe %_OUTPUT_DIR%\bin\removeds.exe %_OUTPUT_DIR%\bin\removeds.exe
if not "%_ERROR%" =="" goto error

rem =====================================================
rem Generate layout file
rem =====================================================
call _DOIT _echo Generate layout file
call _DOIT _echofile HEADER~ %_OUTPUT_DIR%\ris.lyt
@echo HEADER> %_OUTPUT_DIR%\ris.lyt
call _DOIT _echofile SRC = %_OUTPUT_DIR%~~ %_OUTPUT_DIR%\ris.lyt
@echo SRC = %_OUTPUT_DIR%>> %_OUTPUT_DIR%\ris.lyt
call _DOIT _typea %_PRODUCT%.lyt %_OUTPUT_DIR%\ris.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea %_OUTPUT_SC%\rissetup.lyt %_OUTPUT_DIR%\ris.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _echofile REMOVE~~ %_OUTPUT_DIR%\ris.lyt
@echo REMOVE>> %_OUTPUT_DIR%\ris.lyt

call _DOIT _dsklayt2 %_OUTPUT_DIR%\ris.lyt %_OUTPUT_DELIV%\risds.inf
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
@echo Re-Packaging RIS %_PRODNAME% is complete
@echo Your delivery files are located in %_OUTPUT_DELIV%

:end
rem delete temporary files
if exist %_OUTPUT_DIR%\ris.lyt @del %_OUTPUT_DIR%\ris.lyt

rem clear the environment variables
set _OUTPUT_SC=
set _OUTPUT_SHARED=
set _OUTPUT_COMP=
set _OUTPUT_DELIV=
set _PRODUCT=
set _EXT=
set _PRODNAME=
set _PRODUCTDIR=
set _IN_DIR=

:quit
