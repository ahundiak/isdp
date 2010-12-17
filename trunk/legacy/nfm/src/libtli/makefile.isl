
#--------------------------
# Definitions for this file
#--------------------------

    CC		= /opt/SUNWspro/bin/cc
    AR		= ar
    INC		= ../include/
    CFLAGS	=  -c -g -I$(INC) $(COMP_OPT)
    OBJS	= server.o tcp.o generic.o
    ARCHV	= ../tdlib/libtli.a
    LFLAGS	= $(ARCHV)
    SOBJS	= stest.o timer.o
    COBJS	= ctest.o 
    STGT	= stest
    CTGT	= ctest


all:$(STGT) $(CTGT)

clean:
	rm -f $(ARCHV) $(OBJS) $(SOBJS) $(COBJS) $(STGT) $(CTGT)

#--------------------------
# Server Test Program
#--------------------------

$(STGT): $(ARCHV) $(SOBJS)
	$(CC) -o $(STGT) $(SOBJS) $(LFLAGS) -lnsl -lsocket

#--------------------------
# Client Test Program
#--------------------------

$(CTGT): $(ARCHV) $(COBJS)
	$(CC) -o $(CTGT) $(COBJS) $(LFLAGS) -lnsl -lsocket 

#--------------------------
# Library Archive
#--------------------------

$(ARCHV): $(OBJS)
	$(AR) -ru $(ARCHV) $(OBJS)

#--------------------------
# Server Test Objects
#--------------------------

stest.o: stest.c $(INC)net.h
	$(CC) $(CFLAGS) stest.c

timer.o: timer.c
	$(CC) $(CFLAGS) timer.c

#--------------------------
# Client Test Objects
#--------------------------

ctest.o: ctest.c $(INC)net.h
	$(CC) $(CFLAGS) ctest.c

#--------------------------
# Library Archive Objests
#--------------------------

server.o: server.c $(INC)net.h
	$(CC) $(CFLAGS) server.c

tcp.o: tcp.c $(INC)net.h
	$(CC) $(CFLAGS) tcp.c

generic.o: generic.c $(INC)net.h
	$(CC) $(CFLAGS) generic.c

