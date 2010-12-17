.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8
CC=acc
RM=/bin/rm -rf
BINDIR=../binc100
EXEC=$(BINDIR)/nfmmkmk
CPUFLAG=-D__cpu_c100__
OBJEXT=1
CFLAGS= -I../include
TARGSTR=-Atarg=c100

OBJECTS=reduce_pth.$(OBJEXT) fget_atom.$(OBJEXT) \
	is_file.$(OBJEXT) mkmk.$(OBJEXT) \
	fget_str.$(OBJEXT)

#====================================================
.c.$(OBJEXT):
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) $*.c
	@mv $*.o $*.$(OBJEXT)
#====================================================

mkmksys : ${OBJECTS}
	$(CC) -o $(EXEC) $(CPUFLAG) $(OPT) $(TARGSTR) $(OBJECTS)
	$(RM) ${OBJECTS}

reduce_pth.$(OBJEXT) : reduce_pth.c

fget_atom.$(OBJEXT) : fget_atom.c /usr/include/stdio.h /usr/include/ctype.h

is_file.$(OBJEXT) : is_file.c /usr/include/sys/types.h /usr/include/sys/stat.h

mkmk.$(OBJEXT) : mkmk.c /usr/include/stdio.h lib.h /usr/include/string.h

fget_str.$(OBJEXT) : fget_str.c /usr/include/stdio.h /usr/include/ctype.h
