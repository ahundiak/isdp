.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

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
	PDMrs_rpt.o \
	SQLqry.o

objects = \
	$(c_objects) 


# main target

target: \
	PDMris.s


# src group targets

objects_TARGET = $(PDM)/lib/$(TARG)/PDMris.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/$(TARG)/PDMris.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/$(TARG)/PDMris.a"; fi; ls -ls $(PDM)/lib/$(TARG)/PDMris.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMrs_tool.o : \
	$(SRC)/PDMrs_tool.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
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
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(PDM)/include/PDUris_incl.h \
	/usr/include/sql.h \
	$(RIS)/include/rislimit.h \
	/usr/include/windows.h \
	$(RIS)/include/ris.h \
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
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
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
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(PDM)/include/PDUris_incl.h \
	/usr/include/sql.h \
	$(RIS)/include/rislimit.h \
	/usr/include/windows.h \
	$(RIS)/include/ris.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

PDMrs_bom.o : \
	$(SRC)/PDMrs_bom.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/standards.h \
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
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(PDM)/include/PDUris_incl.h \
	/usr/include/sql.h \
	$(RIS)/include/rislimit.h \
	/usr/include/windows.h \
	$(RIS)/include/ris.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

PDMrs_cat.o : \
	$(SRC)/PDMrs_cat.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
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
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(PDM)/include/PDUris_incl.h \
	/usr/include/sql.h \
	$(RIS)/include/rislimit.h \
	/usr/include/windows.h \
	$(RIS)/include/ris.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

PDMrs_rpt.o : \
	$(SRC)/PDMrs_rpt.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(PDM)/include/MRPstr.h \
	$(PDU)/include/rMRPstr.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDM)/include/MRPmacros.h \
	$(PDM)/include/MRPmessage.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUerror.h \
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
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(PDM)/include/PDUris_incl.h \
	/usr/include/sql.h \
	$(RIS)/include/rislimit.h \
	/usr/include/windows.h \
	$(RIS)/include/ris.h \
	$(RIS)/include/RISprototype.h \
	$(PDM)/include/PDMris_fnpro.h

SQLqry.o : \
	$(SRC)/SQLqry.c \
	/usr/include/windows.h \
	$(RIS)/include/ris.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
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
	     echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)"; \
	 fi; \
	 $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)
	@echo 

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c
	@echo 

DIR = $(PDU)/config/dload/prod/pdm/ris

PDMris.s:	$(objects_TARGET)
	@echo "Making PDMris.s for reactive loading."
	@echo
	@-mkstubs -o PDMris.s -t"Pdu:pdm/ris" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from ris directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubris.o
	@echo "Compiling PDMstubris.o from PDMris.s"
	@as -o PDMstubris.o PDMris.s


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
	             echo "\t$(ocfiles) $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c `cat cc.list`"; \
	         fi; \
	         $(ocfiles) $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c `cat cc.list`; \
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

