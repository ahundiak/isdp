rem @echo off
rem Order of the arguments should be as follow

rem MSVC BS BSPLIBS logfile OM_src OM_DBG_Target OM_REL_Target MINIEMS_SRC MINIEMS_DBG_Target MINIEMS_REL_Target
rem OM_DBG_BUILD OM_REL_BUILD MN_DBG_BUILD MN_REL_BUILD

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

set OM_DBG_TARG=%1
@SHIFT

set OM_REL_TARG=%1
@SHIFT

set MINIEMS=%1
@SHIFT

set MN_DBG_TARG=%1
@SHIFT

set MN_REL_TARG=%1
@SHIFT

set OM_DBG_BUILD=%1
@SHIFT
 
set OM_REL_BUILD=%1
@SHIFT

set MN_DBG_BUILD=%1
@SHIFT

set MN_REL_BUILD=%1
@SHIFT

:OM_DBG_BUILD
if "%OM_DBG_BUILD%" == "NO" goto OM_REL_BUILD
   call %OM%\nt\vb\ombld.bat %MSVC% %LOGFILE% %OM% %OM_DBG_TARG% NO

:OM_REL_BUILD
if "%OM_REL_BUILD%" == "NO" goto MN_DBG_BUILD
   call %OM%\nt\vb\ombld.bat %MSVC% %LOGFILE% %OM% NO %OM_REL_TARG% 

:MN_DBG_BUILD
if "%MN_DBG_BUILD%" == "NO" goto MN_REL_BUILD
   call %MINIEMS%\nt\build\vb\mnemsbld.bat %MSVC% %BS% %BSPLIBS% %LOGFILE% %OM% %OM_DBG_TARG% NO %MINIEMS% %MN_DBG_TARG% NO

:MN_REL_BUILD
if "%MN_REL_BUILD%" == "NO" goto END
   call %MINIEMS%\nt\build\vb\mnemsbld.bat %MSVC% %BS% %BSPLIBS% %LOGFILE% %OM% NO %OM_REL_TARG% %MINIEMS% NO %MN_REL_TARG%

:END


