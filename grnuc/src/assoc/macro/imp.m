INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/src/assoc/include_priv
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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

SRC
$(GRNUC)/src/assoc/macro

SOURCE
ACcpx.S
ACcpxi.I
ACcpx_loc.I
ACcpx_tmp.I
ACinit.I
ACfunct.I
dir_macro.I
ACfor_text.I

ACcpx_defn.S
ACcpx_defni.I
ACcpx_def_tm.I

ACcomplex.S
ACcomplexi.I

ACmacro_hdr.S
ACmacro_hdri.I

ACmacro_defn.S
ACm_dn_place.I
ACm_dn_util.I
ACm_dn_const.I
ACm_dn_min.I
ACm_dn_sym.I
ACm_option.I

ACsym.S
ACsym_cpx.I
ACsym_util.I

ACroot.S
ACrooti.I

ACexpand.S
ACexpandi.I

ACcreate.S
ACcreatei.I

ACpretend.S
ACpretendi.I
ACpretendin.S
ACpretendini.I
ACpretdef.S
ACpretdefi.I
ACpreroot.S
ACprerooti.I

ACpretgo.S
ACpretgoi.I

ACtmp_defn.S
ACtmp_defni.I

ACregexp.C

#ifndef NT
LIB
$(GRLIB)/lib/macro.o
#else
ARCHIVE
$(GRLIB)/lib/macro.lib
#endif
