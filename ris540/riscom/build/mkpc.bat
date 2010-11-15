@REM Do not alter this SPC information: $Revision: 1.1.55.1 $
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
echo    Making arch
cd %RISDEVDIR%\riscom\arch
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error


echo    Making network
cd %RISDEVDIR%\riscom\network
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making common
cd %RISDEVDIR%\riscom\common
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making parse
cd %RISDEVDIR%\riscom\parse
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making parsetpg
cd %RISDEVDIR%\riscom\parsetpg
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

rem lib
echo    Making lib
cd %RISDEVDIR%\riscom\lib
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

if %PLATFORM% == dos goto fastdos
if %PLATFORM% == nt goto fastnt

rem ***** fastdos *********************************************************
:fastdos
rem *********************************************************************
echo    Making drvr
cd %RISDEVDIR%\riscom\drvr
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END

rem ***** fastnt *********************************************************
:fastnt
rem *********************************************************************
echo    Making tcpsr
cd %RISDEVDIR%\riscom\tcpsr
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

rem bin
echo    Making bin
cd %RISDEVDIR%\riscom\bin
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

goto END


rem ***** proto *********************************************************
:proto
rem *********************************************************************
echo    Making arch prototypes
cd %RISDEVDIR%\riscom\arch
nmake /nologo /e /f makefile.%PLATFORM% prt
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making network prototypes
cd %RISDEVDIR%\riscom\network
nmake /nologo /e /f makefile.%PLATFORM% prt
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making common prototypes
cd %RISDEVDIR%\riscom\common
nmake /nologo /e /f makefile.%PLATFORM% prt
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making parse prototypes
cd %RISDEVDIR%\riscom\parse
nmake /nologo /e /f makefile.%PLATFORM% prt
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making parsetpg prototypes
cd %RISDEVDIR%\riscom\parsetpg
nmake /nologo /e /f makefile.%PLATFORM% prt
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

if %PLATFORM% == dos goto END

rem ***** protont *********************************************************
:protont
rem *********************************************************************
echo    Making tcpsr prototypes
cd %RISDEVDIR%\riscom\tcpsr
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error
goto END

rem ***** subdirs *******************************************************
:subdirs
rem *********************************************************************
echo    Creating arch subdirectories
if not exist %RISDEVDIR%\riscom\arch\prt mkdir %RISDEVDIR%\riscom\arch\prt> nul
if not exist %RISDEVDIR%\riscom\arch\obj_%PLATFORM% mkdir %RISDEVDIR%\riscom\arch\obj_%PLATFORM%> nul

echo    Creating network subdirectories
if not exist %RISDEVDIR%\riscom\network\prt mkdir %RISDEVDIR%\riscom\network\prt> nul
if not exist %RISDEVDIR%\riscom\network\obj_%PLATFORM% mkdir %RISDEVDIR%\riscom\network\obj_%PLATFORM%> nul

echo    Creating common subdirectories
if not exist %RISDEVDIR%\riscom\common\prt mkdir %RISDEVDIR%\riscom\common\prt> nul
if not exist %RISDEVDIR%\riscom\common\obj_%PLATFORM% mkdir %RISDEVDIR%\riscom\common\obj_%PLATFORM%> nul

echo    Creating parse subdirectories
if not exist %RISDEVDIR%\riscom\parse\prt mkdir %RISDEVDIR%\riscom\parse\prt> nul
if not exist %RISDEVDIR%\riscom\parse\obj_%PLATFORM% mkdir %RISDEVDIR%\riscom\parse\obj_%PLATFORM%> nul

echo    Creating parsetpg subdirectories
if not exist %RISDEVDIR%\riscom\parsetpg\prt mkdir %RISDEVDIR%\riscom\parsetpg\prt> nul
if not exist %RISDEVDIR%\riscom\parsetpg\obj_%PLATFORM% mkdir %RISDEVDIR%\riscom\parsetpg\obj_%PLATFORM%> nul

