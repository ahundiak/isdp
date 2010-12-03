
calc: calc.tab.o calc.l.o
	cc -o calc calc.tab.o calc.l.o

calc.tab.o: calc.y
	yacc -b calc -d calc.y
	cc -c calc.tab.c
	
calc.l.o: calc.l
	lex -t calc.l > calc.l.c
	cc -c calc.l.c
	
clean:
	@rm -f core *.o y.tab.c y.tab.h a.out lex.yy.c
	@rm -f calc.l.c calc.tab.c calc.tab.h calc

