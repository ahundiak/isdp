COPT
#ifdef NT

#ifdef _DEBUG
-W3 -Zp8 -Gd -nologo -Od -Zi -MTd
#else /* _DEBUG */
-W3 -Zp8 -Gd -nologo -O2
#endif /* _DEBUG */

#else /* NT */
-DBASE_EMS
#endif /* NT */

SRC
$(EXNUC)/om/test

#ifndef NT

#if defined(BIG_ENDIAN)
TARGET
OMTdrv.x
class_defns
#else
TARGET
OMTdrv.x
#endif

#endif /* NT */

SOURCE
ResA.S
ResAi.I
ResB.S
ResBi.I
A.S
Ai.I
B.S
Bi.I
C.S
Ci.I
D.S
Di.I
Q.S
Qi.I
OMTdrv.C
OMTdumprel.C
#ifndef NT
OMTdumpR3df.C
OMTab.C
OMTconnect.C
OMTwild.C
OMTrange.C
OMTmovech.C
OMTcopych.C
OMTsibling.C
OMTorder.C
OMTvararray.C
OMTisosend.C
OMTdynamic.C
OMTdynamic2.C
OMTdynamic3.C
OMTeyeso.C
OMTpr.S
OMTpri.I
OMTprodem.C
OMTroos.C
OMTrecog.C
OMTsupgrp.C
OMTos.C
OMTboolean.C
OMTclust.C
OMTgrptst.C
OMTvla.C
OMTsend.C
OMTsend51.C
OMTswap.C
OMTcdtime1.C
OMTcdtime2.C
OMTintrcpt.C
OMTbstring.C
OMTbint.C
OMTr2di.C
OMTsk2di.C
OMTtree.I
OMTsk3dd.C
#else
OMTdrvz.C
OMapplinit.C
btreestubs.c
#endif /* NT */

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/include
$(LIBXC_INC_PATH)
#if defined X11
$(X11_INC_PATH)
#endif
#ifdef XGL
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif


SPEC
$(EXNUC)/spec

DEPLIB
#ifndef NT
$(TARGET)/$(LIBLOC)/libOM.a
$(LIBXC_LIB_PATH)/libxc.a
$(TARGET)/$(LIBLOC)/libexprod.a
#else
$(TARGET)/libOM.lib
$(TARGET)/spec/exnucspec.lib
#endif /* NT */

SUFFIXES
.C .I .S .c .o .x

DEFINE
CCDEF
OMCPPDEF

#ifndef NT
POST_SPECIAL
 #
 #    TEST makefile
 #
 #    main targets:: 
 #
 #         AllTests:  Tthis target is generally used to run all std tests.
 #                    It will recursively call itself to perform the makes.
 #                    One side effect is that after a test has successfully
 #                     run - there will be a zero block .x file to keep track
 #                     of which tests have been run.
 #
 #      OMT<test>.x: This target is used to make a specific test.
 #
 #
 #      TESTER:      This target is used in the recursive call to specify that
 #                    the test should be built, run, and checked against .std
 #                    file for differences
 #
 #
 #      TESTER_NEW:  This target is used just as TESTER but it is for tests
 #                    which do not have a .std file (no output is a good
 #                    result)
 #
 #      TEST:        This target is used to make - but NOT run a std test.
 #                    One may enter this target via the action macro on the
 #                    command line. e.g.  make -r OMTab.x action=TEST
 #
 #
 #      Because some tests do not use the standard .S and .I files (A.S,B.S...)
 #       they had to be entered as a specific target in order to override the
 #	 macros (specs and impls).  Also they needed a unique classinit file
 #	other than the standard (OMTstdz.C).
 #
 #      Any of the macros may be overridden by inputing them on the make
 #	command line.  Be sure to group via double quotes if more than one
 #	file is to be macroized. e.q. specs="my.S my2.S my3.S"
 #

action   = TESTER
opl      = $(BASE)/bin/opl
ztest    = OMTstdz

