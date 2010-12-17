.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

SRC = .

IPATH =  \
	-I$(PDM)/include \
	-I$(PDM)/pdmapi/include \
	-I$(PDU)/include \
	-I$(NFM)/include \
	-I$(RIS)/include \
	-I$(RIS)/errmsg

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMcopy_f.o \
	PDMffast.o \
	PDMcopy_m.o \
	PDMassy_mem.o \
	PDMfunc1.o \
	PDMcp_files.o \
	PDMfcopy_m.o \
	PDMiteminfo.o \
	PDMn_ci.o \
	PDMsettools.o \
	PDMexp_copy.o \
	PDMsave_part.o \
	PDMcipart.o \
	PDMCheckOut.o

objects = \
	$(c_objects) 


# main target

target: \
	PDMcicocp.s


# src group targets

objects_TARGET = $(PDM)/lib/$(TARG)/PDMcicocp.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/$(TARG)/PDMcicocp.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/$(TARG)/PDMcicocp.a"; fi; ls -ls $(PDM)/lib/$(TARG)/PDMcicocp.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMcopy_f.o : \
	$(SRC)/PDMcopy_f.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMfile.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMffast.o : \
	$(SRC)/PDMffast.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/NFMfile.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDMmessage.h

PDMcopy_m.o : \
	$(SRC)/PDMcopy_m.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMfile.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(PDU)/include/PDUstorage.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(NFM)/include/MEMstruct.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/NFMschema.h \
	$(PDM)/include/NFMfto_buf.h \
	$(PDU)/include/PDMmessage.h

PDMassy_mem.o : \
	$(SRC)/PDMassy_mem.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMfunc1.o : \
	$(SRC)/PDMfunc1.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(NFM)/include/NFMfile.h

PDMcp_files.o : \
	$(SRC)/PDMcp_files.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMmessage.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/NFMitemfiles.h \
	$(NFM)/include/MSGstruct.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMfcopy_m.o : \
	$(SRC)/PDMfcopy_m.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/NFMitemfiles.h \
	$(NFM)/include/MSGstruct.h \
	$(PDU)/include/PDUstorage.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMiteminfo.o : \
	$(SRC)/PDMiteminfo.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMn_ci.o : \
	$(SRC)/PDMn_ci.c \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/MSGstruct.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMfile.h \
	$(PDU)/include/PDUstorage.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDMmessage.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/../include/WFstruct.h \
	$(PDM)/include/WFexterns.h

PDMsettools.o : \
	$(SRC)/PDMsettools.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/DEBUG.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/NFMitemfiles.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h

PDMexp_copy.o : \
	$(SRC)/PDMexp_copy.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMsave_part.o : \
	$(SRC)/PDMsave_part.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/MSGstruct.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(PDU)/include/PDUstorage.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/../include/WFstruct.h \
	$(PDM)/include/WFexterns.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h

PDMcipart.o : \
	$(SRC)/PDMcipart.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/DEBUG.h \
	$(NFM)/include/NFMitemfiles.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/WFstruct.h \
	$(PDM)/include/NFMfto_buf.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUstorage.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(PDU)/include/PDUpdmrpro.h

PDMCheckOut.o : \
	$(SRC)/PDMCheckOut.c \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	/usr/include/RISdbs_err.h \
	/usr/include/RIStrn_err.h \
	/usr/include/RISdic_err.h \
	/usr/include/RISerror.h \
	$(RIS)/include/RISlimits.h \
	$(RIS)/include/ris_err.h \
	$(RIS)/include/net_err.h \
	$(RIS)/include/utl_err.h \
	$(RIS)/include/rislimit.h \
	$(PDM)/include/PDUris_incl.h \
	$(NFM)/include/NFMfile.h \
	$(NFM)/include/NFMstruct.h \
	$(PDU)/include/PDUstorage.h \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	$(NFM)/include/ERRerrordef.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(NFM)/include/ERRproto.h \
	$(NFM)/include/ERR.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(PDM)/include/PDMSasspro.h \
	$(PDM)/include/PDMSbompro.h \
	$(PDM)/include/PDMScicocpro.h \
	$(PDM)/include/PDMSfmgrpro.h \
	$(PDM)/include/PDMSmacropro.h \
	$(PDM)/include/PDMSmulfpro.h \
	$(PDM)/include/PDMSpdmppro.h \
	$(PDM)/include/PDMSpdmspro.h \
	$(PDM)/include/PDMSrispro.h \
	$(PDM)/include/PDMSrptspro.h \
	$(PDM)/include/PDMStoolspro.h \
	$(PDM)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDM)/include/PDMproto.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDMmessage.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/NFMitemfiles.h \
	$(PDM)/include/NFMfto_buf.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/../include/WFstruct.h \
	$(PDM)/include/WFexterns.h

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

DIR = $(PDU)/config/dload/prod/pdm/cicocp

PDMcicocp.s:	$(objects_TARGET)
	@echo "Making PDMcicocp.s for reactive loading."
	@echo
	@-mkstubs -o PDMcicocp.s -t"Pdu:pdm/cicocp" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from cicocp directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubcicoc.o
	@echo "Compiling PDMstubcicoc.o from PDMcicocp.s"
	@as -o PDMstubcicoc.o PDMcicocp.s


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

