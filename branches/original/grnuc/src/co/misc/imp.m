SRC
$(GRNUC)/src/co/misc

#ifdef NT
ARCHIVE
$(GRLIB)/lib/misc.lib
#else
LIB
$(GRLIB)/lib/misc.o
#endif

SOURCE
CObrlni.I
CObuildev.C
CObuildpt.C
COcheckcv.C
COconstr.I
COcurptfrm.C
COdisact.C
COerase.I
COgetcmdi.I
COmpnspyc.C
COnisetcst.C
COnisetvar.C
COnishovar.C
COnspolyc.C
COpjptvwpl.I
COprojev.I
COrclpnti.I
COsglpick.C
DYmvalvc.I
GRrapapnd.I
GRcleannot.c
GRcolbtn.C
GRconfirm.C
GRcustmenu.C
GRdelaybtn.C
GRdisassoc.C
GRfindbtn.c
GRfindfile.c
GRgetbarmenu.c
GRgetcmds.C
GRgettoken.C
GRingrconf.c
GRisform.c
GRmenunot.c
GRmenupath.c
GRmkwforms.c
GRmodelmode.C
GRposform.C
GRputkybf.C
GRstdisbtn.C
GRstopsign.C
GRswaptask.C
GRswitch.c
GRudir.C
GRvalbutton.C
GRvwvolbrln.C
GRwindec.c
GRchkvalrng.c
GRdimcleanup.I
GRremdups.I
GRremnan.I
#if (!(defined SUNOS5) && !(defined IRIX))
COdmvi.I
GRlicense.C 
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
#ifdef X11
$(XINC)
#endif
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#ifndef SUNOS5
/usr/ip32/lictools
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
