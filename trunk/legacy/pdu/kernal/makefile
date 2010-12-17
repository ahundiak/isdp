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
	-I$(FORMS)/include \
	-I$(PDU)/pal/src/pdmr/svs

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDUglobals.o \
	PDMglobals.o

objects = \
	$(c_objects) 


# main target

target: \
	PDUkernal.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUkernal.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUkernal.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUkernal.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUkernal.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDUglobals.o : \
	$(SRC)/PDUglobals.c \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUint.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUrefresh.h \
	$(PDU)/include/PDUassy.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDUfile_def.h \
	$(DBA)/include/FI.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/pal/src/pdmr/svs/header.h \
	$(PDU)/include/MRPintdef.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h

PDMglobals.o : \
	$(SRC)/PDMglobals.c \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h

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

DIR = $(PDU)/config/dload/init

PDUkernal.s:	$(objects)
	@echo "Copying PDUglobals.o and PDMglobals.o to $(DIR)."
	@cp PDUglobals.o $(DIR)
	@cp PDMglobals.o $(DIR)


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

