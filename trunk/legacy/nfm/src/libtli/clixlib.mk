
#--------------------------
# Definitions for this file
#--------------------------

    CC		= acc
    AR		= ar
    INC		= ./include/
    CFLAGS	=  -c -I$(INC) -DCLIX -DBSD43 
    OBJS	= server.o tcp.o generic.o
    ARCHV	= ./libtli.a
    #LFLAGS	= -lnsl -lbsd $(ARCHV)
    LFLAGS	=  $(ARCHV)


#all:$(STGT) $(CTGT)

#--------------------------
# Library Archive
#--------------------------

$(ARCHV): $(OBJS)
	$(AR) -ru $(ARCHV) $(OBJS)

server.o: server.c $(INC)net.h
	$(CC) $(CFLAGS) server.c

tcp.o: tcp.c $(INC)net.h
	$(CC) $(CFLAGS) tcp.c

generic.o: generic.c $(INC)net.h
	$(CC) $(CFLAGS) generic.c

