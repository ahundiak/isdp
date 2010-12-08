#ifndef PDUmac_struc_h
#define PDUmac_struc_h

#define   CHG_MODE   0
#define   ADD_MODE   1

/* API definitions */

#define  ADD    1
#define  CHANGE 2
#define  DELETE 3
 
#define IK_ATTR_MAX     21
#define IK_DATATYPE_MAX 16
#define IK_SYNONYM_MAX  41
#define IK_VALUE_MAX    256
#define IK_FILEDESC_MAX 41
#define IK_FILENAME_MAX 15
#define IK_FILETYPE_MAX 6
#define IK_STATENAME_MAX        41
#define IK_TRANSNAME_MAX        81

/***************************************************
 * linked list definitions *
 ***************************************************/

struct PDUattribute_info
        {
        char                 *attr_name;
        char                 *datatype;
        char                 *synonym;
        char                 *value;
        struct PDUattribute_info *next;
        };

/* API link lists */

struct attribute_info
  {
  char                 attr_name[IK_ATTR_MAX];
  char                 datatype[IK_DATATYPE_MAX];
  char                 synonym[IK_SYNONYM_MAX];
  char                 value[IK_VALUE_MAX];
  struct attribute_info *next;
  };
 
 struct file_info
  {
  char                 file_desc[IK_FILEDESC_MAX];
  char                 local_fn[IK_FILENAME_MAX];
  char                 storage_fn[IK_FILENAME_MAX];
  char                 file_type[IK_FILETYPE_MAX];
  int                  mode;
  struct file_info  *next;
  };

struct chg_file_info
  {
  char                 file_desc[IK_FILEDESC_MAX];
  char                 chg_file_desc[IK_FILEDESC_MAX];
  char                 local_fn[IK_FILENAME_MAX];
  char                 chg_local_fn[IK_FILENAME_MAX];
  char                 storage_fn[IK_FILENAME_MAX];
  char                 chg_storage_fn[IK_FILENAME_MAX];
  char                 file_type[IK_FILETYPE_MAX];
  char                 chg_file_type[IK_FILETYPE_MAX];
  int                  mode;
  struct chg_file_info  *next;
  };
 
 struct part_transition
  {
  char                 statename[IK_STATENAME_MAX];
  char                 transition[IK_TRANSNAME_MAX];
  int                  stateno;
  struct part_transition *next;
  };
#endif
