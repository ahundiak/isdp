## -*- Makefile -*-
##
## User: impd
## Time: Mar 22, 2010 7:32:51 PM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for the ums project in src/cfiles directory to create libUMS.so


#### Compiler and tool definitions shared by all build targets #####
ISDP_C_CC	= cc
ISDP_C_DEFINES	= -Di86pc
ISDP_C_FLAGS	= -g -xCC -Xa -Kpic -m32
CC		= $(ISDP_C_CC)
CPPFLAGS	= -I../include
CFLAGS		= $(CPPFLAGS) $(ISDP_C_FLAGS) $(ISDP_C_DEFINES)


# Define the target directories.
ISDP_TARGET   = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/ums
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

SHAREDLIB_NAME      = libUMS.so
SHAREDLIB_NAME_VER  = libUMS.so.1
ISDP_SHAREDLIB_FLAGS= -g -G -norunpath
SHAREDLIB_FLAGS     = $(ISDP_SHAREDLIB_FLAGS) -h $(SHAREDLIB_NAME_VER)

## Target: UMS
OBJS_UMS =  \
	COMPcall.o \
	COMPmsg.o \
	COMPread.o \
	COMPwrit.o \
	UMSfile.o \
	UMSgbkey.o \
	UMSgbnum.o \
	UMSinitm.o \
	UMSkeyby.o \
	UMSmsgco.o \
	UMSmsgfm.o \
	UMSnumby.o \
	UMSrbkey.o \
	UMSrbnum.o \
	getopt.o

all: $(TARGETDIR_LIB) $(TARGETDIR_OBJ) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)

# Link or archive
$(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER): \
		Makefile \
		$(OBJS_UMS)
	$(CC) -o $@ $(OBJS_UMS) $(SHAREDLIB_FLAGS)
	mv $(OBJS_UMS) $(TARGETDIR_OBJ)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)

# Install
install: \
	all \
	$(INSTALLDIR_LIB) \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER)

$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER) : $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)
	cp $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)  $(INSTALLDIR_LIB)
	rm -f $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)


# Clean up
clean:
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)*
	rm -f -r $(TARGETDIR_OBJ)


# Create the target directory (if needed)
$(TARGETDIR_OBJ): $(TARGETDIR)
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_LIB): $(TARGETDIR)
	mkdir -p $(TARGETDIR_LIB)

$(TARGETDIR): $(ISDP_TARGET)
	@mkdir -p $(TARGETDIR)

$(ISDP_TARGET):
	@mkdir -p $(ISDP_TARGET)

$(INSTALLDIR_LIB): $(INSTALLDIR)
	mkdir -p $(INSTALLDIR_LIB)

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

# Compile source files into .o files
.c.o:
	$(COMPILE.c) $< -o $@

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
