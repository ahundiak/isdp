@echo off

pcio -ivmud -f target.cpio
if not errorlevel 1 goto next1
echo Error in cpio of target.cpio
goto error

:next1
pcio -ivmud -f source.cpio
if not errorlevel 1 goto next2
echo Error in cpio of source.cpio
goto error

:next2
copy pcio.exe bin
goto success

:error
echo ERROR
goto end

:success
echo SUCCESS
goto end

:end
rm pcio.exe target.cpio source.cpio
