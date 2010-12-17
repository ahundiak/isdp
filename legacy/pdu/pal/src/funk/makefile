.PRECIOUS:

.SUFFIXES: .a .I .c .o

LINKOPT =

SRC = .

OPPFLAGS =  \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(BS)/include \
	-I$(PDM)/include \
	-I$(PDU)/include \
	-I$(NFM)/include \
	-I$(FPAL)/include \
	-I$(FORMS)/include \
	-I$(EXNUC)/spec \
	-I$(GRNUC)/spec \
	-I$(SRC)

IPATH =  \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(BS)/include \
	-I$(PDM)/include \
	-I$(PDU)/include \
	-I$(NFM)/include \
	-I$(FPAL)/include \
	-I$(FORMS)/include

opp = $(EXNUC)/bin/opp

omcpp = $(EXNUC)/bin/omcpp

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	GRpuldwnlst.o \
	PALtools.o \
	PDMClsCats.o \
	PDMpdmparams.o \
	PDMselprt.o \
	PLM_functs.o \
	parsit.o \
	PALmodsplatr.o \
	PALmacintf.o \
	PALgetfmt.o

imp_objects = \
	MOlocate.o \
	PDMchekin.o \
	PDMdynpar.o \
	PDMgetrle.o \
	PDMplprt.o \
	SelMacUtil.o \
	parse_fun.o \
	PDMattach.o \
	feet_depend.o \
	PDMmodprt.o \
	PDMdyncmp.o \
	PDMcpyprt.o \
	PDMmapcoll.o \
	ismacdef.o

objects = \
	$(c_objects) \
	$(imp_objects) 


# main target

target: \
	PDUfunk.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUfunk.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUfunk.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUfunk.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUfunk.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

GRpuldwnlst.o : \
	$(SRC)/GRpuldwnlst.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FI.h

PALtools.o : \
	$(SRC)/PALtools.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	$(PDU)/include/PALmsg.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/exdef.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PDMClsCats.o : \
	$(SRC)/PDMClsCats.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/standards.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/malloc.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(PDU)/include/PDUcommand.h \
	$(NFM)/include/MEMerrordef.h \
	$(FPAL)/include/PALglbs.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/exdef.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PDMpdmparams.o : \
	$(SRC)/PDMpdmparams.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/standards.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/malloc.h \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALglbs.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/exdef.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PDMselprt.o : \
	$(SRC)/PDMselprt.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/standards.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/exdef.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PALmsg.h \
	$(GRNUC)/include/ACattrib.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDMmessage.h \
	$(FORMS)/include/FI.h \
	$(FPAL)/include/PALlctypes.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PLM_functs.o : \
	$(SRC)/PLM_functs.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/malloc.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDM)/include/PDMdebug.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/griodef.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PALmsg.h \
	$(NFM)/include/MEMerrordef.h \
	$(FORMS)/include/FI.h \
	$(PDU)/include/PDUuser.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

parsit.o : \
	$(SRC)/parsit.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h

PALmodsplatr.o : \
	$(SRC)/PALmodsplatr.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/ctype.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUint.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(NFM)/include/MEMerrordef.h \
	$(FORMS)/include/FI.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUuser.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUstorage.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/exdef.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PALmacintf.o : \
	$(SRC)/PALmacintf.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	/usr/include/standards.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(EXNUC)/include/exdef.h \
	$(FPAL)/include/PALglbs.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PALmsg.h \
	$(GRNUC)/include/ACattrib.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(GRNUC)/include/tools.h \
	$(FORMS)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PALgetfmt.o : \
	$(SRC)/PALgetfmt.c \
	$(EXNUC)/include/exdef.h \
	$(FORMS)/include/FI.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUerror.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDM)/include/PDMdebug.h \
	$(NFM)/include/MEMstruct.h \
	$(NFM)/include/MEMerrordef.h

MOlocate.o : \
	$(SRC)/MOlocate.I \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/stddef.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/lcmacros.h \
	$(EXNUC)/include/exdef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/tools.h \
	$(EXNUC)/include/wl.h \
	$(EXNUC)/include/exproto.h \
	$(EXNUC)/include/exmacros.h

