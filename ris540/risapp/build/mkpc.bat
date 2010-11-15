@REM Do not alter this SPC information: $Revision: 1.1.59.1 $
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
echo    Making app
cd %RISDEVDIR%\risapp\app
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making intrface
cd %RISDEVDIR%\risapp\intrface
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making cpp
cd %RISDEVDIR%\risapp\cpp
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dload
cd %RISDEVDIR%\risapp\dload
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making remove
cd %RISDEVDIR%\risapp\remove
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

rem lib
echo    Making lib
cd %RISDEVDIR%\risapp\lib
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

rem bin
echo    Making bin
cd %RISDEVDIR%\risapp\bin
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END


rem ***** proto *********************************************************
:proto
rem *********************************************************************
echo    Making app prototypes
cd %RISDEVDIR%\risapp\app
nmake /nologo /e /f makefile.%PLATFORM% protos
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making intrface prototypes
cd %RISDEVDIR%\risapp\intrface
nmake /nologo /e /f makefile.%PLATFORM% protos
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making cpp prototypes
cd %RISDEVDIR%\risapp\cpp
nmake /nologo /e /f makefile.%PLATFORM% protos
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dload prototypes
cd %RISDEVDIR%\risapp\dload
nmake /nologo /e /f makefile.%PLATFORM% protos
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making remove prototypes
cd %RISDEVDIR%\risapp\remove
nmake /nologo /e /f makefile.%PLATFORM% protos
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END

rem ***** subdirs *******************************************************
:subdirs
rem *********************************************************************
echo    Creating app subdirectories
if not exist %RISDEVDIR%\risapp\app\prt mkdir %RISDEVDIR%\risapp\app\prt> nul
if not exist %RISDEVDIR%\risapp\app\obj_%PLATFORM% mkdir %RISDEVDIR%\risapp\app\obj_%PLATFORM%> nul

echo    Creating intrface subdirectories
if not exist %RISDEVDIR%\risapp\intrface\prt mkdir %RISDEVDIR%\risapp\intrface\prt> nul
if not exist %RISDEVDIR%\risapp\intrface\obj_%PLATFORM% mkdir %RISDEVDIR%\risapp\intrface\obj_%PLATFORM%> nul

echo    Creating cpp subdirectories
if not exist %RISDEVDIR%\risapp\cpp\prt mkdir %RISDEVDIR%\risapp\cpp\prt> nul
if not exist %RISDEVDIR%\risapp\cpp\obj_%PLATFORM% mkdir %RISDEVDIR%\risapp\cpp\obj_%PLATFORM%> nul

echo    Creating dload subdirectories
if not exist %RISDEVDIR%\risapp\dload\prt mkdir %RISDEVDIR%\risapp\dload\prt> nul
if not exist %RISDEVDIR%\risapp\dload\obj_%PLATFORM% mkdir %RISDEVDIR%\risapp\dload\obj_%PLATFORM%> nul

echo    Creating remove subdirectories
if not exist %RISDEVDIR%\risapp\remove\prt mkdir %RISDEVDIR%\risapp\remove\prt> nul
if not exist %RISDEVDIR%\risapp\remove\obj_%PLATFORM% mkdir %RISDEVDIR%\risapp\remove\obj_%PLATFORM%> nul

echo    Creating lib subdirectories
if not exist %RISDEVDIR%\risapp\lib\%PLATFORM% mkdir %RISDEVDIR%\risapp\lib\%PLATFORM%> nul

echo    Creating bin subdirectories
if not exist %RISDEVDIR%\risapp\bin\%PLATFORM% mkdir %RISDEVDIR%\risapp\bin\%PLATFORM%> nul
goto END


rem ***** cleanworld *****
rem *********************************************************************
:cleanworld
rem clnobjs
echo    Cleaning object directories
if exist %RISDEVDIR%\risapp\app\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risapp\app\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risapp\intrface\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risapp\intrface\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risapp\cpp\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risapp\cpp\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risapp\dload\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risapp\dload\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risapp\remove\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risapp\remove\obj_%PLATFORM%\*.obj> nul

rem clnmkout
echo    Cleaning makeout
if exist %RISDEVDIR%\risapp\app\makeout del %RISDEVDIR%\risapp\app\makeout> nul
if exist %RISDEVDIR%\risapp\intrface\makeout del %RISDEVDIR%\risapp\intrface\makeout> nul
if exist %RISDEVDIR%\risapp\cpp\makeout del %RISDEVDIR%\risapp\cpp\makeout> nul
if exist %RISDEVDIR%\risapp\dload\makeout del %RISDEVDIR%\risapp\dload\makeout> nul
if exist %RISDEVDIR%\risapp\remove\makeout del %RISDEVDIR%\risapp\remove\makeout> nul

rem clnpro
echo    Cleaning prototypes
if exist %RISDEVDIR%\risapp\app\prt\*.prt del %RISDEVDIR%\risapp\app\prt\*.prt> nul
if exist %RISDEVDIR%\risapp\intrface\prt\*.prt del %RISDEVDIR%\risapp\intrface\prt\*.prt> nul
if exist %RISDEVDIR%\risapp\cpp\prt\*.prt del %RISDEVDIR%\risapp\cpp\prt\*.prt> nul
if exist %RISDEVDIR%\risapp\dload\prt\*.prt del %RISDEVDIR%\risapp\dload\prt\*.prt> nul
if exist %RISDEVDIR%\risapp\remove\prt\*.prt del %RISDEVDIR%\risapp\remove\prt\*.prt> nul

rem clnlib
echo    Cleaning lib
if exist %RISDEVDIR%\risapp\lib\%PLATFORM%\*.lib del %RISDEVDIR%\risapp\lib\%PLATFORM%\*.lib> nul

rem clnbin
echo    Cleaning bin
if exist %RISDEVDIR%\risapp\bin\%PLATFORM%\*.exe del %RISDEVDIR%\risapp\bin\%PLATFORM%\*.exe> nul
goto END

:error
echo    Error build %PLATFORM% > %XRISTMP%\%PLATFORM%.err
goto END

:END
cd %RISDEVDIR%\risapp\build

