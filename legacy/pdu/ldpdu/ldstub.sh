ar -x /usr/ip32/ums/lib/${TARG}/libUMS.a UMSmsgco.o
mv UMSmsgco.o ${PDU}/config/dload/init

ar -x /usr/ip32/ums/lib/${TARG}/libUMS.a UMSfile.o
mv UMSfile.o ${PDU}/config/dload/init

ar -x /usr/lib/libc.a clock_ansi.o
mv clock_ansi.o ${PDU}/config/dload/init

ar -x /usr/lib/libc.a setpgrp.o _setpgrp.o
mv setpgrp.o ${PDU}/config/dload/init
mv _setpgrp.o ${PDU}/config/dload/init

ar -x /usr/lib/libbsd.a setitimer.o
mv setitimer.o ${PDU}/config/dload/init

ar -x /usr/lib/libbsd.a usleep.o
mv usleep.o ${PDU}/config/dload/init

ar -x /usr/lib/libc.a _l64a.o
mv _l64a.o ${PDU}/config/dload/init
 
if [ "$TARG" = "c100" ]
then
ar -x ${NFM}/lib$TARG/libnfmr.a NFMRtic.1
mv NFMRtic.1 ${PDU}/lib/$TARG/NFMRtic.o
fi
if [ "$TARG" = "c400" ]
then
ar -x ${NFM}/lib$TARG/libnfmr.a NFMRtic.4
mv NFMRtic.4 ${PDU}/lib/$TARG/NFMRtic.o
fi
#ar -x ${EXNUC}/lib/libexnuc.a Rload.o
#mv Rload.o ${PDU}/config/dload/init

ar -x /usr/lib/libxc.a CLIP_Rload.o
mv CLIP_Rload.o ${PDU}/config/dload/init

ar -x ${EXNUC}/lib/libexnuc.a exdload.o
mv exdload.o ${PDU}/config/dload/init

rm kumar.o
rm PDUdbastub.o
rm PDUnfmstub.o

if [ "$TARG" = "c100" ]
then
echo "Compile kumar.c for c100"
echo ""
acc -ansi -O3 -c kumar.c
acc -ansi -O3 -c PDUdbastub.c
acc -ansi -O3 -c PDUnfmstub.c
fi
if [ "$TARG" = "c400" ]
then
echo "Compile kumar.c for c400"
echo ""
acc -ansi -O3 -Atarg=c400 -c kumar.c
acc -ansi -O3 -Atarg=c400 -c PDUdbastub.c
acc -ansi -O3 -Atarg=c400 -c PDUnfmstub.c
fi

