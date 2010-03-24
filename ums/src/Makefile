## -*- Makefile -*-
##
## User: impd
## Time: Mar 22, 2010 7:32:51 PM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##


#### Compiler and tool definitions shared by all build targets #####
CC = cc
BASICOPTS = -g
CFLAGS = $(BASICOPTS) -xCC


# Define the target directories.
ISDP_TARGET   = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/ums
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib

ISDP_INSTALL   = $(HOME)/ingr
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

SHAREDLIB_NAME      = libUMS.so
SHAREDLIB_NAME_VER  = libUMS.so.1
SHAREDLIB_FLAGS     = -G -norunpath -h $(SHAREDLIB_NAME_VER)

all: $(TARGETDIR_LIB) $(TARGETDIR_OBJ) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)

## Target: UMS
CFLAGS_UMS = -Kpic 
OBJS_UMS =  \
	$(TARGETDIR_OBJ)/COMPcall.o \
	$(TARGETDIR_OBJ)/COMPmsg.o \
	$(TARGETDIR_OBJ)/COMPread.o \
	$(TARGETDIR_OBJ)/COMPwrit.o \
	$(TARGETDIR_OBJ)/UMSfile.o \
	$(TARGETDIR_OBJ)/UMSgbkey.o \
	$(TARGETDIR_OBJ)/UMSgbnum.o \
	$(TARGETDIR_OBJ)/UMSinitm.o \
	$(TARGETDIR_OBJ)/UMSkeyby.o \
	$(TARGETDIR_OBJ)/UMSmsgco.o \
	$(TARGETDIR_OBJ)/UMSmsgfm.o \
	$(TARGETDIR_OBJ)/UMSnumby.o \
	$(TARGETDIR_OBJ)/UMSrbkey.o \
	$(TARGETDIR_OBJ)/UMSrbnum.o \
	$(TARGETDIR_OBJ)/getopt.o

CPPFLAGS_UMS = -I../include

# Link or archive
$(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER): $(OBJS_UMS) $(DEPLIBS_UMS)
	$(LINK.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ $(OBJS_UMS) $(SHAREDLIB_FLAGS) $(LDLIBS_UMS)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)

# Compile source files into .o files
$(TARGETDIR_OBJ)/COMPcall.o: COMPcall.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ COMPcall.c

$(TARGETDIR_OBJ)/COMPmsg.o:  COMPmsg.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ COMPmsg.c

$(TARGETDIR_OBJ)/COMPread.o: COMPread.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ COMPread.c

$(TARGETDIR_OBJ)/COMPwrit.o: COMPwrit.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ COMPwrit.c

$(TARGETDIR_OBJ)/UMSfile.o: UMSfile.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSfile.c

$(TARGETDIR_OBJ)/UMSgbkey.o: UMSgbkey.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSgbkey.c

$(TARGETDIR_OBJ)/UMSgbnum.o: UMSgbnum.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSgbnum.c

$(TARGETDIR_OBJ)/UMSinitm.o: UMSinitm.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSinitm.c

$(TARGETDIR_OBJ)/UMSkeyby.o: UMSkeyby.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSkeyby.c

$(TARGETDIR_OBJ)/UMSmsgco.o: UMSmsgco.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSmsgco.c

$(TARGETDIR_OBJ)/UMSmsgfm.o: UMSmsgfm.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSmsgfm.c

$(TARGETDIR_OBJ)/UMSnumby.o: UMSnumby.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSnumby.c

$(TARGETDIR_OBJ)/UMSrbkey.o: UMSrbkey.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSrbkey.c

$(TARGETDIR_OBJ)/UMSrbnum.o: UMSrbnum.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ UMSrbnum.c

$(TARGETDIR_OBJ)/getopt.o: getopt.c
	$(COMPILE.c) $(CFLAGS_UMS) $(CPPFLAGS_UMS) -o $@ getopt.c

# Install
install: \
	all \
	$(INSTALLDIR_LIB) \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER)

$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER) : $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)
	cp -p $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)  $(INSTALLDIR_LIB)
	rm -f $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)


# Clean up
clean:
	rm -f \
		 $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_UMS)* \
		 $(TARGETDIR_OBJ)/*.o
	rm -f -r $(TARGETDIR_OBJ)


# Create the target directory (if needed)
$(TARGETDIR_OBJ):
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_LIB):
	mkdir -p $(TARGETDIR_LIB)

$(INSTALLDIR_LIB):
	mkdir -p $(INSTALLDIR_LIB)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris

