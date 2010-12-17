#include <stdio.h>
#include "FI.h"
#include "PDUstr.h"
#include "PDUuser.h"
#include "PDUpart.h"
#include "PDUforms.h"
#include "MEMstruct.h"

int PDU_cat_operat_create = FALSE;	/* flag for Catalog Operations Form */
int PDU_cat_operat_display = FALSE;     /* flag for Catalog Operations Form */
int PDU_cat_name_create = FALSE;        /* flag for Catalog Name Form */
int PDU_cat_name_display = FALSE;       /* flag for Catalog Name Form */
int PDU_cat_attr_create = FALSE;        /* flag for Catalog Attribute Form */
int PDU_cat_attr_display = FALSE;       /* flag for Catalog Attribute Form */
int PDU_user_attr = FALSE;              /* flag for adding user-defined attr */
int PDU_required_attr = FALSE;          /* flag for displaying required attr */
char *PDU_to_catalog = NULL;            /* new catalog in Copy and Change Cat */
char *PDU_cat_description = NULL;       /* cat description for catalog */
char *PDU_cat_aclno = NULL;             /* acl no for catalog */
char *PDU_cat_aclname = NULL;             /* acl no for catalog */
int PDU_command;                        /* command between two forms */
char *PDU_loc_attr;                     /* catalog data buffer */
char *PDU_loc_data;                     /* catalog data buffer */
char *PDU_loc_list;                     /* catalog data buffer */
char *PDU_cat_atr;                      /* catalog attribute buffer */
char *PDU_cat_data;                     /* catalog data buffer */
char *PDU_cat_list;                     /* catalog list buffer */
char *PDU_dyn_attr;                     /* dynamic attribute buffer */
char *PDU_dyn_data;                     /* dynamic data buffer */
char *PDU_dyn_list;                     /* dynamic list buffer */
char *PDU_message = NULL;               /* message for message strip */
int PDU_list_cat  = FALSE;              /* flag for updating list of catalogs */
int PDU_parm_cat  = FALSE;              /* flag for parametric catalog */
char *PDU_attr_name = NULL;             /* attribute name for catalog */
char *PDU_datatype = NULL;              /* datatype for catalog attribute */
char *PDU_synonym = NULL;               /* synonym for catalog attribute */
char *PDU_default_value = NULL;		/* default value for attribute */
char *PDU_auto_file_gen = NULL;		/* default value for attribute */
MEMptr PDU_save_attr_bufr= NULL;        /* buffer to save attributes */
int PDU_tempcat_pulldown;  	        /* value for template catalog pulldown*/
int PDU_catalog_pulldown;  	        /* value for catalog name pulldown*/
int PDU_view;  			        /* flag for view catalog*/
char *PDU_template_catalog = NULL;	/* store template catalog */
char *PDU_default_usageid = NULL;	/* store template catalog */
char *PDU_dynamic_table = NULL;		/* store dynamic table name*/
MEMptr PDU_cat_class_bufr = NULL;       /* buffer for catalog classification */
MEMptr PDU_cat_func_bufr = NULL;       /* buffer for catalog functions */
MEMptr PDU_query_class_bufr = NULL;    /* buffer for catalog classification */
char *PDU_macro_name = NULL;            /* storage for macro name */
char *PDU_macro_library = NULL;         /* storage for macro library */
char *PDU_macro_catalog = NULL;         /* storage for macro library */
char *PDU_macro_partid = NULL;         /* storage for macro library */
char *PDU_macro_partrev = NULL;         /* storage for macro library */
int  PDU_list_size = 0;                 /* global for pulldowns */
char *PDU_part_function = NULL;         /* store Part Number Functions */
char *PDU_temp_catalog = NULL;          /* save refresh->rev_catalog */
int  PDU_new_param_mode = TRUE;         /* mode for parametric part form */
int  PDU_change_param_mode = FALSE;     /* mode for parametric part form */
MEMptr PDU_parm_attr_bufr = NULL;       /* buffer for parametric part form */
MEMptr PDU_parm_data_bufr = NULL;       /* buffer for parametric part form */
MEMptr PDU_parm_list_bufr = NULL;       /* buffer for parametric part form */
MEMptr PDU_parm_dflt_bufr = NULL;       /* buffer for parametric part form */
MEMptr PDU_parameter_buffer = NULL;     /* buffer for macro parameters */
MEMptr PDU_macro_buffer = NULL;     /* buffer for macro parameters */
MEMptr acl_bufr = NULL;     /* buffer for macro parameters */
short PDU_checkin_lib = TRUE;           /* flag to checkin macro library */
int PDU_num_feet = 0;
int PDU_num_temp = 0;
int PDU_class_level = 0;
