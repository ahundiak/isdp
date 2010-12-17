SOURCE=UMSCOMP
UMScomp.c


SPECIAL
COMLIBS=\
$(UMS)/lib/$(CURRENT_PROC_TYPE)/libUMS.a


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

all:\
	umscomp

END_SPECIAL

POST_SPECIAL

umscomp: $(UMSCOMP)
	@echo
	$(CC) $(COPT) $(DOPT) $(MOPT) -o umscomp $(IPATH) $(UMSCOMP) $(LIBS)
	@echo
	@ls -ls umscomp
	@echo


promote:
	@if [ ! -d $(UMS)/bin ] ;\
	then \
	  mkdir -p $(UMS)/bin ;\
	fi	
	@-rm -f $(UMS)/bin/umscomp ; \
	ln umscomp  $(UMS)/bin/umscomp

END_SPECIAL

INCLUDE
$(UMS)/include
$(ANSI_INCLUDE)
/usr/include/xc
/usr/include
