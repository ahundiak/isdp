.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8
CFLAGS = -DSCO_UNIX
CC=cc
OBJEXT=5
NFM_LIB_DIR=$(NFMDP)/scolib
FTR_LIB_DIR=$(FTRDP)/lib/$(CPU)

EXE_DIR = $(BLK)/build/bin/$(CPU)

IPATH = \
	-I . \
	-I$(BLK)/build/include \
	-I$(NFMDP)/include

NFM_LIBS =  \
	$(BLK)/build/lib/$(CPU)/utl.a \
	$(FTR_LIB_DIR)/FTRlib.a \
	$(NFM_LIB_DIR)/libnfma.a \
	$(NFM_LIB_DIR)/libnfmr.a \
	$(NFM_LIB_DIR)/libfilexfer.a \
	$(NFM_LIB_DIR)/libnfmtools.a \
	$(NFM_LIB_DIR)/libdbtools.a \
	$(NFM_LIB_DIR)/libsystools.a \
	$(NFM_LIB_DIR)/libnfmnet.a \
	$(NFM_LIB_DIR)/libtli.a \
	$(NFM_LIB_DIR)/libnfmmem.a \
	$(NFM_LIB_DIR)/libnfmerr.a \
	$(NFM_LIB_DIR)/alter.a

BLK_objects = \
	BLRISdelete.$(OBJEXT)	BLRISinsert.$(OBJEXT)	\
	BLRISpreload.$(OBJEXT)	BL_ftr.$(OBJEXT)        \
	BLadditem.$(OBJEXT)	BLaddset.$(OBJEXT)      \
	BLbulkload.$(OBJEXT)	BLcatalog.$(OBJEXT)     \
	BLcheckin.$(OBJEXT)	BLcheckout.$(OBJEXT)	\
	BLconvertblk.$(OBJEXT)	BLcopy.$(OBJEXT)        \
	BLcreate_cat.$(OBJEXT)	BLdatarec.$(OBJEXT)	\
	BLdeleteitem.$(OBJEXT)	BLmain.$(OBJEXT)        \
	BLmanip_data.$(OBJEXT)	BLmirror.$(OBJEXT)	\
	BLmodify.$(OBJEXT)	BLproject.$(OBJEXT)     \
	BLutilities.$(OBJEXT)	BLset.$(OBJEXT)

other_objects = \
	NFM2_stuff.$(OBJEXT)	SS_vararg.$(OBJEXT)

all : BLums.h $(BLK)/build/bin/$(CPU)/BLUbulkload

clean : 
	\rm -f $(BLK_objects) BLums.h BLums.msg \
		$(BLK)/build/bin/$(CPU)/BLUbulkload \
		$(other_objects) $(BLK)/build/config/$(CPU)/BLums*

$(BLK_objects) :	BLums.h BLdefs.h BLvars.h BLtypes.h
BLcreate_cat.$(OBJEXT) :	MCC_make_red.h
NFM2_stuff.$(OBJEXT) :		MDSstruct.h NFM2_errors.h

BLums.h: BLums.txt
	umscompile -m BLums.msg -p BLums.h BLums.txt
	cp BLums.txt BLums.msg $(BLK)/build/config/$(CPU)

$(BLK)/build/bin/$(CPU)/BLUbulkload: \
	$(NFM_LIBS) $(BLK_objects) $(other_objects)
	$(CC) -o $(BLK)/build/bin/$(CPU)/BLUbulkload \
	$(BLK_objects) $(other_objects) $(NFM_LIBS) \
        -lnsl_s -ll -lUMS -lmalloc -lm -lsocket -lc_s

#====================================================
.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(CC) -c $(CFLAGS) $(IPATH) $*.c
	@echo
	@mv $*.o $*.$(OBJEXT)
#====================================================
