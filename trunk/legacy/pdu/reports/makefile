.PRECIOUS:

.SUFFIXES: .a .c .o

LINKOPT =

SRC = .

IPATH =  \
	-I$(INGRHOME)/include \
	-I$(PDU)/include \
	-I$(PDM)/include \
	-I$(PDM)/pdmapi/include \
	-I$(EXNUC)/include \
	-I$(GRNUC)/include \
	-I$(NFM)/include \
	-I$(DBA)/include \
	-I$(FORMS)/include

CC = $(COMP)

COPT =  \
	$(COMP_OPT)

MOPT = -Dclipper=1 -D__clipper__=1

ocfiles = $(EXNUC)/bin/ocfiles


# Object files 

c_objects = \
	PDUsort_name.o \
	PDUcrt_buff.o \
	PDUdef_crit.o \
	PDUsrchname.o \
	PDUget_strin.o \
	PDUsearch.o \
	PDUdef_sort.o \
	PDUlist_rpts.o \
	PDUsetup_def.o \
	PDUrpt_form.o \
	PDUbom_cnts.o \
	PDUdef_rpt.o \
	PDUdsp_rpt.o \
	PDUdel_rpt.o \
	PDUrpt_tools.o

objects = \
	$(c_objects) 


# main target

target: \
	PDUreports.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUreports.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUreports.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUreports.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUreports.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDUsort_name.o : \
	$(SRC)/PDUsort_name.c \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

PDUcrt_buff.o : \
	$(SRC)/PDUcrt_buff.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

PDUdef_crit.o : \
	$(SRC)/PDUdef_crit.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUsrchname.o : \
	$(SRC)/PDUsrchname.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

PDUget_strin.o : \
	$(SRC)/PDUget_strin.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUsearch.o : \
	$(SRC)/PDUsearch.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/FCdata.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMtypes.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

PDUdef_sort.o : \
	$(SRC)/PDUdef_sort.c \
	$(PDU)/include/FCdata.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMtypes.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUlist_rpts.o : \
	$(SRC)/PDUlist_rpts.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUsetup_def.o : \
	$(SRC)/PDUsetup_def.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUrpt_form.o : \
	$(SRC)/PDUrpt_form.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/part_gadgets.h \
	$(EXNUC)/include/exdef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUbom_cnts.o : \
	$(SRC)/PDUbom_cnts.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/part_gadgets.h \
	$(PDU)/include/PDMtypes.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUdef_rpt.o : \
	$(SRC)/PDUdef_rpt.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUforms.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/MRPmacros.h \
	$(PDU)/include/MRPstr.h \
	$(PDU)/include/PSUgadlabs.h \
	$(PDU)/include/MRPmessage.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUdsp_rpt.o : \
	$(SRC)/PDUdsp_rpt.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUforms.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/MRPstr.h \
	$(PDU)/include/PSUgadlabs.h \
	$(PDU)/include/MRPmessage.h \
	$(PDU)/include/MRPmacros.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUdel_rpt.o : \
	$(SRC)/PDUdel_rpt.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUforms.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDMexec.h \
	$(PDU)/include/PDMSasspro.h \
	$(PDU)/include/PDMSbompro.h \
	$(PDU)/include/PDMScicocpro.h \
	$(PDU)/include/PDMSfmgrpro.h \
	$(PDU)/include/PDMSmacropro.h \
	$(PDU)/include/PDMSmulfpro.h \
	$(PDU)/include/PDMSpdmppro.h \
	$(PDU)/include/PDMSpdmspro.h \
	$(PDU)/include/PDMSrispro.h \
	$(PDU)/include/PDMSrptspro.h \
	$(PDU)/include/PDMStoolspro.h \
	$(PDU)/include/PDMSinitpro.h \
	$(PDM)/pdmapi/include/PDMapipro.h \
	$(PDM)/pdmapi/include/PDMapi.h \
	$(PDM)/pdmapi/include/PDMextapipro.h \
	$(PDU)/include/PDMproto.h

PDUrpt_tools.o : \
	$(SRC)/PDUrpt_tools.c \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUuser.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/MRPstr.h \
	$(PDU)/include/PSUgadlabs.h \
	$(PDU)/include/MRPmessage.h \
	$(PDU)/include/MRPmacros.h \
	$(PDU)/include/PDUrptdef.h \
	/usr/include/unistd.h \
	/usr/include/time.h \
	$(DBA)/include/dba_err.h \
	$(DBA)/include/dbadev.h \
	$(PDU)/include/rMRPstr.h \
	$(NFM)/include/MEMstruct.h \
	$(PDU)/include/PDUmac_struc.h \
	$(PDU)/include/sunlimits.h \
	$(PDU)/include/PDUnode.h \
	$(PDU)/include/PDUpartspro.h \
	$(PDU)/include/PDUassypro.h \
	$(PDU)/include/PDUcatpro.h \
	$(PDU)/include/PDUcommonpro.h \
	$(PDU)/include/PDUdesignpro.h \
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h \
	$(PDU)/include/PDUfmgrpro.h \
	$(PDU)/include/PDUinitpro.h \
	$(PDU)/include/PDUmacrospro.h \
	$(PDU)/include/PDUmiscpro.h \
	$(PDU)/include/PDUpdmrpro.h \
	$(PDU)/include/PDUrptspro.h \
	$(PDU)/include/PDUtoolspro.h \
	$(GRNUC)/include/tools.h \
	$(DBA)/include/FI.h \
	$(FORMS)/include/FIdyn.h \
	$(FORMS)/include/FIproto_pub.h \
	$(PDU)/include/PDUproto.h

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

DIR = $(PDU)/config/dload/prod/pdu/reports

PDUreports.s:	$(objects_TARGET)
	@echo "Making PDUreports.s for reactive loading."
	@echo
	@-mkstubs -o PDUreports.s -t"Pdu:pdu/reports" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from reports to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubrpts.o
	@echo "Compiling PDUstubrpts.o from PDUreports.s"
	@as -o PDUstubrpts.o PDUreports.s


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

