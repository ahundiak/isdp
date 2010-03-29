## -*- Makefile -*-
##
## User: impd
## Time: Mar 25, 2010 9:27:43 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for objtester in the libxc project in libxc/test directory.


#### Compiler and tool definitions shared by all build targets #####
# CC = cc
# BASICOPTS = -g
# CFLAGS = $(BASICOPTS) -xCC -Xa
ISDP_C_CC      = cc
ISDP_C_FLAGS   = -xCC -Xa -g -Kpic
ISDP_C_DEFINES = -DRUN_X -DX11 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DSVR4 -DSUNOS -DSUNOS5 -DSUNOS58 -Di386 -D__i386 -D__i386__ -DINTEL -DUNIX -D__BUILTIN_VA_ARG_INCR
CC = $(ISDP_C_CC)
CPPFLAGS	= -I../inc.pvt -I ../include
CFLAGS = $(ISDP_C_FLAGS) $(ISDP_C_DEFINES)

# Define the target directories.
ISDP_TARGET   = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/libxc
TARGETDIR_OBJ = $(TARGETDIR)/test/obj
TARGETDIR_LIB = $(TARGETDIR)/lib
TARGETDIR_BIN = $(TARGETDIR)/test/bin

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib
INSTALLDIR_BIN = $(ISDP_INSTALL)/bin

## Target: objtester
OBJS_objtester =  \
	objtester.o
USERLIBS_objtester = $(SYSLIBS_objtester)
DEPLIBS_objtester =
LDLIBS_objtester = $(USERLIBS_objtester)
TARGET		= objtester

ISDP_libXFS_DIR		= $(ISDP_TARGET)/fontserver/src/lib
ISDP_libXFS		= -L $(ISDP_libXFS_DIR) -lXFS
ISDP_libXFI_DIR		= $(ISDP_TARGET)/xforms/xfi/lib
ISDP_libXFI		= -L $(ISDP_libXFI_DIR) -lXFI
ISDP_libxc_DIR		= $(ISDP_TARGET)/libxc/lib
ISDP_libxc		= -L $(ISDP_libxc_DIR)/ -lxc
ISDP_libxcmalloc	= -L $(ISDP_libxc_DIR) -lxcmalloc
ISDP_libxcmalloc_debug	= -L $(ISDP_libxc_DIR) -lxcmalloc_debug

all: $(TARGETDIR_OBJ) $(TARGETDIR_BIN) $(TARGETDIR_BIN)/$(TARGET)


# Link or archive
$(TARGETDIR_BIN)/$(TARGET): Makefile $(OBJS_tester) $(DEPLIBS_objtester)
	$(CC) -o $@ $(OBJS_objtester) $(LDLIBS_objtester) \
	$(ISDP_libxc) \
	$(ISDP_libxcmalloc) 
	
# Compile source files into .o files
.c.o: Makefile
	$(COMPILE.c) $< -o $@

#### Clean target deletes all generated files ####
clean:
	rm -f $(TARGETDIR_BIN)/$(TARGET)
	rm -f -r $(TARGETDIR_OBJ)

# Create the target directory (if needed)
$(TARGETDIR_OBJ):  $(TARGETDIR)
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_BIN):  $(TARGETDIR)
	mkdir -p $(TARGETDIR_BIN)

$(TARGETDIR): $(ISDP_TARGET)
	mkdir -p $(TARGETDIR)

$(INSTALLDIR_BIN):  $(INSTALL_DIR)
	mkdir -p $(INSTALLDIR_BIN)

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

# Install it
install: \
	all \
	$(INSTALLDIR_BIN) \
	$(INSTALLDIR_BIN)/$(TARGET)

$(INSTALLDIR_BIN)/$(TARGET):
	cp $(TARGETDIR_BIN)/$(TARGET) $(INSTALLDIR_BIN)/$(TARGET)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
