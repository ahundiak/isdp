#ifndef PDM_EXTAPI_PRO_H
#define PDM_EXTAPI_PRO_H

#include "PDMapi_value.h"
#include "PDMapi_struc.h"

#if defined(__STDC__) || defined(__cplusplus)
#define __PDM(args) args
#else
#define __PDM(args) ()
#endif

#include "PDMapi.h"

#if defined(__cplusplus)
extern "C" {
#endif

extern int pdmoAddFiles __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_stg_name, struct file_info *spr_add_files));
extern int pdmoAddPart __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_parttype, char *cpr_description, char *cpr_acl_name, char *cpr_stg_name, struct attribute_info *spr_attrs, struct file_info *spr_files));
extern int pdmoLoadChildStructure __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_description, int ir_childno, double dr_quantity, char *car_p_usageid, char *car_n_cofilename, int ir_p_tagno, char *car_p_alttagno, char *car_p_incbom, char *car_p_explode, char *car_p_incstr, PDMchildren spr_PDMstructure));
extern int pdmoChangeFiles __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_stg_name, struct chg_file_info *spr_chg_files));
extern int pdmoChangePart __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, char *cpr_parttype, char *cpr_description, char *cpr_acl_name, char *cpr_stg_name, struct attribute_info *spr_attrs, struct file_info *spr_add_files, struct chg_file_info *spr_chg_files));
extern int pdmoDebugOn __PDM((int *apitog, char **apifiles));
extern int pdmoDebugOff __PDM((void));
extern int pdmoDeleteFiles __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, struct file_info *spr_delete_files));
extern int pdmoDeletePart __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision));
extern int pdmoGetTransitions __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, struct part_transition **spm_trans_list));
extern int pdmoFreeTransStructure __PDM((struct part_transition **trans_list));
extern int pdmoLoadAttrStructure __PDM((char *cpr_attr_name, char *cpr_datatype, char *cpr_synonym, char *cpr_value, struct attribute_info **spm_attrs));
extern int pdmoFreeAttrStructure __PDM((struct attribute_info **attr_list));
extern int pdmoGetPartAttributes __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, struct attribute_info **attr_list));
extern int pdmoLoadFileStructure __PDM((char *cpr_file_desc, char *cpr_local_fn, char *cpr_storage_fn, char *cpr_file_type, int ir_mode, struct file_info **spm_file_list));
extern int pdmoLoadChangeStructure __PDM((char *cpr_file_desc, char *cpr_chg_file_desc, char *cpr_local_fn, char *cpr_chg_local_fn, char *cpr_storage_fn, char *cpr_chg_storage_fn, char *cpr_file_type, char *cpr_chg_file_type, int ir_mode, struct chg_file_info **spm_chg_list));
extern int pdmoFreeFileStructure __PDM((struct file_info **file_list));
extern int pdmoFreeChangeStructure __PDM((struct chg_file_info **file_list));
extern long pdmoLogin __PDM((char *cpr_env, char *cpr_pdmuser, char *cpr_pdmpasswd, struct pdmWorkingArea **spm_userinfo));
extern int pdmoLogout __PDM((void));
extern int pdmoModifyAssembly __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, PDMchildren spr_PDMadd_to_structure, PDMchildren spr_PDMdelete_from_structure));
extern int pdmoMoveToNextState __PDM((char *cpr_catalog, char *cpr_partnum, char *cpr_revision, int ir_stateno, char *cpr_statename));
extern long pdmoRisStatement __PDM((char *cpr_sql_str, struct pdmRisError **spw_err_code));
extern int pdmoRisQuery __PDM((char *cpr_sql_str, struct pdmRisQuery **spm_query_info, struct pdmRisError **spw_err_code));

#if defined(__cplusplus)
}
#endif


#endif
