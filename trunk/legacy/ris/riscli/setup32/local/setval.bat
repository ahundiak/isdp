@echo off
rem Do not alter this SPC information: $Revision: 1.1.41.1 $
rem This program is sets environment variables. It requires no
rem editing by the user.
rem
rem
call setenv
if exist setreg.bat goto end
cd >wert.rlk
@perl reg.pl
@perl setcd.pl
call setreg

:end