#if defined(CLIX)
linklibs = -lg $(LIBXC_LIB_PATH)/libxcmalloc.a $(LIBXC_LIB_PATH)/libxc.a -lix -lmath -lbsd
#elif defined(SUNOS)
linklibs = $(LIBXC_LIB_PATH)/libxcmalloc.a $(LIBXC_LIB_PATH)/libxc.a -lm
#elif defined(IRIX)
linklibs = $(LIBXC_LIB_PATH)/libxcmalloc.a $(LIBXC_LIB_PATH)/libxc.a -lm
#endif

omlib    = $(TARGET)/$(LIBLOC)/libOM.a
#ifdef SUNOS55
sun55lib = -lsunmath
#endif
#ifdef SUNOS
sunstublib = -lfpstub
#endif

specs = \
	ResA.o \
	ResB.o \
	A.o \
	B.o \
	C.o \
	D.o \
	Q.o

impls = $(specs:.o=i.o)

class_d = $(specs:.o=.d)

DDP = $(BASE)/bin/ddp
CCD = $(BASE)/bin/ccd
CTD = $(BASE)/bin/ctd
DDPOPT = $(OPPFLAGS)

supobjs = \
	OMTdumprel.o \
	OMapplinit.o

tests = \
	OMTab.C \
	OMTconnect.C \
	OMTwild.C \
	OMTrange.C \
	OMTmovech.C \
	OMTcopych.C \
	OMTsibling.C \
	OMTorder.C \
	OMTvararray.C \
	OMTisosend.C \
	OMTdynamic.C \
	OMTdynamic2.C \
	OMTdynamic3.C \
	OMTeyeso.C \
	OMTprodem.C \
	OMTroos.C \
	OMTrecog.C \
	OMTsupgrp.C

newtests = \
	OMTos.C \
	OMTboolean.C \
	OMTclust.C \
	OMTgrptst.C \
	OMTvla.C \
	OMTsend.C \
	OMTsend51.C \
	OMTswap.C \
	OMTcdtime1.C \
	OMTcdtime2.C \
	OMTintrcpt.C

treetests = \
	OMTbstring.C \
	OMTbint.C \
	OMTr2di.C \
	OMTsk2di.C \
	OMTr3dd.C \
	OMTsk3dd.C

AllTests: $(tests:.C=.x) $(newtests:.C=.x) $(treetests:.C=.x)

$(ztest).C: $(specs)
	$(opl) -o $(ztest).C  $(specs)

TEST:: $(ftest).o $(ztest).o $(specs) $(impls) $(supobjs) $(omlib)
	@echo "************************************************************"
	@echo "*********************************** makeing $(ftest).x"
	@echo "************************************************************"
	$(CCDEF) $(EXECOPT) -o $(ftest).x $(ftest).o $(specs) $(impls) \
         $(supobjs) $(omlib) $(TARGET)/$(LIBLOC)/libexprod.a $(ztest).o $(linklibs) $(sun55lib) $(sunstublib)

TESTER:: $(ftest).o $(ztest).o $(specs) $(impls) $(supobjs)
	@echo "************************************************************"
	@echo "*********************************** makeing $(ftest).x"
	@echo "************************************************************"
	$(CCDEF) $(EXECOPT) -o $(ftest).x $(ftest).o $(specs) $(impls) \
         $(supobjs) $(omlib) $(ztest).o $(linklibs)

TESTER_NEW:: $(ftest).o $(ztest).o $(specs) $(impls) $(supobjs)
	@echo "************************************************************"
	@echo "*********************************** makeing $(ftest).x"
	@echo "************************************************************"
	$(CCDEF) $(EXECOPT) -o $(ftest).x $(ftest).o $(specs) $(impls) \
         $(supobjs) $(omlib) $(ztest).o $(linklibs)

class_defns: $(class_d)
	cat $(class_d) > class_defns
	rm -f v.* *.

