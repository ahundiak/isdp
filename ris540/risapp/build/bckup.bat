@echo off
set SUB=ap
set SUBDIR=risapp
set SKIPFILE=build\spc.skp
set DATEFILE=tstamp

if "%RISDEVDRIVE%" == "" goto norisdevdrive
if "%RISDEVDIR%" == "" goto norisdevdir

:checkarg1
if "%1" == "-z" goto zip
if "%1" == "-l" goto listonly
if "%1" == "-t" goto tree
goto usage

:listonly
%RISDEVDRIVE%
cd %RISDEVDIR%\%SUBDIR%
getfiles -e -s %SKIPFILE% -n %DATEFILE%
goto exit

:zip
if "%RISSAVEDRIVE%" == "" goto norissavedrive
if "%RISSAVEDIR%" == "" goto norissavedir
if "%RIS_MAJ%" == "" goto norismaj
if "%RIS_MIN%" == "" goto norismin
if "%RIS_REL%" == "" goto norisrel
set ZIPFILE=%RISSAVEDIR%\%RIS_MAJ%%RIS_MIN%%RIS_REL%b.%SUB%z
%RISDEVDRIVE%
cd %RISDEVDIR%\%SUBDIR%
if exist %ZIPFILE% del %ZIPFILE%
echo.
echo Making backup zip file %ZIPFILE%
getfiles -e -s %SKIPFILE% -n %DATEFILE% | zip %ZIPFILE% -@
set ZIPFILE=
goto exit

:tree
if "%RISSAVEDRIVE%" == "" goto norissavedrive
if "%RISSAVEDIR%" == "" goto norissavedir

set ZIPFILE=%RISSAVEDIR%\temp.zip
set LISTFILE=%RISSAVEDIR%\%SUBDIR%\files.dat

echo.
echo Making %SUBDIR% backup tree in %RISSAVEDIR%

if exist %ZIPFILE% del %ZIPFILE%
if exist %LISTFILE% del %LISTFILE%
if not exist %RISSAVEDIR%\%SUBDIR% goto :mkdir
echo y | rmdir /s %RISSAVEDIR%\%SUBDIR% > NUL

:mkdir
mkdir %RISSAVEDIR%\%SUBDIR%

%RISDEVDRIVE%
cd %RISDEVDIR%\%SUBDIR%
getfiles -e -s %SKIPFILE% -n %DATEFILE% > %LISTFILE%
type %LISTFILE%
zip -q %ZIPFILE% -@ < %LISTFILE%

%RISSAVEDRIVE%
cd %RISSAVEDIR%\%SUBDIR%
unzip -q -d %ZIPFILE%

del %ZIPFILE%
set ZIPFILE=
set LISTFILE=
goto exit

:usage
echo.
echo Usage: bckup {-z|-l|-t}
goto exit

:norisdevdrive
echo.
echo RISDEVDRIVE must be set
goto exit

:norisdevdir
echo.
echo RISDEVDIR must be set
goto exit

:norissavedrive
echo.
echo RISSAVEDRIVE must be set
goto exit

:norissavedir
echo.
echo RISSAVEDIR must be set
goto exit

:norismaj
echo.
echo RIS_MAJ must be set
goto exit

:norismin
echo.
echo RIS_MIN must be set
goto exit

:norisrel
echo.
echo RIS_REL must be set
goto exit

:exit
set SUB=
set SUBDIR=
set SKIPFILE=
set DATEFILE=
