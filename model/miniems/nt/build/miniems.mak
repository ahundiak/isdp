# Microsoft Visual C++ Generated NMAKE File, Format Version 2.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=Win32 Debug
!MESSAGE No configuration specified.  Defaulting to Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Win32 Release" && "$(CFG)" != "Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "miniems.mak" CFG="Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

################################################################################
# Begin Project
# PROP Target_Last_Scanned "Win32 Release"
MTL=MkTypLib.exe
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "WinRel"
# PROP BASE Intermediate_Dir "WinRel"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "WinRel"
# PROP Intermediate_Dir "WinRel"
OUTDIR=$(MINIEMSTARG)
INTDIR=$(MINIEMSTARG)

ALL : $(MINIEMSTARG)\bin\MINIEMS.DLL $(OUTDIR)/miniems.bsc

$(OUTDIR) : 
    if not exist $(OUTDIR)/nul mkdir $(OUTDIR)

# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE CPP /nologo /MT /W3 /GX /YX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /c
# ADD CPP /nologo /MD /W3 /GX /YX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "NT" /D "BASE_EMS" /FR /c
CPP_PROJ=/nologo /MD /W3 /GX /YX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "NT" /D "BASE_EMS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"miniems.pch" /Fo$(INTDIR)/ /c 
CPP_OBJS=.\WinRel/
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
BSC32_SBRS= \
	
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o$(OUTDIR)/"miniems.bsc" 

$(OUTDIR)/miniems.bsc : $(OUTDIR)  $(BSC32_SBRS)
LINK32=link.exe
DEF_FILE=$(MINIEMS)\nt\src\miniapi.def
LINK32_OBJS= \
	$(BSPLIBS)\UBSPM_EM.LIB \
	$(BSPLIBS)\UBSPM_MA.LIB \
	$(BSPLIBS)\UBSPM_MD.LIB \
	$(MINIEMSTARG)\lib\grmod.lib \
	$(MINIEMSTARG)\lib\int2d.lib \
	$(MINIEMSTARG)\lib\grquery.lib \
	$(MINIEMSTARG)\lib\tolfunc.lib \
	$(MINIEMSTARG)\lib\map.lib \
	$(MINIEMSTARG)\lib\sfcre.lib \
	$(MINIEMSTARG)\lib\bdryquery.lib \
	$(MINIEMSTARG)\lib\bdrycre.lib \
	$(MINIEMSTARG)\lib\sfmod.lib \
	$(MINIEMSTARG)\lib\bdrymod.lib \
	$(MINIEMSTARG)\lib\math.lib \
	$(MINIEMSTARG)\lib\grfunk.lib \
	$(MINIEMSTARG)\lib\util.lib \
	$(MINIEMSTARG)\lib\bdryint.lib \
	$(MINIEMSTARG)\lib\runtypes.lib \
	$(MINIEMSTARG)\lib\uom.lib \
	$(MINIEMSTARG)\lib\errdbg.lib \
	$(MINIEMSTARG)\lib\sfquery.lib \
	$(MINIEMSTARG)\lib\mdfunk.lib \
	$(MINIEMSTARG)\lib\OMuse.lib \
	$(MINIEMSTARG)\lib\dpb.lib \
	$(MINIEMSTARG)\lib\uomimp.lib \
	$(MINIEMSTARG)\lib\mdimp.lib \
	$(MINIEMSTARG)\lib\uomspec.lib \
	$(MINIEMSTARG)\lib\stubs.lib \
	$(MINIEMSTARG)\lib\grspec.lib \
	$(MINIEMSTARG)\lib\mdspec.lib \
	$(MINIEMSTARG)\lib\grimp.lib \
	$(OMTARG)\libOM.lib \
	$(MINIEMSTARG)\miniems\DllEntry.obj \
	$(MINIEMSTARG)\miniems\OMclassinit.obj \
	$(MINIEMSTARG)\miniems\OMapplinit.obj \
	$(MINIEMSTARG)\lib\profqry.lib \
	$(MINIEMSTARG)\lib\cvquery.lib \
	$(MINIEMSTARG)\lib\cvmod.lib
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /NOLOGO /SUBSYSTEM:windows /DLL /MACHINE:I386
# ADD LINK32 /NOLOGO /SUBSYSTEM:windows /DLL /MACHINE:I386 /FORCE /OUT:"$(MINIEMSTARG)\bin\MINIEMS.DLL" /IMPLIB:"$(MINIEMSTARG)\lib\MINIEMS.LIB"
# SUBTRACT LINK32 /PDB:none
LINK32_FLAGS=/NOLOGO /SUBSYSTEM:windows /DLL /INCREMENTAL:no\
 /PDB:$(MINIEMSTARG)/bin/"miniems.pdb" /MACHINE:I386 /DEF:"$(MINIEMS)\nt\src\miniapi.def"\
 /FORCE /OUT:"$(MINIEMSTARG)\bin\MINIEMS.DLL"\
 /IMPLIB:"$(MINIEMSTARG)\lib\MINIEMS.LIB" 

