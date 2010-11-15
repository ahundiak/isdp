@echo off

set _LOG=copy.log
@echo Starting mkcopy >%_LOG%

rem =====================================================
rem set the environment variables
rem =====================================================
call _DOIT _echo Setting environment variables
call setval

rem =====================================================
rem check that Environment Variables are correct
rem =====================================================
@echo .
@echo .
@echo RIS product version number    : %_RISVER%
@echo Localized file input directory: %_LOCAL_DIR%
@echo Language                      : %_LANG%

@echo.
@echo. These Products will be Localized and re-packaged
@echo. in the corresponding Directories:
@echo.
                              @echo   RIS Shared Components        %_RIS_OUTPUT_DIR%
                              @echo   RIS Development Platform     %_RISDP_OUTPUT_DIR%
if not "%_RISORADS_DIR%" =="" @echo   RIS ORACLE Data Server       %_RISORADS_OUTPUT_DIR%
if not "%_RISORANS_DIR%" =="" @echo   RIS ORACLE Net Server        %_RISORANS_OUTPUT_DIR%
if not "%_RISSYBDS_DIR%" =="" @echo   RIS SYBASE Data Server       %_RISSYBDS_OUTPUT_DIR%
if not "%_RISDB2DS_DIR%" =="" @echo   RIS DB2 Data Server          %_RISDB2DS_OUTPUT_DIR%
if not "%_RISINGDS_DIR%" =="" @echo   RIS INGRES Data Server       %_RISINGDS_OUTPUT_DIR%
if not "%_RISMSFDS_DIR%" =="" @echo   RIS MS SQL Data Server       %_RISMSFDS_OUTPUT_DIR%
if not "%_RISINFDS_DIR%" =="" @echo   RIS INFORMIX Data Server     %_RISINFDS_OUTPUT_DIR%
if not "%_RISINFNS_DIR%" =="" @echo   RIS INFORMIX Net Server      %_RISINFNS_OUTPUT_DIR%
@echo .
choice /c:yn "Is This Information Correct? (Y/N): "
if errorlevel 2  goto end

rem =====================================================
rem set my environment
rem =====================================================
rem Indicates that a product is not installed
set _MISSING_ERROR=n

rem Indicates that a product output directory is not empty
set _EXIST_ERROR=n

rem =====================================================
rem check that RIS products exist
rem =====================================================
@if exist %_RIS_DIR%\bin\risgui.exe goto chk_dp
@echo Not Found: RIS Shared Component Product at %_RIS_DIR%
set _MISSING_ERROR=y

:chk_dp
@if exist %_RISDP_DIR%\bin\riscpp.exe goto chk_ora
@echo Not Found: RIS Development Platform Product at %_RISDP_DIR%
set _MISSING_ERROR=y

:chk_ora
if "%_RISORADS_DIR%" ==""  goto chk_oran
@if exist %_RISORADS_DIR%\bin\risorads.exe goto chk_oran
@echo Not Found: RIS ORACLE Data Server Product at %_RISORADS_DIR%
set _MISSING_ERROR=y

:chk_oran
if "%_RISORANS_DIR%" ==""  goto chk_db2
@if exist %_RISORANS_DIR%\bin\risorans.exe goto chk_db2
@echo Not Found: RIS ORACLE Net Server Product at %_RISORANS_DIR%
set _MISSING_ERROR=y

:chk_db2
if "%_RISDB2DS_DIR%" ==""  goto chk_msf
@if exist %_RISDB2DS_DIR%\bin\risdb2ds.exe goto chk_msf
@echo Not Found: RIS DB2 Data Server Product at %_RISDB2DS_DIR%
set _MISSING_ERROR=y

:chk_msf
if "%_RISMSFDS_DIR%" ==""  goto chk_ing
@if exist %_RISMSFDS_DIR%\bin\rismsfds.exe goto chk_ing
@echo Not Found: RIS MS SQL Data Server Product at %_RISMSFDS_DIR%
set _MISSING_ERROR=y

:chk_ing
if "%_RISINGDS_DIR%" ==""  goto chk_inf
@if exist %_RISINGDS_DIR%\bin\risingds.exe goto chk_inf
@echo Not Found: RIS INGRES Data Server Product at %_RISINGDS_DIR%
set _MISSING_ERROR=y

