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
	-u _dba_setup_dbforms \
	-u _dba_setup_report \
	-u _dba_setup_dbnuc \
	-u _dba_setup_script \
	-u _dba_setup_gui \
	-u _dba_set_catt \
	-u _dba_build_where_text \
	-u _dba_attach_schema \
	-u _dba_ris_text \
	-u _dba_single_quote \
	-u _dba_process_convert_input \
	-u _dba_get_current_column \
	-r -o ${PDU}/config/dload/init/PDUdba.o \
	${DBA}/lib/$TARG/dbforms.a \
	${DBA}/lib/$TARG/report.a \
	${DBA}/lib/$TARG/dbnuc.a \
	${DBA}/lib/$TARG/script.a \
	${DBA}/lib/$TARG/gui.a \
	${DBA}/lib/$TARG/nucleus.a \
	${PDU}/ldpdu/PDUdbastub.o 

echo "PDUdba.o created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUdba.o
echo

