@echo off
rem Do not alter this SPC information: $Revision: 1.7.41.1 $
rem This program is used to re-package the RIS product. It requires no
rem editing by the user.
rem
rem

@echo Starting to re-package RIS product
set _LOG=ris.log
@echo Starting mkris >%_LOG%

rem =====================================================
rem set the environment variables
rem =====================================================
call _DOIT _echo Setting environment variables
call setval

rem =====================================================
rem set my environment
rem =====================================================
rem RIS output shared version dir as in locris\shared\ris05.03
set _OUTPUT_SC=%_RIS_OUTPUT_DIR%\shared\ris%_RISVER%

rem RIS output shared dir as in locris\shared
set _OUTPUT_SHARED=%_RIS_OUTPUT_DIR%\shared

rem RIS output compress dir
set _OUTPUT_COMP=%_RIS_OUTPUT_DIR%\compress

rem RIS output delivery dir
set _OUTPUT_DELIV=%_RIS_OUTPUT_DIR%\deliv

rem =====================================================
rem make output sub dirs
rem =====================================================
call _DOIT _echo Making Localized Output Sub-directories
call _DOIT _md %_RIS_OUTPUT_DIR%
if not "%_ERROR%" =="" goto error

call _DOIT _md %_OUTPUT_SHARED%
if not "%_ERROR%" =="" goto error

call _DOIT _md %_OUTPUT_COMP%
if not "%_ERROR%" =="" goto error

call _DOIT _md %_OUTPUT_DELIV%
if not "%_ERROR%" =="" goto error

call _DOIT _md %_OUTPUT_SC%\config\%_LANG%\messages\src
if not "%_ERROR%" =="" goto error

call _DOIT _md %_OUTPUT_SC%\config\%_LANG%\forms\v5forms
if not "%_ERROR%" =="" goto error

call _DOIT _md %_OUTPUT_SC%\config\%_LANG%\help
if not "%_ERROR%" =="" goto error

call _DOIT _echo Deleting all files under %_OUTPUT_SHARED%
call _DOIT _deldir %_RIS_OUTPUT_DIR%\*.*

rem =====================================================
rem copy files to output area
rem =====================================================
call _DOIT _echo Copying shared files
call _DOIT _xcopysubs %_RISDP_DIR%\shared\*.* %_RIS_OUTPUT_DIR%\shared %_RIS_OUTPUT_DIR%\shared\*.*
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_RIS_DIR%\appinfo.txt %_OUTPUT_SC% %_OUTPUT_SC%\appinfo.txt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %WINDIR%\system32\msvcrt20.dll  %_OUTPUT_SC%\lib %_OUTPUT_SC%\lib\msvcrt20.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo setup files
call _DOIT _copy setup.lst %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\setup.lst
if not "%_ERROR%" =="" goto error
call _DOIT _copy risshare.exe %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\risshare.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy msdetstf.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\msdetstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy msuilstf.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\msuilstf.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo Copying Shamrock files
call _DOIT _copy c:\win32app\ingr\share\i9shamr1.dll %_RIS_OUTPUT_DIR%\shared %_RIS_OUTPUT_DIR%\shared\i9shamr1.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy c:\win32app\ingr\share\i9shamr2.dll %_RIS_OUTPUT_DIR%\shared %_RIS_OUTPUT_DIR%\shared\i9shamr2.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo Copying UMS files
call _DOIT _copy c:\win32app\ingr\share\i9ums1.dll %_RIS_OUTPUT_DIR%\shared %_RIS_OUTPUT_DIR%\shared\i9ums1.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy c:\win32app\ingr\share\i9ums2.dll %_RIS_OUTPUT_DIR%\shared %_RIS_OUTPUT_DIR%\shared\i9ums2.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy c:\win32app\ingr\share\i9risu.dll %_RIS_OUTPUT_DIR%\shared %_RIS_OUTPUT_DIR%\shared\i9risu.dll
if not "%_ERROR%" =="" goto error

call _DOIT _echo Copying localized files
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\setup.exe %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\setup.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\remove.exe  %_OUTPUT_SC%\bin %_OUTPUT_SC%\bin\remove.exe
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\mscomstf.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\mscomstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\msinsstf.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\msinsstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\msshlstf.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\msshlstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\rissc.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\rissc.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\setup\ingrstf.dll %_RIS_OUTPUT_DIR% %_RIS_OUTPUT_DIR%\ingrstf.dll
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\messages\*.txt %_OUTPUT_SC%\config\%_LANG%\messages\src\*.ttt  %_OUTPUT_SC%\config\%_LANG%\messages\src\*.ttt
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\messages\*.msg %_OUTPUT_SC%\config\%_LANG%\messages\*.mmm %_OUTPUT_SC%\config\%_LANG%\messages\*.mmm 
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\help\*.hlp %_OUTPUT_SC%\config\%_LANG%\help\*.hhh %_OUTPUT_SC%\config\%_LANG%\help\*.hhh
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\help\*.doc %_OUTPUT_SC%\config\%_LANG%\help\*.ddd %_OUTPUT_SC%\config\%_LANG%\help\*.ddd
if not "%_ERROR%" =="" goto error
call _DOIT _copy %_LOCAL_DIR%\%_RIS_IN%\forms\*.frm %_OUTPUT_SC%\config\%_LANG%\forms\v5forms\*.xxx %_OUTPUT_SC%\config\%_LANG%\forms\v5forms\*.xxx
if not "%_ERROR%" =="" goto error

