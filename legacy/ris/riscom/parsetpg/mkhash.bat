@REM Do not alter this SPC information: $Revision: 1.1.54.1 $
@echo off
set ALPHA=71
set TABLE_SIZE=405

set TEMP_FILE=hashtab.tmp
set TARGET_FILE=%RISDEVDIR%\riscom\internal\hashtab.h
set KEYWORDS_FILE=keywords

rem
rem	Note:	If this script fails, APLHA & TABLE_SIZE may need to be changed.
rem			Run hashsize to find proper values for these variables.

echo Calling mkhshtb with ALPHA=%ALPHA% and TABLE_SIZE=%TABLE_SIZE%
mkhshtb -a %ALPHA% -t %TABLE_SIZE% -p < %KEYWORDS_FILE% > %TEMP_FILE%
if errorlevel 1 goto error

diff -q %TEMP_FILE% %TARGET_FILE%
if errorlevel 1 goto filesdiff

:filessame
echo %TARGET_FILE% is up to date
del %TEMP_FILE%
goto end

:filesdiff
echo Creating new %TARGET_FILE%
if exist %TARGET_FILE% del %TARGET_FILE%
move %TEMP_FILE% %TARGET_FILE%
goto end

:error
echo.
echo 	The current values of ALPHA(%ALPHA%) and TABLE_SIZE(%TABLE_SIZE%) are invalid.
echo 	Choose new values from the output of "hashsize.exe".  Select the ALPHA
echo 	with the largest TABLE_SIZE with no collsions. Once new values are
echo 	selected, modify "mkhash.bat" and "parlex.c" to use the new values.
echo.
echo Running hashsize
hashsize

:end
set ALPHA=
set TABLE_SIZE=

set TEMP_FILE=
set TARGET_FILE=
set KEYWORDS_FILE=
echo on
