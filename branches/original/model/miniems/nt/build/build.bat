@echo off

if not "%MINIEMS_USER_ENV%" == "" goto test1
echo Please edit and execute %MINIEMS%\NT\BUILD\USER.BAT first.
goto ERROR

:test1
if not "%OM%" == "" goto test2
echo error OM variable not set
goto ERROR

:test2
if exist %OM% goto test3
echo Directory %OM% does not exist
goto ERROR

:test3
if not "%BS%" == "" goto test4
echo error BS variable not set
goto ERROR

:test4
if exist %BS% goto test5
echo Directory %BS% does not exist
goto ERROR

:test5
if not "%MINIEMS%" == "" goto test6
echo error MINIEMS variable not set
goto ERROR

:test6
if exist %MINIEMS% goto test7
echo Directory %MINIEMS% does not exist
goto ERROR

:test7
if not "%OMTARG%" == "" goto test8
echo OMTARG variable not set
goto ERROR

:test8
if exist %OMTARG% goto test9
echo Directory %OMTARG% does not exist
goto ERROR

:test9
if not "%MINIEMSTARG%" == "" goto test10
echo MINIEMSTARG variable not set
goto ERROR

:test10
if not "%MSVC%" == "" goto test11
echo MSVC variable not set
goto ERROR

:test11
if exist %MSVC% goto test12
echo Directory %MSVC% does not exist
goto ERROR

:test12

:BUILD
call %MINIEMS%\nt\build\mnemsntenv.bat
call %MINIEMS%\nt\build\mems_sbd.bat

time < nul | find "current"
date < nul | find "current"

goto END

:ERROR
echo ERROR

:END
