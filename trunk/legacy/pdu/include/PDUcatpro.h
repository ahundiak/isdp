#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./catalogs/PDUbuff.c */
extern int PDUformat_list_buffer __PDU((MEMptr *list_buffer));
extern int PDUfind_attr_by_synonym __PDU((char *synonym, MEMptr attr_bufr));
extern int PDUformat_classification_buffer __PDU((MEMptr *class_buffer));
extern int PDUformat_cat_class_bufr __PDU((int no_levels, MEMptr *class_buffer));
extern int PDUformat_parameter_buffer __PDU((MEMptr *parm_buffer));
extern int PDUformat_macro_buffer __PDU((MEMptr *macro_buffer));
extern int PDUformat_search_dyntable_bufr __PDU((MEMptr *dyntable_bufr));
extern int PDUformat_delete_part_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_status_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_macro_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_macrolib_copy_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_os_parts_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_function_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_catalog_list_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_define_support_lib_bufr __PDU((MEMptr *new_bufr));
extern int PDUformat_update_parm_parts_bufr __PDU((MEMptr *new_bufr));

/* ./catalogs/PDUcat_attr.c */
extern int cat_attr_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int PDUupdate_attr_form __PDU((MEMptr attr_buffer, MEMptr data_buffer, MEMptr list_buffer, int label));
extern int PDUadd_attribute __PDU((MEMptr *attr_buffer, MEMptr *data_buffer, MEMptr *list_buffer));
extern int PDUchange_attribute __PDU((MEMptr *attr_buffer, MEMptr *data_buffer, MEMptr *list_buffer));
extern int PDUfill_in_mcf __PDU((MEMptr attribute_buffer, MEMptr data_buffer, int mcf_label));
extern int PDUupdate_attr_buffer __PDU((MEMptr *attr_buffer, int mcf_label));
extern int catalog_attr_form __PDU((void));
extern int PDUcatalog_attr_form __PDU((void));
extern int PDUcheck_if_datatype __PDU((void));
extern int PDUvalidate_default_in_range __PDU((char *default_value, char *type));
extern int PDUvalidate_default_in_list __PDU((char *default_value));
extern int PDUload_search_dyntable_bufr __PDU((MEMptr dyn_attr, MEMptr *new_bufr));

/* ./catalogs/PDUcat_name.c */
extern int cat_name_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int cat_name_form __PDU((void));
extern int PDUcatalog_name_form __PDU((void));
extern int PDUupdate_catalog_list __PDU((void));
extern int PDUget_classification_scheme __PDU((void));
extern int PDUload_classification __PDU((MEMptr *input_buffer));
extern int PDUfill_in_class __PDU((MEMptr input_buffer));
extern int PDUcheck_catalog_commands __PDU((void));
extern int PDUcheck_for_class __PDU((void));
extern int PDUget_classification_for_listing __PDU((void));
extern int PDUcheck_catalog_template __PDU((void));
extern int PDUcheck_catalog_char __PDU((char *filename, char *spec_char));

/* ./catalogs/PDUcommands.c */
extern int PDUvalidate_access __PDU((int command));

/* ./catalogs/PDUcopy_cat.c */
extern int PDUcreate_like_catalog __PDU((void));
extern int PDUmerge_copycat_buffers __PDU((MEMptr *src_attr, MEMptr new_attr));

/* ./catalogs/PDUcreat_cat.c */
extern int PDUcreate_catalog __PDU((void));

/* ./catalogs/PDUdef_lib.c */
extern int define_lib_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int define_lib_form __PDU((void));
extern int PDUdefine_library_form __PDU((void));
extern int PDUload_define_support_library_mcf __PDU((int gadget_label, MEMptr buffer));
extern int PDUcheck_for_mcf_select __PDU((Form fp, int gadget_label));
extern int PDUadd_define_library __PDU((void));
extern int PDUdelete_support_library __PDU((void));
extern int PDUload_support_lib_bufr __PDU((MEMptr *ass_bufr));
extern int PDUdefine_support_update __PDU((void));

