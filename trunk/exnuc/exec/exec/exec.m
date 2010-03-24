SRC
$(EXNUC)/exec/exec

SOURCE
exfork.C
exsys.C
execi.I
execj.I
exwfi.I
global_clasi.I
super_cmdi.I
file_test.C
set_paths.C
mod_type.C
invis_funcs.I
exgetptr.C
exintr.C
extran.C
srch_path.C
igestartup.I
exsharem.I
#ifndef NT
exipc.C
exrececho.C
journal.c
#endif
exdload.C
EXfile_form.C

SPEC
$(EXNUC)/spec

INCLUDE
$(EXNUC)/include
$(LIBXC_INC_PATH)
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(XFORMSDP_INC_PATH)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

#ifdef IRIX5
OPPFLAGS
-I$(SRC)
-D_MIPS_ISA=_MIPS_ISA_MIPS2
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

SOURCE=exprod
EXproduct.C

ARCHIVE=exprod
$(TARGET)/$(LIBLOC)/libexprod.a
