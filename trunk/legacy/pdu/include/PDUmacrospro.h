#ifndef PDU_PROTO_H
#define PDU_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __PDU(s) s
#else
# define __PDU(s) ()
#endif


/* ./macros/PDUactdeact.c */
extern void PDUprepare_activate_part __PDU((int *status, char *catalog, char *part, char *revision, char *file));
extern void PDUprepare_deactivate_part __PDU((int *status, int save_flag));
extern void PDUprepare_create_bom __PDU((int *status, char *catalog, char *part, char *revision));
extern void PDUprepare_where_used __PDU((int *status, char *catalog, char *part, char *revision, char *report_name, char *filename, int display));

/* ./macros/PDUm_add_pt.c */
extern void PDUm_add_part __PDU((int *status, char *catalog, char *part_id, char *rev, char *part_type, char *desc, char *acl_name, char *stg_name, struct PDUattribute_info *attrs, struct file_info *files));
extern void PDUload_file_structure __PDU((int *status, char *file_desc, char *local_fn, char *chg_local_fn, char *storage_fn, char *file_type, int mode, struct file_info **file_list));
extern void PDUfree_file_structure __PDU((int *status, struct file_info **file_list));

/* ./macros/PDUm_cat.c */
extern void PDUprepare_create_catalog __PDU((int *status, char *catalog, char *description, char *acl_name, char *temp_cat, struct PDUattribute_info *static_attr, struct PDUattribute_info *dynamic_attr));
extern void PDUprepare_load_attribute_structure __PDU((int *status, char *attribute, char *datatype, char *synonym, char *value, struct PDUattribute_info **attr_list));
extern void PDUprepare_free_attribute_structure __PDU((int *status, struct PDUattribute_info **attr_list));
extern int PDUadd_static_attributes __PDU((struct PDUattribute_info *attr));
extern int PDUadd_dynamic_attributes __PDU((struct PDUattribute_info *attr));

/* ./macros/PDUm_chg_pt.c */
extern void PDUm_chg_part __PDU((int *status, char *catalog, char *part_id, char *rev, char *part_type, char *desc, char *acl_name, char *stg_name, struct PDUattribute_info *attrs, struct file_info *files));
extern int PDUunlock_part __PDU((char *catalog, char *part, char *rev, MEMptr attr_bufr, MEMptr data_bufr));

/* ./macros/PDUm_chkin.c */
extern void PDUppl_checkin_part __PDU((int *status, char *catalog, char *part, char *revision));
extern int PDUmacro_checkin_part __PDU((void));

/* ./macros/PDUm_chkout.c */
extern void PDUppl_checkout_part __PDU((int *status, char *catalog, char *part, char *revision, int activate_flag));
extern int PDUmacro_checkout_part __PDU((void));

/* ./macros/PDUm_cpfiles.c */
extern void PDUppl_copy_files __PDU((int *status, char *catalog, char *part, char *revision, int activate_flag));
extern int PDUmacro_copy_file __PDU((void));

/* ./macros/PDUm_login.c */
extern void PDUppl_login __PDU((int *status, char *environment, char *username, char *passwd));

/* ./macros/PDUm_logout.c */
extern void PDUppl_logout __PDU((int *status));

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
