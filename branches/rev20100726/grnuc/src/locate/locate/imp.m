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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/locate/locate

#ifdef NT
ARCHIVE
$(GRLIB)/lib/locate.lib
#else
LIB
$(GRLIB)/lib/locate.o
#endif

SOURCE
GRLocInfo.I
GRfindmod.C
GRlcbllocate.C
GRlclocate.C
GRlcptlocate.C
GRlcquery.C
GRmdaddwrng.I
GRmdnbrwrng.I
GRmdremove.I
GRmdremwrng.I
GRrtconn.I
GRrtdebug.I
GRrtutil.I
GRrtdpass.I
LCaccact.C
LCaddclass.I
LCandclass.C
LCblptloc.I
LCcheck.C
LCcheckact.C
LCcheckid.C
LCcheckon.C
LCclasschek.I
LCcriteria.C
LCcselect.C
LCcursor.I
LCdisplay.I
LCevaction.C
LCevent.I
LCevselect.C
LCgetinfo.I
LCgetparms.I
LCgsadd.C
LCgsclean.I
LCgsend.I
LCgsinit.I
LClayer.I
LClocate.I
LClocproc.I
LCnmlocate.I
LCobjproj.C
LCpost.C
LCpostid.C
LCptlocact.C
LCquery.I
LCselect.I
LCskew.C
