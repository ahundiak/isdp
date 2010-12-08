#ifndef PDM_BOM_STRUCT_H
#define PDM_BOM_STRUCT_H

#include "NFMschema.h"

struct PDMbom_member
{
  long level;
  long citno;
  long pcat_no;
  long pitem_no;
  char type[NFM_TYPE+1];
  long cat_no;
  char cat_name[NFM_CATALOGNAME+1];
  long item_no;
  char file_status[NFM_STATUS+1];
  char archive_state[NFM_ARCHIVESTATE+1];
/* will be mallocd in future */
  char item_name[240+1];
  char item_rev[NFM_ITEMREV+1];
  char lock[NFM_ITEMLOCK+1];
  long version_limit;
  char set_indicator[NFM_SETINDICATOR+1];
  char file_class[NFM_FILECLASS+1];
  char file_type[NFM_FILETYPE+1];
  char file_co[NFM_FILETYPE+1];
  long file_version;
  char pending_flag[NFM_PENDINGFLAG+1];
  long file_size;
  char ci_filename[NFM_CIFILENAME+1];
  long ci_sano;
  long co_sano;
  char co_filename[NFM_COFILENAME+1];
  long filenum;
  long move;
  long mark;
  long flag;  /* NFM_DROPPED_MEMBER */
 /* added for pdm bom*/
 char attached[2];
 char history[11];
 char orient[241];
 char quantity[241];
 /*double quantity ;*/
 int childno;
 char usageid[26];
 char viewid [26];
 int tagno ;
 char alttagno[26];
 char incbom [2];
 char explode[2];
 int pdcno;
 int dyn_cat_no;
 char dyn_cat_name[NFM_CATALOGNAME+1];
 char alt_parent_attr[50];
 char *select_str;
 char *insert_str;
 char *dyn_select_str;
 char *dyn_insert_str;

  struct PDMbom_member *next;
};
#endif

