## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 10:07:11 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for the xforms project in xforms/source/xfi/src directory to create libXFI.so


#### Compiler and tool definitions shared by all build targets #####
ISDP_C_CC	= cc
ISDP_C_DEFINES	= -Di86pc -Di386 -DSYSV
C_DEFINES	= $(ISDP_C_DEFINES) -DSHFONT -DNDEBUG
ISDP_C_FLAGS	= -g -xCC -Xa -Kpic -m32
CC		= $(ISDP_C_CC)
CPPFLAGS	= -I../include -I../fs_include
CFLAGS		= $(CPPFLAGS) $(ISDP_C_FLAGS) $(C_DEFINES)


# Define the target directories.
ISDP_TARGET = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/xforms/xfi
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

SHAREDLIB_NAME      = libXFI.so
SHAREDLIB_NAME_VER  = libXFI.so.2
ISDP_SHAREDLIB_FLAGS= -g -G -norunpath
SHAREDLIB_FLAGS     = $(ISDP_SHAREDLIB_FLAGS) -h $(SHAREDLIB_NAME_VER)

## Target: XFI
OBJS_XFI =  \
	scroll.o \
	palette.o \
	symbol.o \
	load_sym.o \
	fieldTrack.o \
	Xevent.o \
	button.o \
	gad_sym.o \
	message.o \
	text.o \
	listpi2.o \
	gauge.o \
	16stuff.o \
	fldpi.o \
	fei.o \
	mcf.o \
	field2.o \
	egpi2.o \
	fieldScrl.o \
	fs.o \
	memory.o \
	fieldMove.o \
	copy.o \
	menusub.o \
	fldpi2.o \
	cklst.o \
	miset.o \
	grppi.o \
	toggle.o \
	scale.o \
	gad_loc.o \
	icon.o \
	gad_util.o \
	seq.o \
	mcfpi.o \
	cmd_oid.o \
	gad_text.o \
	setup.o \
	form.o \
	listpi.o \
	dial.o \
	mcfScrlTrk.o \
	import.o \
	gad_disp.o \
	generic.o \
	fieldWrap.o \
	fpi.o \
	load.o \
	gpi.o \
	sym_info.o \
	efpi.o \
	egpi.o \
	pocket.o \
	mpi.o \
	SS.o \
	fldpiRow.o \
	mepi.o \
	iforms_stub.o \
	group.o \
	rect.o \
	save.o \
	panel.o \
	bezel.o \
	hm.o \
	look.o \
	bar.o \
	dump.o \
	pass.o \
	fieldDel.o \
	drawbezel.o \
	find.o \
	slider.o \
	glob.o \
	field.o \
	modify.o \
	line.o \
	common.o \
	gad_mem.o \
	gad_load.o \
	fieldAdd.o

all: $(TARGETDIR_LIB) $(TARGETDIR_OBJ) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)

$(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER): \
		Makefile \
		$(OBJS_XFI)
	$(CC) -o $@ $(OBJS_XFI) $(SHAREDLIB_FLAGS)
	mv $(OBJS_XFI) $(TARGETDIR_OBJ)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)


# Install
install: \
	all \
	$(INSTALLDIR_LIB) \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER)

$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER): $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)
	cp $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)
	rm -f $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)


#### Clean target deletes all generated files ####
clean:
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)*
	rm -f -r $(TARGETDIR_OBJ)


# Create the target directory (if needed)
$(TARGETDIR_OBJ): $(TARGETDIR)
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_LIB): $(TARGETDIR)
	mkdir -p $(TARGETDIR_LIB)

$(TARGETDIR): $(ISDP_TARGET)
	mkdir -p $(TARGETDIR)

$(ISDP_TARGET):
	mkdir -p $(ISDP_TARGET)

$(INSTALLDIR_LIB): $(INSTALL_DIR)
	mkdir -p $(INSTALLDIR_LIB)

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

# Compile source files into .o files
.c.o:
	$(COMPILE.c) $< -o $@


# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
