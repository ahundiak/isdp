SRC 
$(GRNUC)/src/pplsrc/cci

SOURCE
ciy.y
cil.l
cioptions.c
cibasictype.c
ciprepro.c
ciactions.c
ciistype.c
ciregister.c
cimmgr.c
ciconstant.c
ciinstr.c
ciparse.c
cierrmess.c
ciglobals.c
ciutil.c
citree.c
cistruct.c
citypedef.c
citypinit.c
cienum.c
citypes.c
ciop.c
cilabel.c
cidocmd.c
cistrop.c
ciusrfcn.c
cisysfcn.c
ciextfcn.c
ciswitch.c
ciusropr.c
cisymtab.c
ciimp.c
#	if defined(sun)
SUN_libPW.c
#	endif

DEPLIB
$(GRLIB)/lib/cicom.o
#	if defined(sun)
$(GRLIB)/src/pplsrc/cci/SUNregex/libregexp.a
#	endif

#if defined(sgi)
EXECOPT
-L $(INGRHOME)/lib
#endif

LINKLIB
-ly
#if defined(clipper)
-lxc
-lPW
-lc_s
#endif
#if defined(sparc)
-lxcmalloc
-lxc
#endif
#if defined(sgi)
-lPW
-lxcmalloc
-lxc
#endif
#if defined(INTEL)
-lxc
#endif

EXEC
$(GRLIB)/bin/cci

INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include/xc
$(GRTARG)/src/pplsrc/cci
$(GRNUC)/src/pplsrc/cci
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
$(GRNUC)/src/pplsrc/cci/SUNregex

POST_SPECIAL
cil.c:	$(SRC)/cil.l
	@echo "\n\t$(SRC)/cil.l -> cil.c\n"
	@lex $(SRC)/cil.l
	@/bin/mv lex.yy.c cil.c

ciy.c ciy.h:	$(SRC)/ciy.y
	@echo "\n\t$(SRC)/ciy.y -> ciy.c\n"
	@echo "\t>>> The 4 shift/reduce conflicts are handled <<<"
	@yacc -vd $(SRC)/ciy.y
	@/bin/mv y.tab.h ciy.h
	@/bin/mv y.tab.c ciy.c
	@/bin/rm y.output

#	if defined(sun)
$(GRLIB)/src/pplsrc/cci/SUNregex/libregexp.a:
	@cd ./SUNregex; make libregexp.a
#	endif
END_SPECIAL