echo
echo "linking NFMlib.o"
echo
ld \
	-u _MEMno_buffers \
	-u _MEMwrite \
	-u _MEMsplit_copy_buffer \
	-u _NETclose_c \
	-u _NETclose_s \
	-u _NETbuffer_receive_s \
	-u _NETbuffer_send_s \
	-u _MEMreset_buffer_no \
	-u _MEMbuffer_size \
	-u _MEMwrite_format \
	-u _NETbuffer_receive_c \
	-u _MEMreset_buffer \
	-u _MEMopen \
	-u _MEMbuild_array \
	-u _MEMappend \
	-u _MEMwrite_data \
	-u _MEMprint_buffer \
	-u _NETbuffer_send_c \
	-u _NETfmu_receive \
	-u _NETfmu_rcmd \
	-u _NETfmu_connect \
	-u _NETfmu_disconnect \
	-u _MEMprint_buffers \
	-u _MEMbuild_struct \
	-u _MEMclose \
	-u _MEMcopy_row \
	-u _NFMconnect \
	-u _NFMdecrypt \
	-u _NFMls_nodes \
	-u _NFMload_user_info \
	-u _NFMget_item_no \
	-u _NFMflag_item_delete \
	-u _NFMsplit_catalog_attributes \
	-u _NFMquery_item_attributes \
	-u _NFMreset_change_table \
	-u _NFMcheck_item_owned_project \
	-u _NFMcancel_item_copy \
	-u _NFMquery_changeto_loc_attributes \
	-u _NFMcancel_item_checkout \
	-u _NFMconvert_to_set \
	-u _NFMnfs_file_remove \
	-u _NFMreset_message_struct \
	-u _NFMitem_files \
	-u _NFMcancel_item_backup_flag \
	-u _NFMupd_set_mem_co \
	-u _NFMunlock_item \
	-u _NFMget_storages_information \
	-u _WFmake_transition \
	-u _NFMchange_user_passwd \
	-u _NFMcancel_set_flag \
	-u _NFMretrieve_values \
	-u _NFMflag_set_backup \
	-u _NFMadd_user \
	-u _NFMdelete_catalog \
	-u _NFMdefine_query \
	-u _NFMset_load_item_files \
	-u _NFMall_debug \
	-u _NFMdisplay_users \
	-u _NFMget_file_information \
	-u _NFMcreate_catalog \
	-u _NFMcheckout_item \
	-u _NFMcheckout_set \
	-u _NFMdisplay_catalogs \
	-u _NFMadd_item \
	-u _NFMcancel_update_item \
	-u _NFMreset_file_information \
	-u _NFMcheckin_item \
	-u _NFMquery_project_members \
	-u _NFMquery_add_item_attributes \
	-u _NFMsearch_across_catalogs \
	-u __NFMfs_undo_recv_files \
	-u _NFMupdate_project_members \
	-u _NFMcancel_check_out_set \
	-u _NFMquery_catalog_template_n \
	-u _NFMupdate_item \
	-u _NFMretrieve_query \
	-u _NFMprepare_update_item \
	-u __NFMfs_recv_files \
	-u _NFMdisplay_querys \
	-u _NFMcancel_check_out_item \
	-u _NFMchange_working_area_passwd \
	-u _NFMchange_catalog \
	-u _NFMdelete_item \
	-u _NFMdefine_file_information \
	-u _NFM_SQL_LOCK \
	-u _NFMquery_set_members \
	-u _NFMsave_item_files \
	-u __NFMfree_linked_lists \
	-r -o ${PDU}/config/dload/init/NFMlib.o \
        ${PDU}/lib/$TARG/NFMRtic.o \
	${NFM}/lib$TARG/libnfma.a \
        ${NFM}/lib$TARG/libnfmu.a \
        ${NFM}/lib$TARG/libnfmlists.a \
        ${NFM}/lib$TARG/libnfmsac.a \
        ${NFM}/lib$TARG/libcmdtools.a \
        ${NFM}/lib$TARG/libnfmwf.a \
        ${NFM}/lib$TARG/libdbtools.a \
        ${NFM}/lib$TARG/libnfmtools.a \
        ${NFM}/lib$TARG/libnfmsql.a \
        ${NFM}/lib$TARG/libfilexfer.a \
        ${NFM}/lib$TARG/libtli.a \
        ${NFM}/lib$TARG/libsystools.a \
        ${NFM}/lib$TARG/libnfmmem.a \
        ${NFM}/lib$TARG/libnfmnet.a \
        ${NFM}/lib$TARG/libtli.a \
        ${NFM}/lib$TARG/libnfmerr.a \
	${PDU}/ldpdu/PDUnfmstub.o \
        ${PDU}/ldpdu/kumar.o 

echo
echo "linking PDUdba.o"
echo
ld \
        -u _dba_save_default \
        -u _dba_setup \
        -u _dba_map_character \
        -u _dba_process_menu \
        -u _dba_process_script \
        -u _dba_get_mnunum \
        -u _dba_get_menu_by_name \
        -u _dba_schema_select \
        -u _dba_execute_default \
        -u _dba_single_report \
        -u _dba_set_variable_start \
        -u _dba_set_field_justify \
        -u _dba_display_report \
        -u _dba_add_to_table_list \
        -u _dba_set_current_menu \
        -u _dba_setup_script \
        -u _dba_setup_report \
        -u _dba_setup_dbnuc \
        -u _dba_setup_dbforms \
        -u _dba_setup_gui \
	-u _dba_process_convert_input \
	-u _dba_ris_text \
	-u _dba_get_current_column \
	-u _dba_attach_schema \
	-u _dba_set_catt \
	-u _dba_single_quote \
	-u _dba_build_where_text \
	-r -o ${PDU}/config/dload/init/PDUdba.o \
	${DBA}/lib/$TARG/report.a \
	${DBA}/lib/$TARG/script.a \
	${DBA}/lib/$TARG/dbnuc.a \
	${DBA}/lib/$TARG/dbforms.a \
	${DBA}/lib/$TARG/gui.a \
	${DBA}/lib/$TARG/nucleus.a \
	${PDU}/ldpdu/PDUdbastub.o 