$(class_d):
	@if [ "$(WHY)" ]; then echo "\t$@: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$? -> $(@F:.d=)."; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(DDP) $(DDPOPT) $(IPATH) $?"; fi; \
	 $(DDP) $(DDPOPT) $(IPATH) $?; \
	 if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=). -> $(@F).c"; \
         else \
             echo "\t$(CCD) $(@F:.d=) > $(@F).c"; \
         fi; \
	 $(CCD) $(@F:.d=) > $(@F).c; \
	 if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$(@F).c -> $(@F:.d=)"; \
	 else \
	     echo "\t$(CCDEF) $(EXECOPT) -o $(@F:.d=) $(@F).c"; \
	 fi; \
	 $(CCDEF) $(EXECOPT) -o $(@F:.d=) $(@F).c; \
         if test -z "$(VERBOSE_RULES)"; \
         then \
             echo "\t$(@F:.d=) -> $(@F)"; \
         else \
             echo "\t./$(@F:.d=)"; \
         fi; \
         ./$(@F:.d=); \
	 if [ "$(COPT)" != "-g" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\tremoving $(@F).c $(@F:.d=)"; \
	     else \
	         echo "\trm $(@F).c $(@F:.d=)"; \
	     fi; \
	     rm $(@F).c $(@F:.d=); \
	 else \
	     if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@F).c $(@F:.d=)"; fi; \
	 fi
	 @echo

ResA.d:	$(SRC)/ResA.S
ResB.d:	$(SRC)/ResB.S
A.d: $(SRC)/A.S
B.d: $(SRC)/B.S
C.d: $(SRC)/C.S
D.d: $(SRC)/D.S
Q.d: $(SRC)/Q.S

OMTsend.x: $(specs) $(impls) timea.o timeai.o
	$(MAKE) -r TESTER_NEW ftest=$* \
	ztest=OMTsendz \
	omlib=$(omlib) \
	specs="$(specs) timea.o" \
	impls="$(impls) timeai.o"

