
#--------------------------
# Definitions for this file
#--------------------------

    CC		= cc
    AR		= ar
    INCFLAGS	= -I./ -I../include/ -I/usr/include -I/usr/include/sys  
    INC		= ./
#  CFLAGS	=  -c -I$(INC) -DSCO -DBSD43 
    CFLAGS	=  -c $(INCFLAGS) -DSCO -DDEBUG 
    OBJS	= server.o tcp.o generic.o
    ARCHV	= ./libtli.a
#   LFLAGS	= -lnsl -lbsd $(ARCHV)
    LFLAGS	= $(ARCHV) -lnsl_s -lsocket
    SOBJS	= stest.o timer.o
    COBJS	= ctest.o 
    STGT	= stest
    CTGT	= ctest


all:$(STGT) $(CTGT)

#--------------------------
# Library Archive
#--------------------------

$(ARCHV): $(OBJS)
	$(AR) -ru $(ARCHV) $(OBJS)

#clean:
#	rm -f $(ARCHV) $(OBJS) $(SOBJS) $(COBJS) $(STGT) $(CTGT)

#--------------------------
# Server Test Program
#--------------------------

$(STGT): $(ARCHV) $(SOBJS)
	$(CC) $(LFLAGS) $(SOBJS) $(ARCHV) -o $(STGT)

#--------------------------
# Client Test Program
#--------------------------

$(CTGT): $(ARCHV) $(COBJS)
	$(CC) -o $(CTGT) $(COBJS) $(LFLAGS)

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

