.SUFFIXES: .c .o .so

INC_PVT	= ../inc.pvt
INC_PUB = ../include

XCLIBS	= -lxc -lxcmalloc
DOPT=-DRUN_X=1 -DX11=1 -DLITTLE_ENDIAN=1 -DSYSV=1 -DSYS5=1 -DSVR4=1 -DSUNOS=1 -DSUNOS5=1 -DSUNOS58=1 -Di386=1 -D__i386=1 -DINTEL=1 -DUNIX=1 -DSunOS_5x=1 -D__i386__=1 -DSunOS=1
COPT	= -g -Xa -xCC -m32 -Kpic -c -I$(INC_PVT) -I$(INC_PUB) $(DOPT)

# Main target

TARGET: objtester testdrive DLtest_1.so DLtest_2.so DLtest_2A.so DLtest_2B.so DLtest_3.so DLtest_4.so DLtest_4A.so DLtest_4B.so DLtest_5.so DLtest_5A.so DLtest_5B.so DLtest_6.so

objtester: objtester.o
	$(CC) -g -o objtester objtester.o $(XCLIBS)

testdrive: testdrive.o
	$(CC) -g -o testdrive testdrive.o $(XCLIBS)

# Dependencies

objtester.o: \
	objtester.c

testdrive.o: \
	testdrive.c

# Rules

.c.o:
	$(CC) $(COPT) -c $*.c

.o.so:	DLtest_1.o DLtest_2.o DLtest_2A.o DLtest_2B.o DLtest_3.o DLtest_4.o DLtest_4A.o DLtest_4B.o DLtest_5.o DLtest_5A.o DLtest_5B.o DLtest_6.o
	$(LD) -G $< -o $@
