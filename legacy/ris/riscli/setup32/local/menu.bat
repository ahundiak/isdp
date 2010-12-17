@echo off
rem Do not alter this SPC information: $Revision: 1.8.35.1 $
rem This program is used to call the localization programs. It requires
rem no editing from the user.
rem
rem

rem get product info
call setval

:loop
if exist riserr.err del riserr.err >NUL
@echo            **************************************************
@echo                       RIS Localization Kit
@echo            **************************************************
@echo.
@echo            1) Configure the RIS Localization Kit
@echo            2) Copy files to be localized
@echo.
@echo           *3) Configure previous Localized files
@echo            4) Localize RIS Message Files
@echo            5) Compile RIS Messages
@echo            6) Localize RIS Form Files
@echo            7) Localize RIS Setup Files
@echo.
@echo            8) Re-Package the RIS Product
@echo            9) Re-Package the RIS Development Platform Product
@echo            a) Re-Package the RIS DB2 Data Server Product
@echo            b) Re-Package the RIS Informix Data Server Product
@echo            c) Re-Package the RIS Informix Net Server Product
@echo            d) Re-Package the RIS Ingres Data Server Product
@echo            e) Re-Package the RIS Oracle Data Server Product
@echo            f) Re-Package the RIS Oracle Net Server Product
@echo            g) Re-Package the RIS Sybase Data Server Product
@echo            h) Re-Package the RIS MS SQL Data Server Product
@echo.
@echo            i) Back up Localized Input Files
@echo            j) Remove Localized Input Directories
@echo.
@echo            X) Exit
@echo.
choice /c:123456789abcdefghijx "           Enter your choice: "

if errorlevel 20 goto end
if errorlevel 19 goto CLEANUP
if errorlevel 18 goto BACKUP
if errorlevel 17 goto MSSQL
if errorlevel 16 goto SYBASE
if errorlevel 15 goto ORACLE_NET
if errorlevel 14 goto ORACLE
if errorlevel 13 goto INGRES
if errorlevel 12 goto INFORMIX_NET
if errorlevel 11 goto INFORMIX
if errorlevel 10 goto DB2
if errorlevel 9  goto RISDP
if errorlevel 8  goto RIS
if errorlevel 7  goto LOC_SETUP
if errorlevel 6  goto FORMS
if errorlevel 5  goto MESSAGES
if errorlevel 4  goto LOC_MESS
if errorlevel 3  goto LOC_PREV
if errorlevel 2  goto COPY_LOC
if errorlevel 1  goto SETENV

:CLEANUP
echo Removing All Files and Directories from %_LOCAL_DIR%
rd /s %_LOCAL_DIR%
goto loop

:BACKUP
echo Copying Input files from %_LOCAL_DIR% to %_BU_DIR%
xcopy %_LOCAL_DIR%\*.* %_BU_DIR%\*.* /s >NUL
goto loop


:MSSQL
call mkds rismsfds
if exist riserr.err goto end
goto loop

:SYBASE
call mkds rissybds
if exist riserr.err goto end
goto loop

:ORACLE_NET
call mkds risorans
if exist riserr.err goto end
goto loop

:ORACLE
call mkds risorads
if exist riserr.err goto end
goto loop

:INGRES
call mkds risingds
if exist riserr.err goto end
goto loop

:INFORMIX_NET
call mkds risinfns
if exist riserr.err goto end
goto loop

:INFORMIX
call mkds risinfds
if exist riserr.err goto end
goto loop

:DB2
call mkds risdb2ds
if exist riserr.err goto end
goto loop

:RISDP
call mkdp
if exist riserr.err goto end
goto loop

:RIS
call mkris
if exist riserr.err goto end
goto loop

:MESSAGES
call mkmess
goto loop

:LOC_SETUP
call mkloc
goto loop

:LOC_MESS
%_IN_DRIVE%
cd %_LOCAL_DIR%\%_RIS_IN%\messages
notepad
%_KIT_DRIVE%
cd %_KIT%
goto loop

:FORMS
%_IN_DRIVE%
cd %_LOCAL_DIR%\%_RIS_IN%\forms
dba
%_KIT_DRIVE%
cd %_KIT%
goto loop

:COPY_LOC
call mkcopy
if exist riserr.err goto end
goto loop

:LOC_PREV
goto PREV_LOC_MENU

echo prev here
rem call mkcopy
rem if exist riserr.err goto end
goto loop

:SETENV
notepad setenv.bat
goto loop


:PREV_LOC_MENU

:loop1
if exist riserr.err del riserr.err >NUL
@echo            **************************************************
@echo             RIS Localization Kit Previous Locialization Menu
@echo            **************************************************
@echo.
@echo.
@echo          **  Copy the last RIS localized files to this system **
@echo.
@echo          **  Merge RIS Message Files from
@echo                %_LOCAL_DIR%\ris\messages to %_OLD_DIR%\ris\messages **
@echo.
@echo          **  Merge RIS Form Files from
@echo                 %_LOCAL_DIR%\ris\forms to %_OLD_DIR%\ris\forms **
@echo.
@echo            1) Copy Modified files to Input Directory
@echo            x) Return to Main Menu
@echo.
choice /c:1x "           Enter your choice: "
if errorlevel 2  goto loop

choice /c:yn "           Are you sure you want to delete the files: "
if errorlevel 2  goto loop1

call mkprev
if exist riserr.err goto end
goto loop


:end
call clearenv
if exist setreg.bat del setreg.bat >nul
if exist wert.rlk del wert.rlk >nul