PDMchekin.o : \
	$(SRC)/PDMchekin.I \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/fs/s5param.h \
	/usr/include/sys/param.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUmacros.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/ci_mac_def.h \
	$(GRNUC)/include/ci_macro.h \
	$(GRNUC)/include/cisymb.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(GRNUC)/include/DImacros.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(PDU)/include/MOmacros.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUfile_def.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(PDU)/include/PDUerror.h \
	$(FPAL)/include/PALglbs.h \
	$(FORMS)/include/FI.h \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(GRNUC)/spec/ACcomplex.S \
	$(GRNUC)/spec/ACmacro_defn.S \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/spec/ACdiowner.S \
	$(GRNUC)/spec/ACrg_collect.S \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/include/ACdb_info.h \
	$(GRNUC)/spec/ACdb_info.S \
	$(GRNUC)/spec/ACncpx.S \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/spec/ACcpx_defn.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/spec/expression.S

PDMdynpar.o : \
	$(SRC)/PDMdynpar.I \
	/usr/include/stddef.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUmacros.h \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/sunlimits.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(GRNUC)/include/ci_mac_def.h \
	$(GRNUC)/include/ci_macro.h \
	$(GRNUC)/include/cisymb.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msdef.h \
	$(EXNUC)/include/msmacros.h \
	$(PDU)/include/PALmsg.h \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/include/asmacros.h \
	$(GRNUC)/include/asbox.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lcmacros.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpmacros.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(GRNUC)/include/DImacros.h \
	$(FORMS)/include/FI.h \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALglbs.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h

PDMgetrle.o : \
	$(SRC)/PDMgetrle.I \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(EXNUC)/spec/super_cmd.S \
	$(GRNUC)/include/OMprimindex.h \
	$(GRNUC)/include/codef.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/grerr.h \
	$(GRNUC)/include/grdpbdef.h \
	$(GRNUC)/include/grdpb.h \
	$(GRNUC)/include/griomacros.h \
	$(GRNUC)/include/ciinclude.h \
	/usr/include/sys/fs/s5param.h \
	/usr/include/sys/param.h \
	/usr/include/rand48.h \
	/usr/include/stdlib.h \
	$(GRNUC)/include/cidef.h \
	/usr/include/setjmp.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h \
	/usr/include/float.h \
	/usr/include/limits.h \
	$(GRNUC)/include/citypedef.h \
	$(GRNUC)/include/ciprivmacros.h \
	$(GRNUC)/include/ci.h \
	$(GRNUC)/spec/ci.S \
	/usr/include/malloc.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/ciexecdef.h \
	$(GRNUC)/include/ciexecmacros.h \
	$(GRNUC)/include/COmdef.h \
	$(FORMS)/include/FI.h \
	$(PDU)/include/MOmacros.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(GRNUC)/spec/ACcomplex.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/igrdef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/spec/ACcpx_defn.S \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACmacro_defn.S \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALglbs.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(PDU)/include/PDUfile_def.h

PDMplprt.o : \
	$(SRC)/PDMplprt.I \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(FORMS)/include/FI.h \
	$(GRNUC)/include/ACdyn_col.h \
	$(GRNUC)/include/grdpbdef.h \
	$(GRNUC)/include/grdpbmacros.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(FPAL)/include/PALglbs.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/tools.h \
	$(EXNUC)/include/wl.h \
	$(EXNUC)/include/exproto.h \
	$(EXNUC)/include/exmacros.h \
	$(GRNUC)/include/expression.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(GRNUC)/include/acdef.h \
	$(GRNUC)/include/acmacros.h \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(GRNUC)/spec/ci_macro.S \
	$(GRNUC)/spec/expression.S \
	$(GRNUC)/spec/text_exp.S \
	$(GRNUC)/include/ACrg_collect.h \
	$(GRNUC)/spec/ACdyn_col.S \
	$(GRNUC)/spec/ACcomplex.S \
	$(GRNUC)/spec/ACcpx_defn.S \
	$(GRNUC)/spec/ACmacro_defn.S \
	$(GRNUC)/spec/GRlbsys.S \
	$(GRNUC)/spec/GRsmhdr.S \
	$(GRNUC)/include/ACheader.h \
	$(GRNUC)/spec/ACheader.S \
	$(GRNUC)/spec/ACconst.S \
	$(GRNUC)/spec/ACpretend.S \
	$(GRNUC)/spec/ACpretdef.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/include/ACdb_info.h \
	$(GRNUC)/spec/ACdb_info.S \
	$(GRNUC)/spec/ACncpx.S \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/spec/GRnotify.S \
	$(EXNUC)/include/OMindex.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/igrdef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/spec/ACdiowner.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/NDnode.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/ACrg_collect.S

