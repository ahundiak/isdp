.PRECIOUS:

.SUFFIXES: .a .S .c .o

opp = $(EXNUC)/bin/opp

LINKOPT =

SRC = .

OPPFLAGS =  \
	-I$(PDU)/include \
	-I$(PDM)/include \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(NFM)/include \
	-I$(EXNUC)/spec \
	-I$(GRNUC)/spec \
	-I$(SRC)

IPATH =  \
	-I$(PDU)/include \
	-I$(PDM)/include \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(NFM)/include

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

spec_objects = \
	COpdu.o \
	PDUstartup.o \
	PDUasmmgr.o

objects = \
	$(spec_objects) 


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUspec.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUspec.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUspec.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUspec.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

COpdu.o : \
	$(SRC)/COpdu.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(EXNUC)/spec/super_cmd.S \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/tools.h \
	$(EXNUC)/include/wl.h \
	$(EXNUC)/include/exproto.h \
	$(EXNUC)/include/exmacros.h \
	$(EXNUC)/include/COBmacros.h \
	$(EXNUC)/include/COBshfn.h \
	/usr/include/UMS.h \
	$(EXNUC)/include/ode_export.h \
	$(EXNUC)/include/COB_arg.h \
	$(EXNUC)/include/ODE.h \
	$(EXNUC)/include/COBlist_tool.h \
	$(EXNUC)/include/COBstructs.h \
	$(EXNUC)/spec/CEO.S \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/dp.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/grdpbdef.h \
	$(GRNUC)/include/grdpb.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/CEO_LOCATE.S \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUint.h \
	$(GRNUC)/include/igrdp.h \
	$(PDU)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h

PDUstartup.o : \
	$(SRC)/PDUstartup.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/exdef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msdef.h \
	$(EXNUC)/include/msmacros.h \
	$(EXNUC)/spec/super_cmd.S

PDUasmmgr.o : \
	$(SRC)/PDUasmmgr.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(EXNUC)/spec/global_class.S \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h

$(spec_objects):
	@if [ "$(WHY)" ]; then echo "\t$(@): $?"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; \
	 then \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\tcd $(@D)"; \
	     fi; \
	     cd $(@D); \
	 fi; \
	 if [ "$(FAST)" ]; \
	 then \
	     if [ -f $(@) ]; then rm $(@); fi; \
	     echo "\t$(@:.o=.S) -> opp.list\c"; \
	     echo "$(@:.o=.S)" >>opp.list; \
	 else \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$(SRC)/$(@:.o=.S) -> $(@:.o=.c)"; \
	     fi; \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.S)"; \
	     fi; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.S); \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$(@:.o=.c) -> $(@)"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c)"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c); \
	     if [ "$(COPT)" != "-g" -a "$(DEBUG)" != "yes" ]; \
	     then \
	         if [ -z "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\tremoving $(@:.o=.c)"; \
	         else \
	             echo "\trm $(@F:.o=.c)"; \
	         fi; \
	         rm $(@F:.o=.c); \
	     else \
	         if [ -z "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\tleaving $(@:.o=.c)"; \
	         fi; \
	     fi; \
	 fi
	@echo 

.S.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ "$(FAST)" ]; \
	 then \
	     if [ -f $(@) ]; then rm $(@); fi; \
	     echo "\t$< -> opp.list\c"; \
	     echo "$<" >>opp.list; \
	 else \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$< -> $*.c"; \
	     else \
	         echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<"; \
	     fi; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<; \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$*.c -> $*.o"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c;  \
	     if [ "$(COPT)" != "-g" -a "$(DEBUG)" != "yes" ]; \
	     then \
	        if [ -z "$(VERBOSE_RULES)" ]; \
	        then \
	            echo "\tremoving $*.c"; \
	        else \
	            echo "\trm $*.c"; \
	        fi; \
	        rm $*.c; \
	     else \
	        if [ -z "$(VERBOSE_RULES)" ]; \
	        then \
	            echo "\tleaving $*.c"; \
	        fi; \
	     fi; \
	 fi
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