$(MINIEMSTARG)\bin\MINIEMS.DLL : $(OUTDIR)  $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "WinDebug"
# PROP BASE Intermediate_Dir "WinDebug"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "WinDebug"
# PROP Intermediate_Dir "WinDebug"
OUTDIR=$(MINIEMSTARG)
INTDIR=$(MINIEMSTARG)

ALL : $(MINIEMSTARG)\bin\MINIEMSD.DLL $(OUTDIR)/miniems.bsc

$(OUTDIR) : 
    if not exist $(OUTDIR)/nul mkdir $(OUTDIR)

# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE CPP /nologo /MT /W3 /GX /Zi /YX /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /c
# ADD CPP /nologo /MD /W3 /GX /Zi /YX /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "NT" /D "BASE_EMS" /FR /c
CPP_PROJ=/nologo /MD /W3 /GX /Zi /YX /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "NT" /D "BASE_EMS" /FR$(INTDIR)/ /Fp$(OUTDIR)/"miniems.pch" /Fo$(INTDIR)/\
 /Fd$(MINIEMSTARG)/bin/"miniems.pdb" /c 
CPP_OBJS=.\WinDebug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
BSC32_SBRS= \
	
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o$(OUTDIR)/"miniems.bsc" 

$(OUTDIR)/miniems.bsc : $(OUTDIR)  $(BSC32_SBRS)
LINK32=link.exe
DEF_FILE=$(MINIEMS)\nt\src\miniapi.def
LINK32_OBJS= \
	$(BSPLIBS)\UBSPM_EM.LIB \
	$(BSPLIBS)\UBSPM_MA.LIB \
	$(BSPLIBS)\UBSPM_MD.LIB \
	$(MINIEMSTARG)\lib\grimp.lib \
	$(MINIEMSTARG)\lib\uom.lib \
	$(MINIEMSTARG)\lib\grfunk.lib \
	$(MINIEMSTARG)\lib\errdbg.lib \
	$(MINIEMSTARG)\lib\mdfunk.lib \
	$(MINIEMSTARG)\lib\grspec.lib \
	$(MINIEMSTARG)\lib\mdimp.lib \
	$(MINIEMSTARG)\lib\grmod.lib \
	$(MINIEMSTARG)\lib\dpb.lib \
	$(MINIEMSTARG)\lib\int2d.lib \
	$(MINIEMSTARG)\lib\mdspec.lib \
	$(MINIEMSTARG)\lib\sfcre.lib \
	$(MINIEMSTARG)\lib\grquery.lib \
	$(MINIEMSTARG)\lib\sfmod.lib \
	$(MINIEMSTARG)\lib\runtypes.lib \
	$(MINIEMSTARG)\lib\uomimp.lib \
	$(MINIEMSTARG)\lib\bdryquery.lib \
	$(MINIEMSTARG)\lib\tolfunc.lib \
	$(MINIEMSTARG)\lib\map.lib \
	$(MINIEMSTARG)\lib\bdrycre.lib \
	$(MINIEMSTARG)\lib\stubs.lib \
	$(MINIEMSTARG)\lib\bdrymod.lib \
	$(MINIEMSTARG)\lib\bdryint.lib \
	$(MINIEMSTARG)\lib\math.lib \
	$(MINIEMSTARG)\lib\OMuse.lib \
	$(MINIEMSTARG)\lib\uomspec.lib \
	$(MINIEMSTARG)\lib\util.lib \
	$(MINIEMSTARG)\lib\sfquery.lib \
	$(OMTARG)\libOM.lib \
	$(MINIEMSTARG)\miniems\DllEntry.obj \
	$(MINIEMSTARG)\miniems\OMclassinit.obj \
	$(MINIEMSTARG)\miniems\OMapplinit.obj \
	$(MINIEMSTARG)\lib\profqry.lib \
	$(MINIEMSTARG)\lib\cvquery.lib \
	$(MINIEMSTARG)\lib\cvmod.lib
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /NOLOGO /SUBSYSTEM:windows /DLL /DEBUG /MACHINE:I386
# ADD LINK32 /NOLOGO /SUBSYSTEM:windows /DLL /DEBUG /MACHINE:I386 /FORCE /OUT:"$(MINIEMSTARG)\bin\MINIEMSD.DLL" /IMPLIB:"$(MINIEMSTARG)\lib\MINIEMSD.LIB"
# SUBTRACT LINK32 /PDB:none
LINK32_FLAGS=/NOLOGO /SUBSYSTEM:windows /DLL /INCREMENTAL:yes\
 /PDB:$(MINIEMSTARG)/bin/"miniems.pdb" /DEBUG /MACHINE:I386\
 /DEF:"$(MINIEMS)\nt\src\miniapi.def" /FORCE\
 /OUT:"$(MINIEMSTARG)\bin\MINIEMSD.DLL"\
 /IMPLIB:"$(MINIEMSTARG)\lib\MINIEMSD.LIB" 

