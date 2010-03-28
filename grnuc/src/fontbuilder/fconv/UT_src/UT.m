
#ifndef NT
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/UT.a
#else
ARCHIVE
$(GRLIB)/src/fontbuilder/fconv/lib/UT.lib
#endif

SRC
$(GRNUC)/src/fontbuilder/fconv/UT_src

SOURCE
UTsun_conv.c
UTbanner.c
UTck_file.c
UTck_path.c
UTcopyfile.c
UTdirEmpty.c
UTgetfile.c
UTlabel.c
UTstring.c
UTvax_conv.c

CC
$(COMPILER)

COPT
$(COMPOPT)

SPEC

INCLUDE
$(INGRHOME)/include
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/fontbuilder/fconv/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
