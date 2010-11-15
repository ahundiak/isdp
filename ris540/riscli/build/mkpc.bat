@echo off

if "%1%" =="" goto fast
if %1 == fast goto fast
if %1 == clean goto cleanworld
if %1 == proto goto proto
if %1 == subdirs goto subdirs
echo Invalid information
goto error

rem ***** fast **********************************************************
:fast
rem *********************************************************************
rem source
echo    Making dosrem
cd %RISDEVDIR%\riscli\dosrem
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making bin
cd %RISDEVDIR%\riscli\bin
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END

rem ***** subdirs *******************************************************
:subdirs
rem *********************************************************************
echo    Creating dosrem subdirectories
if not exist %RISDEVDIR%\riscli\dosrem\prt mkdir %RISDEVDIR%\riscli\dosrem\prt> nul
if not exist %RISDEVDIR%\riscli\dosrem\obj_%PLATFORM% mkdir %RISDEVDIR%\riscli\dosrem\obj_%PLATFORM%> nul

echo    Creating dosinstl subdirectories
if not exist %RISDEVDIR%\riscli\dosinstl mkdir %RISDEVDIR%\riscli\dosinstl> nul

echo    Creating bin subdirectories
if not exist %RISDEVDIR%\riscli\bin mkdir %RISDEVDIR%\riscli\bin> nul
if not exist %RISDEVDIR%\riscli\bin\%PLATFORM% mkdir %RISDEVDIR%\riscli\bin\%PLATFORM%> nul
goto END


rem ***** proto *********************************************************
:proto
rem *********************************************************************
echo    Making dosrem prototypes
cd %RISDEVDIR%\riscli\dosrem
nmake /nologo /e /f makefile.%PLATFORM% protos
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error
goto END


rem ***** cleanworld *****
rem *********************************************************************
:cleanworld
rem clnobjs
echo    Cleaning object directories
if exist %RISDEVDIR%\riscli\dosrem\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscli\dosrem\obj_%PLATFORM%\*.obj> nul

rem clnmkout
echo    Cleaning makeout
if exist %RISDEVDIR%\riscli\dosrem\makeout del %RISDEVDIR%\riscli\dosrem\makeout> nul

rem clnpro
echo    Cleaning prototypes
if exist %RISDEVDIR%\riscli\dosrem\prt\*.prt del %RISDEVDIR%\riscli\dosrem\prt\*.prt> nul

rem clnbin
echo    Cleaning bin
if exist %RISDEVDIR%\riscli\bin\%PLATFORM%\*.exe del %RISDEVDIR%\riscli\bin\%PLATFORM%\*.exe> nul

goto END

:error
echo    Error build %PLATFORM% > %XRISTMP%\%PLATFORM%.err
goto END

:END
cd %RISDEVDIR%\riscli\build

