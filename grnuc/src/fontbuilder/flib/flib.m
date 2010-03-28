SOURCE
sunconv.c
create.c
io.c
list.c
flib.c
fltvaxto32.c
EXproduct.c

SRC
$(GRNUC)/src/fontbuilder/flib

#ifdef SUNOS_2.4
EXECOPT
-L /usr/5lib
#endif

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/src/fontbuilder/flib
$(EXNUC)/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

LINKLIB
#ifdef CLIX
-lm
-ltools_s
-lbsd
-lc_s
-lxc
#endif
#if defined ( SUNOS ) || defined ( SUNOS5 )
-lm
-ltools_s
-lbsd
-lc_s
-lxc
#endif
#ifdef IRIX
-lm
-ltools_s
-lbsd
-lc
-lxc
#endif

EXEC
$(GRLIB)/src/fontbuilder/bin/GRFlib

CC
$(COMPILER)

COPT
$(COMPOPT)

