.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

SRC = .

IPATH =  \
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
	PDUnode_info.o \
	PDUget_node.o \
	PDUmiscapi.o

objects = \
	$(c_objects) 


# main target

target: \
	PDUmisc.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUmisc.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUmisc.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUmisc.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUmisc.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDUnode_info.o : \
	$(SRC)/PDUnode_info.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/FCdata.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(PDU)/include/PDUstorage.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
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
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

PDUget_node.o : \
	$(SRC)/PDUget_node.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
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
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

PDUmiscapi.o : \
	$(SRC)/PDUmiscapi.c \
	$(PDU)/include/PDUerror.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
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
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h

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

DIR = $(PDU)/config/dload/prod/pdu/misc

PDUmisc.s:	$(objects_TARGET)
	@echo "Making PDUmisc.s for reactive loading."
	@echo
	@-mkstubs -o PDUmisc.s -t"Pdu:pdu/misc" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from misc to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubmisc.o
	@echo "Compiling PDUstubmisc.o from PDUmisc.s"
	@as -o PDUstubmisc.o PDUmisc.s


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