:chk_inf
if "%_RISINFDS_DIR%" ==""  goto chk_infn
@if exist %_RISINFDS_DIR%\bin\risinfds.exe goto chk_infn
@echo Not Found: RIS INFORMIX Data Server Product at %_RISINFDS_DIR%
set _MISSING_ERROR=y

:chk_infn
if "%_RISINFNS_DIR%" ==""  goto chk_syb
@if exist %_RISINFNS_DIR%\bin\risinfns.exe goto chk_syb
@echo Not Found: RIS INFORMIX Net Server Product at %_RISINFNS_DIR%
set _MISSING_ERROR=y

:chk_syb
if "%_RISSYBDS_DIR%" ==""  goto missing_files
@if exist %_RISSYBDS_DIR%\bin\rissybds.exe goto missing_files
@echo Not Found: RIS SYBASE Data Server Product at %_RISSYBDS_DIR%
set _MISSING_ERROR=y

:missing_files
if %_MISSING_ERROR% ==n goto chk_output
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@echo There was errors during this process
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pause
goto end

@echo on
:chk_output
@if exist %_RIS_OUTPUT_DIR%\*.* echo RIS Directory %_RIS_OUTPUT_DIR% already contains files
@if exist %_RIS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISDP_OUTPUT_DIR%\*.* echo RISDP Directory %_RISDP_OUTPUT_DIR% already contains files
@if exist %_RISDP_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISORADS_OUTPUT_DIR%\*.* echo ORACLE Directory %_RISORADS_OUTPUT_DIR% already contains files
@if exist %_RISORADS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISORANS_OUTPUT_DIR%\*.* echo ORACLE NET Directory %_RISORANS_OUTPUT_DIR% already contains files
@if exist %_RISORANS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISSYBDS_OUTPUT_DIR%\*.* echo SYBASE Directory %_RISSYBDS_OUTPUT_DIR% already contains files
@if exist %_RISSYBDS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISINGDS_OUTPUT_DIR%\*.* echo INGRES Directory %_RISINGDS_OUTPUT_DIR% already contains files
@if exist %_RISINGDS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISMSFDS_OUTPUT_DIR%\*.* echo MS SQL Directory %_RISMSFDS_OUTPUT_DIR% already contains files
@if exist %_RISMSFDS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISDB2DS_OUTPUT_DIR%\*.* echo DB2 Directory %_RISDB2DS_OUTPUT_DIR% already contains files
@if exist %_RISDB2DS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISINFDS_OUTPUT_DIR%\*.* echo INFORMIX Directory %_RISINFDS_OUTPUT_DIR% already contains files
@if exist %_RISINFDS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

@if exist %_RISINFNS_OUTPUT_DIR%\*.* echo INFORMIX NET Directory %_RISINFNS_OUTPUT_DIR% already contains files
@if exist %_RISINFNS_OUTPUT_DIR%\*.* set _EXIST_ERROR=y

if %_EXIST_ERROR% ==n goto make_dirs
@echo.
@echo If you continue and there are localized files in that directory,
@echo they will be overwritten.
choice /c:yn "Do you want to continue? (Y/N): "
if errorlevel 2  goto end
if errorlevel 1  goto make_dirs

:make_dirs
@echo Starting to copy files to localized directory
rem =====================================================
rem create output dirs
rem =====================================================
call _DOIT _echo Making Localized Out Directories
call _DOIT _md %_RIS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

call _DOIT _md %_RISDP_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISORADS_DIR%" =="" call _DOIT _md %_RISORADS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISORANS_DIR%" =="" call _DOIT _md %_RISORANS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISINGDS_DIR%" =="" call _DOIT _md %_RISINGDS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISDB2DS_DIR%" =="" call _DOIT _md %_RISDB2DS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISMSFDS_DIR%" =="" call _DOIT _md %_RISMSFDS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISSYBDS_DIR%" =="" call _DOIT _md %_RISSYBDS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISINFDS_DIR%" =="" call _DOIT _md %_RISINFDS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

