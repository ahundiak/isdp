CC=acc

CFLAGS=-I../include

objects=reduce_pth.o fget_atom.o is_file.o mkmk.o fget_str.o

mkmksys : ${objects}
	$(CC) -o nfmmkmk mkmk.o reduce_pth.o fget_atom.o is_file.o fget_str.o

reduce_pth.o : reduce_pth.c

fget_atom.o : fget_atom.c /usr/include/stdio.h /usr/include/ctype.h

is_file.o : is_file.c /usr/include/sys/types.h /usr/include/sys/stat.h

mkmk.o : mkmk.c /usr/include/stdio.h lib.h /usr/include/string.h

fget_str.o : fget_str.c /usr/include/stdio.h /usr/include/ctype.h
