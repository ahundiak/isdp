@echo off
rem Do not alter this SPC information: $Revision: 1.2.42.1 $
rem This program is used to actually process  the commands from the
rem localization programs. It requires no editing by the user.
rem
rem

set _ERROR=
set _COMMAND=
set _SOURCE=
set _DEST=
set _CHECK_FILE=

if %1==_md goto _MAKE_DIR
if %1==_echo goto _ECHO
if %1==_copy goto _COPY
if %1==_deldir goto _DEL_DIR
if %1==_xcopysubs goto _XCOPY_SUBS
if %1==_perlpass goto _PERL_PASS_THRU
if %1==_typea goto _TYPE_APPEND
if %1==_perl goto _PERL
if %1==_dsklayt2 goto _DISKLAY
if %1==_echofile goto _ECHO_FILE
if %1==_passthru goto _PASS_THRU
goto BAD_COMMAND

:_MAKE_DIR
set _COMMAND=perl dirmk.pl
set _SOURCE=%2
if not "%_DEBUG%" =="" echo %_COMMAND% %_SOURCE%
echo %_COMMAND% %_SOURCE% >>%_LOG%
%_COMMAND% %_SOURCE% >>%_LOG%
set _CHECK_FILE=%_SOURCE%
goto _CHECKIT

:_ECHO
@echo ***** %2 %3 %4 %5 %6 %7 %8 %9 ***** >>%_LOG%
if not "%_DEBUG%" =="" echo ***** %2 %3 %4 %5 %6 %7 %8 %9 *****
goto end

:_COPY
set _COMMAND=copy
set _SOURCE=%2
set _DEST=%3
set _CHECK_FILE=%4
if not "%_DEBUG%" =="" echo %_COMMAND% %_SOURCE% %_DEST%
echo [%_COMMAND% %_SOURCE% %_DEST%] >>%_LOG%
copy %_SOURCE% %_DEST% >>%_LOG%
goto _CHECKIT

:_DEL_DIR
if not "%_DEBUG%" =="" echo del /s /q %2 %3 %4 %5 %6 %7 %8 %9
echo del /s /q %2 %3 %4 %5 %6 %7 %8 %9 >>%_LOG%
del /s /q %2 %3 %4 %5 %6 %7 %8 %9 >nul
goto end

:_XCOPY_SUBS
set _COMMAND=xcopy
set _SOURCE=%2
set _DEST=%3
set _CHECK_FILE=%4
if not "%_DEBUG%" =="" echo %_COMMAND% %_SOURCE% %_DEST% /s
echo [%_COMMAND% %_SOURCE% %_DEST% /s] >>%_LOG%
xcopy /i /e /f %_SOURCE% %_DEST% /s >>%_LOG%
goto _CHECKIT

:_PERL_PASS_THRU
set _COMMAND=perl
set _SOURCE=%3
set _DEST=%4
set _CHECK_FILE=%5
if not "%_DEBUG%" =="" echo perl -p -e %2 %3 ~%4 
echo [perl -p -e %2 %3 ~%4] >>%_LOG%
perl -p -e %2 %3 >%4
goto _CHECKIT

:_TYPE_APPEND
set _COMMAND=type
set _SOURCE=%2
set _DEST=%3
set _CHECK_FILE=%2
if not "%_DEBUG%" =="" echo %_COMMAND% %_SOURCE% ~~%_DEST%
echo [%_COMMAND% %_SOURCE% ~~%_DEST%] >>%_LOG%
type %_SOURCE% >>%_DEST% 2>>%_LOG%
goto _CHECKIT

:_PERL
set _COMMAND=perl
set _SOURCE=%2
set _CHECK_FILE=%2
if not "%_DEBUG%" =="" echo %_COMMAND% %_SOURCE% %_DEST%
echo [%_COMMAND% %_SOURCE% %_DEST%] >>%_LOG%
perl %_SOURCE% >>%_LOG%
goto _CHECKIT

:_DISKLAY
set _COMMAND=dsklayt2
set _SOURCE=%2
set _DEST=%3
set _CHECK_FILE=%3
if not "%_DEBUG%" =="" echo %_COMMAND% %_SOURCE% %_DEST% /k12 /f /c%_OUTPUT_COMP% /d%_OUTPUT_DELIV% /w1
echo [%_COMMAND% %_SOURCE% %_DEST% /f /c%_OUTPUT_COMP% /d%_OUTPUT_DELIV% /w1] >>%_LOG%
%_COMMAND% %_SOURCE% %_DEST% /v /f /c%_OUTPUT_COMP% /d%_OUTPUT_DELIV% /w1 >>%_LOG%
goto _CHECKIT

:_ECHO_FILE
@echo echo %2 %3 %4 %5 %6 %7 %8 %9 >>%_LOG%
if not "%_DEBUG%" =="" echo echo %2 %3 %4 %5 %6 %7 %8 %9
goto end

:_PASS_THRU
if not "%_DEBUG%" =="" echo %2 %3 %4 %5 %6 %7 %8 %9
echo [%2 %3 %4 %5 %6 %7 %8 %9] >>%_LOG%
%2 %3 %4 %5 %6 %7 %8 %9 >>%_LOG%
goto end

:_CHECKIT
call _CHKIT %_CHECK_FILE%
if "%_ERROR%" =="" goto end
echo %_COMMAND% %_SOURCE% %_DEST% failed >>%_LOG%
echo %_COMMAND% %_SOURCE% %_DEST% failed
goto end


:BAD_COMMAND
@echo IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
@echo bad command %1 %2 %3 %4 %5 %6 %7 %8 %9
@echo IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
set _ERROR=1
goto end

:end
