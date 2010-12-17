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
	PDUbufrs.o \
	PDUcheckin.o \
	PDUcheckout.o \
	PDUfile.o \
	PDUflag.o \
	PDUlf_form.o \
	PDUlist_file.o \
	PDUlogin.o \
	PDUmcf_list.o \
	PDUmisc2.o \
	PDUp_login.o \
	PDUsgl_list.o \
	PDUsort.o \
	PDUsort_form.o \
	PDUstring.o \
	PDUvalidate.o \
	PDUwrkst_mgr.o \
	PDUbuffers.o \
	PDUmodes.o \
	PDUsort_opt.o \
	PDUfile_list.o \
	PDUsv_refrsh.o \
	PDUdate.o \
	PDUpart_lst.o \
	PDUpt_fl_lst.o \
	PDUcancl_lst.o \
	PDUwher_used.o \
	PDUgen_valid.o \
	PDUfileapi.o \
	PDUckin_tls.o \
	PDUflag_form.o \
	PDUstate_frm.o

objects = \
	$(c_objects) 


# main target

target: \
	PDUfilemgr.s


# src group targets

objects_TARGET = $(PDU)/lib/$(TARG)/PDUfilemgr.a

$(objects_TARGET): $(objects)
	@echo 
	ld $(LDOPT) -r -o $(PDU)/lib/$(TARG)/PDUfilemgr.a $(objects)
	@if test -n "$(VERBOSE_RULES)"; then echo "\tls -ls $(PDU)/lib/$(TARG)/PDUfilemgr.a"; fi; ls -ls $(PDU)/lib/$(TARG)/PDUfilemgr.a; echo

objects_FAST: FASTstart $(objects) FASTfinish $(objects_TARGET)

PDUbufrs.o : \
	$(SRC)/PDUbufrs.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUstorage.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/part_gadgets.h \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUform_def.h \
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

PDUcheckin.o : \
	$(SRC)/PDUcheckin.c \
	$(PDU)/include/PDUuser.h \
	$(EXNUC)/include/igrtypedef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUint.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUforms.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(PDU)/include/PDUpart.h \
	$(EXNUC)/include/exdef.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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
	/usr/include/standards.h \
	/usr/include/sys/types.h \
	/usr/include/sys/stat.h

PDUcheckout.o : \
	$(SRC)/PDUcheckout.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUuser.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUcommand.h \
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

PDUfile.o : \
	$(SRC)/PDUfile.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUstorage.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	/usr/include/sys/stat.h \
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

PDUflag.o : \
	$(SRC)/PDUflag.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/part_gadgets.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
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

PDUlf_form.o : \
	$(SRC)/PDUlf_form.c \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUassy.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/part_gadgets.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
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

PDUlist_file.o : \
	$(SRC)/PDUlist_file.c \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUforms.h \
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

PDUlogin.o : \
	$(SRC)/PDUlogin.c \
	/usr/include/sys/utsname.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUforms.h \
	/usr/include/sys/signal.h \
	/usr/include/signal.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDMmessage.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
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

PDUmcf_list.o : \
	$(SRC)/PDUmcf_list.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUprompt.h \
	$(PDU)/include/PDUfile_def.h \
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

PDUmisc2.o : \
	$(SRC)/PDUmisc2.c \
	$(PDU)/include/PDUfile_def.h \
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

PDUp_login.o : \
	$(SRC)/PDUp_login.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUforms.h \
	$(NFM)/include/MEMerrordef.h \
	/usr/include/sys/stat.h \
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

PDUsgl_list.o : \
	$(SRC)/PDUsgl_list.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
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

PDUsort.o : \
	$(SRC)/PDUsort.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
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

PDUsort_form.o : \
	$(SRC)/PDUsort_form.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
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

PDUstring.o : \
	$(SRC)/PDUstring.c \
	/usr/include/ctype.h \
	$(PDU)/include/PDUfile_def.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
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

PDUvalidate.o : \
	$(SRC)/PDUvalidate.c \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUsts_st.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/part_gadgets.h \
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
	$(PDU)/include/PDMproto.h \
	$(PDU)/include/PDUfile_def.h

