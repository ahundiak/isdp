#ifndef QUI_PROTO_H
#define QUI_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __QUI(s) s
#else
# define __QUI(s) ()
#endif


/* QUI_Get_text.c */
extern int QUI_Get_text __QUI((Form fp, long g_label));

/* QUI_and_or.c */
extern long QUI_and_or __QUI((Form form, long g_label));

/* QUI_attribut.c */
extern long QUIattribute __QUI((Form form, long g_label));

/* QUI_catalog.c */
extern long QUI_catalog __QUI((Form form, long g_label));

/* QUI_checkbox.c */
extern long QUIcheckbox __QUI((Form form, long g_label));
extern long QUIdisplay_checkboxes __QUI((Form form, int on_or_off));

/* QUI_clear_ok.c */
extern void QUI_clear_form __QUI((Form form));

/* QUI_clr_vals.c */
extern long QUI_clear_values __QUI((Form form));

/* QUI_del_row.c */
extern long QUI_delete_row __QUI((Form form, long g_label));

/* QUI_delete.c */
extern long QUI_delete __QUI((Form form, long gadget_index));

/* QUI_get_op.c */
extern short QUI_get_op __QUI((char *oper));

/* QUI_get_type.c */
extern void QUIget_type __QUI((char *type_string, short *data_type, short *data_length));

/* QUI_high_lst.c */
extern int QUI_highlight_list __QUI((Form fp, long g_label, char *row_text));

/* QUI_init_gad.c */
extern long QUI_initialize_structure __QUI((long index));
extern long QUI_initialize_gadgets __QUI((Form form));

/* QUI_load.c */
extern long QUIload_definition __QUI((Form form, char *where_clause));

/* QUI_man_form.c */
extern long QUI_manipulate_form __QUI((Form form, long gadget_index));

/* QUI_operator.c */
extern long QUI_operator __QUI((Form form, long g_label));

/* QUI_order.c */
extern long QUI_order_button __QUI((Form form, long g_label));

/* QUI_pars_tri.c */
extern long QUIparse_trio __QUI((char *trio));
extern long QUIformat_date __QUI((char *value));

/* QUI_parseval.c */
extern long SQF_num_chars __QUI((int ch, char *st));
extern int SQF_make_op __QUI((long oper, char *symbol));
extern void parse_star __QUI((char *hld, long pos_star, char *item_name, long type, long sign, char *valstr));
extern void parse_qmark __QUI((char *hld, long pos_qmark, char *item_name, long type, long sign, char *valstr));
extern void parse_colon __QUI((char *hld, long num_colon, char *item_name, long type, long sign, char *valstr));
extern void QUI_parseval __QUI((char *item_name, long type, long sign, char *invalue, char *outvalue));
extern void QUI_tic_to_tics __QUI((char *in, char *out));

/* QUI_reorder.c */
extern long QUI_reorder __QUI((Form form, long gadget_index));

/* QUI_set_op.c */
extern int QUI_set_op __QUI((long number, char *oper));

/* QUI_set_vals.c */
extern long QUIset_values __QUI((Form form, double value));

/* QUI_swap.c */
extern int QUI_swap __QUI((long index1, long index2));

/* QUI_unhilite.c */
extern int QUI_unhilite __QUI((Form fp, long g_label));

/* QUI_value.c */
extern long QUI_value __QUI((Form form, long g_label));

/* QUIattr_fld.c */
extern long QUIload_attribute_info __QUI((Form form, int label, long gadget_index));

/* QUIexchange.c */
extern long _QUIexchange_lists __QUI((Form form, int label1, int label2));

/* QUIfree.c */
extern long QUIfree_structs __QUI((void));

/* QUIfrom.c */
extern long _QUIparse_from_clause __QUI((char *from_clause));
extern long QUIsave_from_data __QUI((int catalog_no, int attrib_no));
extern long QUIbuild_from_clause __QUI((char *from_clause, char **where_clause));

/* QUIget_attr.c */
extern long QUIget_attributes __QUI((int catalog_no));

/* QUIget_qrys.c */
extern long _QUIget_queries __QUI((Form form, char *username));

/* QUIinit.c */
extern long QUIinit_form __QUI((char *catalog, char *form_title, char *query_title, char *active_query, long config_mask, QFONT *font_info, QCOLOR *color_info, int attribute_source, char *application, char *username, void (*notify_routine )(), Form field_form, int field_label, char *field_ptr, Form *query_form));
extern long _QUInotify __QUI((int g_label, double value, Form *form));

/* QUIload_attr.c */
extern long _QUIload_catalog_attributes __QUI((Form form, int label, int catalog_no));

/* QUIload_cat.c */
extern long _QUIload_catalogs __QUI((Form form, char *catalog, char *application));

/* QUIload_qry.c */
extern long _QUIload_query __QUI((Form form));

/* QUIload_vals.c */
extern long QUIload_value_list __QUI((Form form, long gadget_index));

/* QUImessage.c */
extern void QUIform_message __QUI((Form form, int message_no, char *message_fmt, ...));
extern void QUIerror_message __QUI((Form form));
extern void QUIerase_message __QUI((Form form));

/* QUIqry_fld.c */
extern long _QUIquery_field __QUI((Form form, int label));

/* QUIsave.c */
extern long QUIsave_definition __QUI((Form form));

/* QUItools.c */
extern long _QUIfind_column_offset __QUI((MEMptr buffer, char *attrname, short *offset));
extern long _QUIcenter_form __QUI((Form form, int xlocation, int ylocation));

/* QUItranslate.c */
extern long QUIget_catalog_from_alias __QUI((char *alias, short *catalog_no));
extern long QUIget_number_from_catalog __QUI((char *catalog_name, short *catalog_no));
extern long QUIget_catalog_from_number __QUI((int catalog_no, char *catalog_name));
extern long QUIget_alias_from_number __QUI((int catalog_no, int attrib_no, char *alias));
extern long QUIget_attribute_from_number __QUI((int catalog_no, int attrib_no, char *attribute));
extern long QUIget_number_from_attribute __QUI((int catalog_no, char *attribute, short *attrib_no));
extern long QUIget_synonym __QUI((int catalog_no, int attrib_no, char *synonym));

#undef __QUI

#endif
