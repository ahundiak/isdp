
DEFINES= -D__i386 -D__i386__ -D__STDC__ -D__BUILTIN_VA_ARG_INCR

target: test01x.c

test01x.c: test01.c
	cpp -B $(DEFINES) test01.c test01x.c

clean:
	@rm -f *.o a.out test01x.c