if not "%_RISINFNS_DIR%" =="" call _DOIT _md %_RISINFNS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

rem =====================================================
rem create input product sub dirs
rem =====================================================
call _DOIT _echo Making Localized Input Sub-directories
call _DOIT _md %_LOCAL_DIR%\%_RIS_IN%\messages\orig
if not "%_ERROR%" =="" goto error

call _DOIT _md %_LOCAL_DIR%\%_RIS_IN%\help\orig
if not "%_ERROR%" =="" goto error

call _DOIT _md %_LOCAL_DIR%\%_RIS_IN%\forms\orig
if not "%_ERROR%" =="" goto error

call _DOIT _md %_LOCAL_DIR%\%_RIS_IN%\setup\orig
if not "%_ERROR%" =="" goto error

call _DOIT _md %_LOCAL_DIR%\%_RISDP_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISORADS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_ORA_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISORANS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_ORAN_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISINGDS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\_%RIS_INGRES%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISDB2DS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_DB2_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISMSFDS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_MSSQL_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISINFDS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_INF_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISINFNS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_INFN_IN%\orig
if not "%_ERROR%" =="" goto error

if not "%_RISSYBDS_DIR%" =="" call _DOIT _md %_LOCAL_DIR%\%_RIS_SYB_IN%\orig
if not "%_ERROR%" =="" goto error

rem =====================================================
rem copy RIS messages
rem =====================================================
if "%_RIS_DIR%" =="" goto do_risdp
call _DOIT _echo Copying message files
call _DOIT _copy %_RIS_DIR%\config\english\messages\src\*.txt %_LOCAL_DIR%\%_RIS_IN%\messages %_LOCAL_DIR%\%_RIS_IN%\messages\*.txt
if not "%_ERROR%" =="" goto error

call _DOIT _copy %_RIS_DIR%\config\english\messages\src\*.txt %_LOCAL_DIR%\%_RIS_IN%\messages\orig %_LOCAL_DIR%\%_RIS_IN%\messages\orig\*.txt
if not "%_ERROR%" =="" goto error

rem =====================================================
rem copy RIS help files
rem =====================================================
call _DOIT _echo Copying help files
call _DOIT _copy %_RIS_DIR%\config\english\help\*.* %_LOCAL_DIR%\%_RIS_IN%\help %_LOCAL_DIR%\%_RIS_IN%\help\*.*
if not "%_ERROR%" =="" goto error

call _DOIT _copy %_RIS_DIR%\config\english\help\*.* %_LOCAL_DIR%\%_RIS_IN%\help\orig %_LOCAL_DIR%\%_RIS_IN%\help\orig\*.*
if not "%_ERROR%" =="" goto error

rem =====================================================
rem copy RIS forms
rem =====================================================
call _DOIT _echo Copying Form files
call _DOIT _copy %_RIS_DIR%\config\english\forms\v5forms\*.frm  %_LOCAL_DIR%\%_RIS_IN%\forms %_LOCAL_DIR%\%_RIS_IN%\forms\*.frm
if not "%_ERROR%" =="" goto error

call _DOIT _copy %_RIS_DIR%\config\english\forms\v5forms\*.frm  %_LOCAL_DIR%\%_RIS_IN%\forms\orig %_LOCAL_DIR%\%_RIS_IN%\forms\orig\*.frm
if not "%_ERROR%" =="" goto error

rem =====================================================
rem copy RIS setup
rem =====================================================
call _DOIT _echo Copying RIS Setup Files
call _DOIT _copy %_RIS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\remove.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy mscomstf.dll %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\mscomstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy msinsstf.dll %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\msinsstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy msshlstf.dll %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\msshlstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy rissc.dll %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\rissc.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy ingrstf.dll %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\ingrstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy setup.exe %_LOCAL_DIR%\%_RIS_IN%\setup %_LOCAL_DIR%\%_RIS_IN%\setup\setup.exe
if not "%_ERROR%" =="" goto error

call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\*.* %_LOCAL_DIR%\%_RIS_IN%\setup\orig %_LOCAL_DIR%\%_RIS_IN%\setup\orig\*.*
if not "%_ERROR%" =="" goto error


