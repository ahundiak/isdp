@echo off
rem
rem	OM NT build script.  All the environment variables for
rem	the build are set here.
rem

:test1
if not "%OM%" == "" goto test2
echo error OM variable not set
echo Please edit and execute OM\NT\USER.BAT first.
goto error

:test2
if exist %OM% goto test3
echo Directory %OM% does not exist
goto error

:test3
if not "%OMTARG%" == "" goto test4
echo OMTARG variable not set
goto error

:test4
if not "%MSVC%" == "" goto test5
echo MSVC variable not set
goto error

:test5
if exist %MSVC% goto test6
echo Directory %MSVC% does not exist
goto error

:test6
if not "%OM%" == "%OMTARG%" goto test7
echo OM and OMTARG env variables cannot be the same
echo set OMTARG to some other location
goto error

:test7
if not "%OM%" == "%OMTARG%" goto test8
echo Don't set OMTARG env variable to %OM% directory
echo set OMTARG to some other location
goto error

:test8

call %OM%\nt\omntenv.bat
set EXNUC=%OM%
:make
pushd %OM%
nmake -nologo -e -f %OM%\makefile.nt %MARG%
if not errorlevel 1 goto success

:error
echo ERROR
goto end

:success
echo SUCCESS

:end
time < nul | find "current"
date < nul | find "current"
