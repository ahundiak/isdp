.PRECIOUS:

.SUFFIXES: .a .c .o

SRC = .

IPATH =  \
	-I$(PDM)/include \
	-I$(PDM)/pdmapi/include \
	-I$(PDU)/include \
	-I$(NFM)/include \
	-I$(RIS)/include \
	-I$(DBA)/include \
	-I$(RIS)/errmsg

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMrs_tool.o \
	PDMrs_fmgr.o \
	PDMrs_bom.o \
	PDMrs_cat.o \
	SQLqry.o

objects = \
	$(c_objects) 


# main target

target: \
	PDMris.s


# src group targets

objects_TARGET = $(PDM)/lib/PDMris.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/PDMris.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/PDMris.a"; fi; ls -ls $(PDM)/lib/PDMris.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMrs_tool.o : \
	$(SRC)/PDMrs_tool.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/DEBUG.h \
	$(PDM)/include/SQLstruct.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/include/PDMproto.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(RIS)/include/sql.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

PDMrs_fmgr.o : \
	$(SRC)/PDMrs_fmgr.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/MSGstruct.h \
	$(NFM)/include/DEBUG.h \
	/usr/include/stdio.h \
	/usr/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/include/PDMproto.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(RIS)/include/sql.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

PDMrs_bom.o : \
	$(SRC)/PDMrs_bom.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/stdio.h \
	/usr/include/math.h \
	$(PDM)/include/MRPstr.h \
	$(PDM)/include/MRPintdef.h \
	$(PDM)/include/MRPmessage.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/include/PDMproto.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(RIS)/include/sql.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

PDMrs_cat.o : \
	$(SRC)/PDMrs_cat.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/stdio.h \
	$(PDM)/include/MRPstr.h \
	$(PDM)/include/MRPmessage.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/include/PDMproto.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(RIS)/include/sql.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

SQLqry.o : \
	$(SRC)/SQLqry.c \
	$(RIS)/include/sql.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/stdio.h \
	/usr/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/DEBUG.h \
	$(PDM)/include/SQLstruct.h \
	$(NFM)/include/MEMstruct.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDM)/include/SQLproto.h \
	$(PDM)/include/SQL.h

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

DIR = $(PDU)/config/dload/prod/pdm/ris

PDMris.s:	$(objects)
	@echo "Making PDMris.s for reactive loading."
	@echo
	@-mkstubs -o PDMris.s -p"Pdu:config/dload/prod/pdm/ris" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from ris directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)


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

