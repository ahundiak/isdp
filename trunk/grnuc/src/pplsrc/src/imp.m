SRC
$(GRNUC)/src/pplsrc/src

SOURCE
cidynhandler.I
cilchandler.C
COcidgnop.S
COcidgnopi.I
cifiget.I
ciisentry.I
cisetargs.I
cifcnval.I
cipush.C
cidebug.I
cierrno.C
ciextsym.C
super_ci.S
super_cii.I
ci.S
cii.I
COci.S
COcii.I
cilocate.I
ciexec.I
cievent.C
M_cidb.C
cidb.C
ciwind.C
cichannel.C
cifunc.C
ciforms.I
cidiv.C
ciclone.I
cimess.C
cireadrtree.C
ciio.C
cisymb.C 
cioper.C
ciextern.C
ciexinstr.C
cisizeof.C
cifstack.C
#ifdef clipper
CLIP_fcall.s
#endif
#ifdef sparc
SOL_fcall.s
#endif
#ifdef mips
MIPS_fcall.s
#endif
#ifdef INTELx
X86_fcall.s
#endif

#if 0
DEPLIB
$(GRLIB)/lib/cicom.o
#endif
        
#ifndef NT
LIB
$(GRLIB)/lib/ci.o
#else
ARCHIVE
$(GRLIB)/lib/ci.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(UMS)/include
$(LIBXC)/include
$(FORMS)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

#ifdef SUNOS5
DOPT
_POSIX_SOURCE=1
#endif
