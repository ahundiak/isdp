## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 10:07:11 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##


#### Compiler and tool definitions shared by all build targets #####
CC = cc
AS=as
BASICOPTS = -g
CFLAGS = $(BASICOPTS) -xCC -Xa


# Define the target directories.
ISDP_TARGET = $(HOME)/target
TARGETDIR_XFORMS_XFI     = $(ISDP_TARGET)/xforms/xfi
TARGETDIR_XFORMS_XFI_SRC = $(TARGETDIR_XFORMS_XFI)/src
TARGETDIR_XFORMS_XFI_LIB = $(TARGETDIR_XFORMS_XFI)/lib

all: $(TARGETDIR_XFORMS_XFI_LIB) $(TARGETDIR_XFORMS_XFI_SRC) $(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so.2

## Target: XFS
CFLAGS_XFS = -Kpic 
CPPFLAGS_XFS = \
	-I../include \
	-I../fs_include
OBJS_XFS =  \
	$(TARGETDIR_XFORMS_XFI_SRC)/scroll.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/palette.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/symbol.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/load_sym.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fieldTrack.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/Xevent.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/button.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_sym.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/message.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/text.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/listpi2.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gauge.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/16stuff.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fldpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fei.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/mcf.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/field2.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/egpi2.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fieldScrl.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fs.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/memory.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fieldMove.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/copy.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/menusub.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fldpi2.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/cklst.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/miset.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/grppi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/toggle.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/scale.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_loc.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/icon.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_util.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/seq.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/mcfpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/cmd_oid.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_text.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/setup.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/form.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/listpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/dial.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/mcfScrlTrk.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/import.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_disp.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/generic.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fieldWrap.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/load.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/sym_info.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/efpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/egpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/pocket.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/mpi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/SS.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fldpiRow.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/mepi.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/iforms_stub.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/group.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/rect.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/save.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/panel.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/bezel.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/hm.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/look.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/bar.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/dump.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/pass.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fieldDel.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/drawbezel.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/find.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/slider.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/glob.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/field.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/modify.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/line.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/common.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_mem.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/gad_load.o \
	$(TARGETDIR_XFORMS_XFI_SRC)/fieldAdd.o


# Link or archive
SHAREDLIB_FLAGS_XFS = -G -norunpath -h libXFS.so.2
$(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so.2: $(OBJS_XFS) $(DEPLIBS_XFS)
	$(LINK.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ $(OBJS_XFS) $(SHAREDLIB_FLAGS_XFS) $(LDLIBS_XFS)
	ln -s $(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so.2 $(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so

# Compile source files into .o files
$(TARGETDIR_XFORMS_XFI_SRC)/scroll.o: scroll.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ scroll.c

$(TARGETDIR_XFORMS_XFI_SRC)/palette.o: palette.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ palette.c

$(TARGETDIR_XFORMS_XFI_SRC)/symbol.o: symbol.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ symbol.c

$(TARGETDIR_XFORMS_XFI_SRC)/load_sym.o: load_sym.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ load_sym.c

$(TARGETDIR_XFORMS_XFI_SRC)/fieldTrack.o: fieldTrack.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fieldTrack.c

$(TARGETDIR_XFORMS_XFI_SRC)/Xevent.o: Xevent.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ Xevent.c

$(TARGETDIR_XFORMS_XFI_SRC)/button.o: button.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ button.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_sym.o: gad_sym.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_sym.c

$(TARGETDIR_XFORMS_XFI_SRC)/message.o: message.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ message.c

$(TARGETDIR_XFORMS_XFI_SRC)/text.o: text.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ text.c

$(TARGETDIR_XFORMS_XFI_SRC)/listpi2.o: listpi2.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ listpi2.c

$(TARGETDIR_XFORMS_XFI_SRC)/gauge.o: gauge.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gauge.c

$(TARGETDIR_XFORMS_XFI_SRC)/16stuff.o: 16stuff.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ 16stuff.c

$(TARGETDIR_XFORMS_XFI_SRC)/fldpi.o: fldpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fldpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/fei.o: fei.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fei.c

$(TARGETDIR_XFORMS_XFI_SRC)/mcf.o: mcf.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ mcf.c

$(TARGETDIR_XFORMS_XFI_SRC)/field2.o: field2.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ field2.c

$(TARGETDIR_XFORMS_XFI_SRC)/egpi2.o: egpi2.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ egpi2.c

$(TARGETDIR_XFORMS_XFI_SRC)/fieldScrl.o: fieldScrl.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fieldScrl.c

$(TARGETDIR_XFORMS_XFI_SRC)/fs.o: fs.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fs.c

$(TARGETDIR_XFORMS_XFI_SRC)/memory.o: memory.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ memory.c

$(TARGETDIR_XFORMS_XFI_SRC)/fieldMove.o: fieldMove.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fieldMove.c

$(TARGETDIR_XFORMS_XFI_SRC)/copy.o: copy.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ copy.c

$(TARGETDIR_XFORMS_XFI_SRC)/menusub.o: menusub.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ menusub.c

$(TARGETDIR_XFORMS_XFI_SRC)/fldpi2.o: fldpi2.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fldpi2.c

$(TARGETDIR_XFORMS_XFI_SRC)/cklst.o: cklst.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ cklst.c

$(TARGETDIR_XFORMS_XFI_SRC)/miset.o: miset.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ miset.c

$(TARGETDIR_XFORMS_XFI_SRC)/grppi.o: grppi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ grppi.c

$(TARGETDIR_XFORMS_XFI_SRC)/toggle.o: toggle.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ toggle.c

$(TARGETDIR_XFORMS_XFI_SRC)/scale.o: scale.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ scale.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_loc.o: gad_loc.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_loc.c

$(TARGETDIR_XFORMS_XFI_SRC)/icon.o: icon.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ icon.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_util.o: gad_util.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_util.c

$(TARGETDIR_XFORMS_XFI_SRC)/seq.o: seq.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ seq.c

$(TARGETDIR_XFORMS_XFI_SRC)/mcfpi.o: mcfpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ mcfpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/cmd_oid.o: cmd_oid.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ cmd_oid.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_text.o: gad_text.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_text.c

$(TARGETDIR_XFORMS_XFI_SRC)/setup.o: setup.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ setup.c

$(TARGETDIR_XFORMS_XFI_SRC)/form.o: form.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ form.c

$(TARGETDIR_XFORMS_XFI_SRC)/listpi.o: listpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ listpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/dial.o: dial.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ dial.c

$(TARGETDIR_XFORMS_XFI_SRC)/mcfScrlTrk.o: mcfScrlTrk.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ mcfScrlTrk.c

$(TARGETDIR_XFORMS_XFI_SRC)/import.o: import.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ import.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_disp.o: gad_disp.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_disp.c

$(TARGETDIR_XFORMS_XFI_SRC)/generic.o: generic.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ generic.c

$(TARGETDIR_XFORMS_XFI_SRC)/fieldWrap.o: fieldWrap.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fieldWrap.c

$(TARGETDIR_XFORMS_XFI_SRC)/fpi.o: fpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/load.o: load.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ load.c

$(TARGETDIR_XFORMS_XFI_SRC)/gpi.o: gpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/sym_info.o: sym_info.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ sym_info.c

$(TARGETDIR_XFORMS_XFI_SRC)/efpi.o: efpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ efpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/egpi.o: egpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ egpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/pocket.o: pocket.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ pocket.c

$(TARGETDIR_XFORMS_XFI_SRC)/mpi.o: mpi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ mpi.c

$(TARGETDIR_XFORMS_XFI_SRC)/SS.o: SS.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ SS.c

$(TARGETDIR_XFORMS_XFI_SRC)/fldpiRow.o: fldpiRow.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fldpiRow.c

$(TARGETDIR_XFORMS_XFI_SRC)/mepi.o: mepi.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ mepi.c

$(TARGETDIR_XFORMS_XFI_SRC)/iforms_stub.o: iforms_stub.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ iforms_stub.c

$(TARGETDIR_XFORMS_XFI_SRC)/group.o: group.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ group.c

$(TARGETDIR_XFORMS_XFI_SRC)/rect.o: rect.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ rect.c

$(TARGETDIR_XFORMS_XFI_SRC)/save.o: save.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ save.c

$(TARGETDIR_XFORMS_XFI_SRC)/panel.o: panel.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ panel.c

$(TARGETDIR_XFORMS_XFI_SRC)/bezel.o: bezel.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ bezel.c

$(TARGETDIR_XFORMS_XFI_SRC)/hm.o: hm.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ hm.c

$(TARGETDIR_XFORMS_XFI_SRC)/look.o: look.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ look.c

$(TARGETDIR_XFORMS_XFI_SRC)/bar.o: bar.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ bar.c

$(TARGETDIR_XFORMS_XFI_SRC)/dump.o: dump.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ dump.c

$(TARGETDIR_XFORMS_XFI_SRC)/pass.o: pass.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ pass.c

$(TARGETDIR_XFORMS_XFI_SRC)/fieldDel.o: fieldDel.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fieldDel.c

$(TARGETDIR_XFORMS_XFI_SRC)/drawbezel.o: drawbezel.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ drawbezel.c

$(TARGETDIR_XFORMS_XFI_SRC)/find.o: find.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ find.c

$(TARGETDIR_XFORMS_XFI_SRC)/slider.o: slider.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ slider.c

$(TARGETDIR_XFORMS_XFI_SRC)/glob.o: glob.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ glob.c

$(TARGETDIR_XFORMS_XFI_SRC)/field.o: field.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ field.c

$(TARGETDIR_XFORMS_XFI_SRC)/modify.o: modify.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ modify.c

$(TARGETDIR_XFORMS_XFI_SRC)/line.o: line.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ line.c

$(TARGETDIR_XFORMS_XFI_SRC)/common.o: common.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ common.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_mem.o: gad_mem.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_mem.c

$(TARGETDIR_XFORMS_XFI_SRC)/gad_load.o: gad_load.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ gad_load.c

$(TARGETDIR_XFORMS_XFI_SRC)/fieldAdd.o: fieldAdd.c
	$(COMPILE.c) $(CFLAGS_XFS) $(CPPFLAGS_XFS) -o $@ fieldAdd.c




#### Clean target deletes all generated files ####
clean:
	rm -f \
		$(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so \
		$(TARGETDIR_XFORMS_XFI_LIB)/libXFI.so.2 \
	rm -r   $(TARGETDIR_XFORMS_XFI_SRC)


# Create the target directory (if needed)
$(TARGETDIR_XFORMS_XFI_SRC):
	mkdir -p $(TARGETDIR_XFORMS_XFI_SRC)

$(TARGETDIR_XFORMS_XFI_LIB):
	mkdir -p $(TARGETDIR_XFORMS_XFI_LIB)


# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris

