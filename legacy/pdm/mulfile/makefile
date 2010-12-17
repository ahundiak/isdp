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
	-I$(RIS)/errmsg

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMnew_part.o \
	PDMadd_del.o

objects = \
	$(c_objects) 


# main target

target: \
	PDMmulfile.s


# src group targets

objects_TARGET = $(PDM)/lib/$(TARG)/PDMmulfile.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/$(TARG)/PDMmulfile.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/$(TARG)/PDMmulfile.a"; fi; ls -ls $(PDM)/lib/$(TARG)/PDMmulfile.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMnew_part.o : \
	$(SRC)/PDMnew_part.c \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMapi.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
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
	$(PDM)/include/PDMtypes.h

PDMadd_del.o : \
	$(SRC)/PDMadd_del.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMapi.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(PDM)/include/PDMdbs_err.h \
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
	$(PDM)/include/PDMproto.h

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

DIR = $(PDU)/config/dload/prod/pdm/mulfile

PDMmulfile.s:	$(objects_TARGET)
	@echo "Making PDMmulfile.s for reactive loading."
	@echo
	@-mkstubs -o PDMmulfile.s -t"Pdu:pdm/mulfile" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from mulfile directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubmulfl.o
	@echo "Compiling PDMstubmulfl.o from PDMmulfile.s"
	@as -o PDMstubmulfl.o PDMmulfile.s


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

