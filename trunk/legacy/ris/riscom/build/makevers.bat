@REM Do not alter this SPC information: $Revision: 1.6.9.1 $
@echo off
set TEMPFILE=%TEMP%\version.h
set VERSIONFILE=%RISDEVDIR%\riscom\internal\risver.h

rem call perl script to add version and date info
perl %RISDEVDIR%\riscom\build\makevers.pl %TEMPFILE%

REM
REM compare the new version file to the one in the internal directory
REM if they are different then replace the old with the new
REM otherwise remove the new file
REM
echo n | comp %TEMPFILE% %VERSIONFILE% >NUL 2>NUL
if errorlevel 1 goto diff

del/q %TEMPFILE%
echo.
echo. %VERSIONFILE% was up to date.
echo.
goto exit

:diff
del/q %VERSIONFILE%
move %TEMPFILE% %VERSIONFILE%
echo.
echo.	Made a new %VERSIONFILE%
echo.

:exit

