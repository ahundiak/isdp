CC=acc -g
CFLAGS= -c -PIC -I../include

objects= \
	server.o \
	generic.o \
	tcp.o 

TARGET_LIB: ./libtli.a

./libtli.a: $(objects) 
	ar rvu ./libtli.a $(objects)

# Include dependencies

generic.o ping.o server.o tcp.o xns.o : ./net.h

.c.o:
	$(CC) $(CFLAGS) $*.c
