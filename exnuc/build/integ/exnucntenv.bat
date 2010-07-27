set EXNUC=%EXNUC%
set BASE=%TARGET%
set LIBXC_LIB_PATH=

set BUILD=ntEXNUC
set BLDNUMB=00

set PRODUCT_VERSION=03.01.00.%BLDNUMB%
set PRODUCT_NAME=EXNUC
set PRODUCT_DATE=

rem set CC=cl -W3 -Zp8 -G3d -Ox -Gs -nologo
set DOPT1=-DWIN32 -DNT -D_NTWIN -D_WINDOWS -D_X86_ 
rem -D"_MSC_VER=900" -D_WIN32 -DDEBUG
rem -D"CRTAPI1=_cdecl" -D"CRTAPI2=_cdecl"
set MAKEMAKE=%BASE%\bin\makemake -i%EXNUC%\build\winntIgnore %DOPT1%
set ECHO=%BASE%\bin\execho

rem set DEBUGAMOUNT=
rem set DEBUGTYPE=

rem	Uncomment the following lines to compile debug.

set CC=cl -W3 -Zp8 -G3d -Zi -Od -nologo
set DEBUGAMOUNT=-debug:full
set DEBUGTYPE=-debugtype:cv
