
CC  = /opt/sunstudio12.1/bin/cc
OPT = -Xc -xCC -m32 -KPIC -features=no%conststrings -errfmt
DEF = -D__STDC__=1
ALN = -Ddouble='double __attribute__((aligned(8)))'
INC = -I$(BS)/include

target: align align8 align.txt align8.txt

align: align.c
	$(CC) $(OPT) $(DEF) $(INC) -o align align.c

align8: align.c
	$(CC) $(OPT) $(DEF) $(ALN) $(INC) -o align8 align.c

align.txt: align
	align > align.txt

align8.txt: align8
	align8 > align8.txt

clean:
	@rm -f *.o align align8 alignx
