CC
$(COMPILER)

SOURCE

UTck_file.c
UTstring.c
UTvax_conv.c
UTsun_conv.c

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/src/fontbuilder/fconv/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
/usr/include/X11
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/fontbuilder/fconv/UT_src


#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/UT.a 
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/UT.lib 
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
