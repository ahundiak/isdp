CC=/opt/SUNWspro/bin/cc
CFLAGS = -DINTEL_SOLARIS 
BLK=../
INGRHOME=/opt/ingr
NFMDP=../../tdlib
BINDIR=../../tdbin
MSGDIR= ../../config/english/messages
SRCDIR=.
CPU=i386

IPATH = \
	-I . \
	-I $(INGRHOME)/include \
	-I../../include \
	-I/opt/ingr/xformsdp/xfi/include

LINKLIB =  \
	$(BLK)/lib/utl.a \
	$(NFMDP)/libnfma.a \
	$(NFMDP)/libnfmr.a \
	$(NFMDP)/libfilexfer.a \
	$(NFMDP)/libnfmtools.a \
	$(NFMDP)/libdbtools.a \
	$(NFMDP)/libsystools.a \
	$(NFMDP)/libnfmnet.a \
	$(NFMDP)/libtli.a \
	$(NFMDP)/libnfmmem.a \
	$(NFMDP)/libnfmerr.a \
	$(NFMDP)/libalter.a
#	$(INGRHOME)/lib/libftft.so.010 \
#	$(TMPHOME)/FTRlib.so \

BLK_objects = \
	BLRISdelete.o	BLRISinsert.o	BLRISpreload.o	BL_ftr.o \
	BLadditem.o	BLaddset.o	BLbulkload.o	BLcatalog.o \
	BLcheckin.o	BLcheckout.o	BLconvertblk.o	BLcopy.o \
	BLcreate_cat.o	BLdatarec.o	BLdeleteitem.o	BLmain.o \
	BLmanip_data.o	BLmirror.o	BLmodify.o	BLproject.o \
	BLutilities.o	BLset.o

other_objects = \
	NFM2_stuff.o	SS_vararg.o

all : $(SRCDIR)/BLums.h $(BINDIR)/BLUbulkload
#all : BLums.h $(BINDIR)/BLUbulkload

clean : 
	\rm -f $(BLK_objects) $(SRCDIR)/BLums.h $(MSGDIR)/BLums.msg \
		$(BINDIR)/BLUbulkload \
		$(other_objects) 

$(BLK_objects) :	BLums.h BLdefs.h BLvars.h BLtypes.h
BLcreate_cat.o :	MCC_make_red.h
NFM2_stuff.o :		MDSstruct.h NFM2_errors.h

#BLums.h: BLums.txt
#	umscompile -m $(MSGDIR)/BLums.msg -p BLums.h $(MSGDIR)/BLums.txt
#	cp BLums.txt BLums.msg $(BLK)/config/$(CPU)

$(BINDIR)/BLUbulkload: \
	$(LINKLIB) $(BLK_objects) $(other_objects)
	$(CC) $(CFLAGS) -o $(BINDIR)/BLUbulkload \
	$(BLK_objects) $(other_objects) $(LINKLIB) \
	-lUMS -ll -lnsl -lm -lform -lsocket -ldl -lgen

.c.o:
	$(CC) -g -c $(CFLAGS) $(IPATH) $*.c
