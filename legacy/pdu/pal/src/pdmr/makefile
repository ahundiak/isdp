.SUFFIXES: .c .o

SRC = .

IPATH =  \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(FPAL)/include \
	-I$(PDU)/include \
	-I$(PDM)/include \
	-I$(NFM)/include

CC = acc -g
COPT = $(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1 -DRISV$(RISVER)

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMgetstat.o \
	PDMrsrch.o \
	PDMrsaclist.o \
	PDMlistatr.o \
	PDMsrcatr.o \
	PDMgetcat.o \
	PDMrsac.o \
	PDMunionatr.o \
	CID.o

lex_objects = conditionl.o

yacc_objects = conditiony.o

objects = \
	$(c_objects)  \
	$(lex_objects) \
	$(yacc_objects) 


# src group targets

objects_TARGET = objects

$(objects_TARGET): $(objects) 

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMgetstat.o : \
	$(SRC)/PDMgetstat.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMrsrch.o : \
	$(SRC)/PDMrsrch.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMsrcatr.o : \
	$(SRC)/PDMsrcatr.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMrsaclist.o : \
	$(SRC)/PDMrsaclist.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMlistatr.o : \
	$(SRC)/PDMlistatr.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMgetcat.o : \
	$(SRC)/PDMgetcat.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMrsac.o : \
	$(SRC)/PDMrsac.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

PDMunionatr.o : \
	$(SRC)/PDMunionatr.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/SQLerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/FI.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALpdmr.h \
	$(FPAL)/include/PALpdmrpro.h

CID.o : \
	$(SRC)/CID.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/malloc.h \
	/usr/include/stand.h \
	/usr/include/math.h

conditiony.o : conditiony.y
	yacc -dvlt conditiony.y
	mv y.tab.h conditiony.h
	sed -e 's/yy/CID_yy/g' y.tab.c > out
	mv out conditiony.c
	acc -c $(COPT) $(MOPT) conditiony.c

conditionl.o : conditionl.l
	lex -v conditionl.l
	sed -e '1 i\
#include "conditiony.h"' lex.yy.c > out
	sed -f condsedcom out > conditionl.c	
	rm out
	acc -c $(COPT) $(MOPT) conditionl.c

$(c_objects):
	@if [ "$(WHY)" ]; then echo "\t$(@): $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$(SRC)/$(@:.o=.c) -> $(@)"; \
	 fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; \
	 then \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\tcd $(@D)"; \
	     fi; \
	     cd $(@D); \
	 fi; \
	 if [ -n "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)"; \
	 fi; \
	 $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)
	@echo 

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c
	@echo 

DIR = $(PDU)/config/dload/prod/pdu/pal/src/pdmr

PDUpalpdmr.s:	$(objects_TARGET)
	@echo "Making PDUpalpdmr.s for reactive loading."
	@echo
	@echo "Moving conditionl.o and conditiony.o to extension .X"
	@mv conditionl.o conditionl.X
	@mv conditiony.o conditiony.X
	@-mkstubs -o PDUpalpdmr.s -t"Pdu:pdu/pal/src/pdmr" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pal/src/pdmr directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubppdmr.o
	@echo "Moving conditionl.X and conditiony.X to extension .o"
	@mv conditionl.X conditionl.o
	@mv conditiony.X conditiony.o
	@echo "Copying conditionl.o and conditiony.o to $(PDU)/config/dload/init."
	@cp conditionl.o $(PDU)/config/dload/init
	@cp conditiony.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubppdmr.o from PDUpalpdmr.s"
	@as -o PDUstubppdmr.o PDUpalpdmr.s

FASTstart:
	@rm -f opp.list cc.list

FASTfinish:
	@if [ "$(FAST)" ]; \
	 then \
	     if [ -s opp.list ]; \
	     then \
	         echo "\topping files"; \
	         if [ -n "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\t$(ocfiles) $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) `cat opp.list`"; \
	         fi; \
	         $(ocfiles) $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) `cat opp.list`; \
	         sed -e 's/\.[IS]/.c/' <opp.list >>cc.list; \
	     else \
	         echo "\tnothing to opp"; \
	     fi; \
	     if [ -s cc.list ]; \
	     then \
	         echo "\tcompiling files"; \
	         if [ -n "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\t$(ocfiles) $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c `cat cc.list`"; \
	         fi; \
	         $(ocfiles) $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c `cat cc.list`; \
	         if [ "$(COPT)" != "-g" -a "$(DEBUG)" != "yes" ]; \
	         then \
	             echo "\tremoving .c files"; \
	             rm `cat cc.list`; \
	         else \
	             echo "\tleaving .c files"; \
	         fi; \
	     else \
	         echo "\tnothing to compile"; \
	     fi; \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\trm -f opp.list cc.list"; \
	     fi; \
	     rm -f opp.list cc.list; \
	 fi

FAST:
	$(MAKE) FAST=1 objects_FAST

