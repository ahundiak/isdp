## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 11:50:52 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for the xforms project in source/xfi/test_lnk directory.

#### Compiler and tool definitions shared by all build targets #####
CC = cc
BASICOPTS = -g
CFLAGS = $(BASICOPTS) -xCC


# Define the target directories.
ISDP_TARGET = $(HOME)/target
TARGETDIR_XFORMS_XFI		= $(ISDP_TARGET)/xforms/xfi
TARGETDIR_XFORMS_XFI_SRC	= $(TARGETDIR_XFORMS_XFI)/test_link
TARGETDIR_XFORMS_XFI_LIB	= $(TARGETDIR_XFORMS_XFI)/lib
TARGETDIR_XFORMS_XFI_BIN	= $(TARGETDIR_XFORMS_XFI)/bin
TARGETDIR_FONTSERVER_SRC	= $(ISDP_TARGET)/fontserver/src
TARGETDIR_FONTSERVER_SRC_LIB	= $(TARGETDIR_FONTSERVER_SRC)/lib


## Target: xfi_test_link
CPPFLAGS_xfi_test_link = \
	-I../include
OBJS_xfi_test_link =  \
	main.o
SYSLIBS_xfi_test_link = -lm -lX11
USERLIBS_xfi_test_link = -L $(TARGETDIR_XFORMS_XFI_LIB) -L $(TARGETDIR_FONTSERVER_SRC_LIB) -R ../lib:/opt/ingr/lib -lXFI -lXFS $(SYSLIBS_xfi_test_link)
DEPLIBS_xfi_test_link =   
LDLIBS_xfi_test_link = $(USERLIBS_xfi_test_link)


all: $(TARGETDIR_XFORMS_XFI_SRC) $(TARGETDIR_XFORMS_XFI_BIN) xfi_test_link


# Link or archive
xfi_test_link: $(OBJS_xfi_test_link) $(DEPLIBS_xfi_test_link)
	$(LINK.c) $(CFLAGS_xfi_test_link) \
		$(CPPFLAGS_xfi_test_link) -o $@ \
		$(OBJS_xfi_test_link) \
		$(LDLIBS_xfi_test_link)
	mv main.o $(TARGETDIR_XFORMS_XFI_SRC)
	mv xfi_test_link $(TARGETDIR_XFORMS_XFI_BIN)


# Compile source files into .o files
main.o: main.c
	$(COMPILE.c) $(CFLAGS_xfi_test_link) $(CPPFLAGS_xfi_test_link) -o $@ main.c


#### Clean target deletes all generated files ####
clean:
	rm -f $(TARGETDIR_XFORMS_XFI_BIN)/xfi_test_link
	rm -f -r $(TARGETDIR_XFORMS_XFI_SRC)


# Create the target directory (if needed)
$(TARGETDIR_XFORMS_XFI_SRC):
	mkdir -p $(TARGETDIR_XFORMS_XFI_SRC)

$(TARGETDIR_XFORMS_XFI_BIN):
	mkdir -p $(TARGETDIR_XFORMS_XFI_BIN)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
