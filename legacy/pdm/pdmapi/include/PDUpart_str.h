/*  The structures in this file were created to support the part operations
    APIs.
*/

#include "PDMapi_value.h"

 struct attribute_info
  {
  char                 cpr_attr_name[IK_ATTR_MAX];
  char                 cpr_datatype[IK_DATATYPE_MAX];
  char                 cpr_synonym[IK_SYNONYM_MAX];
  char                 cpr_value[IK_VALUE_MAX];
  struct attribute_info *spm_next;
  };
 
 struct file_info
  {
  char                 cpr_file_desc[IK_FILEDESC_MAX];
  char                 cpr_local_fn[IK_FILENAME_MAX];
  char                 cpr_storage_fn[IK_FILENAME_MAX];
  char                 cpr_file_type[IK_FILETYPE_MAX];
  int                  ir_mode;
  struct file_info  *spm_next;
  };

 struct chg_file_info
  {
  char                 cpr_file_desc[IK_FILEDESC_MAX];
  char                 cpr_chg_file_desc[IK_FILEDESC_MAX];
  char                 cpr_local_fn[IK_FILENAME_MAX];
  char                 cpr_chg_local_fn[IK_FILENAME_MAX];
  char                 cpr_storage_fn[IK_FILENAME_MAX];
  char                 cpr_chg_storage_fn[IK_FILENAME_MAX];
  char                 cpr_file_type[IK_FILETYPE_MAX];
  char                 cpr_chg_file_type[IK_FILETYPE_MAX];
  int                  ir_mode;
  struct chg_file_info  *spm_next;
  };

 struct part_transition
  {
  char                 cpr_statename[IK_STATENAME_MAX];
  char                 cpr_transition[IK_TRANSNAME_MAX];
  int                  ir_stateno;
  struct part_transition *spm_next;
  };

#define  ADD	1
#define  CHANGE	2
#define  DELETE	3
