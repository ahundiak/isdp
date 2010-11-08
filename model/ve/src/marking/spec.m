SRC
$(MODEL)/ve/src/marking

LIB
$(MDTARG)/src_lib/ve_marking.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec

INCLUDE
$(UMS)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(BS)/include
$(BS)/include/prototypes
$(MODEL)/include
$(MODEL)/proto_include
$(MODEL)/hsurf/include

OPP
$(EXTARG)/bin/opp
OMCPP

$(EXTARG)/bin/omcpp
        
SOURCE
VEmk_lpedges.I
VEmk_rules.I
VEmk_surf.I
VEmk_xhatch.I
VEmk_cvpt.c
VEmk_natural.c
VEmk_part.c
VEmk_shrpmsh.c
