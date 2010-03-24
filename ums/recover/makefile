UMS           = /usr/xforms/ums
MB            = ./mb
TXT           = ./txt

LIB_DIR       = $(UMS)/lib/$(PROC_TYPE)
INCLUDE_DIR   = $(UMS)/include

UMS_LIB       = $(LIB_DIR)/libUMS.a

CC            = acc
DBGFLAGS      = -ga -O3 -knr
IPATH         = -I$(INCLUDE_DIR) -I$(MB) -I$(TXT)
CFLAGS        = $(DBGFLAGS) $(IPATH)

#MALLOC        = -ldmalloc
MALLOC        = -lmalloc

EXE_DIR       = $(UMS)/bin
EXE           = $(EXE_DIR)/umscompile

CLIX_LIB_LOC  = /usr/lib
SUN_LIB_LOC   = /usr/lib/X11

ARCHIVE       = libX11.a
SHARABLE      = libX11_s.a

# For SunOS
SUN_XLIB      = "$(SUN_LIB_LOC)/$(ARCHIVE)"
# For CLIX
#CLIX_XLIB    = "$(CLIX_LIB_LOC)/$(ARCHIVE)"
CLIX_XLIB     = "$(CLIX_LIB_LOC)/$(SHARABLE)"

BOX=`uname -s`

####################################
# Need to finish this: Check older makefiles for original.
####################################

recover : recover.o $(UMS_LIB)
	$(CC) $(CFLAGS) $(LDFLAGS) -o recover recover.o \
	$(UMS_LIB) $(MALLOC) -lc_s

