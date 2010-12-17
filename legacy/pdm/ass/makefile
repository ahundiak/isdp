.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

SRC = .

IPATH =  \
	-I$(PDU)/include \
	-I$(PDM)/include \
	-I$(PDM)/pdmapi/include \
	-I$(RIS)/include \
	-I$(NFM)/include

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMass_struc.o \
	PDMatt_struc.o \
	PDMchkin_cit.o \
	PDMqry_mem.o

objects = \
	$(c_objects) 


# main target

target: \
	PDMass.s


# src group targets

objects_TARGET = $(PDM)/lib/$(TARG)/PDMass.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/$(TARG)/PDMass.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/$(TARG)/PDMass.a"; fi; ls -ls $(PDM)/lib/$(TARG)/PDMass.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMass_struc.o : \
	$(SRC)/PDMass_struc.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDU)/include/PDUris_incl.h \
	$(PDU)/include/PDMdbs_err.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h \
	$(PDU)/include/PDMmessage.h

PDMatt_struc.o : \
	$(SRC)/PDMatt_struc.c \
	$(NFM)/include/NFMdef.h \
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
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDU)/include/PDUris_incl.h \
	$(PDU)/include/PDMdbs_err.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDMchkin_cit.o : \
	$(SRC)/PDMchkin_cit.c \
	$(NFM)/include/NFMdef.h \
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
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDU)/include/PDUris_incl.h \
	$(PDU)/include/PDMdbs_err.h

PDMqry_mem.o : \
	$(SRC)/PDMqry_mem.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMdef.h \
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
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h \
	$(PDU)/include/PDMdebug.h

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

DIR = $(PDU)/config/dload/prod/pdm/ass

PDMass.s:	$(objects_TARGET)
	@echo "Making PDMass.s for reactive loading."
	@echo
	@-mkstubs -o PDMass.s -t"Pdu:pdm/ass" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from ass directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubass.o
	@echo "Compiling PDMstubass.o from PDMass.s"
	@as -o PDMstubass.o PDMass.s


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

