INCLUDE
#ifdef X11
$(XINC)
#endif
$(INGRHOME)/include
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
$(GRNUC)/src/co/plotco

#ifdef STANDALONE

EXEC
submit_plot

LINKLIB
$(GRNUC)/src/go/transgo/GRvaxconv.o
$(GRNUC)/src/go/transgo/GRvaxutils.o
$(GRNUC)/lib/utilmisc.a
#ifdef SUNOS5
$(GRNUC)/src/go/transgo/GUconv_utils.o
$(BS)/lib/bsma_sn5.a
$(BS)/lib/bsmd_sn5.a
-lUMS -lXFI -lXFS -lXt -lX11 -lm
#endif
#ifdef CLIX
$(BS)/lib/c100/bsma_ap.a
$(BS)/lib/c100/bsmd_ap.a
-lUMS -lforms_s -ltools_s -lm -lc_s
#endif

#else	/* not STANDALONE */

LIB
$(GRLIB)/lib/plotco.o

#endif

SOURCE
COchcmd.C
COfiledef.c
COiplot.C
COpfext.c
COpftype.c
COplotmisc.C
COpqinfo.C
COqprreq.C
COqscancel.C
COqsnotify.C
COqsupdate.C
COsizeplot.c
COspcvtsz.C
COspexecute.C
COspjobsts.C
COspnotify.C
COsppfname.C
COspszsc.C
COsplocal.C
COfrtype90.c
COplotlog.c
#ifdef STANDALONE
COspmain.c
#else
COpersrange.C
COcpnotify.C
COcrefunc.I
COgetfence.I
COploti.I
COrasplot.C
#endif
GRsetpfor.c
#ifdef IRIX
GRpopen.c
#endif
