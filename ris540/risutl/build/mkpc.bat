@REM Do not alter this SPC information: $Revision: 1.1.54.1 $
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
echo    Making ucommon
cd %RISDEVDIR%\risutl\ucommon
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making userver
cd %RISDEVDIR%\risutl\userver
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error


echo    Making batch
cd %RISDEVDIR%\risutl\batch
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making clnsr
cd %RISDEVDIR%\risutl\clnsr
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dcode
cd %RISDEVDIR%\risutl\dcode
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dloadld
cd %RISDEVDIR%\risutl\dloadld
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dtype
cd %RISDEVDIR%\risutl\dtype
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making edit
cd %RISDEVDIR%\risutl\edit
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making lod
cd %RISDEVDIR%\risutl\lod
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making plbck
cd %RISDEVDIR%\risutl\plbck
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making recrd
cd %RISDEVDIR%\risutl\recrd
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making remove
cd %RISDEVDIR%\risutl\remove
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making unlod
cd %RISDEVDIR%\risutl\unlod
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making upparm
cd %RISDEVDIR%\risutl\upparm
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making util
cd %RISDEVDIR%\risutl\util
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

rem lib
echo    Making lib
cd %RISDEVDIR%\risutl\lib
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

rem bin
echo    Making bin
cd %RISDEVDIR%\risutl\bin
nmake /nologo /e /f makefile.%PLATFORM%
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error
goto END


rem ***** proto *********************************************************
:proto
rem *********************************************************************
echo    Making ucommon prototypes
cd %RISDEVDIR%\risutl\ucommon
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making userver prototypes
cd %RISDEVDIR%\risutl\userver
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making batch prototypes
cd %RISDEVDIR%\risutl\batch
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making clnsr prototypes
cd %RISDEVDIR%\risutl\clnsr
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dcode prototypes
cd %RISDEVDIR%\risutl\dcode
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dloadld prototypes
cd %RISDEVDIR%\risutl\dloadld
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making dtype prototypes
cd %RISDEVDIR%\risutl\dtype
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making edit prototypes
cd %RISDEVDIR%\risutl\edit
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making lod prototypes
cd %RISDEVDIR%\risutl\lod
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making plbck prototypes
cd %RISDEVDIR%\risutl\plbck
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making recrd prototypes
cd %RISDEVDIR%\risutl\recrd
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making remove prototypes
cd %RISDEVDIR%\risutl\remove
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making unlod prototypes
cd %RISDEVDIR%\risutl\unlod
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making upparm prototypes
cd %RISDEVDIR%\risutl\upparm
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error

echo    Making util prototypes
cd %RISDEVDIR%\risutl\util
nmake /nologo /e /f makefile.%PLATFORM% proto
if ERRORLEVEL ==4 goto error
if ERRORLEVEL ==2 goto error
if ERRORLEVEL ==1 goto error
goto END

rem ***** subdirs *******************************************************
:subdirs
rem *********************************************************************
echo    Creating ucommon subdirectories
if not exist %RISDEVDIR%\risutl\ucommon\prt     mkdir %RISDEVDIR%\risutl\ucommon\prt> nul
if not exist %RISDEVDIR%\risutl\ucommon\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\ucommon\obj_%PLATFORM%> nul

echo    Creating userver subdirectories
if not exist %RISDEVDIR%\risutl\userver\prt     mkdir %RISDEVDIR%\risutl\userver\prt> nul
if not exist %RISDEVDIR%\risutl\userver\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\userver\obj_%PLATFORM%> nul

echo    Creating batch subdirectories
if not exist %RISDEVDIR%\risutl\batch\prt     mkdir %RISDEVDIR%\risutl\batch\prt> nul
if not exist %RISDEVDIR%\risutl\batch\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\batch\obj_%PLATFORM%> nul

echo    Creating clnsr subdirectories
if not exist %RISDEVDIR%\risutl\clnsr\prt     mkdir %RISDEVDIR%\risutl\clnsr\prt> nul
if not exist %RISDEVDIR%\risutl\clnsr\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\clnsr\obj_%PLATFORM%> nul

echo    Creating dcode subdirectories
if not exist %RISDEVDIR%\risutl\dcode\prt     mkdir %RISDEVDIR%\risutl\dcode\prt> nul
if not exist %RISDEVDIR%\risutl\dcode\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\dcode\obj_%PLATFORM%> nul

echo    Creating dloadld subdirectories
if not exist %RISDEVDIR%\risutl\dloadld\prt     mkdir %RISDEVDIR%\risutl\dloadld\prt> nul
if not exist %RISDEVDIR%\risutl\dloadld\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\dloadld\obj_%PLATFORM%> nul

echo    Creating dtype subdirectories
if not exist %RISDEVDIR%\risutl\dtype\prt     mkdir %RISDEVDIR%\risutl\dtype\prt> nul
if not exist %RISDEVDIR%\risutl\dtype\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\dtype\obj_%PLATFORM%> nul

echo    Creating edit subdirectories
if not exist %RISDEVDIR%\risutl\edit\prt     mkdir %RISDEVDIR%\risutl\edit\prt> nul
if not exist %RISDEVDIR%\risutl\edit\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\edit\obj_%PLATFORM%> nul

echo    Creating lod subdirectories
if not exist %RISDEVDIR%\risutl\lod\prt     mkdir %RISDEVDIR%\risutl\lod\prt> nul
if not exist %RISDEVDIR%\risutl\lod\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\lod\obj_%PLATFORM%> nul