:do_risdp
rem =====================================================
rem copy RISDP setup
rem =====================================================
call _DOIT _echo Copying RISDP Setup Files
call _DOIT _copy %_RISDP_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\remove.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy risdp.exe %_LOCAL_DIR%\%_RISDP_IN%\risdp.exe %_LOCAL_DIR%\%_RISDP_IN%\risdp.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy risdp.ws %_LOCAL_DIR%\%_RISDP_IN%\risdp.ws %_LOCAL_DIR%\%_RISDP_IN%\risdp.ws
if not "%_ERROR%" =="" goto error
call _DOIT _copy risdp.dll %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\risdp.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy setup.dp %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\setup.dp
if not "%_ERROR%" =="" goto error
call _DOIT _copy settings.ini %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\settings.ini
if not "%_ERROR%" =="" goto error
call _DOIT _copy geninf.cmd %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\geninf.cmd
if not "%_ERROR%" =="" goto error
call _DOIT _copy readprod.pl %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\readprod.pl
if not "%_ERROR%" =="" goto error
call _DOIT _copy readme.dp %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\readme.dp
if not "%_ERROR%" =="" goto error
call _DOIT _copy prod.ini %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\prod.ini
if not "%_ERROR%" =="" goto error
call _DOIT _copy risdp.lyt %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\risdp.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDP_DIR%\config\english\help\risdp.* %_LOCAL_DIR%\%_RISDP_IN% %_LOCAL_DIR%\%_RISDP_IN%\risdp.*
if not "%_ERROR%" =="" goto error

call _DOIT _copy %_LOCAL_DIR%\%_RISDP_IN%\*.* %_LOCAL_DIR%\%_RISDP_IN%\orig %_LOCAL_DIR%\%_RISDP_IN%\orig\*.*
if not "%_ERROR%" =="" goto error


:do_oracle
rem =====================================================
rem copy Oracle setup
rem =====================================================
if "%_RISORADS_DIR%" =="" goto do_sybase
call _DOIT _echo Copying Oracle Setup Files
call _DOIT _copy oracle.exe %_LOCAL_DIR%\%_RIS_ORA_IN%\risds.exe %_LOCAL_DIR%\%_RIS_ORA_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy oracle.dll %_LOCAL_DIR%\%_RIS_ORA_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_ORA_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISORADS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_ORA_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_ORA_IN%\removeds.exe
if not "%_ERROR%" =="" goto error

call _DOIT _copy %_LOCAL_DIR%\%_RIS_ORA_IN%\*.* %_LOCAL_DIR%\%_RIS_ORA_IN%\orig %_LOCAL_DIR%\%_RIS_ORA_IN%\orig\*.*
if not "%_ERROR%" =="" goto error


:do_sybase
rem =====================================================
rem copy Sybase setup
rem =====================================================
if "%_RISSYBDS_DIR%" =="" goto do_ingres
call _DOIT _echo Copying Sybase Setup Files
call _DOIT _copy sybase.exe %_LOCAL_DIR%\%_RIS_SYB_IN%\risds.exe %_LOCAL_DIR%\%_RIS_SYB_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy sybase.dll %_LOCAL_DIR%\%_RIS_SYB_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_SYB_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISSYBDS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_SYB_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_SYB_IN%\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_SYB_IN%\*.* %_LOCAL_DIR%\%_RIS_SYB_IN%\orig %_LOCAL_DIR%\%_RIS_SYB_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

:do_ingres
rem =====================================================
rem copy Ingres setup
rem =====================================================
if "%_RISINGDS_DIR%" =="" goto ok
call _DOIT _echo Copying Ingres Setup Files
call _DOIT _copy ingres.exe %_LOCAL_DIR%\%_RIS_INGRES_IN%\risds.exe %_LOCAL_DIR%\%_RIS_INGRES_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy ingres.dll %_LOCAL_DIR%\%_RIS_INGRES_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_INGRES_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISINGDS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_INGRES_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_INGRES_IN%\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_ING_IN%\*.* %_LOCAL_DIR%\%_RIS_ING_IN%\orig %_LOCAL_DIR%\%_RIS_ING_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