$(MINIEMSTARG)\bin\MINIEMSD.DLL : $(OUTDIR)  $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Group "Source Files"

################################################################################
# Begin Source File

SOURCE=$(MINIEMS)\nt\src\miniapi.def
# End Source File
# End Group
################################################################################
# Begin Group "LIBRARIES"

################################################################################
# Begin Source File

SOURCE=$(BSPLIBS)\UBSPM_EM.LIB
# End Source File
################################################################################
# Begin Source File

SOURCE=$(BSPLIBS)\UBSPM_MA.LIB
# End Source File
################################################################################
# Begin Source File

SOURCE=$(BSPLIBS)\UBSPM_MD.LIB
# End Source File
# End Group
################################################################################
# Begin Group "LIBRARIES DEBUG"

################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grimp.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\uom.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grfunk.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\errdbg.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\mdfunk.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grspec.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\mdimp.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grmod.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\dpb.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\int2d.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\mdspec.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\sfcre.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grquery.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\sfmod.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\runtypes.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\uomimp.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdryquery.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\tolfunc.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\map.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdrycre.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\stubs.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdrymod.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdryint.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\math.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\OMuse.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\uomspec.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\util.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\sfquery.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(OMTARG)\libOM.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\miniems\DllEntry.obj

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\miniems\OMclassinit.obj

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\miniems\OMapplinit.obj

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\profqry.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\cvquery.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\cvmod.lib

!IF  "$(CFG)" == "Win32 Release"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "Win32 Debug"

!ENDIF 

# End Source File
# End Group
################################################################################
# Begin Group "LIBRARIES RELEASE"

################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grmod.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\int2d.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grquery.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\tolfunc.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\map.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\sfcre.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdryquery.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdrycre.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\sfmod.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdrymod.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\math.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grfunk.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\util.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\bdryint.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\runtypes.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\uom.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\errdbg.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\sfquery.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\mdfunk.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\OMuse.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\dpb.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\uomimp.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\mdimp.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\uomspec.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\stubs.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grspec.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\mdspec.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\grimp.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(OMTARG)\libOM.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\miniems\DllEntry.obj

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\miniems\OMclassinit.obj

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\miniems\OMapplinit.obj

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\profqry.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\cvquery.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=$(MINIEMSTARG)\lib\cvmod.lib

!IF  "$(CFG)" == "Win32 Release"

!ELSEIF  "$(CFG)" == "Win32 Debug"

# PROP Exclude_From_Build 1

!ENDIF 

# End Source File
# End Group
# End Project
################################################################################
