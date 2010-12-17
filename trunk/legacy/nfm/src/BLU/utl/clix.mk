CC=acc
CPU=c100
CFLAGS = -c -O3 -Atarg=$(CPU) $(EXT_DOPT)
LIB = $(BLK)/build/lib/$(CPU)/utl.a

objects = \
	$(LIB)(stubs.o) \
	$(LIB)(timer.o) \
	$(LIB)(utl_copy.o) \
	$(LIB)(utl_dbg.o) \
	$(LIB)(utl_err.o) \
	$(LIB)(utl_getid.o) \
	$(LIB)(utl_mount.o) \
	$(LIB)(utl_move.o) \
	$(LIB)(utl_msg.o) \
	$(LIB)(utl_prnt.o) \
	$(LIB)(utl_slsh.o) \
	$(LIB)(utl_umount.o) \
	$(LIB)(utl_xlt.o) \
	$(LIB)(ping.o)

TARGET_LIB: $(LIB)

clean :
	\rm -f $(LIB)

$(LIB): $(objects) 
	@ls -l $(LIB)
	@echo

$(objects) :	utl.h

.c.a:
	$(CC) $(CFLAGS) $*.c
	@ar ru $(LIB) $*.o
	@rm -f $*.o