SelMacUtil.o : \
	$(SRC)/SelMacUtil.I \
	$(GRNUC)/spec/expression.S \
	$(GRNUC)/include/expmacros.h \
	$(GRNUC)/include/asdef.h \
	$(GRNUC)/include/asbox.h \
	$(GRNUC)/include/asmacros.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(GRNUC)/include/DImacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(GRNUC)/spec/GRnotify.S \
	$(EXNUC)/include/OMindex.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/igrdef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/NDnode.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACpretend.S

parse_fun.o : \
	$(SRC)/parse_fun.I \
	$(GRNUC)/include/expression.h \
	$(GRNUC)/include/expmacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(GRNUC)/include/GMhcode.h \
	$(GRNUC)/include/GMlist.h \
	$(GRNUC)/include/GM.h \
	$(GRNUC)/include/GMmacros.h \
	$(GRNUC)/include/ndmacros.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(GRNUC)/include/DImacros.h \
	$(PDU)/include/PDUerror.h \
	$(GRNUC)/include/grdpbdef.h \
	$(GRNUC)/include/grdpb.h \
	$(GRNUC)/include/grdpbmacros.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/math.h \
	/usr/include/rand48.h \
	/usr/include/stdlib.h \
	$(BS)/include/bsvalues_vx.h \
	$(BS)/include/bsvalues_cl.h \
	$(BS)/include/bsvalues_sg.h \
	$(BS)/include/bsvalues_ib.h \
	$(BS)/include/bsvalues_hp.h \
	$(BS)/include/bsvalues_nt.h \
	$(BS)/include/bsvalues.h \
	$(BS)/include/bsvalues_sn.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/spec/expression.S

PDMattach.o : \
	$(SRC)/PDMattach.I \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/fs/s5param.h \
	/usr/include/sys/param.h \
	$(PDU)/include/PDUmacros.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/ci_mac_def.h \
	$(GRNUC)/include/ci_macro.h \
	$(GRNUC)/include/cisymb.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(GRNUC)/include/DImacros.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(FORMS)/include/FI.h \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALglbs.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/spec/ACdiowner.S \
	$(GRNUC)/spec/ACrg_collect.S \
	$(GRNUC)/spec/ACcomplex.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/igrdef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/spec/ACcpx_defn.S \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACmacro_defn.S

feet_depend.o : \
	$(SRC)/feet_depend.I \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/include/ACdb_info.h \
	$(GRNUC)/spec/ACdb_info.S \
	$(GRNUC)/spec/ACncpx.S \
	$(GRNUC)/include/asbox.h \
	$(GRNUC)/include/AS_status.h \
	$(GRNUC)/spec/GRnotify.S \
	$(EXNUC)/include/OMindex.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/igrdef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx_defn.S \
	$(GRNUC)/spec/ACmacro_defn.S \
	$(GRNUC)/spec/ACpretend.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/NDnode.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMerrordef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACcomplex.S

PDMmodprt.o : \
	$(SRC)/PDMmodprt.I \
	/usr/include/math.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/ciexecdef.h \
	$(GRNUC)/include/ciexecmacros.h \
	$(GRNUC)/include/grdpbdef.h \
	$(GRNUC)/include/grdpb.h \
	$(GRNUC)/include/grdpbmacros.h \
	$(GRNUC)/include/dpmacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(GRNUC)/include/graph.h \
	$(GRNUC)/include/GMhcode.h \
	$(GRNUC)/include/GMlist.h \
	$(GRNUC)/include/GM.h \
	$(GRNUC)/include/GMmacros.h \
	$(GRNUC)/include/ndmacros.h \
	$(GRNUC)/include/asdef.h \
	$(GRNUC)/include/asmacros.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(GRNUC)/include/DImacros.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(GRNUC)/include/expression.h \
	$(GRNUC)/include/expmacros.h \
	$(GRNUC)/include/asbox.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(PDU)/include/PALmsg.h \
	$(FPAL)/include/PALglbs.h \
	$(FPAL)/include/PALlctypes.h \
	$(FPAL)/include/PDMmdprtdef.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMmessage.h \
	$(GRNUC)/include/AS_status.h \
	$(GRNUC)/include/ACrg_collect.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(PDU)/include/PDUfile_def.h \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/include/ACdb_info.h \
	$(GRNUC)/spec/ACdb_info.S \
	$(GRNUC)/spec/ACncpx.S \
	$(GRNUC)/spec/ACcomplex.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx_defn.S \
	$(GRNUC)/spec/ACmacro_defn.S \
	$(GRNUC)/spec/ACpretend.S \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/spec/ACdiowner.S \
	$(GRNUC)/spec/ACrg_collect.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/spec/expression.S

