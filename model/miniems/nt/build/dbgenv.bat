call %EXNUC%\build\exnucntenv.bat
set CC=cl -Tp -W3 -Zp8 -G3d -Zi -Od -nologo

rem set DOPT1=-DWIN32 -DNT -D_NTWIN -D_WINDOWS -D_X86_ 
set ECHO=%BASE%\bin\execho
set COPT=-DBSNTDLL -DWIN32 -D_WINDOWS -D_MCBS -D_AFXDLL

set INGRHOME=nohome

set DEBUGAMOUNT=
set DEBUGTYPE=
set DEBUGAMOUNT=-debug:full
set DEBUGTYPE=-debugtype:cv

