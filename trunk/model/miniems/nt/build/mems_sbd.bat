@echo off
echo --------------------------------------------------------------------
echo -------------------------------------------------------------------- 
echo                          MINIEMS 
echo --------------------------------------------------------------------
echo -------------------------------------------------------------------- 

@if not exist %MINIEMS%\stubs\alloca.h copy %MINIEMS%\nt\src\alloca.h %MINIEMS%\stubs

 echo _______________________________
 echo DIRECTORY:%MINIEMS%\api\bdrycre
 cd    %MINIEMS%\api\bdrycre 
 call  %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\bdrycre\makefile
 cd    %MINIEMSTARG%\api\bdrycre
 nmake %NMAKEOPT%

 echo _______________________________
 echo DIRECTORY:%MINIEMS%\api\bdryint
 cd %MINIEMS%\api\bdryint 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\bdryint\makefile
 cd %MINIEMSTARG%\api\bdryint 
 nmake %NMAKEOPT%

 echo _______________________________
 echo DIRECTORY:%MINIEMS%\api\bdrymod
 cd %MINIEMS%\api\bdrymod 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\bdrymod\makefile
 cd %MINIEMSTARG%\api\bdrymod 
 nmake %NMAKEOPT%  
 
 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\bdryquery
 cd %MINIEMS%\api\bdryquery 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\bdryquery\makefile
 cd %MINIEMSTARG%\api\bdryquery
 nmake %NMAKEOPT% 
 
 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\cvmod
 cd %MINIEMS%\api\cvmod
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\cvmod\makefile
 cd %MINIEMSTARG%\api\cvmod
 nmake %NMAKEOPT%  
  
 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\cvquery
 cd %MINIEMS%\api\cvquery 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\cvquery\makefile
 cd %MINIEMSTARG%\api\cvquery
 nmake %NMAKEOPT%  

 echo _______________________________
 echo DIRECTORY:%MINIEMS%\api\dpb
 cd %MINIEMS%\api\dpb
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\dpb\makefile
 cd %MINIEMSTARG%\api\dpb
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\errdbg
 cd %MINIEMS%\api\errdbg 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\errdbg\makefile
 cd %MINIEMSTARG%\api\errdbg
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\grmod
 cd %MINIEMS%\api\grmod
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\grmod\makefile
 cd %MINIEMSTARG%\api\grmod
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\grquery
 cd %MINIEMS%\api\grquery 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\grquery\makefile
 cd %MINIEMSTARG%\api\grquery
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\int2d
 cd %MINIEMS%\api\int2d 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\int2d\makefile
 cd %MINIEMSTARG%\api\int2d
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\map
 cd %MINIEMS%\api\map 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\map\makefile
 cd %MINIEMSTARG%\api\map
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\math
 cd %MINIEMS%\api\math
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\math\makefile
 cd %MINIEMSTARG%\api\math
 nmake %NMAKEOPT%
 
 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\OMuse
 cd %MINIEMS%\api\OMuse 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\OMuse\makefile
 cd %MINIEMSTARG%\api\OMuse
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\profqry
 cd %MINIEMS%\api\profqry 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\profqry\makefile
 cd %MINIEMSTARG%\api\profqry
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\runtypes
 cd %MINIEMS%\api\runtypes 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\runtypes\makefile
 cd %MINIEMSTARG%\api\runtypes
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\sfcre
 cd %MINIEMS%\api\sfcre
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\sfcre\makefile
 cd %MINIEMSTARG%\api\sfcre
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\sfmod
 cd %MINIEMS%\api\sfmod
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\sfmod\makefile
 cd %MINIEMSTARG%\api\sfmod
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\sfquery
 cd %MINIEMS%\api\sfquery 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\sfquery\makefile
 cd %MINIEMSTARG%\api\sfquery
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\tolfunc
 cd %MINIEMS%\api\tolfunc 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\tolfunc\makefile
 cd %MINIEMSTARG%\api\tolfunc
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\uom
 cd %MINIEMS%\api\uom
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\uom\makefile
 cd %MINIEMSTARG%\api\uom
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\api\util
 cd %MINIEMS%\api\util 
 call %MINIEMS%\nt\build\grmakemake funk.m %MINIEMSTARG%\api\util\makefile
 cd %MINIEMSTARG%\api\util
 nmake %NMAKEOPT% 

 rem Moved all files in %MINIEMS%\exnuc to %MINIEMS%\stubs directory
 rem 
 rem echo _________________________________
 rem echo DIRECTORY:%MINIEMS%\exnuc
 rem cd %MINIEMS%\exnuc
 rem call %MINIEMS%\nt\build\grmakemake exnuc.m %MINIEMSTARG%\exnuc\makefile
 rem cd %MINIEMSTARG%\exnuc
 rem nmake %NMAKEOPT%

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\funk\grnuc
 cd %MINIEMS%\funk\grnuc 
 call %MINIEMS%\nt\build\grmakemake funk.m  %MINIEMSTARG%\funk\grnuc\makefile
 cd %MINIEMSTARG%\funk\grnuc
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\funk\model
 cd %MINIEMS%\funk\model 
 call %MINIEMS%\nt\build\grmakemake funk.m  %MINIEMSTARG%\funk\model\makefile
 cd %MINIEMSTARG%\funk\model
 nmake %NMAKEOPT% 
 
 echo _________________________________
 echo DIRECTORY:%MINIEMS%\imp\grnuc
 cd %MINIEMS%\imp\grnuc 
 call %MINIEMS%\nt\build\grmakemake imp.m  %MINIEMSTARG%\imp\grnuc\makefile
 cd %MINIEMSTARG%\imp\grnuc
 nmake %NMAKEOPT% 
 
 echo _________________________________
 echo DIRECTORY:%MINIEMS%\imp\model
 cd %MINIEMS%\imp\model 
 call %MINIEMS%\nt\build\grmakemake imp.m  %MINIEMSTARG%\imp\model\makefile
 cd %MINIEMSTARG%\imp\model
 nmake %NMAKEOPT% 

 echo _________________________________
 echo DIRECTORY:%MINIEMS%\imp\uom
 cd %MINIEMS%\imp\uom 
 call %MINIEMS%\nt\build\grmakemake imp.m  %MINIEMSTARG%\imp\uom\makefile
 cd %MINIEMSTARG%\imp\uom
 nmake %NMAKEOPT% 

 echo ______________________________
 echo DIRECTORY %MINIEMS%\spec\grnuc
 cd %MINIEMS%\spec\grnuc 
 call  %MINIEMS%\nt\build\grmakemake spec.m  %MINIEMSTARG%\spec\grnuc\makefile
 cd %MINIEMSTARG%\spec\grnuc
 nmake %NMAKEOPT% 

 echo ______________________________
 echo DIRECTORY %MINIEMS%\spec\model
 cd %MINIEMS%\spec\model 
 call %MINIEMS%\nt\build\grmakemake spec.m  %MINIEMSTARG%\spec\model\makefile
 cd %MINIEMSTARG%\spec\model
 nmake %NMAKEOPT% 

 echo ______________________________
 echo DIRECTORY %MINIEMS%\spec\uom
 cd %MINIEMS%\spec\uom
 call %MINIEMS%\nt\build\grmakemake spec.m  %MINIEMSTARG%\spec\uom\makefile
 cd %MINIEMSTARG%\spec\uom
 nmake %NMAKEOPT% 

 echo ______________________________
 echo DIRECTORY %MINIEMS%\stubs
 cd %MINIEMS%\stubs 
 call %MINIEMS%\nt\build\grmakemake stubs.m  %MINIEMSTARG%\stubs\makefile
 cd %MINIEMSTARG%\stubs
 nmake %NMAKEOPT%
					   
 echo ______________________________
 echo DIRECTORY %MINIEMS%\miniEMS
 cd %MINIEMS%\miniEMS
 @if not exist %MINIEMS%\miniEMS\DllEntry.c	copy %MINIEMS%\nt\src\DllEntry.c %MINIEMS%\miniEMS\DllEntry.c
 call %MINIEMS%\nt\build\grmakemake %MINIEMS%\nt\src\ominit.m %MINIEMSTARG%\miniems\ominit.mf
 cd %MINIEMSTARG%\miniems
 nmake %NMAKEOPT% /f ominit.mf

 cd %MINIEMS%\nt\build
 if "%BUILD_TYPE%" == "RELEASE" nmake /f miniems.mak CFG="Win32 Release"
 if "%BUILD_TYPE%" == "DEBUG"   nmake /f miniems.mak CFG="Win32 Debug"

@if not exist %MINIEMS%\miniEMS\main.m copy %MINIEMS%\nt\src\main.m %MINIEMS%\miniEMS\main.m
 echo ______________________________
 echo DIRECTORY %MINIEMS%\miniEMS
 cd %MINIEMS%\miniEMS 
 call %MINIEMS%\nt\build\grmakemake main.m  %MINIEMSTARG%\miniEMS\main.mf
 cd %MINIEMSTARG%\miniEMS
 nmake %NMAKEOPT% /f main.mf
	

:END
