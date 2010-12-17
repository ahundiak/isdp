CC=/opt/SUNWspro/bin/cc
CFLAGS = -g
EXE_DIR = $(BLK)/build/bin/$(CPU)
LIBDIR=../tdlib
BINDIR=../tdbin
OSFLAG=-Dsolaris
NFMDP=../BLUbulk

IPATH = \
	-I . \
	-I $(INGRHOME)/include \
	-I$(BLK)/build/include \
	-I$(NFMDP)/include

LINKLIB =  \
	$(BLK)/build/lib/$(CPU)/utl.a \
	$(INGRHOME)/lib/libftft.so.010 \
	$(INGRHOME)/lib/libFTR.so \
	$(NFMDP)/sollib/libnfma.a \
	$(NFMDP)/sollib/libnfmr.a \
	$(NFMDP)/sollib/libfilexfer.a \
	$(NFMDP)/sollib/libnfmtools.a \
	$(NFMDP)/sollib/libdbtools.a \
	$(NFMDP)/sollib/libsystools.a \
	$(NFMDP)/sollib/libnfmnet.a \
	$(NFMDP)/sollib/libtli.a \
	$(NFMDP)/sollib/libnfmmem.a \
	$(NFMDP)/sollib/libnfmerr.a \
	$(NFMDP)/sollib/libalter.a

BLK_objects = \
	BLRISdelete.o	BLRISinsert.o	BLRISpreload.o	BL_ftr.o \
	BLadditem.o	BLaddset.o	BLbulkload.o	BLcatalog.o \
	BLcheckin.o	BLcheckout.o	BLconvertblk.o	BLcopy.o \
	BLcreate_cat.o	BLdatarec.o	BLdeleteitem.o	BLmain.o \
	BLmanip_data.o	BLmirror.o	BLmodify.o	BLproject.o \
	BLutilities.o	BLset.o

other_objects = \
	NFM2_stuff.o	SS_vararg.o

all : BLums.h $(BLK)/build/bin/$(CPU)/BLUbulkload

clean : 
	\rm -f $(BLK_objects) BLums.h BLums.msg \
		$(BLK)/build/bin/i386/BLUbulkload \
		$(other_objects) $(BLK)/build/config/$(CPU)/BLums*

$(BLK_objects) :	BLums.h BLdefs.h BLvars.h BLtypes.h
BLcreate_cat.o :	MCC_make_red.h
NFM2_stuff.o :		MDSstruct.h NFM2_errors.h

BLums.h: BLums.txt
	umscompile -m BLums.msg -p BLums.h BLums.txt
	cp BLums.txt BLums.msg $(BLK)/build/config/$(CPU)

$(BLK)/build/bin/$(CPU)/BLUbulkload: \
	$(LINKLIB) $(BLK_objects) $(other_objects)
	$(CC) $(CFLAGS) -o $(BLK)/build/bin/$(CPU)/BLUbulkload \
	$(BLK_objects) $(other_objects) $(LINKLIB) \
	-lUMS -ll -lnsl -lm -lform -lsocket -ldl -lgen

.c.o:
	$(CC) -c $(CFLAGS) $(IPATH) $*.c
