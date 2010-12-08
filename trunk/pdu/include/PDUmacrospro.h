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

/* ./macros/PDUactdeact.c */
extern void PDUprepare_activate_part __PDU((int *status, char *catalog, char *part, char *revision, char *file));
extern void PDUprepare_deactivate_part __PDU((int *status, int save_flag));
extern void PDUprepare_create_bom __PDU((int *status, char *catalog, char *part, char *revision));
extern void PDUprepare_where_used __PDU((int *status, char *catalog, char *part, char *revision, char *report_name, char *filename, int display));

/* ./macros/PDUm_add_pt.c */
extern void PDUm_add_part __PDU((int *status, char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_parttype, char *cpr_description, char *cpr_acl_name, char *cpr_stg_name, struct PDUattribute_info *spr_attrs, struct file_info *spr_files));
extern void PDUload_file_structure __PDU((int *status, char *cpr_desc, char *cpr_localfn, char *cpr_stgfn, char *cpr_type, int ir_mode, struct file_info **spm_file_list));
extern void PDUload_change_structure __PDU((int *status, char *cpr_desc, char *cpr_chg_desc, char *cpr_localfn, char *cpr_chg_localfn, char *cpr_stgfn, char *cpr_chg_stgfn, char *cpr_type, char *cpr_chg_type, int ir_mode, struct chg_file_info **spm_chg_list));
extern void PDUfree_file_structure __PDU((int *status, struct file_info **file_list));
extern void PDUfree_change_file_structure __PDU((int *status, struct chg_file_info **file_list));

/* ./macros/PDUm_cat.c */
extern void PDUprepare_create_catalog __PDU((int *status, char *catalog, char *description, char *acl_name, char *temp_cat, struct PDUattribute_info *static_attr, struct PDUattribute_info *dynamic_attr));

/* ./macros/PDUm_chg_pt.c */
extern void PDUm_chg_part __PDU((int *status, char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_parttype, char *cpr_description, char *cpr_acl_name, char *cpr_stg_name, struct PDUattribute_info *spr_attrs, struct file_info *spr_add_files, struct chg_file_info *spr_chg_files));

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
