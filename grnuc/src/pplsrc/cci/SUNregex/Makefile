# Things you might want to put in ENV and LENV:
# -Dvoid=int		compilers that don't do void
# -DCHARBITS=0377	compilers that don't do unsigned char
# -DSTATIC=extern	compilers that don't like "static foo();" as forward decl
# -DSTRCSPN		library does not have strcspn()
# -Dstrchr=index	library does not have strchr()
# -DERRAVAIL		have utzoo-compatible error() function and friends
ENV=#-Dvoid=int -DCHARBITS=0377 -DSTATIC=extern
LENV=#-Dvoid=int -DCHARBITS=0377

# Things you might want to put in TEST:
# -DDEBUG		debugging hooks
# -I.			regexp.h from current directory, not /usr/include
TEST=-I.

# Things you might want to put in PROF:
# -Dstatic='/* */'	make everything global so profiler can see it.
# -p			profiler
PROF=

CC=$(COMPILER)
CFLAGS=-O $(ENV) $(TEST) $(PROF)
LINTFLAGS=$(LENV) $(TEST) -ha
LDFLAGS=

SINGLESRC=$(GRNUC)/src/pplsrc/cci/SUNregex

OBJ=regexp.o regsub.o
LSRC=regexp.c regsub.c regerror.c
DTR=README dMakefile regexp.3 regexp.h regexp.c regsub.c regerror.c \
	regmagic.h try.c timer.c tests

#try:	try.o $(OBJ)
#	cc $(LDFLAGS) try.o $(OBJ) -o try

# Making timer will probably require putting stuff in $(PROF) and then
# recompiling everything; the following is just the final stage.
#timer:	timer.o $(OBJ)
#	cc $(LDFLAGS) $(PROF) timer.o $(OBJ) -o timer

#timer.o:	timer.c timer.t.h

#timer.t.h:	tests
#	sed 's/	/","/g;s/\\/&&/g;s/.*/{"&"},/' tests >timer.t.h

libregexp.a: regexp.o regsub.o regerror.o
	ar -rv libregexp.a regexp.o regsub.o regerror.o

regexp.o: 
	$(CC) -c $(SINGLESRC)/regexp.c

regsub.o: 
	$(CC) -c $(SINGLESRC)/regsub.c

regerror.o: 
	$(CC) -c $(SINGLESRC)/regerror.c

# Regression test.
r:	try tests
	@echo 'No news is good news...'
	try <tests

lint:	timer.t.h
	@echo 'Complaints about multiply-declared regerror() are legit.'
	lint $(LINTFLAGS) $(LSRC) try.c
	lint $(LINTFLAGS) $(LSRC) timer.c

regexp.o:	$(SINGLESRC)/regexp.c $(SINGLESRC)/regexp.h $(SINGLESRC)/regmagic.h
regsub.o:	$(SINGLESRC)/regsub.c $(SINGLESRC)/regexp.h $(SINGLESRC)/regmagic.h

clean:
	rm -f *.o core mon.out timer.t.h dMakefile dtr try timer

dtr:	r makedtr $(DTR)
	makedtr $(DTR) >dtr

dMakefile:	Makefile
	sed '/^L*ENV=/s/ *-DERRAVAIL//' Makefile >dMakefile
