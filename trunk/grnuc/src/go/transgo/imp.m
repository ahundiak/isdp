SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
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

SRC
$(GRNUC)/src/go/transgo

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/transgo.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/transgo.o
#else
ARCHIVE
$(GRLIB)/lib/transgo.lib
#endif


#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

SOURCE
GUotype5lv3.C
GUplotsymbol.I
GUplotIGDS.I
GUplottype5.C
GUplotctb.C
GUbsfuncs.C
GUio.C
GUloadhdr.C
GUmaps.C
GUrad50.C
GUquaternion.C
GUchkovrflow.c
GUiwinminmax.c
GRadd_name.C
GRfontusrlnk.C
GRpoly_fill.C
GUcreateIGDS.I
GUotype2.I
GUotype3.C
GUotype4.C
GUotype5lv1.C
GUotype6.C
GUotype717.C
GUotype9.C
GUotype15.C
GUotype16.C
GUotype21.C
GUotype24.C
GUotype25.C
GUotype26.C
GUotype27.C
GUotype28.C
GUonamedvws.C
GUnormknot.C
GUonvinit.C
GUotxtjust.C
GUotxtesc.I
GUprocsymbol.I
GUsplitcurve.C
GUcpxhand.I
GUcreatevw.I
GUichkigds.C
GUitxtjust.C
GUichkcellib.C
GUrangeupd.I
GUsetmetactb.c
GUtxtsubstr.c
GUgetfontnum.I
GUgetnum.c
GUgetsymlev.C
GUigemapigds.C
GUotype1214.I
GUotype5lv10.C
GRattrLink.c
GRvaxconv.c
GUchangenum.C
#ifdef BIG_ENDIAN
GUconv_utils.C
#endif
GRconvtype.c
GUotype5lv9.I
GRvaxutils.c
