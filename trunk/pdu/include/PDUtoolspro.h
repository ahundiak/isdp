#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./tools/PDUbfr_tools.c */
extern int PDUfind_col_in_buffer __PDU((MEMptr buffer, char *attr));
extern int PDUget_column_width __PDU((char *datatype));
extern int PDUheader_string_to_array __PDU((char *string, char ***header_data, int **header_pos));
extern int PDUupdate_copy_macro_lib_bufr __PDU((char *catalog));

/* ./tools/PDUchsym_frm.c */
extern int change_symbology_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int change_symbology_form __PDU((void));
extern int PDUchange_symbology __PDU((void));

/* ./tools/PDUdebug.c */
extern int PDUdebug_on __PDU((void));
extern int PDUdebug_off __PDU((void));

/* ./tools/PDUform.c */
extern int PDUfree_list __PDU((char **data_list, int number_of_rows, int number_of_cols));
extern int PDUfill_in_string __PDU((char **variable, char *string));
extern int PDUfill_in_string1 __PDU((char **variable, char *string));

/* ./tools/PDUlinklist.c */
extern int PDUassy_buffer_to_linklist __PDU((MEMptr assy_bufr));
extern int PDUprint_linklist __PDU((struct PDUassy_node *head));
extern int PDUassy_linklist_to_buffer __PDU((struct PDUassy_node *head, MEMptr *buffer));
extern void PDUdrop_node_from_linklist __PDU((char *usage_id));
extern void PDUadd_node_to_linklist __PDU((int level, int parent, int child, char *catalog, char *partid, char *revision, char *attach, char *quantity, char *usage, char *tag, char *explode, char *filename, int catalogno, int itemno));
extern int PDUfind_field_in_linklist __PDU((char *field, char **value));
extern int PDUupdate_field_in_linklist __PDU((char *field, char *value));
extern int PDUfind_instanceno_in_linklist __PDU((struct PDUassy_node *head, char **usageid));
extern int PDUfind_childno_in_linklist __PDU((struct PDUassy_node *head));
extern int PDUcheck_usageid_for_uniqueness __PDU((struct PDUassy_node *head, char *usageid));
extern int PDUgenerate_tagno_from_linklist __PDU((struct PDUassy_node *head));
extern int PDUcheck_alttag_for_uniqueness __PDU((struct PDUassy_node *head, char *alttag));

/* ./tools/PDUstat.c */
extern int PDUstat __PDU((char *filename, struct stat *file_status));

/* ./tools/PDUstr_attr.c */
extern int PDUstring_to_attributes __PDU((char *string, int *count, char ***list));

/* ./tools/PDUtoolsapi.c */
extern int PDUadd_buffer_string __PDU((char *buff_string, int *position, char *char_string));
extern int PDUvalid_attr __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_timestamp __PDU((char *string, char *msg));
extern int PDUvalid_number __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_string __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_smallint __PDU((char *string, char *arg, char *msg));
extern int PDUfind_attr_in_buffer __PDU((MEMptr buffer, char *attr));
extern int PDUvalid_datatype __PDU((char *string, char *arg, char *msg));

/* ./tools/PDUupdat_buf.c */
extern int PDUupdate_data_buffer __PDU((MEMptr *data_buffer, MEMptr attr_buffer));
extern int PDUupdate_parm_data_buffer __PDU((MEMptr *data_buffer, MEMptr attr_buffer));
extern int PDUupdate_dyn_data_buffer __PDU((MEMptr *data_buffer, MEMptr attr_buffer));
extern int PDUupdate_dyn_data_buffer1 __PDU((MEMptr *data_buffer, MEMptr attr_buffer));

/* ./tools/PDUvalid.c */
extern int PDUvalid_alt_tag __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_alt_tag_edt_part __PDU((char *string, char *argument, char *msg));
extern int PDUvalid_part_type __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_date __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_dynamic_attr __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_Y_N_attr __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_dynamic_value __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_synonym __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_level __PDU((char *string, char *arg, char *msg));
extern int PDUvalidate_dyn_attr_uniqueness __PDU((char *string, char *arg, char *msg));
extern int PDUvalid_case __PDU((char *string, char *arg, char *msg));
extern int PDUcheck_for_blanks __PDU((char string[132 ]));
extern int PDUpart_id __PDU((char *catalog, char *partid, char *revision));
extern int PDUfile_id __PDU((char *filename));
extern int PDUvalidate_function __PDU((char *filename));
extern int PDUvalid_decimal __PDU((char *string, char *arg, char *msg));
extern int PDUvalidate_synonym_is_unique __PDU((char *synonym, MEMptr buffer));

/* ./tools/PDUverify.c */
extern int PDUverify_catalog __PDU((char *catalog));
extern int PDUverify_element __PDU((char *catalog, char *partid, char *revision));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDU
#define __PDU(args) args
#endif
#else
#ifndef __PDU
#define __PDU(args) ()
#endif
#endif

#endif
