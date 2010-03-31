@if not exist %MINIEMSTARG%                mkdir %MINIEMSTARG%
@if not exist %MINIEMSTARG%\api            mkdir %MINIEMSTARG%\api
@if not exist %MINIEMSTARG%\api\bdrycre    mkdir %MINIEMSTARG%\api\bdrycre
@if not exist %MINIEMSTARG%\api\bdryint    mkdir %MINIEMSTARG%\api\bdryint
@if not exist %MINIEMSTARG%\api\bdrymod    mkdir %MINIEMSTARG%\api\bdrymod
@if not exist %MINIEMSTARG%\api\bdryquery  mkdir %MINIEMSTARG%\api\bdryquery
@if not exist %MINIEMSTARG%\api\cvmod      mkdir %MINIEMSTARG%\api\cvmod
@if not exist %MINIEMSTARG%\api\cvquery    mkdir %MINIEMSTARG%\api\cvquery
@if not exist %MINIEMSTARG%\api\dpb        mkdir %MINIEMSTARG%\api\dpb
@if not exist %MINIEMSTARG%\api\errdbg     mkdir %MINIEMSTARG%\api\errdbg
@if not exist %MINIEMSTARG%\api\grmod      mkdir %MINIEMSTARG%\api\grmod
@if not exist %MINIEMSTARG%\api\grquery    mkdir %MINIEMSTARG%\api\grquery
@if not exist %MINIEMSTARG%\api\int2d      mkdir %MINIEMSTARG%\api\int2d
@if not exist %MINIEMSTARG%\api\map        mkdir %MINIEMSTARG%\api\map
@if not exist %MINIEMSTARG%\api\math       mkdir %MINIEMSTARG%\api\math
@if not exist %MINIEMSTARG%\api\OMuse      mkdir %MINIEMSTARG%\api\OMuse
@if not exist %MINIEMSTARG%\api\profqry    mkdir %MINIEMSTARG%\api\profqry
@if not exist %MINIEMSTARG%\api\runtypes   mkdir %MINIEMSTARG%\api\runtypes
@if not exist %MINIEMSTARG%\api\sfcre      mkdir %MINIEMSTARG%\api\sfcre
@if not exist %MINIEMSTARG%\api\sfmod      mkdir %MINIEMSTARG%\api\sfmod
@if not exist %MINIEMSTARG%\api\sfquery    mkdir %MINIEMSTARG%\api\sfquery
@if not exist %MINIEMSTARG%\api\tolfunc    mkdir %MINIEMSTARG%\api\tolfunc
@if not exist %MINIEMSTARG%\api\uom        mkdir %MINIEMSTARG%\api\uom
@if not exist %MINIEMSTARG%\api\util       mkdir %MINIEMSTARG%\api\util
@if not exist %MINIEMSTARG%\exnuc          mkdir %MINIEMSTARG%\exnuc
@if not exist %MINIEMSTARG%\funk           mkdir %MINIEMSTARG%\funk
@if not exist %MINIEMSTARG%\funk\grnuc     mkdir %MINIEMSTARG%\funk\grnuc
@if not exist %MINIEMSTARG%\funk\model     mkdir %MINIEMSTARG%\funk\model
@if not exist %MINIEMSTARG%\imp            mkdir %MINIEMSTARG%\imp
@if not exist %MINIEMSTARG%\imp\grnuc      mkdir %MINIEMSTARG%\imp\grnuc
@if not exist %MINIEMSTARG%\imp\model      mkdir %MINIEMSTARG%\imp\model
@if not exist %MINIEMSTARG%\imp\uom        mkdir %MINIEMSTARG%\imp\uom
@if not exist %MINIEMSTARG%\lib            mkdir %MINIEMSTARG%\lib
@if not exist %MINIEMSTARG%\bin            mkdir %MINIEMSTARG%\bin
@if not exist %MINIEMSTARG%\spec           mkdir %MINIEMSTARG%\spec
@if not exist %MINIEMSTARG%\spec\grnuc     mkdir %MINIEMSTARG%\spec\grnuc
@if not exist %MINIEMSTARG%\spec\model     mkdir %MINIEMSTARG%\spec\model
@if not exist %MINIEMSTARG%\spec\uom       mkdir %MINIEMSTARG%\spec\uom
@if not exist %MINIEMSTARG%\stubs          mkdir %MINIEMSTARG%\stubs
@if not exist %MINIEMSTARG%\miniems        mkdir %MINIEMSTARG%\miniems

set BUILD=MINIEMS
set BLDNUMB=00

set PRODUCT_VERSION=00.00.00.00
set PRODUCT_NAME=MINIEMS
set PRODUCT_DATE=

set Include=%MSVC%\include
set LIB=%MSVC%\lib;%LIB%

set EXNUC=%OM%
set PATH=%OMTARG%\bin;%PATH%

set UMS_INC_PATH=noums
set LIBXC_INC_PATH=nolibxc
set LIBXC_LIB_PATH= 
set XINC=noxinc
set INGRHOME=noingrhome

set MINIEMSSRC=%MINIEMS%

@if not "%FIRST_TIME_MINIEMS_BUILD%"=="" goto UPDATE_PATHS
@set FIRST_TIME_MINIEMS_BUILD=NO
@set PATH=%MSVC%\bin;%PATH%
@set MSVC_OLD=%MSVC%
@set PATH=%OM%\src\build;%OMTARG%\bin;%PATH%
@set OM_OLD=%OM%
@set PATH=%MINIEMS%\nt\build;%PATH%
@set MINIEMS_OLD=%MINIEMS%
@goto BUILD_OPTIONS

:UPDATE_PATHS
:MSVC_PATH
@if "%MSVC%"=="%MSVC_OLD%" goto OM_PATH
@set MSVC_OLD=%MSVC%
@set PATH=%MSVC%\bin;%PATH%

:OM_PATH
@if "%OM%"=="%OM_OLD%" goto MINIEMS_PATH
@set OM_OLD=%OM%
@set PATH=%OM%\src\build;%OMTARG%\bin;%PATH%

:MINIEMS_PATH
@if "%MINIEMS%"=="%MINIEMS_OLD%" goto BUILD_OPTIONS
@set MINIEMS_OLD=%MINIEMS%
@set PATH=%MINIEMS%\nt\build;%PATH%

:BUILD_OPTIONS
@echo %PATH%
set NMAKEOPT=/nologo /I

@if "%BUILD_TYPE%" == "RELEASE" goto RELEASE
@echo *** BUILDING DEBUG VERSION ***
set CC=cl -Tc -W3 -Zp8 -Gd -Zi -Od -nologo -MD 
set COPT = -D_WIN32 -D_DEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ -DBASE_EMS -DSTRICT
set DOPT1= -D_WIN32 -D_DEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ -DBASE_EMS -DSTRICT
set DOPT = -D_WIN32 -D_DEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ -DBASE_EMS -DSTRICT
set DEBUGAMOUNT=-debug:full
set DEBUGTYPE=-debugtype:cv
@goto END

:RELEASE
@echo *** BUILDING RELEASE VERSION ***
set CC=cl -Tc -W3 -Zp8 -Gd -Ox -Gs -nologo -MD
set COPT = -D_WIN32 -DNDEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ -DBASE_EMS -DSTRICT
set DOPT1= -D_WIN32 -DNDEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ -DBASE_EMS -DSTRICT
set DOPT = -D_WIN32 -DNDEBUG -D_WINDOWS -DNT -D_NTWIN -D_X86_ -DBASE_EMS -DSTRICT
set DEBUGAMOUNT=
set DEBUGTYPE=


:END