/* ./catalogs/PDUdel_cat.c */
extern int PDUdelete_catalog __PDU((void));

/* ./catalogs/PDUdyn_attr.c */
extern int PDUcreate_dynamic_attr_buffr __PDU((MEMptr *dynamic_attr_buffr));

/* ./catalogs/PDUfrm_tools.c */
extern int PDUget_catalog_buffers __PDU((int command));
extern int PDUsort_by_order __PDU((MEMptr attr_bufr, MEMptr data_bufr, MEMptr *sort_attr, MEMptr *sort_data));
extern int PDUcheck_for_reserved_words __PDU((char *string));
extern int PDUcheck_if_attribute_already_created __PDU((void));
extern int PDUconvert_parametric_datatype __PDU((char *text, char **datatype));
extern int PDUconvert_to_iotype __PDU((char *text, char **datatype, char *type));
extern int PDUget_catalog_description __PDU((void));
extern int PDUcreate_class_and_catalog_bufr __PDU((MEMptr in_buffer, MEMptr *out_buffer));
extern int PDUcreate_list_of_cat_attributes __PDU((MEMptr in_buffer, MEMptr *out_buffer));

/* ./catalogs/PDUmod_cat.c */
extern int PDUmodify_catalog __PDU((void));

/* ./catalogs/PDUparm_form.c */
extern int parm_cat_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int parametric_catalog_form __PDU((void));
extern int PDUparametric_catalog_form __PDU((void));
extern int PDUload_parametric_attributes __PDU((MEMptr *attr_bufr, MEMptr *data_bufr, MEMptr *dyn_attr, MEMptr *dyn_data, int gadget_label));
extern int PDUload_macro_parameters __PDU((void));
extern int PDUload_map_buffer __PDU((MEMptr *buffer));
extern int PDUupdate_parametric_catalog_form __PDU((void));
extern int PDUload_parametric_catalog_form __PDU((MEMptr macro_buffer, MEMptr parm_buffer));
extern int PDUchange_parameters __PDU((void));
extern int PDUmodify_parametric_synonym __PDU((MEMptr *cat_attr, MEMptr *dyn_attr));

/* ./catalogs/PDUparm_part.c */
extern int parm_part_notification_routine __PDU((int f_label, int g_label, double value, Form fp));
extern int parametric_part_form __PDU((char *prev_cat_name));
extern int PDUparametric_part_form __PDU((char *prev_cat_name));
extern int PDUload_data_into_mcf __PDU((MEMptr attr_bufr, MEMptr data_bufr, MEMptr list_bufr));
extern int PDUload_parametric_part_bufr __PDU((MEMptr def_data));
extern int PDUload_mod_parametric_part_bufr __PDU((void));
extern int PDUload_deleted_parts __PDU((MEMptr *del_bufr));
extern int PDUadd_row_with_defaults __PDU((void));
extern int PDUload_delete_parts_bufr __PDU((MEMptr *buffer));
extern int PDUdisplay_where_used __PDU((MEMptr bufr));
extern int PDUcheck_if_catalog __PDU((char *text));
extern int PDUupdate_class_buffer __PDU((MEMptr old_bufr, MEMptr *new_bufr, int level_no));
extern int PDUget_parametric_part_attributes __PDU((void));
extern int PDUload_parametric_parts_after_select __PDU((void));
extern int PDUprocess_class_pulldown __PDU((void));
extern int PDUextract_refresh_from_mcf __PDU((int selected_row));
extern int PDUfinish_parametric_move_to_next_state __PDU((void));

/* ./catalogs/PDUvalidate.c */
extern int PDUvalidate_value __PDU((char *value, char *datatype));
extern int PDUvalidate_dyn_value __PDU((char *attr_name, char *value, MEMptr attr_buffer, MEMptr list_buffer));
extern int PDUcheck_if_change_toggles __PDU((char *attr_name));
extern int PDUcheck_if_change_datatype __PDU((char *attr_name));

/* ./catalogs/cat_global.c */

#undef __PDU
#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif

#endif
