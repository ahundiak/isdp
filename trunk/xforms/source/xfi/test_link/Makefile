## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 11:50:52 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for xfi_test_link in the xforms project in source/xfi/testlnk directory.

#### Compiler and tool definitions shared by all build targets #####
ISDP_C_CC	= cc
ISDP_C_FLAGS	= -xCC -Xa -g -Kpic
ISDP_C_DEFINES	= -DSYSV
CC		= $(ISDP_C_CC)
CPPFLAGS	= -I../include
CFLAGS		= $(ISDP_C_FLAGS) $(ISDP_C_DEFINES)


# Define the target directories.
ISDP_TARGET	= $(HOME)/target
TARGETDIR	= $(ISDP_TARGET)/xforms/xfi/test_link
TARGETDIR_OBJ	= $(TARGETDIR)/obj
TARGETDIR_BIN	= $(TARGETDIR)/bin

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib
INSTALLDIR_BIN = $(ISDP_INSTALL)/bin

ISDP_libXFS_DIR		= $(ISDP_TARGET)/fontserver/src/lib
ISDP_libXFS		= -L $(ISDP_libXFS_DIR) -lXFS
ISDP_libXFI_DIR		= $(ISDP_TARGET)/xforms/xfi/lib
ISDP_libXFI		= -L $(ISDP_libXFI_DIR) -lXFI
ISDP_libxc_DIR		= $(ISDP_TARGET)/libxc/lib
ISDP_libxc		= -L $(ISDP_libxc_DIR)/ -lxc
ISDP_libxcmalloc	= -L $(ISDP_libxc_DIR) -lxcmalloc
ISDP_libxcmalloc_debug	= -L $(ISDP_libxc_DIR) -lxcmalloc_debug


## Target: xfi_test_link
OBJS_xfi_test_link =  \
	$(TARGETDIR_OBJ)/main.o
USERLIBS_xfi_test_link	= $(SYSLIBS_Xmain)
DEPLIBS_xfi_test_link	=
LDLIBS_xfi_test_link	= $(USERLIBS_Xmain)
TARGET			= xfi_test_link


all: $(TARGETDIR_OBJ) $(TARGETDIR_BIN) $(TARGETDIR_BIN)/$(TARGET)


# Link or archive
$(TARGETDIR_BIN)/$(TARGET): Makefile $(OBJS_xfi_test_link) $(DEPLIBS_xfi_test_link)
	$(CC) -o $@ $(OBJS_xfi_test_link) $(LDLIBS_xfi_test_link) \
		-R $(ISDP_libXFI_DIR):$(INSTALLDIR_LIB) \
		$(ISDP_libXFI) \
		$(ISDP_libXFS) \
		-lX11 -lm


# Compile source files into .o files
$(TARGETDIR_OBJ)/main.o: main.c
	$(COMPILE.c) main.c -o $@


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
	cp $(TARGETDIR_BIN)/$(TARGET) $(INSTALLDIR_BIN)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
