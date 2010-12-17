.SUFFIXES: .o .c .rc .1 .4 .5 .6 .7 .8 .9
CC=cc
RISCC=/opt/ingr/ris/risdp/bin/riscpp
OPT=
CPUFLAG=
COMBINE_FLAG=-DCOMBINED_MAKE
OBJEXT=9
LIBDIR=../tdlib
ARCHNAME=libquis.a
OSFLAG=-Dsolaris
MISCFLAG=
TARGSTR=
CFLAGS=-Xa 	-I../include	-I/opt/ingr/include	-I/opt/ingr/ris/risdp/include	-I/opt/ingr/forms/include	-I/opt/ingr/xformsdp/xfi/include	-I/opt/ingr/ftrdp/include	-I/opt/ingr/helpdp/include	-I/opt/ingr/resrc/fortserver/include	-I/opt/ingr/include/X11	-I/opt/ingr/risdp/bin/riscpp
OBJECTS= QUI_Get_text.$(OBJEXT) QUI_and_or.$(OBJEXT) QUI_attribut.$(OBJEXT) \
 QUI_catalog.$(OBJEXT) QUI_checkbox.$(OBJEXT) QUI_clear_ok.$(OBJEXT) \
 QUI_clr_vals.$(OBJEXT) QUI_del_row.$(OBJEXT) QUI_delete.$(OBJEXT) \
 QUI_get_op.$(OBJEXT) QUI_get_type.$(OBJEXT) QUI_high_lst.$(OBJEXT) \
 QUI_init_gad.$(OBJEXT) QUI_load.$(OBJEXT) QUI_man_form.$(OBJEXT) \
 QUI_operator.$(OBJEXT) QUI_order.$(OBJEXT) QUI_pars_tri.$(OBJEXT) \
 QUI_parseval.$(OBJEXT) QUI_reorder.$(OBJEXT) QUI_set_op.$(OBJEXT) \
 QUI_set_vals.$(OBJEXT) QUI_swap.$(OBJEXT) QUI_unhilite.$(OBJEXT) \
 QUI_value.$(OBJEXT) QUIattr_fld.$(OBJEXT) QUIexchange.$(OBJEXT) \
 QUIfree.$(OBJEXT) QUIfrom.$(OBJEXT) QUIget_attr.$(OBJEXT) \
 QUIget_qrys.$(OBJEXT) QUIinit.$(OBJEXT) QUIload_attr.$(OBJEXT) \
 QUIload_cat.$(OBJEXT) QUIload_qry.$(OBJEXT) QUIload_vals.$(OBJEXT) \
 QUImessage.$(OBJEXT) QUIqry_fld.$(OBJEXT) QUIsave.$(OBJEXT) \
 QUItools.$(OBJEXT) QUItranslate.$(OBJEXT)

#====================================================
.c.$(OBJEXT):
	@echo " $*.c -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(COMBINE_FLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.c
	@echo
	@mv $*.o $*.$(OBJEXT)
