SRC
$(MODEL)/ve/src/util_imp
LIB
util_imp.o
COPT
-ga
CC
acc -knr
SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(BS)/include
$(BS)/include/prototypes
$(BS)/include/prototypes
$(MODEL)/include
$(MODEL)/proto_include
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
OPP
$(EXTARG)/bin/opp
OMCPP
$(EXTARG)/bin/omcpp
SOURCE
VEbatch_imp.I
VEclass_sol.I
VEclassify.I
VEclip_diag.I
VEedge_types.I
VEestab.I
VEfence.I
VEget_env.I
VEget_geom.I
VEgetrefleve.I
VEin_solid.I
VElink.I
VEmake_ve.I
VEmult_trim.I
VEset_trim.I
VEsoos.I
VEsplt_class.I
VEtrim.I
VExsect_imp.I
