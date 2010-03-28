## -*- Makefile -*-
##
## User: impd
## Time: Mar 22, 2010 7:17:41 PM
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
TARGETDIR_BIN = $(TARGETDIR)/bin

ISDP_INSTALL   = $(HOME)/ingr
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib
INSTALLDIR_BIN = $(ISDP_INSTALL)/bin

EXEC_NAME = umscompile

all: $(TARGETDIR_BIN) $(TARGETDIR_OBJ) $(TARGETDIR_BIN)/$(EXEC_NAME)

## Target: umscompile
OBJS_umscompile =  \
	$(TARGETDIR_OBJ)/UMScomp.o
CPPFLAGS_umscompile = -I../include
SYSLIBS_umscompile = -lm 
USERLIBS_umscompile = $(SYSLIBS_umscompile) -L $(TARGETDIR_LIB) -lUMS
DEPLIBS_umscompile =  
LDLIBS_umscompile = $(USERLIBS_umscompile)


# Link or archive
$(TARGETDIR_BIN)/$(EXEC_NAME): $(OBJS_umscompile) $(DEPLIBS_umscompile)
	$(LINK.c) $(CFLAGS_umscompile) $(CPPFLAGS_umscompile) -o $@ $(OBJS_umscompile) $(LDLIBS_umscompile)


# Compile source files into .o files
$(TARGETDIR_OBJ)/UMScomp.o: UMScomp.c
	$(COMPILE.c) $(CFLAGS_umscompile) $(CPPFLAGS_umscompile) -o $@ UMScomp.c

# Install it
install: \
	all \
	$(INSTALLDIR_BIN) \
	$(INSTALLDIR_BIN)/$(EXEC_NAME)

$(INSTALLDIR_BIN)/$(EXEC_NAME) : $(TARGETDIR_BIN)/$(EXEC_NAME)
	cp -p $(TARGETDIR_BIN)/$(EXEC_NAME)  $(INSTALLDIR_BIN)

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

