dattoclh : dattoclh.o
	cc -o ../tdbin/dattoclh dattoclh.o \
	   ../tdlib/libsystools.a \
	   ../tdlib/libnfmerr.a \
	   -lUMS -lsocket -lnsl
	chmod +s ../tdbin/dattoclh
	ls -ls ../tdbin/dattoclh

dattoclh.o : dattoclh.c
	cc -c -I../include dattoclh.c


