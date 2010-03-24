@echo off
if not "%LOGFILE%" == "" goto next
echo log.sh: error LOGFILE variable not set
goto end

:next
%1 %2 %3 %4 %5 %6 %7 %8 %9 2>&1 | %OM%\nt\tee -a %LOGFILE%
goto end

:end
