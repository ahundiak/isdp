.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

SRC = .

IPATH =  \
	-I$(INGRHOME)/include \
	-I$(PDU)/include \
	-I$(PDM)/include \
	-I$(PDM)/pdmapi/include \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(NFM)/include \
	-I$(DBA)/include \
	-I$(FORMS)/include

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDUdef_assy.o \
	PDUassy_tls.o \
	PDUassyapi.o \
	PDUrev_assy.o \
	PDUrevasytls.o

objects = \
	$(c_objects) 


# main target

target: \
	PDUassembly.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUassembly.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUassembly.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUassembly.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUassembly.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDUdef_assy.o : \
	$(SRC)/PDUdef_assy.c \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUassy.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
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
	/usr/include/standards.h \
	/usr/include/ctype.h

PDUassy_tls.o : \
	$(SRC)/PDUassy_tls.c \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUassy.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
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
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	$(EXNUC)/include/exdef.h

PDUassyapi.o : \
	$(SRC)/PDUassyapi.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUfile_def.h

PDUrev_assy.o : \
	$(SRC)/PDUrev_assy.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
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
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDMdebug.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUrev_str.h \
	$(DBA)/include/FI.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDMmessage.h \
	$(PDU)/include/PDUcommand.h \
	$(EXNUC)/include/exdef.h

PDUrevasytls.o : \
	$(SRC)/PDUrevasytls.c \
	/usr/include/sys/stat.h \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUforms.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUrev_str.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDMmessage.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/SQLerrordef.h \
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
	$(PDU)/include/SQLstruct.h \
	$(NFM)/include/MEMstruct.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLproto.h \
	$(PDU)/include/SQL.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h

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

DIR = $(PDU)/config/dload/prod/pdu/assembly

PDUassembly.s:	$(objects_TARGET)
	@echo "Making PDUassembly.s for reactive loading."
	@echo
	@-mkstubs -o PDUassembly.s -t"Pdu:pdu/assembly" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from assembly to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubassy.o
	@echo "Compiling PDUstubassy.o from  PDUassembly.s"
	@as -o PDUstubassy.o PDUassembly.s


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

