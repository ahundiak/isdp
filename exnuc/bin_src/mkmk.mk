.PRECIOUS: $(TARGET)/bin/mkmklib.a

.SUFFIXES: .a .c .o

CC = cc -ga

SRC = $(EXNUC)/bin

IPATH =  \
	-I$(EXNUC)/include

MOPT = -Dclipper=1 -D__clipper__=1


# Object files 

c_objects = \
	exfilnam.o \
	fget_atom.o \
	fget_str.o \
	fread_input.o \
	ignore.o \
	is_file.o \
	make_rules.o \
	red_fname.o \
	reduce_pth.o \
	str_malloc.o \
	version.o \
	toolshash.o

objects = \
	$(c_objects) 

c_mkmk = \
	mkmk.o

mkmk = \
	$(c_mkmk) 


# main target

target: \
	$(TARGET)/bin/mkmk \
	$(TARGET)/bin/makemake


# src group targets

$(TARGET)/bin/mkmklib.a: $(objects)
	@echo 
	ar rsuv $(TARGET)/bin/mkmklib.a $(objects)
	@echo
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(TARGET)/bin/mkmklib.a"; fi; ls -ls $(TARGET)/bin/mkmklib.a; echo

LINKLIB_mkmk = \
	-lPW \
	-lmalloc \
	-lg

$(TARGET)/bin/mkmk: $(mkmk) $(TARGET)/bin/mkmklib.a
	@echo 
	$(CC) $(EXECOPT) $(COPT) -o $(TARGET)/bin/mkmk $(mkmk) $(TARGET)/bin/mkmklib.a $(LINKLIB_mkmk)
	@echo
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(TARGET)/bin/mkmk"; fi; ls -ls $(TARGET)/bin/mkmk; echo

exfilnam.o : \
	$(SRC)/exfilnam.c \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	/usr/include/malloc.h \
	/usr/include/memory.h \
	/usr/include/string.h

fget_atom.o : \
	$(SRC)/fget_atom.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/ctype.h

fget_str.o : \
	$(SRC)/fget_str.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/ctype.h

fread_input.o : \
	$(SRC)/fread_input.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/ctype.h

ignore.o : \
	$(SRC)/ignore.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(SRC)/lib.h

is_file.o : \
	$(SRC)/is_file.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/fs/s5param.h \
	/usr/include/sys/param.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(SRC)/toolshash.h \
	$(EXNUC)/include/exsysdep.h

make_rules.o : \
	$(SRC)/make_rules.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(SRC)/lib.h

red_fname.o : \
	$(SRC)/red_fname.c \
	/usr/include/memory.h \
	/usr/include/string.h

reduce_pth.o : \
	$(SRC)/reduce_pth.c

str_malloc.o : \
	$(SRC)/str_malloc.c \
	/usr/include/ctype.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/malloc.h

version.o : \
	$(SRC)/version.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h

toolshash.o : \
	$(SRC)/toolshash.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(SRC)/toolshash.h

mkmk.o : \
	$(SRC)/mkmk.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/ctype.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	$(SRC)/toolshash.h \
	$(SRC)/lib.h

$(c_objects) $(c_mkmk) :
	@if [ "$(WHY)" ]; then echo "\t$(SRC)/$(@F:.o=.c): $?"; fi
	@if test -z "$(VERBOSE_RULES)"; then echo "\t$(SRC)/$(@:.o=.c) -> $(@)"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; then if test -n "$(VERBOSE_RULES)"; then echo "\tcd $(@D)"; fi; cd $(@D); fi; \
	 if test -n "$(VERBOSE_RULES)"; then echo "\t$(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)"; fi; \
	 $(CC) $(COPT) $(IPATH) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)
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

$(TARGET)/bin/makemake: $(TARGET)/bin/mkmk
	chmod +x $(TARGET)/bin/makemake
	touch $(TARGET)/bin/makemake