PDMdyncmp.o : \
	$(SRC)/PDMdyncmp.I \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/spec/ACdiowner.S \
	$(GRNUC)/spec/ACrg_collect.S \
	$(GRNUC)/include/ACrg_collect.h \
	$(GRNUC)/spec/ACdyn_col.S \
	$(GRNUC)/include/AS_status.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/tools.h \
	$(EXNUC)/include/wl.h \
	$(EXNUC)/include/exproto.h \
	$(EXNUC)/include/exmacros.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/dpmacros.h \
	$(GRNUC)/include/asdef.h \
	$(GRNUC)/include/asmacros.h \
	$(GRNUC)/include/expmacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(GRNUC)/include/GMhcode.h \
	$(GRNUC)/include/GMlist.h \
	$(GRNUC)/include/GM.h \
	$(GRNUC)/include/GMmacros.h \
	$(GRNUC)/include/ndmacros.h \
	$(GRNUC)/include/asbox.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(FPAL)/include/PALglbs.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(PDU)/include/PALmsg.h \
	$(FORMS)/include/FI.h \
	$(GRNUC)/include/CIforms.h \
	$(GRNUC)/include/expression.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUuser.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/spec/expression.S

PDMcpyprt.o : \
	$(SRC)/PDMcpyprt.I \
	/usr/include/malloc.h \
	$(GRNUC)/include/dperr.h \
	$(GRNUC)/include/dpdef.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(GRNUC)/include/asdef.h \
	$(GRNUC)/include/asmacros.h \
	$(GRNUC)/include/ci_mac_def.h \
	$(GRNUC)/include/ci_macro.h \
	$(GRNUC)/include/expmacros.h \
	$(GRNUC)/include/graph.h \
	$(GRNUC)/include/GMhcode.h \
	$(GRNUC)/include/GMlist.h \
	$(GRNUC)/include/GM.h \
	$(GRNUC)/include/GMmacros.h \
	$(GRNUC)/include/ndmacros.h \
	$(GRNUC)/include/asbox.h \
	$(GRNUC)/include/ACattrib.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(PDU)/include/PDUextdef.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUprompt.h \
	$(FORMS)/include/FI.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(PDU)/include/PALmsg.h \
	$(FPAL)/include/PALglbs.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/tools.h \
	$(EXNUC)/include/wl.h \
	$(EXNUC)/include/exproto.h \
	$(EXNUC)/include/exmacros.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(GRNUC)/include/dpmacros.h \
	$(GRNUC)/spec/ACcomplex.S \
	$(GRNUC)/spec/ACmacro_defn.S \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx.S \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACcpx_defn.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S

PDMmapcoll.o : \
	$(SRC)/PDMmapcoll.I \
	$(EXNUC)/spec/IGRdir.S \
	$(GRNUC)/spec/ACdiowner.S \
	$(GRNUC)/spec/ACrg_collect.S \
	$(GRNUC)/include/ACrg_collect.h \
	$(GRNUC)/spec/ACdyn_col.S \
	$(GRNUC)/include/AS_status.h \
	$(EXNUC)/include/exdef.h \
	$(GRNUC)/include/tools.h \
	$(EXNUC)/include/wl.h \
	$(EXNUC)/include/exproto.h \
	$(EXNUC)/include/exmacros.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/types.h \
	/usr/include/sys/dirent.h \
	$(EXNUC)/include/DItypedef.h \
	$(EXNUC)/include/DIglob.h \
	/usr/include/malloc.h \
	$(EXNUC)/include/DIprims.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/MOmacros.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/dpmacros.h \
	$(GRNUC)/include/asdef.h \
	$(GRNUC)/include/asmacros.h \
	$(GRNUC)/include/expmacros.h \
	$(GRNUC)/include/GMdef.h \
	$(GRNUC)/include/nddef.h \
	$(GRNUC)/include/GMhcode.h \
	$(GRNUC)/include/GMlist.h \
	$(GRNUC)/include/GM.h \
	$(GRNUC)/include/GMmacros.h \
	$(GRNUC)/include/ndmacros.h \
	$(GRNUC)/include/asbox.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(FPAL)/include/PALglbs.h \
	$(GRNUC)/include/ACattrib.h \
	$(GRNUC)/include/ACdyn_col.h \
	$(EXNUC)/include/exms.h \
	$(EXNUC)/include/msmacros.h \
	$(PDU)/include/PALmsg.h \
	$(FORMS)/include/FI.h \
	$(GRNUC)/include/CIforms.h \
	$(GRNUC)/include/expression.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/MEMstruct.h \
	$(FPAL)/include/PALfunkpro.h \
	$(FPAL)/include/PALpdmrpro.h \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(GRNUC)/include/igrdef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/spec/ACcpx.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	$(EXNUC)/include/igetypedef.h \
	$(EXNUC)/include/igrtypedef.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACcpx_defn.S