#====================================================
.rc.$(OBJEXT):
	@echo " $*.rc -> $*.$(OBJEXT)"
	@echo "\n remaking $*.$(OBJEXT) because of : $? \n"
	$(RISCC) -r $(CFLAGS) $(CPUFLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.rc
	@echo
	$(CC) -c $(CFLAGS) $(CPUFLAG) $(OSFLAG) $(MISCFLAG) $(RISFLAGS) $(OPT) $(TARGSTR) $*.c
	@echo
	@mv $*.o $*.$(OBJEXT)
#====================================================
$(LIBDIR)/$(ARCHNAME) : $(OBJECTS)
	@echo
	ar ruv $(LIBDIR)/$(ARCHNAME) $(OBJECTS)
	@echo
	@ls -l $(LIBDIR)/$(ARCHNAME)
	@echo
#====================================================


QUI_Get_text.$(OBJEXT) :   ../include/machine.h  ../include/tools.h \
  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_and_or.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_attribut.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_catalog.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_checkbox.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_clear_ok.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_clr_vals.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_del_row.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_delete.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_get_op.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_get_type.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h \
  /usr/include/sys/va_list.h  /usr/include/stdio.h  /usr/include/ctype.h \
  /usr/include/sys/feature_tests.h  /usr/include/string.h \
  /usr/include/memory.h

QUI_high_lst.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_init_gad.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_load.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_man_form.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_operator.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_order.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_pars_tri.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_parseval.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/varargs.h \
  ../include/ERRproto.h  ../include/ERR.h  ../include/DEBUG.h \
  ../include/MEMproto.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h  /usr/include/sys/va_list.h  /usr/include/stdio.h \
  /usr/include/ctype.h  /usr/include/sys/feature_tests.h \
  /usr/include/string.h  /usr/include/memory.h

QUI_reorder.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_set_op.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_set_vals.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_swap.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUI_unhilite.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUI_value.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUIattr_fld.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUIexchange.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUIfree.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUIfrom.$(OBJEXT) :   ../include/machine.h  ../include/tools.h \
  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUIget_attr.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/QUIdef.h  ../include/QUIstruct.h  ../include/QUIlabels.h \
  ../include/QUIproto.h  ../include/QUIerrordef.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NDXstruct.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/QUI.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h

QUIget_qrys.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h

QUIinit.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUIload_attr.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h

QUIload_cat.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/QUIdef.h  ../include/QUIstruct.h  ../include/QUIlabels.h \
  ../include/QUIproto.h  ../include/QUIerrordef.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NDXstruct.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/QUI.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h

QUIload_qry.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUIload_vals.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/QUIdef.h  ../include/QUIstruct.h  ../include/QUIlabels.h \
  ../include/QUIproto.h  ../include/QUIerrordef.h  ../include/MEMstruct.h \
  ../include/NFMstruct.h  ../include/NFMschema.h  ../include/NFMapi.h \
  ../include/NFMUproto.h  ../include/NFMAproto.h  ../include/DISproto.h \
  ../include/NDXstruct.h  ../include/NFMRstruct.h  ../include/NFMRproto.h \
  ../include/NFMcombine.h  ../include/QUI.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h

QUImessage.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  ../include/ERRerrordef.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h  /opt/ingr/include/UMS.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  /usr/include/stdarg.h

QUIqry_fld.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/MEMerrordef.h  ../include/SQLerrordef.h \
  ../include/NETerrordef.h  ../include/NFMerrordef.h  ../include/QUIdef.h \
  ../include/QUIstruct.h  ../include/QUIlabels.h  ../include/QUIproto.h \
  ../include/QUIerrordef.h  ../include/MEMstruct.h  ../include/NFMstruct.h \
  ../include/NFMschema.h  ../include/NFMapi.h  ../include/NFMUproto.h \
  ../include/NFMAproto.h  ../include/DISproto.h  ../include/NDXstruct.h \
  ../include/NFMRstruct.h  ../include/NFMRproto.h  ../include/NFMcombine.h \
  ../include/QUI.h

QUIsave.$(OBJEXT) :   ../include/machine.h  ../include/tools.h \
  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h

QUItools.$(OBJEXT) :  \
  ../include/machine.h  ../include/tools.h  /usr/include/string.h \
  /usr/include/ctype.h  /opt/ingr/xformsdp/xfi/include/FI.h \
  /opt/ingr/include/UMS.h  /usr/include/sys/feature_tests.h \
  /usr/include/stdio.h  /usr/include/stdarg.h  ../include/ERRerrordef.h \
  /usr/include/sys/va_list.h  /usr/include/varargs.h  ../include/ERRproto.h \
  ../include/ERR.h  ../include/DEBUG.h  ../include/MEMproto.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h \
  ../include/MEMerrordef.h

QUItranslate.$(OBJEXT) :   ../include/machine.h \
  ../include/tools.h  /usr/include/string.h  /usr/include/ctype.h \
  /opt/ingr/xformsdp/xfi/include/FI.h  /opt/ingr/include/UMS.h \
  /usr/include/sys/feature_tests.h  /usr/include/stdio.h \
  /usr/include/stdarg.h  ../include/ERRerrordef.h  /usr/include/sys/va_list.h \
  /usr/include/varargs.h  ../include/ERRproto.h  ../include/ERR.h \
  ../include/DEBUG.h  ../include/MEMproto.h  ../include/MEMerrordef.h \
  ../include/SQLerrordef.h  ../include/NETerrordef.h \
  ../include/NFMerrordef.h  ../include/QUIdef.h  ../include/QUIstruct.h \
  ../include/QUIlabels.h  ../include/QUIproto.h  ../include/QUIerrordef.h \
  ../include/MEMstruct.h  ../include/NFMstruct.h  ../include/NFMschema.h \
  ../include/NFMapi.h  ../include/NFMUproto.h  ../include/NFMAproto.h \
  ../include/DISproto.h  ../include/NDXstruct.h  ../include/NFMRstruct.h \
  ../include/NFMRproto.h  ../include/NFMcombine.h  ../include/QUI.h