dyn_specs=clsa.o clsb.o clsc.o clse.o
dyn_impls=$(dyn_specs:.o=i.o)
OMTdynamic.x: $(dyn_specs) $(dyn_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTdynamicz \
	omlib=$(omlib) \
	specs="$(dyn_specs)" \
	impls="$(dyn_impls)"

OMTdynamic2.x: $(dyn_specs) $(dyn_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTdynamicz \
	omlib=$(omlib) \
	specs="$(dyn_specs)" \
	impls="$(dyn_impls)"

OMTdynamic3.x: $(dyn_specs) $(dyn_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTdynamicz \
	omlib=$(omlib) \
	specs="$(dyn_specs)" \
	impls="$(dyn_impls)"

pro_specs=clsa.o clsb.o clsc.o clse.o parenta.o parentb.o clsd.o clsf.o \
          clsg.o clsq.o clsr.o dump_btree.o OMTpb.o
pro_impls=$(pro_specs:.o=i.o)
OMTprodem.x: $(pro_specs) $(pro_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTprodemz \
	omlib=$(omlib) \
	specs="$(pro_specs)" \
	impls="$(pro_impls)"

rec_specs=clsj.o sub_clsj.o clsd.o sub_clsb.o clsa.o clsb.o clsc.o clse.o \
          clsf.o clsg.o clsh.o sub_clsh.o
rec_impls=$(rec_specs:.o=i.o)
OMTrecog.x: $(rec_specs) $(rec_impls)
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTrecogz \
	omlib=$(omlib) \
	specs="$(rec_specs)" \
	impls="$(rec_impls)"

testa.o : \
	$(SRC)/testa.S \
	$(SRC)/testa.c

testai.o : \
	$(SRC)/testai.I

testb.o : \
	$(SRC)/testb.S \
	$(SRC)/testb.c

testbi.o : \
	$(SRC)/testbi.I

timea.o : \
	$(SRC)/timea.S \
	$(SRC)/timea.c

timeai.o : \
	$(SRC)/timeai.I

clsa.o : \
	$(SRC)/clsa.S \
	$(SRC)/clsa.c

clsai.o : \
	$(SRC)/clsai.I

clsb.o : \
	$(SRC)/clsb.S \
	$(SRC)/clsb.c

clsbi.o : \
	$(SRC)/clsbi.I

clsc.o : \
	$(SRC)/clsc.S \
	$(SRC)/clsc.c

clsci.o : \
	$(SRC)/clsci.I

clsd.o : \
	$(SRC)/clsd.S \
	$(SRC)/clsd.c

clsdi.o : \
	$(SRC)/clsdi.I

clse.o : \
	$(SRC)/clse.S \
	$(SRC)/clse.c

clsei.o : \
	$(SRC)/clsei.I

clsf.o : \
	$(SRC)/clsf.S \
	$(SRC)/clsf.c

clsfi.o : \
	$(SRC)/clsfi.I

clsg.o : \
	$(SRC)/clsg.S \
	$(SRC)/clsg.c

clsgi.o : \
	$(SRC)/clsgi.I

clsh.o : \
	$(SRC)/clsh.S \
	$(SRC)/clsh.c

clshi.o : \
	$(SRC)/clshi.I

clsj.o : \
	$(SRC)/clsj.S \
	$(SRC)/clsj.c

clsji.o : \
	$(SRC)/clsji.I

clsk.o : \
	$(SRC)/clsk.S \
	$(SRC)/clsk.c

clski.o : \
	$(SRC)/clski.I

clsl.o : \
	$(SRC)/clsl.S \
	$(SRC)/clsl.c

clsli.o : \
	$(SRC)/clsli.I

clsm.o : \
	$(SRC)/clsm.S \
	$(SRC)/clsm.c

clsem.o : \
	$(SRC)/clsmi.I

clsq.o : \
	$(SRC)/clsq.S \
	$(SRC)/clsq.c

clsqi.o : \
	$(SRC)/clsqi.I

clsr.o : \
	$(SRC)/clsr.S \
	$(SRC)/clsr.c

clsri.o : \
	$(SRC)/clsri.I

sub_clsb.o : \
	$(SRC)/sub_clsb.S \
	$(SRC)/sub_clsb.c

sub_clsbi.o : \
	$(SRC)/sub_clsbi.I

sub_clsh.o : \
	$(SRC)/sub_clsh.S \
	$(SRC)/sub_clsh.c

sub_clshi.o : \
	$(SRC)/sub_clshi.I

sub_clsj.o : \
	$(SRC)/sub_clsj.S \
	$(SRC)/sub_clsj.c

sub_clsji.o : \
	$(SRC)/sub_clsji.I

parenta.o : \
	$(SRC)/parenta.S \
	$(SRC)/parenta.c

parentai.o : \
	$(SRC)/parentai.I

parentb.o : \
	$(SRC)/parentb.S \
	$(SRC)/parentb.c

parentbi.o : \
	$(SRC)/parentbi.I

dump_btree.o : \
	$(SRC)/dump_btree.S \
	$(SRC)/dump_btree.c

dump_btreei.o : \
	$(SRC)/dump_btreei.I

OMTpb.o : \
	$(SRC)/OMTpb.S \
	$(SRC)/OMTpb.c

OMTpbi.o : \
	$(SRC)/OMTpbi.I

class1.o : \
	$(SRC)/class1.S \
	$(SRC)/class1.c

class1i.o : \
	$(SRC)/class1i.I

class2.o : \
	$(SRC)/class2.S \
	$(SRC)/class2.c

class2i.o : \
	$(SRC)/class2i.I

class3.o : \
	$(SRC)/class3.S \
	$(SRC)/class3.c

class3i.o : \
	$(SRC)/class3i.I

class4.o : \
	$(SRC)/class4.S \
	$(SRC)/class4.c

class4i.o : \
	$(SRC)/class4i.I

class5.o : \
	$(SRC)/class5.S \
	$(SRC)/class5.c

class5i.o : \
	$(SRC)/class5i.I

OMTboolean.x: testa.o testai.o testb.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTbooleanz \
	omlib=$(omlib) \
	specs="testa.o testb.o" \
	impls="testai.o"

OMTos.x: $(specs) $(impls)
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTstdz \
	omlib=$(omlib) \
	specs="$(specs)" \
	impls="$(impls)"

51_specs=$(specs) class1.o class2.o class3.o class4.o class5.o
51_impls=$(impls) class1i.o
OMTsend51.x: $(51_specs) $(51_impls)
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTsend51z \
	omlib=$(omlib) \
	specs="$(51_specs)" \
	impls="$(51_impls)"

OMTcdtime1.x: testa.o testai.o testb.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTbooleanz \
	omlib=$(omlib) \
	specs="testa.o testb.o" \
	impls="testai.o"

OMTcdtime2.x: testa.o testai.o testb.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTbooleanz \
	omlib=$(omlib) \
	specs="testa.o testb.o" \
	impls="testai.o"

OMTclust.x: g.o gi.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTclustz \
	omlib=$(omlib) \
	specs="g.o" \
	impls="gi.o"

OMTgrptst.x: g.o gi.o OMTgrptsti.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTclustz \
	omlib=$(omlib) \
	specs="g.o" \
	impls="gi.o OMTgrptsti.o"

OMTintrcpt.x: g.o gi.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTclustz \
	omlib=$(omlib) \
	specs="g.o" \
	impls="gi.o"

OMTswap.x: c1.o c1i.o OMTswaptsti.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTswapz \
	omlib=$(omlib) \
	specs="c1.o" \
	impls="c1i.o OMTswaptsti.o"

OMTvla.x: vla.o vlai.o
	$(MAKE) -r  TESTER_NEW ftest=$* \
	ztest=OMTvlaz \
	omlib=$(omlib) \
	specs="vla.o" \
	impls="vlai.o"

OMTbstring.x: OMTpr.o OMTpri.o OMTpb.o OMTpbi.o A.o Ai.o B.o Bi.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTbstringz \
	omlib=$(omlib) \
	specs="OMTpr.o OMTpb.o A.o B.o" \
	impls="OMTpri.o OMTpbi.o Ai.o Bi.o"

OMTbint.x: OMTpr.o OMTpri.o OMTpb.o OMTpbi.o A.o Ai.o B.o Bi.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTbstringz \
	omlib=$(omlib) \
	specs="OMTpr.o OMTpb.o A.o B.o" \
	impls="OMTpri.o OMTpbi.o Ai.o Bi.o"

OMTr2di.x: $(specs) $(impls) OMTpr.o OMTpri.o OMTdumpR2di.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTr2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR2di.o" \
	specs="$(specs) OMTpr.o" \
	impls="$(impls) OMTpri.o"

OMTsk2di.x: OMTpr.o OMTpri.o OMTdumpR2di.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTsk2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR2di.o" \
	specs="OMTpr.o" \
	impls="OMTpri.o"

OMTtree.x: OMTtree.o $(supobjs) $(specs) $(impls) OMTdumpR3df.o $(omlib)
	$(MAKE) TEST ftest=OMTtree ztest=OMTtreez \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR3df.o" \
	specs="$(specs)" \
	impls="$(impls)"

OMTsk3dd.x: $(specs) $(impls) OMTpr.o OMTpri.o OMTdumpR3dd.o
	$(MAKE) -r  TESTER ftest=$* \
	ztest=OMTr2diz \
	omlib=$(omlib) \
	supobjs="$(supobjs) OMTdumpR3dd.o" \
	specs="$(specs) OMTpr.o" \
	impls="$(impls) OMTpri.o"

OMapplinit.o :
	$(opl) -a
	$(OMCPPDEF) OMapplinit.C OMapplinit.c
	$(CCDEF) -c OMapplinit.c

OMTdrv.x : OMTdrv.o $(specs) $(impls) $(supobjs) $(omlib)
	$(MAKE) TEST ftest=OMTdrv ztest=OMTdrvz \
        omlib="$(omlib)" \
        specs="$(specs)" \
        impls="$(impls)" 

.C.x:
	$(MAKE) -r $(action) ftest=$* ztest=$(ztest) \
        omlib="$(omlib)" \
        specs="$(specs)" \
        impls="$(impls)"
END_SPECIAL

#endif /* NT */

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

#ifdef NT

EXEC
$(TARGET)/bin/OMTdrv.exe

#endif 
