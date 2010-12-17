.SUFFIXES: .o .c .rc .1 .4 .7 .9
CC=cc -g
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OBJEXT=9
LIBDIR=../tdlib
BINDIR=../tdbin
TARGSTR=
EXEC=$(BINDIR)/SCcpp
CFLAGS=	-I../include
OBJECTS= lex.yy.$(OBJEXT) SCcppmain.$(OBJEXT)

.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	@$(CC) -c $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) $*.c
	@echo
	@mv $*.o $*.$(OBJEXT)

SCcpp: $(OBJECTS)
	@$(CC) $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) $(OBJECTS) -ll -o $(EXEC)
	@rm $(OBJECTS)

lex.yy.$(OBJEXT): SCcpp.l
	lex SCcpp.l
	@$(CC) -c $(CFLAGS) $(CPUFLAG) $(OPT) $(TARGSTR) lex.yy.c
	@echo
	@mv $*.o $*.$(OBJEXT)
	rm lex.yy.c
