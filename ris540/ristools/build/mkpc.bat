@REM Do not alter this SPC information: $Revision: 1.1.54.1 $
@echo off

if "%1%" =="" goto fast
if %1 == fast goto fast
if %1 == clean goto cleanworld
if %1 == subdirs goto subdirs
echo Invalid information
goto error

rem ***** fast **********************************************************
:fast
rem *********************************************************************
rem source
echo    Making c
cd %RISDEVDIR%\ristools\c
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error


echo    Making mm
cd %RISDEVDIR%\ristools\mm
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making tpg
cd %RISDEVDIR%\ristools\tpg
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END

rem ***** subdirs *******************************************************
:subdirs
rem *********************************************************************
echo    Creating mm subdirectories
if not exist %RISDEVDIR%\ristools\mm\prt mkdir %RISDEVDIR%\ristools\mm\prt> nul
if not exist %RISDEVDIR%\ristools\mm\obj_%PLATFORM% mkdir %RISDEVDIR%\ristools\mm\obj_%PLATFORM%> nul

echo    Creating tpg subdirectories
if not exist %RISDEVDIR%\ristools\tpg\prt mkdir %RISDEVDIR%\ristools\tpg\prt> nul
if not exist %RISDEVDIR%\ristools\tpg\obj_%PLATFORM% mkdir %RISDEVDIR%\ristools\tpg\obj_%PLATFORM%> nul

echo    Creating bin subdirectories
if not exist %RISDEVDIR%\ristools\bin mkdir %RISDEVDIR%\ristools\bin> nul
if not exist %RISDEVDIR%\ristools\bin\%PLATFORM% mkdir %RISDEVDIR%\ristools\bin\%PLATFORM%> nul
goto END


rem ***** cleanworld *****
rem *********************************************************************
:cleanworld
rem cleanup
echo    Cleaning c directory
cd %RISDEVDIR%\ristools\c
nmake /nologo /e /f makefile.%PLATFORM% cleanup
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Cleaning mm directory
cd %RISDEVDIR%\ristools\mm
nmake /nologo /e /f makefile.%PLATFORM% cleanup
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Cleaning tpg directory
cd %RISDEVDIR%\ristools\tpg
nmake /nologo /e /f makefile.%PLATFORM% cleanup
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END

:error
echo    Error build %PLATFORM% > %XRISTMP%\%PLATFORM%.err
goto END

:END
cd %RISDEVDIR%\ristools\build

