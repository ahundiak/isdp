SPEC
$EXNUC/exec/spec
$EXNUC/om/spec
$GRNUC/co/spec
$GRNUC/go/spec
$GRNUC/display/spec
$GRNUC/font/spec
$GRNUC/grio/spec
$GRNUC/locate/spec
$GRNUC/grdpb/spec

INCLUDE
$(INGRHOME)/include
$EXNUC/include
$GRNUC/include
$BS/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

#ifndef IDRAW

#ifndef NT
LIB
$GRNUC/go/lib/transgo.o
#else
ARCHIVE
$GRNUC/go/lib/transgo.lib
#endif


VERSION
$GRNUC/go/lib/transgo.o 1.2

#else
ARCHIVE
$GRNUC/go/lib/transgo.a

VERSION
$GRNUC/go/lib/transgo.a 1.2
#endif

OPP
$EXTARG/bin/opp

OMCPP
$EXTARG/bin/omcpp

CC
cc

SOURCE

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
flt32tovax.c
GUiwinminmax.c
GRadd_name.C
GRpoly_fill.C
GUcreateIGDS.I
GUotype2.I
GUotype3.C
GUotype4.C
GUotype5lv1.C
GUotype5lv3.C
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
GUitxtfract.c
GUichangefnt.c
GUgetfontnum.I
GUgetnum.c
GUgetsymlev.C
GUigemapigds.C
GUchangenum.c