echo
echo "linking PDUspec.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUspec.o \
        ${PDU}/spec/*.o

echo "linking PDUinit.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUinit.o \
        ${PDU}/init/*.o

echo
echo "linking PDUstub.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUstub.o \
	${PDU}/design/PDUstubdsgn.o \
	${PDU}/catalogs/PDUstubcats.o \
	${PDU}/parts/PDUstubparts.o \
	${PDU}/assembly/PDUstubassy.o \
	${PDU}/pdmr/PDUstubpdmr.o \
	${PDU}/filemgr/PDUstubfmgr.o \
	${PDU}/tools/PDUstubtools.o \
	${PDU}/reports/PDUstubrpts.o \
	${PDU}/reports/PDUstubpsurp.o \
	${PDU}/macros/PDUstubmacro.o \
	${PDU}/misc/PDUstubmisc.o \
	${NPAL}/src/funk/PDUstubfunk.o \
	${NPAL}/src/ris/PDUstubris.o \
	${NPAL}/src/pdmr/PDUstubppdmr.o \
	${NPAL}/src/pdmr/svs/PDUstubsvs.o \
	${PDM}/ass/PDMstubass.o \
	${PDM}/bom/PDMstubbom.o \
	${PDM}/cicocp/PDMstubcicoc.o \
	${PDM}/fmgr/PDMstubfmgr.o \
	${PDM}/macros/PDMstubmacro.o \
	${PDM}/mulfile/PDMstubmulfl.o \
	${PDM}/pdmp/PDMstubpdmp.o \
	${PDM}/pdms/PDMstubpdms.o \
	${PDM}/reports/PDMstubrpts.o \
	${PDM}/ris/PDMstubris.o \
	${PDM}/tools/PDMstubtools.o


${EXNUC}/bin/opl -d Pdu  ${PDU}/config/dload/init/PDUspec.o
#vi OMprodinit.C
SED_FILE=${PDU}/ldpdu/sed_file
TMP_OMPRODINIT_FILE=${PDU}/ldpdu/omprod.tmp
sed -f ${SED_FILE} OMprodinit.C > ${TMP_OMPRODINIT_FILE}
mv ${TMP_OMPRODINIT_FILE} OMprodinit.C
${EXNUC}/bin/omcpp -I${EXNUC}/include OMprodinit.C > OMprodinit.c
if [ "$TARG" = "c100" ]
then
if [ "$PLATFORM" = "21" ]
then
acc -knr -Dbld21 -c -I$EXNUC/include OMprodinit.c
else
acc -ansi -O3 -c -I$EXNUC/include OMprodinit.c
fi
elif [ "$TARG" = "c400" ]
then
acc -ansi -O3 -Atarg=c400 -c -I$EXNUC/include OMprodinit.c
fi
#acc -ansi -O3 -c -I$EXNUC/include OMprodinit.c
mv OMprodinit.o ${PDU}/config/dload/init
${EXNUC}/bin/version.sh
if [ "$TARG" = "c100" ]
then
acc -ansi -O3 -c -I${EXNUC}/include PDUver.c
fi
if [ "$TARG" = "c400" ]
then
acc -ansi -O3 -Atarg=c400 -c -I${EXNUC}/include PDUver.c
fi
#acc -ansi -O3 -c -I${EXNUC}/include PDUver.c
mv PDUver.o ${PDU}/config/dload/init
cd $PDU/config/tables
chmod 777 update_cmdtbl
chmod 777 update_ppltbl
./update_cmdtbl
./update_ppltbl 
cd

echo
echo
echo "PDU images created successfully."
echo
ls -lsat ${PDU}/config/dload/init/*.o
echo

