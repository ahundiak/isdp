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
	-I$(RIS)/errmsg \
	-I$(DBA)/include

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDMattr_f.o \
	PDMbom_f.o \
	PDMbommnpl.o \
	PDMctools.o \
	PDMdbms_f.o \
	PDMdyn_tbd.o \
	PDMdynamic.o \
	PDMpart_f.o \
	PDMrefresh.o \
	PDMreport_f.o \
	PDMstools1.o \
	PDMstools2.o \
	PDMbom_tools.o \
	PDMlfm_tools.o \
	PDMrep_tools.o \
	PDMtable_f.o \
	PDMwf_acl.o \
	PDMdebug.o \
	PDMmisc.o \
	PDMquery_cat.o \
	PDMptools.o \
	PDMpart_p.o \
	PDMviews.o \
	PDMpget_attr.o \
	PDMfasttool.o \
	PDMpara_tool.o \
	PDMpdms_tool.o \
	PDMfmgr_tool.o \
	PDMcico_tool.o \
	PDMtimestamp.o

objects = \
	$(c_objects) 


# main target

target: \
	PDMtools.s


# src group targets

objects_TARGET = $(PDM)/lib/$(TARG)/PDMtools.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDM)/lib/$(TARG)/PDMtools.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDM)/lib/$(TARG)/PDMtools.a"; fi; ls -ls $(PDM)/lib/$(TARG)/PDMtools.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDMattr_f.o : \
	$(SRC)/PDMattr_f.c \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDM)/include/types.h \
	$(PDM)/include/stat.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NETerrordef.h \
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

PDMbom_f.o : \
	$(SRC)/PDMbom_f.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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
	$(PDM)/include/PDMdbs_err.h \
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
	$(PDU)/include/PDUerror.h

PDMbommnpl.o : \
	$(SRC)/PDMbommnpl.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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
	$(PDM)/include/PDMdbs_err.h \
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
	$(PDU)/include/PDUerror.h

PDMctools.o : \
	$(SRC)/PDMctools.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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
	$(PDM)/include/PDMdbs_err.h \
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
	$(PDM)/include/SQLstruct.h

PDMdbms_f.o : \
	$(SRC)/PDMdbms_f.c \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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

PDMdyn_tbd.o : \
	$(SRC)/PDMdyn_tbd.c \
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
	$(PDU)/include/PDUerror.h \
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
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h

PDMdynamic.o : \
	$(SRC)/PDMdynamic.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
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
	$(PDU)/include/PDUerror.h \
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
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h

PDMpart_f.o : \
	$(SRC)/PDMpart_f.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMstruct.h \
	$(PDM)/include/PDMexec.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDM)/include/SQLstruct.h

PDMrefresh.o : \
	$(SRC)/PDMrefresh.c \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/WFstruct.h \
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
	$(PDM)/include/PDMproto.h

PDMreport_f.o : \
	$(SRC)/PDMreport_f.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
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
	$(PDM)/include/PDMdbs_err.h \
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
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h

PDMstools1.o : \
	$(SRC)/PDMstools1.c \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDM)/include/types.h \
	$(PDM)/include/stat.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NETerrordef.h \
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

PDMstools2.o : \
	$(SRC)/PDMstools2.c \
	/usr/include/unistd.h \
	/usr/include/time.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDM)/include/types.h \
	$(PDM)/include/stat.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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

PDMbom_tools.o : \
	$(SRC)/PDMbom_tools.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDM)/include/MRPmessage.h \
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
	$(PDM)/include/PDMbom_strct.h

PDMlfm_tools.o : \
	$(SRC)/PDMlfm_tools.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMitems.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUstorage.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDM)/include/MRPmessage.h \
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
	$(PDM)/include/PDMbom_strct.h

PDMrep_tools.o : \
	$(SRC)/PDMrep_tools.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDM)/include/MRPmessage.h \
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
	$(PDM)/include/PDMbom_strct.h

PDMtable_f.o : \
	$(SRC)/PDMtable_f.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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
	$(PDM)/include/PDMdbs_err.h \
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
	$(PDU)/include/PDUerror.h

PDMwf_acl.o : \
	$(SRC)/PDMwf_acl.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
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
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h

PDMdebug.o : \
	$(SRC)/PDMdebug.c \
	/usr/include/standards.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/varargs.h \
	/usr/include/varargs.h \
	$(PDU)/include/PDUerror.h \
	$(PDM)/include/PDMmach_id.h \
	$(PDM)/include/PDMdebug.h \
	$(NFM)/include/MSGstruct.h \
	$(NFM)/include/NETstruct.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/DEBUG.h \
	$(PDM)/include/NFMsacdef.h \
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

PDMmisc.o : \
	$(SRC)/PDMmisc.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
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

PDMquery_cat.o : \
	$(SRC)/PDMquery_cat.c \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/WFstruct.h \
	$(NFM)/include/NFMdb.h \
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

PDMptools.o : \
	$(SRC)/PDMptools.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
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
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h

PDMpart_p.o : \
	$(SRC)/PDMpart_p.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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

PDMviews.o : \
	$(SRC)/PDMviews.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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

PDMpget_attr.o : \
	$(SRC)/PDMpget_attr.c \
	$(NFM)/include/NFMdb.h \
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
	$(NFM)/include/NFMstruct.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/WFstruct.h \
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
	$(PDU)/include/PDUpdmrpro.h

PDMfasttool.o : \
	$(SRC)/PDMfasttool.c \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
	$(PDU)/include/PDUerror.h \
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
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NETerrordef.h

PDMpara_tool.o : \
	$(SRC)/PDMpara_tool.c \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NFMstruct.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/WFstruct.h \
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
	$(PDM)/include/PDMproto.h

PDMpdms_tool.o : \
	$(SRC)/PDMpdms_tool.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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
	$(PDM)/include/PDMdbs_err.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/NFMapi.h \
	$(NFM)/include/NFMschema.h \
	$(NFM)/include/NFMstruct.h \
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

PDMfmgr_tool.o : \
	$(SRC)/PDMfmgr_tool.c \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h

PDMcico_tool.o : \
	$(SRC)/PDMcico_tool.c \
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
	$(NFM)/include/NFMfile.h \
	$(PDM)/include/NFMfto_buf.h \
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

PDMtimestamp.o : \
	$(SRC)/PDMtimestamp.c \
	$(PDU)/include/PDMtimestamp.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/memory.h \
	/usr/include/string.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/sys/stdarg.h \
	$(PDM)/include/stdarg.h \
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/times.h

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

DIR = $(PDU)/config/dload/prod/pdm/tools

PDMtools.s:	$(objects_TARGET)
	@echo "Making PDMtools.s for reactive loading."
	@echo
	@-mkstubs -o PDMtools.s -t"Pdu:pdm/tools" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from tools directory to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDMstubtools.o
	@echo "Compiling PDMstubtools.o from PDMtools.s"
	@as -o PDMstubtools.o PDMtools.s


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

