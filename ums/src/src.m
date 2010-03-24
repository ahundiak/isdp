SOURCE
COMPcall.c
COMPmsg.c
COMPread.c
COMPwrit.c
getopt.c
UMSfile.c
UMSgbkey.c
UMSgbnum.c
UMSinitm.c
UMSkeyby.c
UMSmsgco.c
UMSmsgfm.c
UMSnumby.c
UMSrbkey.c
UMSrbnum.c

ARCHIVE
libUMS.a

SPECIAL
COMLIBS=

#if defined(clipper)
CLIPPERLIBS=\
-lmath \
-lc_s
ANSI_INCLUDE=/usr/include
#else
CLIPPERLIBS=
#endif


#if defined(SUNOS4)
SUNLIBS= \
-lm \
/usr/5lib/libc.a \
-lc
ANSI_INCLUDE=/usr/sunc/lang/SC1.0/ansi_include
#endif

#if defined(SUNOS5)
SUNLIBS= \
-lm

ANSI_INCLUDE=/usr/include
#endif

#if defined(CLIX) || defined(IRIX) || defined(SCO)
SUNLIBS=
#endif

#if defined(SCO)
SCOLIBS= \
-lc

ANSI_INCLUDE=/usr/include
#endif

#if defined(mips)
MIPSLIBS= \
-lm \
-lc
#else
MIPSLIBS=
#endif

LIBS=$(COMLIBS) $(CLIPPERLIBS) $(SUNLIBS) $(MIPSLIBS) $(SCOLIBS)

END_SPECIAL

POST_SPECIAL


ptypes:
	@trap '' 2 3 15;\
	#time MkPtypes.sh;\
	time chkproto.sh;\
	trap -

promote:
	@if [ ! -d $(UMS)/lib/$(CURRENT_PROC_TYPE) ] ;\
	then \
	  mkdir -p $(UMS)/lib/$(CURRENT_PROC_TYPE) ;\
	fi	
	@-rm -f $(UMS)/lib/$(CURRENT_PROC_TYPE)/libUMS.a ;\
	  ln libUMS.a  $(UMS)/lib/$(CURRENT_PROC_TYPE)/libUMS.a

END_SPECIAL

INCLUDE
$(UMS)/include
$(ANSI_INCLUDE)
/usr/include/xc
/usr/include
