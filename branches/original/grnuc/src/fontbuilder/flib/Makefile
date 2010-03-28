.SUFFIXES: .c .o

SRC = $(GRNUC)/src/fontbuilder/flib

IPATH = \
        -I$(INGRHOME)/include \
        -I$(XINC) \
        -I$(BS)/include \
        -I$(EXNUC)/include \
        -I$(GRNUC)/include

CC = cc

COPT = -g

DOPT = $(MKDOPT)

# Object files

c_objects = \
	sunconv.o \
	create.o \
	io.o \
	list.o \
	flib.o \
	fltvaxto32.o \
	EXproduct.o

objects = \
	$(c_objects)


# src group targets

LINKLIB = \
	-lXFS \
	-lXFI \
	-lm \
	-ldl \
	-lw \
	-lsocket \
	-lnsl \
	/usr/openwin/lib/libXt.a \
	/usr/openwin/lib/libX11.a \
	/usr/openwin/lib/libXext.a \
	-lxc \
	-lxcmalloc

$(GRLIB)/src/fontbuilder/bin/GRFlib: $(objects)
	@echo
	$(CC) $(EXECOPT) $(COPT) -o $(GRLIB)/src/fontbuilder/bin/GRFlib $(objects) $(LINKLIB)
	@echo
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(GRLIB)/src/fontbuilder/bin/GRFlib"; fi; ls -ls $(GRLIB)/src/fontbuilder/bin/GRFlib; echo

sunconv.o : \
        $(SRC)/sunconv.c

create.o : \
	$(SRC)/create.c \
	$(SRC)/cdtstruct.h \
	$(SRC)/local.h \
	$(SRC)/fntdata.h \
	$(SRC)/flib_common.h \
	$(SRC)/struct.h \
	/usr/include/stdio.h \
	/usr/include/time.h

io.o : \
	$(SRC)/io.c \
	$(SRC)/cdtstruct.h \
	$(SRC)/local.h \
	$(SRC)/fntdata.h \
	$(SRC)/flib_common.h \
	$(SRC)/struct.h \
	$(SRC)/msg.h \
	$(GRNUC)/include/dpgraphics.h \
	/usr/include/stdio.h

list.o : \
	$(SRC)/list.c \
	$(SRC)/cdtstruct.h \
	$(SRC)/local.h \
	$(SRC)/fntdata.h \
	$(SRC)/flib_common.h \
	$(SRC)/struct.h \
	$(GRNUC)/include/dpgraphics.h \
	/usr/include/stdio.h \
	$(SRC)/defnames.h

flib.o : \
	$(SRC)/flib.c \
	$(GRNUC)/ingrsys/tools.h \
	$(SRC)/fntdata.h \
	$(SRC)/flibtpa.h \
	$(SRC)/offset_pos.h \
	$(SRC)/local.h \
	$(SRC)/cdtstruct.h \
	$(SRC)/struct.h \
	/usr/include/stdio.h \
	$(SRC)/flib_global.h

fltvaxto32.o : \
        $(SRC)/fltvaxto32.c

EXproduct.o : \
	$(SRC)/EXproduct.c \
	$(EXNUC)/include/exsysdep.h \
	/usr/include/stdio.h \
	/usr/include/string.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr/include/sys/param.h \
	$(EXNUC)/include/EXproduct.h \
	$(EXNUC)/include/OMerrordef.h

$(c_objects) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.c): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.c) -> $(@)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(CC) $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)"; fi; \
	 $(CC) $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)
	@echo

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if test -z "$(VERBOSE_RULES)"; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c
	@echo

