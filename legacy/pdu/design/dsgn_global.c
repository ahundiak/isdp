#include <stdio.h>
#include "FI.h"
#include "PDUstr.h"
#include "PDUuser.h"
#include "PDUpart.h"
#include "PDUforms.h"
#include "MEMstruct.h"
#include "PDUextdef.h"
#include "PDUnode.h"
#include "PDUgrpart.h"

/* global variables for the design commands */

char	*PDU_viewname = NULL;		/* seleted viewname at part placement*/
char	*PDU_filename = NULL;		/* seleted filename at part attachment*/
char    *PDU_usage_id = NULL;		/* usage_id at part placement time */
char    *PDU_alt_tagno = NULL;      	/* alt_tagno at part placement time */
char    *PDU_tagno = NULL;           	/* tagno for part at placement time */
char    *PDU_quantity = NULL;  		/* quantity of parts placed */
char    *PDU_incl_BOM = NULL;           /* include part in BOM "Y" or "N" */
char    *PDU_incl_ASM = NULL;           /* include part in ASM "Y" or "N" */
char    *PDU_explode_BOM = NULL;        /* explode part in BOM "Y" or "N" */
short   PDU_same_part = FALSE;                  
short   PDU_attach = TRUE;             /* flag for part to be attached */
short   PDU_align = FALSE;              /* flag for part to be aligned */
short   PDU_display_pointers = TRUE;    /* flag for part pointer display */
MEMptr  PDU_dyn_attr_bufr = NULL;       /* buffer of dynamic attributes */
MEMptr  PDU_dyn_data_bufr = NULL;       /* buffer of dynamic data */
MEMptr  PDU_dyn_value_bufr = NULL;      /* buffer of dynamic value lists */
MEMptr  PDU_viewnames = NULL;           /* buffer of valid viewnames */
MEMptr  PDU_filenames = NULL;           /* buffer of valid filenames */
MEMptr  PDU_design_parts_bufr = NULL;   /* buffer of parts from search form */
short   PDU_display_dyn_attr = TRUE;    /* flag for displaying dyn attr form */
short   PDU_replace_all_occur = TRUE;   /* flag for replacing part occurences */
char    PDU_place_part_by = 'A';        /* A = aligned view, P = 3 points */
char    PDU_align_part_by = 'P';        /* C = coordinate sys, P = 3 points */
char    *PDU_from_project = NULL;       /* from project for replace part */
char    *PDU_from_catalog = NULL;       /* from catalog for replace part */
char    *PDU_from_partid = NULL;        /* from partid for replace part */
char    *PDU_from_revision = NULL;      /* from revision for replace part */
char    *PDU_from_parttype = NULL;      /* from parttype for replace part */
char    *PDU_from_descr = NULL;         /* from description for replace part */
char    *PDU_from_filename = NULL;      /* from filename for replace part */
char    *PDU_from_usageid = NULL;       /* from usageid for replace part */
char    *PDU_to_usageid = NULL;         /* to usageid for replace part */
short   PDU_store_point = FALSE;        /* flag if point is stored */
double  PDU_point[3];                   /* entered point */
int     PDU_message_type;               /* command message type */
int     PDU_prompt_type;                /* command prompt type */
int     PDU_update_from_part;           /* flag whether to update from or to 
                                           part on the replace part form */
short   PDU_store_view = FALSE;         /* entered view name */
int     PDU_validate_access = TRUE;     /* flag for validate access for part
                                           commands */
int     PDU_design_opt_create;          /* flag for design options form */
int     PDU_active_part_create;         /* flag for active part form */
int     PDU_value_pulldown;             /* global variable for displaying
                                           GRpulldown lists */
int     PDU_attr_label;                 /* variable for attribute list */
MEMptr  PDU_list_bufr;                  /* MEMptr for list buffer */
short   PDU_loop_cmd = TRUE;            /* Command loop flag */
short   PDU_design_form_display = TRUE; /* flag to display form */
MEMptr  PDU_detach_buffer = NULL;       /* bufr for parts detach during design*/
MEMptr  PDU_attach_buffer = NULL;       /* bufr for parts detach during design*/
short   PDU_design_perm_window = FALSE;
char    *PDU_checkin_file = NULL;       /* store file */
char    PDU_placement_type = 'C';      /* placement type for parametrics */
int     PDU_auto_part_selection = FALSE; 
MEMptr  PDUsearch_part_list = NULL;     /* buffer for search */
MEMptr  PDUmacro_lib_list = NULL;       /* buffer for macros */
MEMptr  PDU_ret_buffer = NULL;          /* global buffer for PAL */
MEMptr  PDU_detach_macro_lib = NULL;    /* buffer for macros detached */
short   PDU_list_parts = FALSE;         /* added for 2.1 */
short   PDU_list_origins = FALSE;       /* added for 2.1 */
struct  PDUlist_parts_info *PDU_list_parts_info = NULL; /* linklist for LOP */
struct  PDUlist_origins_info *PDU_list_origins_info = NULL;
int     PDU_default_layer = FALSE;       /* added for 2.1 */
int     PDU_default_color = FALSE;       /* added for 2.1 */
int     PDU_default_weight = FALSE;      /* added for 2.1 */
int     PDU_default_style = FALSE;       /* added for 2.1 */
short   PDU_macro_call = FALSE;
char    PDU_status_string[54] = "";
char    *PDU_macro_dyn_list[50];
int     PDU_macro_dyn_num = 0;
short  PDU_active_part = FALSE;
struct PDUcat_node *PDU_param_cat_list = NULL; /* List of param catalogs */
struct PDUattach_mac_node *PDU_attach_macro_lib = NULL;
int    PDU_dyn_index = 1;            /* Used as an index to para. dyn bufr. */
