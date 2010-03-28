## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 10:07:11 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for the xforms project in source/xfi/test directory.


#### Compiler and tool definitions shared by all build targets #####
CC = cc
AS = as
BASICOPTS = -g
# NOTE: Sun cc will auto-define macros 'sun' & 'sparc' (SPARC only) and 'i386'
CFLAGS_libXFI_test =
CPPFLAGS_libXFI_test = \
	-I../include \
	-I../fs_include
CFLAGS = $(BASICOPTS) $(CFLAGS_libXFI_test) $(CPPFLAGS_libXFI_test) -xCC -Xa -DSYSV
SHAREDLIB_FLAGS_libXFI_test = -norunpath


# Define the target directories.
ISDP_TARGET = $(HOME)/target
TARGETDIR_XFORMS_libXFI		= $(ISDP_TARGET)/xforms/xfi
TARGETDIR_XFORMS_libXFI_LIB	= $(TARGETDIR_XFORMS_libXFI)/lib
TARGETDIR_XFORMS_libXFS_LIB	= $(ISDP_TARGET)/fontserver/src/lib
TARGETDIR_XFORMS_libXFI_test    = $(TARGETDIR_XFORMS_libXFI)/test
TARGETDIR_XFORMS_libXFI_test_OBJ= $(TARGETDIR_XFORMS_libXFI_test)/obj
TARGETDIR_XFORMS_libXFI_test_BIN= $(TARGETDIR_XFORMS_libXFI)/bin

## Target: XFS

OBJS_TEST =  \
	Xmain.o

Xmain_FILES = \
	BAR_MENU	\
	BAR_MENU2	\
	PANEL_MENU	\
	X_form		\
	X_formSR

all: $(TARGETDIR_XFORMS_libXFI_test_OBJ) $(TARGETDIR_XFORMS_libXFI_test_BIN) Xmain


# Link or archive
Xmain: Makefile $(OBJS_TEST)
	$(CC) -g -o $@ $(OBJS_TEST) $(CFLAGS_libXFI_test) $(SHAREDLIB_FLAGS_libXFI_test) $(LDLIBS_libXFS) \
		-L $(TARGETDIR_XFORMS_libXFI_LIB) -L $(TARGETDIR_XFORMS_libXFS_LIB) \
		-R ../lib:/opt/ingr/lib -lXFI -lXFS -lX11 -lm $(SYSLIBS_xfi_test_link)
	mv $(OBJS_TEST) $(TARGETDIR_XFORMS_libXFI_test_OBJ)
	mv $@ $(TARGETDIR_XFORMS_libXFI_test_BIN)
	cp $(Xmain_FILES) $(TARGETDIR_XFORMS_libXFI_test_BIN)

# Compile source files into .o files
Xmain.o: Makefile Xmain.c
	$(COMPILE.c) $< -o $@


#### Clean target deletes all generated files ####
clean:
	rm -f	$(TARGETDIR_XFORMS_libXFI_test_BIN)/Xmain


# Create the target directory (if needed)
$(TARGETDIR_XFORMS_libXFI_test):
	mkdir -p $(TARGETDIR_XFORMS_libXFI_test)

$(TARGETDIR_XFORMS_libXFI_test_OBJ):
	mkdir -p $(TARGETDIR_XFORMS_libXFI_test_OBJ)

$(TARGETDIR_XFORMS_libXFI_test_BIN):
	mkdir -p $(TARGETDIR_XFORMS_libXFI_test_BIN)/Xmain


# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
