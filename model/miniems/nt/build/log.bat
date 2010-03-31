@echo off
if not "%LOGFILE%" == "" goto next
echo log: error LOGFILE variable not set
goto end

:next
%1 %2 %3 %4 %5 %6 %7 %8 %9 2>&1 | %OMTARG%\bin\tee -a %LOGFILE%
goto end

:end
