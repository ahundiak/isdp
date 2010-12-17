.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

SRC = .

IPATH =  \
	-I/usr5/bldc100/pdm32c1/include \
	-I/usr5/bldc100/pdm32c1/pdmapi/include \
	-I/usr5/bldc100/pdu32c1/include \
	-I/usr4/ip32/nfmdp/include

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMi_dbg.o \
	PDMi_file.o \
	PDMi_main.o \
	PDMi_rtns.o \
	PDMi_table.o \
	PDMi_tmplt.o \
	PDMcp_env.o \
	PDMdebug.o

objects = \
	$(c_objects) 


# src group targets

objects_TARGET = $(PDM)/lib/$(TARG)/PDMinit.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/$(TARG)/PDMinit.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/$(TARG)/PDMinit.a"; fi; ls -ls $(PDM)/lib/$(TARG)/PDMinit.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMi_dbg.o : \
	$(SRC)/PDMi_dbg.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr5/bldc100/pdu32c1/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMi_file.o : \
	$(SRC)/PDMi_file.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr4/ip32/nfmdp/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/NETerrordef.h \
	/usr4/ip32/nfmdp/include/NFMerrordef.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr5/bldc100/pdu32c1/include/SQLerrordef.h \
	/usr5/bldc100/pdm32c1/include/PDMmach_id.h \
	/usr5/bldc100/pdm32c1/include/PDMinit.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr4/ip32/nfmdp/include/MSGstruct.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMi_main.o : \
	$(SRC)/PDMi_main.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/ctype.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr/include/standards.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	/usr4/ip32/nfmdp/include/DEBUG.h \
	/usr4/ip32/nfmdp/include/NFMschema.h \
	/usr4/ip32/nfmdp/include/NFMstruct.h \
	/usr4/ip32/nfmdp/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/NETerrordef.h \
	/usr4/ip32/nfmdp/include/NFMerrordef.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr5/bldc100/pdu32c1/include/SQLerrordef.h \
	/usr5/bldc100/pdm32c1/include/PDMmach_id.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr5/bldc100/pdm32c1/include/PDMinit.h \
	/usr4/ip32/nfmdp/include/MSGstruct.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMi_rtns.o : \
	$(SRC)/PDMi_rtns.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr4/ip32/nfmdp/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/NETerrordef.h \
	/usr4/ip32/nfmdp/include/NFMerrordef.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr5/bldc100/pdu32c1/include/SQLerrordef.h \
	/usr5/bldc100/pdm32c1/include/PDMmach_id.h \
	/usr5/bldc100/pdm32c1/include/PDMinit.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr4/ip32/nfmdp/include/MSGstruct.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMi_table.o : \
	$(SRC)/PDMi_table.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr4/ip32/nfmdp/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/NETerrordef.h \
	/usr4/ip32/nfmdp/include/NFMerrordef.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr5/bldc100/pdu32c1/include/SQLerrordef.h \
	/usr5/bldc100/pdm32c1/include/PDMmach_id.h \
	/usr5/bldc100/pdm32c1/include/PDMinit.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr4/ip32/nfmdp/include/MSGstruct.h \
	/usr4/ip32/nfmdp/include/DEBUG.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMi_tmplt.o : \
	$(SRC)/PDMi_tmplt.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr4/ip32/nfmdp/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/NETerrordef.h \
	/usr4/ip32/nfmdp/include/NFMerrordef.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr5/bldc100/pdu32c1/include/SQLerrordef.h \
	/usr5/bldc100/pdm32c1/include/PDMmach_id.h \
	/usr5/bldc100/pdm32c1/include/PDMinit.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr4/ip32/nfmdp/include/MSGstruct.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMcp_env.o : \
	$(SRC)/PDMcp_env.c \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr4/ip32/nfmdp/include/MEMerrordef.h \
	/usr4/ip32/nfmdp/include/SQLerrordef.h \
	/usr4/ip32/nfmdp/include/NETerrordef.h \
	/usr4/ip32/nfmdp/include/NFMerrordef.h \
	/usr4/ip32/nfmdp/include/DEBUG.h \
	/usr4/ip32/nfmdp/include/NETstruct.h \
	/usr5/bldc100/pdu32c1/include/PDUerror.h \
	/usr4/ip32/nfmdp/include/NFMschema.h \
	/usr4/ip32/nfmdp/include/NFMstruct.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/termio.h \
	/usr/include/termio.h \
	/usr/include/sgtty.h \
	/usr/include/unctrl.h \
	/usr/include/curses.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

PDMdebug.o : \
	$(SRC)/PDMdebug.c \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	/usr4/ip32/nfmdp/include/MEMstruct.h \
	/usr5/bldc100/pdm32c1/include/PDMexec.h \
	/usr5/bldc100/pdm32c1/include/PDMSasspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSbompro.h \
	/usr5/bldc100/pdm32c1/include/PDMScicocpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSfmgrpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmacropro.h \
	/usr5/bldc100/pdm32c1/include/PDMSmulfpro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmppro.h \
	/usr5/bldc100/pdm32c1/include/PDMSpdmspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrispro.h \
	/usr5/bldc100/pdm32c1/include/PDMSrptspro.h \
	/usr5/bldc100/pdm32c1/include/PDMStoolspro.h \
	/usr5/bldc100/pdm32c1/include/PDMSinitpro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapipro.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMapi.h \
	/usr5/bldc100/pdm32c1/pdmapi/include/PDMextapipro.h \
	/usr5/bldc100/pdm32c1/include/PDMproto.h

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

