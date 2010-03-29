## -*- Makefile -*-
##
## User: impd
## Time: Mar 22, 2010 7:17:41 PM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for umscompile in the ums project in ums/srcc directory.


#### Compiler and tool definitions shared by all build targets #####
ISDP_C_CC	= cc
ISDP_C_DEFINES	= -Di86pc
C_DEFINES	= $(ISDP_C_DEFINES)
ISDP_C_FLAGS	= -g -xCC -Xa -Kpic -m32
CC		= $(ISDP_C_CC)
CPPFLAGS	= -I../include
CFLAGS		= $(CPPFLAGS) $(C_FLAGS) $(C_DEFINES)


# Define the target directories.
ISDP_TARGET   = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/ums
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib
TARGETDIR_BIN = $(TARGETDIR)/bin

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib
INSTALLDIR_BIN = $(ISDP_INSTALL)/bin

TARGET = umscompile

all: $(TARGETDIR_BIN) $(TARGETDIR_OBJ) $(TARGETDIR_BIN)/$(TARGET)

## Target: umscompile
OBJS_umscompile =  \
	$(TARGETDIR_OBJ)/UMScomp.o
SYSLIBS_umscompile = -lm 
USERLIBS_umscompile = $(SYSLIBS_umscompile) -L $(TARGETDIR_LIB) -lUMS
DEPLIBS_umscompile =  
LDLIBS_umscompile = $(USERLIBS_umscompile)


# Link or archive
$(TARGETDIR_BIN)/$(TARGET): $(OBJS_umscompile) $(DEPLIBS_umscompile)
	$(LINK.c) $(CFLAGS_umscompile) $(CPPFLAGS_umscompile) -o $@ $(OBJS_umscompile) $(LDLIBS_umscompile)


# Compile source files into .o files
$(TARGETDIR_OBJ)/UMScomp.o: UMScomp.c
	$(COMPILE.c) $(CFLAGS) -o $@ UMScomp.c

# Install it
install: \
	all \
	$(INSTALLDIR_BIN) \
	$(INSTALLDIR_BIN)/$(TARGET)

$(INSTALLDIR_BIN)/$(TARGET) : $(TARGETDIR_BIN)/$(TARGET)
	cp -p $(TARGETDIR_BIN)/$(TARGET)  $(INSTALLDIR_BIN)

#### Clean target deletes all generated files ####
clean:
	rm -f \
		 $(TARGETDIR_BIN)/umscompile \
		 $(TARGETDIR_OBJ)/UMScomp.o
	rm -f -r $(TARGETDIR_OBJ)

# Create the target directory (if needed)
$(TARGETDIR_BIN):
	mkdir -p $(TARGETDIR_BIN)

$(TARGETDIR_OBJ):
	mkdir -p $(TARGETDIR_OBJ)

$(INSTALLDIR_BIN):
	mkdir -p $(INSTALLDIR_BIN)

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