call _DOIT _echo Substituting macros in files
call _DOIT _perlpass "s/!maj_min!/%_RISVER%/g" rissetup.lyt %_OUTPUT_SC%\rissetup.lyt rissetup.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _perlpass "s/!maj_min!/%_RISVER%/g" rislang.lyt %_OUTPUT_SC%\rislang1.lyt rislang.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _perlpass "s/!language!/%_LANG%/g" %_OUTPUT_SC%\rislang1.lyt %_OUTPUT_SC%\rislang.lyt %_OUTPUT_SC%\rislang1.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea %_OUTPUT_SC%\rislang.lyt  %_OUTPUT_SC%\rissetup.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea shamshr2.lyt %_OUTPUT_SC%\rissetup.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea shamshr2.lyt %_OUTPUT_SC%\rispack.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _perlpass "s/!maj_min!/%_RISVER%/g" rispack.lyt %_OUTPUT_SC%\rispack1.lyt rispack.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea %_OUTPUT_SC%\rislang.lyt  %_OUTPUT_SC%\rispack1.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _perlpass "s/!language!/%_LANG%/g" %_OUTPUT_SC%\rispack1.lyt %_OUTPUT_SC%\rispack.lyt %_OUTPUT_SC%\rispack1.lyt
if not "%_ERROR%" =="" goto error
set RIS_PROD_SHARE_DIR=%_OUTPUT_SC%
call _DOIT _perl addshar.pl  # adds the shar string and changes SECTION= in rispack.lyt
set RIS_PROD_SHARE_DIR=
if not "%_ERROR%" =="" goto error

rem =====================================================
rem Generate layout file
rem =====================================================
call _DOIT _echo Generate layout file
call _DOIT _echo Making risshare.lyt file in %_OUTPUT_SC% ...
call _DOIT _echofile HEADER~ %_OUTPUT_SC%\risshare.lyt
@echo HEADER> %_OUTPUT_SC%\risshare.lyt
call _DOIT _echofile SRC = %_RIS_OUTPUT_DIR%~~ %_OUTPUT_SC%\risshare.lyt
@echo SRC = %_RIS_OUTPUT_DIR%>> %_OUTPUT_SC%\risshare.lyt
call _DOIT _echofile WRITEABLE = 0 ~~ %_OUTPUT_SC%\risshare.lyt
@echo WRITEABLE = 0 >> %_OUTPUT_SC%\risshare.lyt
call _DOIT _echofile FILES~~ %_OUTPUT_SC%\risshare.lyt
@echo FILES>> %_OUTPUT_SC%\risshare.lyt
call _DOIT _typea locfiles.lyt %_OUTPUT_SC%\risshare.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _typea %_OUTPUT_SC%\rissetup.lyt %_OUTPUT_SC%\risshare.lyt
if not "%_ERROR%" =="" goto error
call _DOIT _echofile REMOVE~~ %_OUTPUT_SC%\risshare.lyt
@echo REMOVE>> %_OUTPUT_SC%\risshare.lyt

rem =====================================================
rem Generate Delivery Files
rem =====================================================
call _DOIT _echo Generate Delivery Files
call _DOIT _dsklayt2 %_OUTPUT_SC%\risshare.lyt %_OUTPUT_DELIV%\risshare.inf
if not "%_ERROR%" =="" goto error
goto ok

rem =====================================================
rem End Routine
rem =====================================================
:error
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@echo There was errors during this process
@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@echo error >riserr.err
goto quit

:ok
@echo Re-Packaging RIS Shared Component is complete
@echo Your delivery files are located in %_OUTPUT_DELIV%

:end
rem delete temporary files
@del/Q %_OUTPUT_SC%\risshare.lyt 2>NUL
@del/Q %_OUTPUT_SC%\rislang1.lyt 2>NUL
@del/Q %_OUTPUT_SC%\rispack1.lyt 2>NUL

rem clear the environment variables
set _OUTPUT_SC=
set _OUTPUT_SHARED=
set _OUTPUT_COMP=
set _OUTPUT_DELIV=

:quit
