@if not exist %OMTARG% mkdir %OMTARG%

set EXNUC=%OM%
set BASE=%OMTARG%
set TARGET=%OMTARG%
set ECHO=%BASE%\bin\execho

set BUILD=ntEXNUC
set BLDNUMB=00

set PRODUCT_VERSION=03.01.00.%BLDNUMB%
set PRODUCT_NAME=EXNUC
set PRODUCT_DATE=

set UMS_INC_PATH=noums
set LIBXC_INC_PATH=nolibxc
set LIBXC_LIB_PATH=

:UPDATE_PATHS
:MSVC_PATH
@if "%MSVC%"=="%MSVC_OLD%" goto OM_PATH
@set MSVC_OLD=%MSVC%
@set PATH=%MSVC%\bin;%PATH%
@set LIB=%MSVC%\lib;%LIB%
@set Include=%MSVC%\include;%Include%

:OM_PATH
@if "%OM%"=="%OM_OLD%" goto MINIEMS_PATH
@set OM_OLD=%OM%
@set PATH=%OM%\build;%OMTARG%\bin;%PATH%

:BUILD_OPTIONS
@echo %PATH%
@if "%BUILD_TYPE%" == "RELEASE" goto RELEASE
@echo *** BUILDING DEBUG VERSION ***
set CC=cl -Tc -W3 -Zp8 -G3d -Zi -Od -nologo -MD

@rem Don't add the option -D_DEBUG to DOPT1. Build cribs.
set DOPT1=-D_WIN32 -DNT -D_NTWIN -D_WINDOWS -D_X86_ 
	
set DEBUGAMOUNT=-debug:full
set DEBUGTYPE=-debugtype:cv
@goto MKMK

:RELEASE
@echo *** BUILDING RELEASE VERSION ***
set CC=cl -Tc -W3 -Zp8 -Gd -Ox -Gs -nologo -MD
set DOPT1=-D_WIN32 -DNDEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ 
set DEBUGAMOUNT=
set DEBUGTYPE=


:MKMK
set MAKEMAKE=%BASE%\bin\makemake -i%EXNUC%\build\winntIgnore %DOPT1%


:END
