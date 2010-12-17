dattoclh : dattoclh.o
	cc -o ../scobin/dattoclh dattoclh.o \
	   ../scolib/libsystools.a \
	   ../scolib/libnfmerr.a \
	   -lUMS -lsocket
	chmod +s ../scobin/dattoclh
	ls -ls ../scobin/dattoclh

dattoclh.o : dattoclh.c
	cc -c -I../include dattoclh.c


