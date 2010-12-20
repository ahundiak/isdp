#ifndef PDM_API_PRO_H
#define PDM_API_PRO_H

#include "PDUmac_struc.h"

#if defined(__STDC__) || defined(__cplusplus)
#define __PDM(args) args
#else
#define __PDM(args) ()
#endif

#include "PDMapi.h"

#if defined(__cplusplus)
extern "C" {
#endif

extern int PDUcleanup_local_filemgr __PDM((void));
extern void UI_status __PDM((char *msg));
extern void MRPget_time __PDM((void));
extern void MRPget_date __PDM((void));
extern void MRPstrcpy __PDM((void));
// extern void PSUexe_rpt __PDM((void)); // Different proto elsewhere
extern void MS_init __PDM((void));
extern void MS_out_msg __PDM((void));
extern void MSmessage __PDM((void));
extern void MS_fix_type __PDM((void));
extern void PDMstrcpy __PDM((char *cpr_value, char **cppw_variable));
extern int PDMassy_linklist_to_buffer __PDM((PDMchildren spr_head, MEMptr *xpw_buffer));
extern int PDMassy_buffer_to_linklist __PDM((MEMptr assy_bufr, PDMchildren spr_PDMstructure));
extern int PDMdrop_node_from_linklist __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, int ir_childno, char *cpr_usageid, PDMchildren spm_PDMstructure));
extern int PDMfind_instanceno_in_linklist __PDM((PDMchildren spm_head, char **usageid));
extern int PDMfind_childno_in_linklist __PDM((PDMchildren spr_head));
extern int PDMcheck_usageid_for_uniqueness __PDM((PDMchildren head, char *usageid));
extern int PDMgenerate_tagno_from_linklist __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, PDMchildren cpr_head));
extern void PDUcleanup_change_part __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, MEMptr attr_bufr, MEMptr data_bufr, MEMptr file_bufr, MEMptr add_bufr, MEMptr acl_bufr, MEMptr stg_bufr));
extern int PDUadd_files_to_buffer __PDM((MEMptr *file_bufr, struct file_info *add_list, char *saname));
extern int PDUchange_files_in_buffer __PDM((MEMptr *file_bufr, struct chg_file_info *chg_list));
extern int PDUmark_files_for_delete __PDM((MEMptr *file_bufr, struct file_info *delete_list));
extern void PDUuser_clear __PDM((void));
extern void PDUstorage_clear __PDM((void));
extern int PDUloadapi_transition_structure __PDM((MEMptr spr_trans_bufr, struct part_transition **spw_trans_list));
extern int PDUloadapi_file_structure __PDM((char *cpr_desc, char *cpr_localfn, char *cpr_stgfn, char *cpr_type, int ir_mode, struct file_info **spm_file_list));
extern int PDUloadapi_change_structure __PDM((char *cpr_desc, char *cpr_chg_desc, char *cpr_localfn, char *cpr_chg_localfn, char *cpr_stgfn, char *cpr_chg_stgfn, char *cpr_type, char *cpr_chg_type, int ir_mode, struct chg_file_info **spm_chg_list));
extern int PDUloadapi_attr_structure __PDM((char *cpr_attrname, char *cpr_datatype, char *cpr_synonym, char *cpr_value, struct attribute_info **attr_list));
extern int PDUloadapi_attr_list_from_buffer __PDM((MEMptr attr_bufr, struct attribute_info **attr_list));
extern int PDUfree_api_file_structure __PDM((struct file_info **file_list));
extern int PDUfree_api_change_file_structure __PDM((struct chg_file_info **file_list));
extern int PDUfree_api_attr_structure __PDM((struct attribute_info **attr_list));
extern int PDUfree_api_trans_structure __PDM((struct part_transition **trans_list));
extern int PDUverify_add_file_list __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_stg_name, struct file_info *spr_file_list));
extern int PDUverify_attr_list __PDM((struct attribute_info *attr_list, MEMptr attr_bufr, MEMptr list_bufr, MEMptr *data_bufr, short mode));
extern int PDUprint_file_list __PDM((struct file_info *file_list));
extern int PDUprint_change_list __PDM((struct chg_file_info *file_list));
extern int PDUprint_attr_list __PDM((struct attribute_info *list));
extern int PDUverify_change_file_list __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_stg_name, struct chg_file_info *spr_files));
extern int PDUverify_delete_file_list __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, struct file_info *spr_files));
extern int PDUprint_transition_list __PDM((struct part_transition *trans_list));
extern long pdmcheck_log_in __PDM((void));

#if defined(__cplusplus)
}
#endif

#endif
