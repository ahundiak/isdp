.SUFFIXES: .o .c .rc .1 .4
CC=acc
RISCC=/usr/ip32/ris/bin/riscpp
OPT=-O3
CPUFLAG=-D__cpu_c100__
OBJEXT=1
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
EXEC=$(BINDIR)/SCcpp
CFLAGS=	-ansi	-Dclipper	-I../include
OBJECTS= lex.yy.$(OBJEXT) SCcppmain.$(OBJEXT)

.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	@$(CC) -c $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) $*.c
	@mv $*.o $*.$(OBJEXT)

SCcpp: $(OBJECTS)
	@$(CC) $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) $(OBJECTS) -ll -o $(EXEC)

lex.yy.$(OBJEXT): SCcpp.l
	lex SCcpp.l
	@$(CC) -c $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) lex.yy.c
	@mv lex.yy.o lex.yy.$(OBJEXT)
	rm lex.yy.c