echo    Creating lib subdirectories
if not exist %RISDEVDIR%\riscom\lib\%PLATFORM% mkdir %RISDEVDIR%\riscom\lib\%PLATFORM%> nul

if %PLATFORM% == dos goto END

echo    Creating tcpsr subdirectories
if not exist %RISDEVDIR%\riscom\tcpsr\prt mkdir %RISDEVDIR%\riscom\tcpsr\prt> nul
if not exist %RISDEVDIR%\riscom\tcpsr\obj_%PLATFORM% mkdir %RISDEVDIR%\riscom\tcpsr\obj_%PLATFORM%> nul

echo    Creating bin subdirectories
if not exist %RISDEVDIR%\riscom\bin\%PLATFORM% mkdir %RISDEVDIR%\riscom\bin\%PLATFORM%> nul
goto END


rem ***** cleanworld *****
rem *********************************************************************
:cleanworld
rem clnobjs
echo    Cleaning object directories
if exist %RISDEVDIR%\riscom\arch\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscom\arch\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\riscom\network\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscom\network\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\riscom\common\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscom\common\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\riscom\parse\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscom\parse\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\riscom\parsetpg\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscom\parsetpg\obj_%PLATFORM%\*.obj> nul

if %PLATFORM% == dos goto dosclmko

if exist %RISDEVDIR%\riscom\tcpsr\obj_%PLATFORM%\*.obj del %RISDEVDIR%\riscom\tcpsr\obj_%PLATFORM%\*.obj> nul

:dosclmko
rem clnmkout
echo    Cleaning makeout
if exist %RISDEVDIR%\riscom\arch\makeout del %RISDEVDIR%\riscom\arch\makeout> nul
if exist %RISDEVDIR%\riscom\network\makeout del %RISDEVDIR%\riscom\network\makeout> nul
if exist %RISDEVDIR%\riscom\common\makeout del %RISDEVDIR%\riscom\common\makeout> nul
if exist %RISDEVDIR%\riscom\parse\makeout del %RISDEVDIR%\riscom\parse\makeout> nul
if exist %RISDEVDIR%\riscom\parsetpg\makeout del %RISDEVDIR%\riscom\parsetpg\makeout> nul

if %PLATFORM% == dos goto dosclpro

if exist %RISDEVDIR%\riscom\tcpsr\makeout del %RISDEVDIR%\riscom\tcpsr\makeout> nul

:dosclpro
rem clnpro
echo    Cleaning prototypes
if exist %RISDEVDIR%\riscom\arch\prt\*.prt del %RISDEVDIR%\riscom\arch\prt\*.prt> nul
if exist %RISDEVDIR%\riscom\network\prt\*.prt del %RISDEVDIR%\riscom\network\prt\*.prt> nul
if exist %RISDEVDIR%\riscom\common\prt\*.prt del %RISDEVDIR%\riscom\common\prt\*.prt> nul
if exist %RISDEVDIR%\riscom\parse\prt\*.prt del %RISDEVDIR%\riscom\parse\prt\*.prt> nul
if exist %RISDEVDIR%\riscom\parsetpg\prt\*.prt del %RISDEVDIR%\riscom\parsetpg\prt\*.prt> nul

if %PLATFORM% == dos goto doscllib

if exist %RISDEVDIR%\riscom\tcpsr\prt\*.prt del %RISDEVDIR%\riscom\tcpsr\prt\*.prt> nul

:doscllib
rem clnlib
echo    Cleaning lib
if exist %RISDEVDIR%\riscom\lib\%PLATFORM%\*.lib del %RISDEVDIR%\riscom\lib\%PLATFORM%\*.lib> nul

rem clnbin
echo    Cleaning bin
if exist %RISDEVDIR%\riscom\bin\%PLATFORM%\*.exe del %RISDEVDIR%\riscom\bin\%PLATFORM%\*.exe> nul
goto END

:error
echo    Error build %PLATFORM% > %XRISTMP%\%PLATFORM%.err
goto END

:END
cd %RISDEVDIR%\riscom\build

