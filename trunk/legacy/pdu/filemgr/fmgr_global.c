#include <stdio.h>
#include "FI.h"
#include "PDUstr.h"
#include "PDUuser.h"
#include "PDUpart.h"
#include "PDUstorage.h"
#include "PDUforms.h"
#include "PDUfile_def.h"
#include "PDMexec.h"
#include "MEMstruct.h"
#include "PDUproto.h"

PDMexec_ptr  PDMexec;

int       PDU_connection = FALSE;
int       PDU_pdm_initialized = FALSE;
int       PDU_login = FALSE;
int       PDU_mcf_list = FALSE;
short     PDU_structure_list = FALSE;
int       PDU_list_files = FALSE;
int       PDU_part_displayed = FALSE;
int       PDU_check_filename = FALSE;
short     PDU_check_file_refresh = FALSE;
int       PDU_form_type;
int       PDU_checkout_type;
int       *PDU_stack;
int       PDU_part_sort_rows;
short     PDU_list_filenames = FALSE;
short     PDU_search_all_catalogs = FALSE;
short     PDU_save_mode = FALSE;
short     PDU_save_sort_mode = FALSE;
short     PDU_refresh_loaded = TRUE;
short	  PDU_load_file_buffer = FALSE;
short	  PDU_activate_copy = FALSE;
short	  PDU_param_cat = FALSE;
short	  PDU_main_form_cat = FALSE;
short	  PDU_files_deleted = FALSE;

/* variables for popup list */
int       PDU_gadget_label;
int      *PDU_display_column;
int      *PDU_gadget_labels;
int       PDU_refresh_gadgets[7];
int      *PDU_buffer_columns;
int      *PDU_struct_fields;
char   ***PDU_update_struct;

/* variables for defining search and sort criteria */
int       PDU_search_type;
int       PDU_prev_part_sort = FALSE;
char     *PDU_cat_search_conds = NULL; /* defined search criteria */
char     *PDU_part_search_conds = NULL;
char    **cat_search_data = NULL;      /* data pointer to attr buffer */
char    **part_search_data = NULL;
char     *PDU_cat_sort_conds = NULL;   /* defined sort criteria */
char     *PDU_part_sort_conds = NULL;
char    **PDU_part_sort_attr = NULL;
char     *PDU_cat_format_name = NULL;
char     *PDU_loc_format_name = NULL;
char     *PDU_cat_sort_string = NULL; 
char     *PDU_part_sort_string = NULL; 
char     *PDU_dyn_cat_search; 
char     *PDU_dyn_part_search; 
MEMptr    PDU_display_buffer = NULL;   /*attrs to be displayed on calling form*/

/* value lists for grpulldown lists */
char     **PDU_part_sort_list;     
char     **PDU_cat_search_list;  
char     **PDU_part_search_list;     
char     *PDU_value_list[240];     

/* buffer pointers */
char    **PDU_data_col = NULL;
char    **PDU_data_row = NULL;
char    **PDU_data_format = NULL;

char     *PDU_popup_list_type = NULL;

char      salt[3];
char     *PDU_roll_through = NULL;

Form      PDU_form_id = NULL_STRING;
Form      PDU_save_form_id;

MEMptr    PDU_ret_bufr = NULL;
MEMptr    PDU_file_bufr = NULL;
MEMptr    PDU_add_bufr = NULL;
MEMptr    PDU_cat_attr = NULL;
MEMptr    PDU_storage_area = NULL;
MEMptr    PDU_value_bufr = NULL;
MEMptr    PDU_parts_list_buffer = NULL;
MEMptr    PDU_part_file_buffer = NULL;
MEMptr    PDU_delete_buffer = NULL;
MEMptr    PDU_where_used_bufr = NULL;

/* global structures */
struct PDUstorage   *storage = NULL;
struct PDUrefresh   *refresh = NULL;
struct PDUuser      *user = NULL;
struct PDUpart      *part = NULL;
struct PDUforms     forms;

