## -*- Makefile -*-
##
## User: impd
## Time: Mar 25, 2010 9:27:43 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##


#### Compiler and tool definitions shared by all build targets #####
# CC = cc
# BASICOPTS = -g
# CFLAGS = $(BASICOPTS) -xCC -Xa
ISDP_C_CC      = cc
ISDP_C_FLAGS   = -xCC -Xa -g -Kpic
ISDP_C_DEFINES = -DRUN_X -DX11 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DSVR4 -DSUNOS -DSUNOS5 -DSUNOS58 -Di386 -D__i386 -D__i386__ -DINTEL -DUNIX -D__BUILTIN_VA_ARG_INCR

CC = $(ISDP_C_CC)
CFLAGS = $(ISDP_C_FLAGS) $(ISDP_C_DEFINES)

# Define the target directories.
ISDP_TARGET   = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/deltools
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib
TARGETDIR_BIN = $(TARGETDIR)/bin

ISDP_INSTALL   = $(HOME)/ingr
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib
INSTALLDIR_BIN = $(ISDP_INSTALL)/bin

all: $(TARGETDIR_OBJ) $(TARGETDIR_BIN) $(TARGETDIR_BIN)/dates

## Target: dates
OBJS_dates =  \
	$(TARGETDIR_OBJ)/dates.o
USERLIBS_dates = $(SYSLIBS_dates) 
DEPLIBS_dates =  
LDLIBS_dates = $(USERLIBS_dates)


# Link or archive
$(TARGETDIR_BIN)/dates: $(OBJS_dates) $(DEPLIBS_dates)
	$(CC) $(CFLAGS) -o $@ $(OBJS_dates) $(LDLIBS_dates)
	rm -f $(TARGETDIR_BIN)/prodinfo
	rm -f $(TARGETDIR_BIN)/proddata
	ln -s $(TARGETDIR_BIN)/dates $(TARGETDIR_BIN)/prodinfo
	ln -s $(TARGETDIR_BIN)/dates $(TARGETDIR_BIN)/proddata

# Compile source files into .o files
$(TARGETDIR_OBJ)/dates.o: dates.c
	$(CC) $(CFLAGS) -o $@ -c dates.c


#### Clean target deletes all generated files ####
clean:
	rm -f \
		 $(TARGETDIR_BIN)/dates \
		 $(TARGETDIR_BIN)/prodinfo \
		 $(TARGETDIR_BIN)/proddata \
		 $(TARGETDIR_OBJ)/dates.o
	rm -f -r $(TARGETDIR_OBJ)

# Create the target directory (if needed)
$(TARGETDIR_OBJ):
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_BIN):
	mkdir -p $(TARGETDIR_BIN)

$(INSTALLDIR_BIN):
	mkdir -p $(INSTALLDIR_BIN)

# Install it
install: \
	all \
	$(INSTALLDIR_BIN) \
	$(INSTALLDIR_BIN)/dates

$(INSTALLDIR_BIN)/dates	:
	cp -p $(TARGETDIR_BIN)/dates $(INSTALLDIR_BIN)/dates
	rm -f $(INSTALLDIR_BIN)/prodinfo
	rm -f $(INSTALLDIR_BIN)/proddata
	ln -s $(INSTALLDIR_BIN)/dates $(INSTALLDIR_BIN)/prodinfo
	ln -s $(INSTALLDIR_BIN)/dates $(INSTALLDIR_BIN)/proddata

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris

