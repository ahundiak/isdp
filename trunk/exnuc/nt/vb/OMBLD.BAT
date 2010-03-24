@echo off
rem Order of the arguments should be as follow

rem MSVC logfile OM_src OM_DBG_Target OM_REL_Target

set MSVC=%1

set LOGFILE=%2

set OM=%3


:OM_DBG_BUILD
if "%4" == "NO" goto OM_REL_BUILD
   set OMTARG=%4
   set BUILD_TYPE=DEBUG
   title=OM DEBUG
   pushd %OM%\nt
   call log build


:OM_REL_BUILD
if "%5" == "NO" goto END
   set OMTARG=%5
   set BUILD_TYPE=RELEASE
   title=OM RELEASE
   pushd %OM%\nt
   call log build

:END
