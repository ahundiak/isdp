@REM Do not alter this SPC information: $Revision: 1.1.54.1 $
@echo off
set KEYWORDS_FILE=keywords

for %%i in (3 5 7 11 13 17 19 23 29 31 37 41 47 53 59 61 67 71 111 311) do mkhshtb -a %%i -t 405 < %KEYWORDS_FILE%

set KEYWORDS_FILE=

echo on