PDUwrkst_mgr.o : \
	$(SRC)/PDUwrkst_mgr.c \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUfile_def.h \
	/usr/include/sys/stat.h \
	/usr/include/sys/utsname.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
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
	$(PDU)/include/PDUproto.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(NFM)/include/DEBUG.h

PDUbuffers.o : \
	$(SRC)/PDUbuffers.c \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUcommand.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/part_gadgets.h \
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

PDUmodes.o : \
	$(SRC)/PDUmodes.c \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUintdef.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDMcommand.h \
	$(PDU)/include/part_gadgets.h \
	$(PDU)/include/PDUform_def.h \
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

PDUsort_opt.o : \
	$(SRC)/PDUsort_opt.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUextdef.h \
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

PDUfile_list.o : \
	$(SRC)/PDUfile_list.c \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
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

PDUsv_refrsh.o : \
	$(SRC)/PDUsv_refrsh.c \
	/usr/include/sys/stat.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUuser.h \
	$(PDU)/include/PDUerror.h \
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

PDUdate.o : \
	$(SRC)/PDUdate.c \
	/usr/include/memory.h \
	/usr/include/string.h \
	$(PDU)/include/PDUerror.h \
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

PDUpart_lst.o : \
	$(SRC)/PDUpart_lst.c \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
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

PDUpt_fl_lst.o : \
	$(SRC)/PDUpt_fl_lst.c \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUcommand.h \
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

PDUcancl_lst.o : \
	$(SRC)/PDUcancl_lst.c \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUfile_def.h \
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

PDUwher_used.o : \
	$(SRC)/PDUwher_used.c \
	$(PDU)/include/PDMtypes.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(EXNUC)/include/exdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUforms.h \
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

PDUgen_valid.o : \
	$(SRC)/PDUgen_valid.c \
	$(PDU)/include/PDUsts_st.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUuser.h \
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

PDUfileapi.o : \
	$(SRC)/PDUfileapi.c \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	/usr/include/sys/stat.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDMmessage.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
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
	/usr/include/sys/types.h \
	/usr/include/standards.h \
	/usr/include/sys/_int_sarg.h \
	/usr/include/_int_sarg.h \
	/usr/include/stdio.h \
	/usr/include/pwd.h

PDUckin_tls.o : \
	$(SRC)/PDUckin_tls.c \
	$(PDU)/include/PDUuser.h \
	$(EXNUC)/include/igrtypedef.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
	$(PDU)/include/PDUint.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUforms.h \
	$(EXNUC)/include/OMlimits.h \
	$(EXNUC)/include/OMtypes.h \
	$(EXNUC)/include/OMminimum.h \
	$(PDU)/include/PDUpart.h \
	$(EXNUC)/include/exdef.h \
	/usr/include/sys/errno.h \
	/usr/include/errno.h \
	$(NFM)/include/MEMerrordef.h \
	$(PDU)/include/SQLerrordef.h \
	$(NFM)/include/NETerrordef.h \
	$(NFM)/include/NFMerrordef.h \
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

PDUflag_form.o : \
	$(SRC)/PDUflag_form.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUcommand.h \
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

PDUstate_frm.o : \
	$(SRC)/PDUstate_frm.c \
	$(PDU)/include/PDUforms.h \
	$(PDU)/include/PDUerror.h \
	$(PDU)/include/PDUintdef.h \
	$(PDU)/include/PDUform_def.h \
	$(PDU)/include/PDUfile_def.h \
	$(PDU)/include/PDUcommand.h \
	$(PDU)/include/PDUextdef.h \
	$(PDU)/include/PDUstr.h \
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

DIR = $(PDU)/config/dload/prod/pdu/filemgr

PDUfilemgr.s:	$(objects_TARGET)
	@echo "Making PDUfilemgr.s for reactive loading."
	@echo
	@-mkstubs -o PDUfilemgr.s -t"Pdu:pdu/filemgr" $(objects)
	@if [ ! -d $(DIR) ] ; then mkdir -p $(DIR) ; fi ;
	@echo "cp .o files from filemgr to $(DIR) for reactive loading."
	@echo
	@cp *.o $(DIR)
	@- rm $(DIR)/PDUstubfmgr.o
	@echo "Compiling PDUstubfmgr.o from PDUfilemgr.s"
	@as -o PDUstubfmgr.o PDUfilemgr.s


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

