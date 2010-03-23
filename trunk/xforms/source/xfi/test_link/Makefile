## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 11:50:52 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##


#### Compiler and tool definitions shared by all build targets #####
CC = cc
BASICOPTS = -g
CFLAGS = $(BASICOPTS) -xCC


# Define the target directories.
ISDP_TARGET = $(HOME)/target
TARGETDIR_XFORMS_XFI     = $(ISDP_TARGET)/xforms/xfi
TARGETDIR_XFORMS_XFI_SRC = $(TARGETDIR_XFORMS_XFI)/test_link
TARGETDIR_XFORMS_XFI_LIB = $(TARGETDIR_XFORMS_XFI)/lib
TARGETDIR_XFORMS_XFI_BIN = $(TARGETDIR_XFORMS_XFI)/bin

all: $(TARGETDIR_XFORMS_XFI_SRC) $(TARGETDIR_XFORMS_XFI_BIN) $(TARGETDIR_XFORMS_XFI_BIN)/xfi_test_link

## Target: xfi_test_link
CPPFLAGS_xfi_test_link = \
	-I../include
OBJS_xfi_test_link =  \
	$(TARGETDIR_XFORMS_XFI_SRC)/main.o
SYSLIBS_xfi_test_link = -lm -lX11
USERLIBS_xfi_test_link = -L $(TARGETDIR_XFORMS_XFI_LIB) -R ../lib:/opt/ingr/lib -lXFI $(SYSLIBS_xfi_test_link)
DEPLIBS_xfi_test_link =   
LDLIBS_xfi_test_link = $(USERLIBS_xfi_test_link)


# Link or archive
$(TARGETDIR_XFORMS_XFI_BIN)/xfi_test_link: $(OBJS_xfi_test_link) $(DEPLIBS_xfi_test_link) $(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so
	$(LINK.c) $(CFLAGS_xfi_test_link) $(CPPFLAGS_xfi_test_link) -o $@ $(OBJS_xfi_test_link) $(LDLIBS_xfi_test_link)


# Compile source files into .o files
$(TARGETDIR_XFORMS_XFI_SRC)/main.o: main.c
	$(COMPILE.c) $(CFLAGS_xfi_test_link) $(CPPFLAGS_xfi_test_link) -o $@ main.c


#### Clean target deletes all generated files ####
clean:
	rm -f \
		 $(TARGETDIR_XFORMS_XFI_BIN)/xfi_test_link
	rm -f -r $(TARGETDIR_XFORMS_XFI_SRC)


# Create the target directory (if needed)
$(TARGETDIR_XFORMS_XFI_SRC):
	mkdir -p $(TARGETDIR_XFORMS_XFI_SRC)

$(TARGETDIR_XFORMS_XFI_BIN):
	mkdir -p $(TARGETDIR_XFORMS_XFI_BIN)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