ismacdef.o : \
	$(SRC)/ismacdef.I \
	/usr/include/math.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(EXNUC)/include/OMcluster.h \
	$(EXNUC)/include/OMmacros.h \
	$(GRNUC)/include/AS_status.h \
	$(GRNUC)/include/nd.h \
	$(GRNUC)/spec/NDnode.S \
	$(GRNUC)/include/parametric.h \
	$(GRNUC)/spec/NDmacro.S \
	$(GRNUC)/spec/NDfather.S \
	$(GRNUC)/spec/NDchildren.S \
	$(GRNUC)/spec/NDnodein.S \
	$(GRNUC)/spec/GRnotify.S \
	$(GRNUC)/spec/GRconnector.S \
	$(GRNUC)/include/EMmsg_obj.h \
	$(GRNUC)/include/emsdattyp.h \
	$(GRNUC)/include/emsinter.h \
	$(GRNUC)/spec/GRvg.S \
	$(GRNUC)/spec/GRcmpowner.S \
	$(GRNUC)/include/growner.h \
	$(GRNUC)/spec/GRowner.S \
	$(GRNUC)/spec/ASnode.S \
	$(GRNUC)/include/macro.h \
	$(GRNUC)/spec/ACcpx.S \
	$(EXNUC)/include/OMOSfilehdr.h \
	$(EXNUC)/spec/OMObjSpace.S \
	/usr/include/stddef.h \
	$(EXNUC)/include/OMprimitives.h \
	$(EXNUC)/spec/Root.S \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(EXNUC)/include/igetypedef.h \
	$(GRNUC)/include/igr.h \
	$(GRNUC)/include/igrdp.h \
	$(GRNUC)/include/gr.h \
	$(GRNUC)/include/dp.h \
	$(GRNUC)/include/godef.h \
	$(GRNUC)/include/sunlimits.h \
	$(EXNUC)/include/DIdef.h \
	$(EXNUC)/include/msdef.h \
	$(GRNUC)/include/go.h \
	$(EXNUC)/include/OMindex.h \
	$(EXNUC)/include/OMerrordef.h \
	$(GRNUC)/include/igrdef.h \
	$(BS)/include/maerr.h \
	$(BS)/include/madef.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(EXNUC)/include/igrtypedef.h \
	$(EXNUC)/include/exfi.h \
	$(EXNUC)/include/ex.h \
	$(GRNUC)/include/griodef.h \
	$(GRNUC)/include/grio.h \
	$(GRNUC)/include/lcdef.h \
	$(GRNUC)/include/lc.h \
	$(GRNUC)/include/dpstruct.h \
	$(GRNUC)/include/report.h \
	$(GRNUC)/include/GRchanpass.h \
	$(GRNUC)/spec/GRgraphics.S

$(c_objects):
	@if [ "$(WHY)" ]; then echo "\t$(@): $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$(SRC)/$(@:.o=.c) -> $(@)"; \
	 fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; \
	 then \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\tcd $(@D)"; \
	     fi; \
	     cd $(@D); \
	 fi; \
	 if [ -n "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)"; \
	 fi; \
	 $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(SRC)/$(@:.o=.c)
	@echo 

$(imp_objects):
	@if [ "$(WHY)" ]; then echo "\t$(@): $?"; fi
	@if [ -n "$(@D)" -a "$(@D)" != "." ]; \
	 then \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\tcd $(@D)"; \
	     fi; \
	     cd $(@D); \
	 fi; \
	 if [ "$(FAST)" ]; \
	 then \
	     if [ -f $(@) ]; then rm $(@); fi; \
	     echo "\t$(@:.o=.I) -> opp.list\c"; \
	     echo "$(@:.o=.I)" >>opp.list; \
	 else \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$(SRC)/$(@:.o=.I) -> $(@:.o=.c)"; \
	     fi; \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.I)"; \
	     fi; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $(@:.o=.I); \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$(@:.o=.c) -> $(@)"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c)"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $(@F:.o=.c); \
	     if [ "$(COPT)" != "-g" -a "$(DEBUG)" != "yes" ]; \
	     then \
	         if [ -z "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\tremoving $(@:.o=.c)"; \
	         else \
	             echo "\trm $(@F:.o=.c)"; \
	         fi; \
	         rm $(@F:.o=.c); \
	     else \
	         if [ -z "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\tleaving $(@:.o=.c)"; \
	         fi; \
	     fi; \
	 fi
	@echo 