:do_db2
rem =====================================================
rem copy DB2 setup
rem =====================================================
if "%_RISDB2DS_DIR%" =="" goto ok
call _DOIT _echo Copying DB2 Setup Files
call _DOIT _copy db2.exe %_LOCAL_DIR%\%_RIS_DB2_IN%\risds.exe %_LOCAL_DIR%\%_RIS_DB2_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy db2.dll %_LOCAL_DIR%\%_RIS_DB2_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_DB2_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISDB2DS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_DB2_IN%\removeds.exe %_LOCAL_DIR%\\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_DB2_IN%\*.* %_LOCAL_DIR%\%_RIS_DB2_IN%\orig %_LOCAL_DIR%\%_RIS_DB2_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

:do_mssql
rem =====================================================
rem copy MS SQL setup
rem =====================================================
if "%_RISMSFDS_DIR%" =="" goto ok
call _DOIT _echo Copying MS SQL Setup Files
call _DOIT _copy msf.exe %_LOCAL_DIR%\%_RIS_MSSQL_IN%\risds.exe %_LOCAL_DIR%\%_RIS_MSSQL_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy msf.dll %_LOCAL_DIR%\%_RIS_MSSQL_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_MSSQL_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISMSFDS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_MSSQL_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_MSSQL_IN%\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_MSSQL_IN%\*.* %_LOCAL_DIR%\%_RIS_MSSQL_IN%\orig %_LOCAL_DIR%\%_RIS_MSSQL_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

:do_informix
rem =====================================================
rem copy Informix setup
rem =====================================================
if "%_RISINFDS_DIR%" =="" goto ok
call _DOIT _echo Copying Informix Setup Files
call _DOIT _copy inf.exe %_LOCAL_DIR%\%_RIS_INF_IN%\risds.exe %_LOCAL_DIR%\%_RIS_INF_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy inf.dll %_LOCAL_DIR%\%_RIS_INF_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_INF_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISINFDS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_INF_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_INF_IN%\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_INF_IN%\*.* %_LOCAL_DIR%\%_RIS_INF_IN%\orig %_LOCAL_DIR%\%_RIS_INF_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

:do_infomix_net
rem =====================================================
rem copy Informix Net setup
rem =====================================================
if "%_RISINFNS_DIR%" =="" goto ok
call _DOIT _echo Copying Informix Net Setup Files
call _DOIT _copy infn.exe %_LOCAL_DIR%\%_RIS_INFN_IN%\risds.exe %_LOCAL_DIR%\%_RIS_INFN_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy infn.dll %_LOCAL_DIR%\%_RIS_INFN_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_INFN_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISINFNS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_INFN_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_INFN_IN%\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_INFN_IN%\*.* %_LOCAL_DIR%\%_RIS_INFN_IN%\orig %_LOCAL_DIR%\%_RIS_INFN_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

:do_oracle_net
rem =====================================================
rem copy Oracle Net setup
rem =====================================================
if "%_RISORANS_DIR%" =="" goto ok
call _DOIT _echo Copying Oracle Net Setup Files
call _DOIT _copy oran.exe %_LOCAL_DIR%\%_RIS_ORAN_IN%\risds.exe %_LOCAL_DIR%\%_RIS_ORAN_IN%\risds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy oran.dll %_LOCAL_DIR%\%_RIS_ORAN_IN%\mscuistf.dll %_LOCAL_DIR%\%_RIS_ORAN_IN%\mscuistf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RISORANS_DIR%\bin\remove.exe %_LOCAL_DIR%\%_RIS_ORAN_IN%\removeds.exe %_LOCAL_DIR%\%_RIS_ORAN_IN%\removeds.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_ORAN_IN%\*.* %_LOCAL_DIR%\%_RIS_ORAN_IN%\orig %_LOCAL_DIR%\%_RIS_ORAN_IN%\orig\*.*
if not "%_ERROR%" =="" goto error

goto ok

:error
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@echo There was errors during this process
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
goto end

:ok
@echo Copying files to be localized directories is completed


:end
rem =====================================================
rem clear the environment variables
rem =====================================================
set _LOG=
set _MISSING_ERROR=
set _EXIST_ERROR=

