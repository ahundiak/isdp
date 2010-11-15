@echo off
rem Do not alter this SPC information: $Revision: 1.3.39.1 $
rem This program is controls the localization of setup files. It requires no
rem editing by the user.
rem
rem

rem =====================================================
rem set the environment variables
rem =====================================================
call setval

:loop
@echo            **************************************************
@echo                       Localize Setup Files
@echo            **************************************************
@echo.
@echo.
@echo            0) RIS Shared Components Product
@echo            1) RIS Development Platform Product
@echo            2) RIS DB2 Data Server Product
@echo            3) RIS Informix Data Server Product
@echo            4) RIS Informix Net Server Product
@echo            5) RIS Ingres Data Server Product
@echo            6) RIS Oracle Data Server Product
@echo            7) RIS Oracle Net Server Product
@echo            8) RIS Sybase Data Server Product
@echo            9) RIS MS SQL Data Server Product
@echo.
@echo            X) Return to Localization Menu
@echo.
choice /c:0123456789x "           Which RIS Product?: "

if errorlevel 11 goto end
if errorlevel 10 goto MSF
if errorlevel 9 goto SYB
if errorlevel 8  goto ORANET
if errorlevel 7  goto ORA
if errorlevel 6  goto IGS
if errorlevel 5  goto INFNET
if errorlevel 4  goto INF
if errorlevel 3  goto DB2
if errorlevel 2  goto RISDP
if errorlevel 1  goto RIS

:MSF
set _GDIR=%_RIS_MSSQL_IN%
set _PNAME=MS SQL Data Server
goto what_prod

:SYB
set _GDIR=%_RIS_SYB_IN%
set _PNAME=Sybase Data Server
goto what_prod

:ORANET
set _GDIR=%_RIS_ORAN_IN%
set _PNAME=Oracle Net Server
goto what_prod

:ORA
set _GDIR=%_RIS_ORA_IN%
set _PNAME=Oracle Data Server
goto what_prod

:IGS
set _GDIR=%_RIS_INGRES_IN%
set _PNAME=Ingres Data Server
goto what_prod

:INFNET
set _GDIR=%_RIS_INFN_IN%
set _PNAME=Informix Net Server
goto what_prod

:INF
set _GDIR=%_RIS_INF_IN%
set _PNAME=Informix Data Server
goto what_prod

:DB2
set _GDIR=%_RIS_DB2_IN%
set _PNAME=DB2 Data Server
goto what_prod

:RISDP
set _GDIR=%_RISDP_IN%
set _PNAME=Development Platform
goto what_prod

:RIS
set _GDIR=%_RIS_IN%\setup
set _PNAME=Shared Components
goto what_prod




:what_prod
@echo.
@echo		 [%_PNAME%]
@echo.
@echo            1) Master Project
@echo            2) Project
@echo.
@echo            X) Return to Product Selection
@echo.
choice /c:12x "           Which Program?: "

if errorlevel 3 goto loop
if errorlevel 2  goto PROJ
if errorlevel 1  goto MAST_PROJ


:MAST_PROJ
%_IN_DRIVE%
cd %_LOCAL_DIR%\%_GDIR%
%_KIT%\rladmin
%_KIT_DRIVE%
cd %_KIT%
goto what_prod

:PROJ
%_IN_DRIVE%
cd %_LOCAL_DIR%\%_GDIR%
%_KIT%\rledit
%_KIT_DRIVE%
cd %_KIT%
goto what_prod

:end
set _GDIR=

