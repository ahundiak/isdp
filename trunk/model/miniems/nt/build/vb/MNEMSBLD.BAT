@echo off
rem Order of the arguments should be as follow

rem MSVC BS BSPLIBS LOGFILE OM_src OM_DBG_Target OM_REL_Target MINIEMS_SRC MINIEMS_DBG_Target MINIEMS_REL_Target

set MSVC=%1
@SHIFT

set BS=%1
@SHIFT

set BSPLIBS=%1
@SHIFT

set LOGFILE=%1
@SHIFT

set OM=%1
@SHIFT

set OM_DBG_TARGET=%1
@SHIFT

set OM_REL_TARGET=%1
@SHIFT

set MINIEMS=%1
@SHIFT

set MN_DBG_TARGET=%1
@SHIFT

set MN_REL_TARGET=%1
@SHIFT

:MINIEMS_DBG_BUILD
if "%MN_DBG_TARGET%" == "NO" goto MINIEMS_REL_BUILD
  set MINIEMSTARG=%MN_DBG_TARGET%
  set OMTARG=%OM_DBG_TARGET%
  set EXNUC=%OM%\src
  set BUILD_TYPE=DEBUG
  title=MINIEMS DEBUG
  set MINIEMS_USER_ENV=Yes
  pushd %MINIEMS%\nt\build
  call log build

:MINIEMS_REL_BUILD
if "%MN_REL_TARGET%" == "NO" goto END
  set MINIEMSTARG=%MN_REL_TARGET%
  set OMTARG=%OM_REL_TARGET%
  set EXNUC=%OM%\src
  set BUILD_TYPE=RELEASE
  title=MINIEMS RELEASE
  set MINIEMS_USER_ENV=Yes
  pushd %MINIEMS%\nt\build
  call log build

:END

