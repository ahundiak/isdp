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
	PDUcopy_cat.o \
	PDUcreat_cat.o \
	PDUdel_cat.o \
	PDUdyn_attr.o \
	PDUmod_cat.o \
	PDUcat_name.o \
	PDUcat_attr.o \
	PDUvalidate.o \
	PDUbuff.o \
	PDUcommands.o \
	PDUfrm_tools.o \
	PDUparm_form.o \
	PDUparm_part.o \
	PDUdef_lib.o \
	PDUcat_list.o \
	PDUcatapi.o \
	PMapi_cat.o

objects = \
	$(c_objects) 


# main target

target: \
	PDUcatalogs.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUcatalogs.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUcatalogs.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUcatalogs.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUcatalogs.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDUcopy_cat.o : \
	$(SRC)/PDUcopy_cat.c \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDMmessage.h \
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

PDUcreat_cat.o : \
	$(SRC)/PDUcreat_cat.c \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDMmessage.h \
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

PDUdel_cat.o : \
	$(SRC)/PDUdel_cat.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
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
	$(PDU)/include/PDMproto.h \
	$(PDU)/include/PDUuser.h

PDUdyn_attr.o : \
	$(SRC)/PDUdyn_attr.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUcommand.h \
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

PDUmod_cat.o : \
	$(SRC)/PDUmod_cat.c \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUcommand.h \
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

PDUcat_name.o : \
	$(SRC)/PDUcat_name.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUfile_def.h \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/part_gadgets.h \
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

PDUcat_attr.o : \
	$(SRC)/PDUcat_attr.c \
	$(NFM)/include/MEMerrordef.h \
	$(NFM)/include/NFMdb.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDMmessage.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUfile_def.h \
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

PDUvalidate.o : \
	$(SRC)/PDUvalidate.c \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
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

PDUbuff.o : \
	$(SRC)/PDUbuff.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
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

PDUcommands.o : \
	$(SRC)/PDUcommands.c \
	$(PDU)/include/PDUcommand.h \
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

PDUfrm_tools.o : \
	$(SRC)/PDUfrm_tools.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUparamdef.h \
	$(PDU)/include/part_gadgets.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDMmessage.h \
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

PDUparm_form.o : \
	$(SRC)/PDUparm_form.c \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUfile_def.h \
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
	$(PDU)/include/PDMproto.h \
	$(PDU)/include/PDUerror.h

PDUparm_part.o : \
	$(SRC)/PDUparm_part.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUfile_def.h \
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
	$(PDU)/include/PDMproto.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDMmessage.h

PDUdef_lib.o : \
	$(SRC)/PDUdef_lib.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUassy.h \
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

PDUcat_list.o : \
	$(SRC)/PDUcat_list.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
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

PDUcatapi.o : \
	$(SRC)/PDUcatapi.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUparamdef.h \
	$(PDU)/include/part_gadgets.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDMmessage.h \
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

PMapi_cat.o : \
	$(SRC)/PMapi_cat.c \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUfile_def.h \
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

DIR = $(PDU)/config/dload/prod/pdu/catalogs

PDUcatalogs.s:	$(objects_TARGET)
	@echo "Making PDUcatalogs.s for reactive loading."
	@echo
	@-mkstubs -o PDUcatalogs.s -t"Pdu:pdu/catalogs" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from catalogs to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubcats.o
	@echo "Compiling PDUstubcats.o from PDUcatalogs.s"
	@as -o PDUstubcats.o PDUcatalogs.s


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