/* global form flags */
int   PDU_login_created = FALSE;
int   PDU_login_displayed = FALSE;
int   PDU_local_files_created = FALSE;
int   PDU_local_files_displayed = FALSE;
int   PDU_search_created = FALSE;
int   PDU_search_displayed = FALSE;
int   PDU_sort_created = FALSE;
int   PDU_sort_displayed = FALSE;
int   PDU_single_list_created = FALSE;
int   PDU_single_list_displayed = FALSE;
int   PDU_mcf_list_created = FALSE;
int   PDU_mcf_list_displayed = FALSE;
int   PDU_cat_list_created = FALSE;
int   PDU_cat_list_displayed = FALSE;
int   PDU_search_options_created = FALSE;
int   PDU_search_options_displayed = FALSE;
int   PDU_sort_options_created = FALSE;
int   PDU_sort_options_displayed = FALSE;
int   PDU_file_list_created = FALSE;
int   PDU_file_list_displayed = FALSE;
int   PDU_topdown_created = FALSE;
int   PDU_topdown_displayed = FALSE;
int   PDU_assy_options_created = FALSE;
int   PDU_assy_options_displayed = FALSE;
short PDU_parts_list_displayed = FALSE;
short PDU_parts_list_created = FALSE;
short PDU_part_file_list_displayed = FALSE;
short PDU_part_file_list_created = FALSE;
short PDU_cancel_list_displayed = FALSE;
short PDU_cancel_list_created = FALSE;
short PDU_where_used_displayed = FALSE;
short PDU_where_used_created = FALSE;
short PDU_flag_form_displayed = FALSE;
short PDU_flag_form_created = FALSE;
short PDU_state_form_displayed = FALSE;
short PDU_state_form_created = FALSE;

/* global pulldown list id's */
int             PDU_part_sort_pulldown;
int             PDU_cat_attr_pulldown;
int             PDU_part_attr_pulldown;
int             PDU_cat_search_pulldown;
int             PDU_part_search_pulldown;
int             PDU_cat_cond_pulldown;
int             PDU_part_cond_pulldown;

/* glabal varaiables for listing parts */
int    * PDU_parts_index;
int      PDU_selected_rows;
MEMptr   PDU_parts_list_bufr = NULL;

short    PDU_default_env = TRUE;

/* global variables for internal checkin */
MEMptr                 PDU_child_buffer = NULL;
MEMptr                 PDU_attach_bufr = NULL;
MEMptr                 PDU_view_buffer = NULL;
MEMptr                 PDU_param_buffer = NULL;

/* global search and sort condition flags */
short         PDU_catalog_required = FALSE;
short         PDU_part_required = FALSE;

/* global list of files for copy local and delete local */
char      ** PDU_file_list;
int          PDU_file_rows;

/* global variables for saving refresh information during search */
char      *PDU_save_project = NULL;
char      *PDU_save_catalog = NULL;
char      *PDU_save_partid = NULL;
char      *PDU_save_revision = NULL;
char      *PDU_save_description = NULL;
char      *PDU_save_filename = NULL;
char      *PDU_save_parttype = NULL;

/* global variable for placing the popup list */
int       PDU_active_button = -1;
int       PDU_active_list = -1;

/* permanent window marker */
short     PDU_perm_window = FALSE;
short     PDU_local_perm_window = FALSE;
short     PDU_assy_perm_window = FALSE;
short     PDU_where_used_perm_window = FALSE;
short     PDU_topdown_perm_window = FALSE;
short     PDU_sort_perm_window = FALSE;
short     PDU_sort_opt_perm_window = FALSE;
short     PDU_flag_perm_window = FALSE;
short     PDU_state_perm_window = FALSE;

int         PDU_cat_search_flag = FALSE;
int         PDU_part_search_flag = FALSE;
int         project_flag = FALSE;
int         catalog_flag = FALSE;
int       * cat_array;
int       * part_array;
int         PDU_free_rows;
char      * PDU_search_catalog = NULL;
char      * PDU_search_project = NULL;
MEMptr      PDU_cat_search_attr = NULL;
MEMptr      PDU_part_search_attr = NULL;
int        part_displayed = TRUE;
int        catalog_displayed = TRUE;

int      PDU_apiflag = FALSE;
char     *PDU_apimessage = NULL;

MEMptr       PDU_func_buffer = NULL;

struct PDUacl_node   *PDU_acl_list = NULL;
struct PDUacl_node   *PDU_acl_group_list = NULL;
