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
$(EXNUC)/om/src

SOURCE
#if defined(sparc) || defined(mips)
OMdict.C
OMport.C
#endif
OMClusteri.I
OMClusterr.I
OMFiledOSi.I
OMFiledOSr.I
OMGroupi.I
OMISOdiri.I
OMISOi.I
OMMOSDOSi.I
OMMOSDi.I
OMOSCOi.I
OMObjSpacei.I
OMTagConi.I
OMTagi.I
OMTransOSi.I
OMUNIXcode.C
OMbcluster.C
OMbcreate.C
OMbdelete.C
OMbdump.C
OMbinsert.C
OMblkmv.C
OMbransear.C
OMbsearch.C
OMbtreei.I
OMchansupp1.C
OMclasses.C
OMclasssupp.C
OMconnect.C
OMconstruct.C
OMextent.C
OMglobaldata.C
OMifrtree.C
OMindexi.I
OMinitialize.C
OMintercept.C
OMobjid.C
OMobjspace.C
OMordersend.C
OMpms.C
OMppgd.C
OMprodem.C
OMrecognize.C
OMrtree3df.C
OMrtreehis.C
OMrtreei.I
OMsend.C
OMslotCntrl.C
OMsmmalloc.C
OMsupport.C
OMtags.C
OMvararray.C
Rooti.I
OMSupGroupi.I
OMarch.C
OMsibling.C
#ifdef NT
OMmetas.c
#endif

ARCHIVE
#ifndef NT
$(TARGET)/$(LIBLOC)/libOM.a
#else
$(TARGET)/libOM.lib
#endif

DEPLIB
#if defined (NT)
$(TARGET)\om\spec\omspec.lib
$(TARGET)\om\IGRdir\lib\DIbtreelib.lib
$(TARGET)\om\IGRdir\lib\GRouplib.lib
$(TARGET)\om\IGRdir\lib\DIrectorylib.lib
#else
$(TARGET)/om/spec/omspec.o
$(TARGET)/om/IGRdir/lib/DIbtreelib.o
$(TARGET)/om/IGRdir/lib/GRouplib.o
$(TARGET)/om/IGRdir/lib/DIrectorylib.o
$(TARGET)/om/src/OMmetas.o
#endif
#	if defined (CLIX)
$(TARGET)/om/src/OMfloatcvt.o
#	endif

SPEC
$(EXNUC)/spec
$(EXNUC)/om/spec

INCLUDE
$(EXNUC)/include
$(EXNUC)/om/include
$(EXNUC)/trans/include
$(LIBXC_INC_PATH)

DEFINE
CCDEF

POST_SPECIAL

opl = $(BASE)/bin/opl

$(TARGET)/om/src/OMmetas.o: $(TARGET)/om/spec/omspec.o
	@echo "\t$(TARGET)/om/src/OMmetas.o"
	$(opl) -m $(TARGET)/om/spec/omspec.o
	$(CCDEF) -c OMmetas.c

#	if defined (CLIX)
$(TARGET)/om/src/OMfloatcvt.o: $(SRC)/OMfloatcvt.s
	@echo "\t$(TARGET)/om/src/OMfloatcvt.o"
	@cd $(SRC); \
	as $(ASOPT) -o $(TARGET)/om/src/OMfloatcvt.o $(SRC)/OMfloatcvt.s
#	endif

END_SPECIAL

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp
