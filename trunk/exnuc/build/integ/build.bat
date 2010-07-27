@echo off
rem
rem	NT build script.  All the environment variables for
rem	the build are set here.
rem

call .\build\exnucntenv.bat

if not "%EXNUC%" == "%TARGET%" goto test2
echo EXNUC and TARGET env variables cannot be set the same
goto error

:test2
rem	Check to make sure EXNUC, TARGET, and BASE directories exist.
if exist %EXNUC% goto test3
echo Directory %EXNUC% does not exist
goto error

:test3
if exist %TARGET% goto test4
echo Directory %TARGET% does not exist
goto error

:test4
if exist %BASE% goto make
echo Directory %BASE% does not exist
goto error

:make
nmake -nologo -e -f makefile.nt %MARG%
if not errorlevel 1 goto success

:error
echo ERROR
goto end

:success
echo SUCCESS

:end
time < nul | find "current"
date < nul | find "current"
