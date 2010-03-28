.SUFFIXES: .C .c .o

SRC = /

OMCPPOPT = -DGRAPHICS_ATP
IPATH =  \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(GRNUC)/proto_priv \
	-I$(BS)/include \
	-I$(BS)/include/prototypes

opp = $(EXNUC)/bin/opp

omcpp = $(EXNUC)/bin/omcpp

CC = acc -knr

COPT =  -ansi \
	-g \
	-DGRAPHICS_ATP 

DOPT = -DCLIX -DSYSV -DBSD -DENV5 -DLITTLE_ENDIAN -D__APGE__

OPPFLAGS =  \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(GRNUC)/proto_priv \
	-I$(BS)/include \
	-I$(BS)/include/prototypes \
	-I/usr/include \
	-I$(EXNUC)/spec \
	-I$(GRNUC)/spec \
	-I. \
	-l

MOPT = -Dclipper=1 -D__clipper__=1


# Object files 

C_objects = \
	$(GRNUC)/src/display/grdisplay/dpbcstrk.o \
	$(GRNUC)/src/display/grdisplay/dpbsqstrk.o \
	$(GRNUC)/src/display/grdisplay/dppsstrk.o \
	$(GRNUC)/src/display/grdisplay/dppystrk.o \
	$(GRNUC)/src/display/grdisplay/dptxstrk.o

objects = \
	$(C_objects) 


# src group targets

$(GRNUC)/test/lib/GRstrktst.o: $(objects)
	@echo 
	ld -r -o $(GRNUC)/test/lib/GRstrktst.o $(objects)
	@echo; if test -n "$(VERBOSE_RULES)"; then echo "\trm -f opp.list cc.list"; fi; rm -f opp.list cc.list
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(GRNUC)/test/lib/GRstrktst.o"; fi; ls -ls $(GRNUC)/test/lib/GRstrktst.o; echo

$(GRNUC)/src/display/grdisplay/dpbcstrk.o : \
	$(SRC)/$(GRNUC)/src/display/grdisplay/dpbcstrk.C \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/ex.h \
	$(BS)/include/bsparameters.h \
	$(GRNUC)/include/grimport.h \
	/usr/include/gpipe.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/igrdef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/dperr.h \
	$(GRNUC)/include/dpdef.h

$(GRNUC)/src/display/grdisplay/dpbsqstrk.o : \
	$(SRC)/$(GRNUC)/src/display/grdisplay/dpbsqstrk.C \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/ex.h \
	$(BS)/include/bsparameters.h \
	$(GRNUC)/include/grimport.h \
	/usr/include/gpipe.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/igrdef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(EXNUC)/include/msdef.h

$(GRNUC)/src/display/grdisplay/dppsstrk.o : \
	$(SRC)/$(GRNUC)/src/display/grdisplay/dppsstrk.C \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/ex.h \
	$(BS)/include/bsparameters.h \
	$(GRNUC)/include/grimport.h \
	/usr/include/gpipe.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igrdef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/dppriv.h \
	$(GRNUC)/include/dperr.h \
	$(GRNUC)/include/dpdef.h \
	$(EXNUC)/include/msdef.h

$(GRNUC)/src/display/grdisplay/dppystrk.o : \
	$(SRC)/$(GRNUC)/src/display/grdisplay/dppystrk.C \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/ex.h \
	$(BS)/include/bsparameters.h \
	$(GRNUC)/include/grimport.h \
	/usr/include/gpipe.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/igrdef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/dperr.h \
	$(GRNUC)/include/dpdef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h

$(GRNUC)/src/display/grdisplay/dptxstrk.o : \
	$(SRC)/$(GRNUC)/src/display/grdisplay/dptxstrk.C \
	/usr/include/FSOutl.h \
	/usr/include/FSTypes.h \
	/usr/include/FS.h \
	/usr/include/FSFont.h \
	/usr/include/FSBmap.h \
	/usr/include/math.h \
	/usr/include/gpipe.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	/usr/include/dirent.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/ex.h \
	$(BS)/include/bsparameters.h \
	$(GRNUC)/include/grimport.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/igrdef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/fontdef.h \
	$(GRNUC)/include/dpfont.h \
	$(GRNUC)/include/dperr.h \
	$(GRNUC)/include/dpdef.h \
	$(GRNUC)/include/dppriv.h \
	$(EXNUC)/include/msdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h 

$(C_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.C): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.C) -> $(@:.o=.c)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(SRC)/$(@:.o=.C) $(@F:.o=.c)"; fi; \
	 $(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) \
		$(SRC)/$(@:.o=.C) $(@F:.o=.c); \
	 if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	        echo "\t$(@:.o=.c) -> cc.list\c"; \
	     else \
	        echo "\techo \"$(@:.o=.c)\" >>cc.list"; \
	     fi; \
	     echo "$(@:.o=.c)" >>cc.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$(@:.o=.c) -> $(@)"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c)"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c); \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	         if test -z "$(VERBOSE_RULES)"; \
	         then \
	             echo "\tremoving $(@:.o=.c)"; \
	         else \
	             echo "\trm $(@F:.o=.c)"; \
	         fi; \
	         rm $(@F:.o=.c); \
	     else \
	         if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $(@:.o=.c)"; fi; \
	     fi; \
	 fi
	@echo 

.C.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.c"; \
	 else \
	     echo "\t$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $< $*.c"; \
	 fi
	@$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $< $*.c
	@if [ "$(FAST)" ]; \
	 then \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$*.c -> cc.list\c"; \
	     else \
	         echo "\techo \"$*.c\" >>cc.list"; \
	     fi; \
	     echo "$*.c" >>cc.list; \
	 else \
	     if test -z "$(VERBOSE_RULES)"; \
	     then \
	         echo "\t$*.c -> $*.o"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c; \
	     if [ "$(COPT)" != "-g" ]; \
	     then \
	        if test -z "$(VERBOSE_RULES)"; \
	        then \
	            echo "\tremoving $*.c"; \
	        else \
	            echo "\trm $*.c"; \
	        fi; \
	        rm $*.c; \
	     else \
	        if test -z "$(VERBOSE_RULES)"; then echo "\tleaving $*.c"; fi; \
	     fi; \
	 fi
	@echo 

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c
	@echo 