.I.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ "$(FAST)" ]; \
	 then \
	     if [ -f $(@) ]; then rm $(@); fi; \
	     echo "\t$< -> opp.list\c"; \
	     echo "$<" >>opp.list; \
	 else \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$< -> $*.c"; \
	     else \
	         echo "\t$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<"; \
	     fi; \
	     $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) $<; \
	     if [ -z "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\t$*.c -> $*.o"; \
	     else \
	         echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	     fi; \
	     $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c;  \
	     if [ "$(COPT)" != "-g" -a "$(DEBUG)" != "yes" ]; \
	     then \
	        if [ -z "$(VERBOSE_RULES)" ]; \
	        then \
	            echo "\tremoving $*.c"; \
	        else \
	            echo "\trm $*.c"; \
	        fi; \
	        rm $*.c; \
	     else \
	        if [ -z "$(VERBOSE_RULES)" ]; \
	        then \
	            echo "\tleaving $*.c"; \
	        fi; \
	     fi; \
	 fi
	@echo 

.c.o:
	@if [ "$(WHY)" ]; then echo "\t$<: $?"; fi
	@if [ -z "$(VERBOSE_RULES)" ]; \
	 then \
	     echo "\t$< -> $*.o"; \
	 else \
	     echo "\t$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c"; \
	 fi
	@$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c $*.c
	@echo 

DIR = $(PDU)/config/dload/prod/pdu/pal/src/funk

PDUfunk.s:	$(objects_TARGET)
	@echo "Making PDUfunk.s for reactive loading."
	@echo
	@echo "Moving PALtools.o and PDMselprt.o to .X extensions."
	@mv PALtools.o PALtools.X
	@mv PDMselprt.o PDMselprt.X
	@-mkstubs -o PDUfunk.s -t"Pdu:pdu/pal/src/funk" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from pal/src/funk to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubfunk.o
	@echo "Moving PALtools.X and PDMselprt.X to .o extensions."
	@mv PALtools.X PALtools.o
	@mv PDMselprt.X PDMselprt.o
	@echo "Copying PALtools.o and PDMselprt.o to $(PDU)/config/dload/init."
	@cp PALtools.o $(PDU)/config/dload/init
	@cp PDMselprt.o $(PDU)/config/dload/init
	@echo "Compiling PDUstubfunk.o from PDUfunk.s"
	@as -o PDUstubfunk.o PDUfunk.s


FASTstart:
	@rm -f opp.list cc.list

FASTfinish:
	@if [ "$(FAST)" ]; \
	 then \
	     if [ -s opp.list ]; \
	     then \
	         echo "\topping files"; \
	         if [ -n "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\t$(ocfiles) $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) `cat opp.list`"; \
	         fi; \
	         $(ocfiles) $(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2) `cat opp.list`; \
	         sed -e 's/\.[IS]/.c/' <opp.list >>cc.list; \
	     else \
	         echo "\tnothing to opp"; \
	     fi; \
	     if [ -s cc.list ]; \
	     then \
	         echo "\tcompiling files"; \
	         if [ -n "$(VERBOSE_RULES)" ]; \
	         then \
	             echo "\t$(ocfiles) $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c `cat cc.list`"; \
	         fi; \
	         $(ocfiles) $(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2) -c `cat cc.list`; \
	         if [ "$(COPT)" != "-g" -a "$(DEBUG)" != "yes" ]; \
	         then \
	             echo "\tremoving .c files"; \
	             rm `cat cc.list`; \
	         else \
	             echo "\tleaving .c files"; \
	         fi; \
	     else \
	         echo "\tnothing to compile"; \
	     fi; \
	     if [ -n "$(VERBOSE_RULES)" ]; \
	     then \
	         echo "\trm -f opp.list cc.list"; \
	     fi; \
	     rm -f opp.list cc.list; \
	 fi

FAST:
	$(MAKE) FAST=1 objects_FAST