echo    Creating plbck subdirectories
if not exist %RISDEVDIR%\risutl\plbck\prt     mkdir %RISDEVDIR%\risutl\plbck\prt> nul
if not exist %RISDEVDIR%\risutl\plbck\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\plbck\obj_%PLATFORM%> nul

echo    Creating remove subdirectories
if not exist %RISDEVDIR%\risutl\remove\prt     mkdir %RISDEVDIR%\risutl\remove\prt> nul
if not exist %RISDEVDIR%\risutl\remove\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\remove\obj_%PLATFORM%> nul

echo    Creating recrd subdirectories
if not exist %RISDEVDIR%\risutl\recrd\prt     mkdir %RISDEVDIR%\risutl\recrd\prt> nul
if not exist %RISDEVDIR%\risutl\recrd\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\recrd\obj_%PLATFORM%> nul

echo    Creating unlod subdirectories
if not exist %RISDEVDIR%\risutl\unlod\prt     mkdir %RISDEVDIR%\risutl\unlod\prt> nul
if not exist %RISDEVDIR%\risutl\unlod\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\unlod\obj_%PLATFORM%> nul

echo    Creating upparm subdirectories
if not exist %RISDEVDIR%\risutl\upparm\prt     mkdir %RISDEVDIR%\risutl\upparm\prt> nul
if not exist %RISDEVDIR%\risutl\upparm\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\upparm\obj_%PLATFORM%> nul

echo    Creating util subdirectories
if not exist %RISDEVDIR%\risutl\util\prt     mkdir %RISDEVDIR%\risutl\util\prt> nul
if not exist %RISDEVDIR%\risutl\util\obj_%PLATFORM% mkdir %RISDEVDIR%\risutl\util\obj_%PLATFORM%> nul

echo    Creating lib subdirectories
if not exist %RISDEVDIR%\risutl\lib\%PLATFORM% mkdir %RISDEVDIR%\risutl\lib\%PLATFORM%> nul

echo    Creating bin subdirectories
if not exist %RISDEVDIR%\risutl\bin\%PLATFORM% mkdir %RISDEVDIR%\risutl\bin\%PLATFORM%> nul
goto END


rem ***** cleanworld *****
rem *********************************************************************
:cleanworld
rem clnobjs
echo    Cleaning object directories
if exist %RISDEVDIR%\risutl\ucommon\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\ucommon\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\userver\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\userver\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\batch\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\batch\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\clnsr\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\clnsr\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\dcode\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\dcode\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\dtype\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\dtype\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\dloadld\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\dloadld\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\edit\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\edit\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\lod\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\lod\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\plbck\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\plbck\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\recrd\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\recrd\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\remove\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\remove\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\unlod\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\unlod\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\upparm\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\upparm\obj_%PLATFORM%\*.obj> nul
if exist %RISDEVDIR%\risutl\util\obj_%PLATFORM%\*.obj del %RISDEVDIR%\risutl\util\obj_%PLATFORM%\*.obj> nul

rem clnmkout
echo    Cleaning makeout
if exist %RISDEVDIR%\risutl\ucommon\makeout del %RISDEVDIR%\risutl\ucommon\makeout> nul
if exist %RISDEVDIR%\risutl\userver\makeout del %RISDEVDIR%\risutl\userver\makeout> nul
if exist %RISDEVDIR%\risutl\batch\makeout del %RISDEVDIR%\risutl\batch\makeout> nul
if exist %RISDEVDIR%\risutl\clnsr\makeout del %RISDEVDIR%\risutl\clnsr\makeout> nul
if exist %RISDEVDIR%\risutl\dcode\makeout del %RISDEVDIR%\risutl\dcode\makeout> nul
if exist %RISDEVDIR%\risutl\dtype\makeout del %RISDEVDIR%\risutl\dtype\makeout> nul
if exist %RISDEVDIR%\risutl\dloadld\makeout del %RISDEVDIR%\risutl\dloadld\makeout> nul
if exist %RISDEVDIR%\risutl\edit\makeout del %RISDEVDIR%\risutl\edit\makeout> nul
if exist %RISDEVDIR%\risutl\lod\makeout del %RISDEVDIR%\risutl\lod\makeout> nul
if exist %RISDEVDIR%\risutl\plbck\makeout del %RISDEVDIR%\risutl\plbck\makeout> nul
if exist %RISDEVDIR%\risutl\recrd\makeout del %RISDEVDIR%\risutl\recrd\makeout> nul
if exist %RISDEVDIR%\risutl\remove\makeout del %RISDEVDIR%\risutl\remove\makeout> nul
if exist %RISDEVDIR%\risutl\unlod\makeout del %RISDEVDIR%\risutl\unlod\makeout> nul
if exist %RISDEVDIR%\risutl\upparm\makeout del %RISDEVDIR%\risutl\upparm\makeout> nul
if exist %RISDEVDIR%\risutl\util\makeout del %RISDEVDIR%\risutl\util\makeout> nul

rem clnlib
echo    Cleaning lib
if exist %RISDEVDIR%\risutl\lib\%PLATFORM%\*.lib del %RISDEVDIR%\risutl\lib\%PLATFORM%\*.lib> nul

rem clnbin
echo    Cleaning bin
if exist %RISDEVDIR%\risutl\bin\%PLATFORM%\*.exe del %RISDEVDIR%\risutl\bin\%PLATFORM%\*.exe> nul
goto END

:error
echo    Error build %PLATFORM% > %XRISTMP%\%PLATFORM%.err
goto END

:END
cd %RISDEVDIR%\risutl\build

