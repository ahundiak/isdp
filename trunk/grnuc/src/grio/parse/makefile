# ========================================================
# 01 Nov 2010
# Tried changing to yacc30/lex30 and got errors
# Just keep with yacc40 for not

.SUFFIXES:  .l .y .o
YFLAGS = -d

PackageTag = COexpr_yy

omcpp = $(EXTARG)/bin/omcpp

opp = $(EXTARG)/bin/opp

CC = $(COMPILER)

#ifdef CLIX
COPT = -ga $(COMPOPT)
#else
COPT =  $(COMPOPT) $(MKDOPT)
#endif

objects = \
	COparse.o \
	COlex.o 


library = $(GRLIB)/lib/parse.o

incfiles = \
	-I$(INGRHOME)/include \
	-I$(XINC) \
        -I$(XGLHOME)/include \
        -I$(XGLHOME)/include/xgl \
	-I$(GRNUC)/include \
	-I$(EXNUC)/include \
	-I$(BS)/include


specfiles = \
	-I$(GRNUC)/display/spec \
	-I$(GRNUC)/go/spec \
	-I$(EXNUC)/exec/spec \
	-I$(GRNUC)/dtl/spec \
	-I$(GRNUC)/co/spec \
	-I$(EXNUC)/om/spec \
	-I$(GRNUC)/grio/spec \
	-I$(EXNUC)/cob/spec \
	-I$(EXNUC)/message/spec \
	-I$(EXNUC)/fi/spec 

oppflags =  $(MKDOPT) $(incfiles) $(specfiles)

omcppflags = $(MKDOPT) $(incfiles)

ipath = $(incfiles)

$(library): $(objects)
	@if [ -r lex.yy.c ]; then rm lex.yy.c; fi
	@if [ -r lex.yy.C ]; then rm lex.yy.C; fi
	@echo
	@echo
	ld -r -o $(library) $(objects)
	@echo
	@echo
	@ls -ls $(library)
	@echo
	@echo


COlex.o: $(GRNUC)/src/grio/parse/COlex.l
	lex  $(GRNUC)/src/grio/parse/COlex.l
	sed "s/ output/ $(PackageTag)output/g" lex.yy.c > lex.yy.C
	$(omcpp) $(omcppflags) lex.yy.C > COlex.C
	sed "s/yy/$(PackageTag)/g" COlex.C | sed "s/YY/$(PackageTag)/g" >COlex.c
	$(CC) -c $(COPT) $(ipath) COlex.c -ll -ly
	rm COlex.c COlex.C


COparse.o: $(GRNUC)/src/grio/parse/COparse.y
	yacc $(YFLAGS) $(GRNUC)/src/grio/parse/COparse.y
	sed "s/yy/$(PackageTag)/g" y.tab.c | sed "s/YY/$(PackageTag)/g" > COparse.C
	@$(omcpp) $(omcppflags) COparse.C > COparse.c
	@$(CC)  -c $(COPT) $(ipath) COparse.c -lm -ll -ly
	@if test "$(COPT)" != "-g"; then rm COparse.c COparse.C; fi
	@rm y.tab.c

clean:
	@rm -f *.o  y.output   y.tab.h
