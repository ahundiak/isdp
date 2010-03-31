@rem USER NEEDS TO SET THE FOLLOWING ENV VARIABLES

set MSVC=c:\msvc20
set BS=g:\BSPMATH
set OM=g:\OM
set MINIEMS=g:\MINIEMS
set BSPLIBS=Z:\MATH\SRC\UBSPMTH\DEV

@rem Comment one of the following sets to build Release/Debug build 

@rem set BUILD_TYPE=RELEASE
@rem set MINIEMSTARG=%MINIEMS%\WinRel
@rem set OMTARG=%OM%\WinRel
@rem set LOGFILE=%MINIEMSTARG%\Build.log
@rem title=MINIEMS RELEASE

set BUILD_TYPE=DEBUG
set MINIEMSTARG=%MINIEMS%\WinDebug
set OMTARG=%OM%\WinDebug
set LOGFILE=%MINIEMSTARG%\010896.log
title=MINIEMS DEBUG


@rem Don't edit below this line
set MINIEMS_USER_ENV=Yes
call %MINIEMS%\nt\build\mnemsntenv.bat



