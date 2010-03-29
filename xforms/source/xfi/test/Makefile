## -*- Makefile -*-
##
## User: impd
## Time: Mar 25, 2010 9:27:43 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for Xmain in the xforms project in source/xfi/test directory.


#### Compiler and tool definitions shared by all build targets #####
# CC = cc
# BASICOPTS = -g
# CFLAGS = $(BASICOPTS) -xCC -Xa
ISDP_C_CC      = cc
ISDP_C_FLAGS   = -xCC -Xa -g -Kpic
ISDP_C_DEFINES = -DSYSV
C_DEFINES	= $(ISDP_C_DEFINES)
CC = $(ISDP_C_CC)
CPPFLAGS	= -I../inc.pvt -I ../include
CFLAGS = $(ISDP_C_FLAGS) $(C_DEFINES)

# Define the target directories.
ISDP_TARGET		= $(HOME)/target
TARGETDIR		= $(ISDP_TARGET)/xforms/xfi
TARGETDIR_OBJ		= $(TARGETDIR)/test/obj
TARGETDIR_LIB		= $(TARGETDIR)/lib
TARGETDIR_BIN		= $(TARGETDIR)/test/bin
TARGETDIR_XFS_LIB	= $(ISDP_TARGET)/fontserver/src/lib

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib
INSTALLDIR_BIN = $(ISDP_INSTALL)/bin

## Target: objtester
OBJS_Xmain =  \
	Xmain.o

Xmain_FILES = \
	BAR_MENU	\
	BAR_MENU2	\
	PANEL_MENU	\
	X_form		\
	X_formSR

USERLIBS_Xmain = $(SYSLIBS_Xmain)
DEPLIBS_Xmain =
LDLIBS_Xmain = $(USERLIBS_Xmain)
TARGET		= Xmain

ISDP_libXFS_DIR		= -$(ISDP_TARGET)/fontserver/src/lib
ISDP_libXFS		= -L $(ISDP_libXFS_DIR) -lXFS
ISDP_libXFI_DIR		= $(ISDP_TARGET)/xforms/xfi/lib
ISDP_libXFI		= -L $(ISDP_libXFI_DIR) -lXFI
ISDP_libxc_DIR		= $(ISDP_TARGET)/libxc/lib
ISDP_libxc		= -L $(ISDP_libxc_DIR) -lxc
ISDP_libxcmalloc	= -L $(ISDP_libxc_DIR) -lxcmalloc
ISDP_libxcmalloc_debug	= -L $(ISDP_libxc_DIR) -lxcmalloc_debug

all: $(TARGETDIR_OBJ) $(TARGETDIR_BIN) $(TARGETDIR_BIN)/$(TARGET)

# Link or archive
$(TARGETDIR_BIN)/$(TARGET): Makefile $(OBJS_Xmain) $(DEPLIBS_Xmain)
	$(CC) -o $@ $(OBJS_Xmain) $(LDLIBS_Xmain) \
		$(ISDP_C_FLAGS)
		-R $(ISDP_libXFI_DIR):$(INSTALLDIR_LIB) \
		$(ISDP_libXFI) \
		$(ISDP_libXFS) \
		-lX11 -lm
	mv $(OBJS_Xmain) $(TARGETDIR_OBJ)
	cp $(Xmain_FILES) $(TARGETDIR_BIN)

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
	$(INSTALLDIR_BIN)/$(TARGET)

$(INSTALLDIR_BIN)/$(TARGET): $(INSTALLDIR_BIN)
	cp $(TARGETDIR_BIN)/$(TARGET) $(INSTALLDIR_BIN)/$(TARGET)
	cp $(Xmain_FILES) $(INSTALLDIR_BIN)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
