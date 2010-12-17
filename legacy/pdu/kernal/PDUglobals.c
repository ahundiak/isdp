#include <PDUint.h>
#include <PDUintdef.h>
#include <PDUrefresh.h>
#include <PDUassy.h>
#include <FI.h>
#include <PDUextdef.h>
#include <PDMexec.h>
#include <PDUfile_def.h>
#include <PDUforms.h>
#include <PDUnode.h>
#include <header.h>
#include <MRPintdef.h>
#include <sys/types.h>
#include <sys/stat.h>

/* PDUglobal.c */
IGRint    PDU_status_temp;                      /* Temp storage for status */
IGRchar   PDU_last_file [OM_K_MAXOSNAME_LEN];
IGRshort  PDU_spi_flag = ON;
IGRint    PDU_invis_file_index;
IGRint    PDU_file_type;
IGRint    PDU_new_part = TRUE;
IGRint    PDUactive_checkin = FALSE;
IGRshort  PDU_tree_attach = OFF;
IGRshort  PDU_nfs_flag = OFF;                   /* NFS usage flag */
IGRmatrix PDUrot_mat;                           /* ALIGN- trans rot matrix */
IGRmatrix PDUal_view_rot;                       /* ALIGN- part's rot matrix */
IGRchar   *PDU_save = NULL;

/* PDUrefresh.c */
char  fields[PDM_REFRESH_FIELDS][PDM_REFRESH_WIDTH];
char  *labels[] = { "review_project", "review_catalog", "review_partid",
                    "review_revision", "review_file", "active_project",
                    "active_catalog", "active_partid", "active_revision",
                    "active_file", "search_criteria", "search_name",
                    "view_name", "serial_number", "line_number" };

/* old dsgn_global.c */
char    *PDU_viewname = NULL;           /* seleted viewname at part placement*/
char    *PDU_filename = NULL;           /* seleted filename at part attachment*/
char    *PDU_usage_id = NULL;           /* usage_id at part placement time */
char    *PDU_alt_tagno = NULL;          /* alt_tagno at part placement time */
char    *PDU_tagno = NULL;              /* tagno for part at placement time */
char    *PDU_quantity = NULL;           /* quantity of parts placed */
char    *PDU_incl_BOM = NULL;           /* include part in BOM "Y" or "N" */
char    *PDU_incl_ASM = NULL;           /* include part in ASM "Y" or "N" */
char    *PDU_explode_BOM = NULL;        /* explode part in BOM "Y" or "N" */
short   PDU_same_part = FALSE;
short   PDU_attach = TRUE;             /* flag for part to be attached */
short   PDU_save_attach = TRUE;        /* flag for part to be attached */
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
MEMptr  PDU_list_bufr = NULL;                  /* MEMptr for list buffer */
short   PDU_loop_cmd = TRUE;            /* Command loop flag */
short   PDU_design_form_display = TRUE; /* flag to display form */
MEMptr  PDU_detach_buffer = NULL;       /* bufr for parts detach during design*/
MEMptr  PDU_attach_buffer = NULL;       /* bufr for parts detach during design*/
MEMptr  PDU_delete_local_buffer = NULL; /* bufr for del. local files */
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
short  PDU_clipping_on = FALSE;
int    PDU_childno = 0;
int    PDU_pchildno = 0;
short  PDU_os_modified = FALSE;
short  PDU_dynamics_on = FALSE;
int    PDU_instance_no = 0;

/* PDUdsgn_list.c */
int PDU_design_listing_form_displayed = FALSE;


/* PDUcat_attr.c */
char *min_value = NULL;
char *max_value = NULL;
char *order_no = NULL;
MEMptr sort_attr = NULL;
MEMptr sort_data = NULL;

/* PDUparm_form.c */
char *PDU_sketch_file;

/* old cat_global.c */
int PDU_cat_operat_create = FALSE;      /* flag for Catalog Operations Form */
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
char *PDU_default_value = NULL;         /* default value for attribute */
char *PDU_auto_file_gen = NULL;         /* default value for attribute */
MEMptr PDU_save_attr_bufr= NULL;        /* buffer to save attributes */
int PDU_tempcat_pulldown;               /* value for template catalog pulldown*/
int PDU_catalog_pulldown;               /* value for catalog name pulldown*/
int PDU_view;                           /* flag for view catalog*/
char *PDU_template_catalog = NULL;      /* store template catalog */
char *PDU_default_usageid = NULL;       /* store template catalog */
char *PDU_dynamic_table = NULL;         /* store dynamic table name*/
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

/* old part_global.c */
int      PDU_add_files = FALSE;
int      PDU_simmode_copy = FALSE;
int      PDU_simmode_checkin = FALSE;
int      mode_change_flag = FALSE;
int      part_operations_created = FALSE;
int      part_operations_displayed = FALSE;
int      change_part = FALSE;
int      checked_in = FALSE;
int      enter_part = TRUE;
int      new_mode = FALSE;
int      similar_mode = FALSE;
int      change_mode = FALSE;
int      review_mode = FALSE;
int      new_file = FALSE;
int      pt_flag = TRUE;
int      bufr_flag = FALSE;
int      existing_file = FALSE;
int      np_cat_btn_flag = FALSE;
int      ep_part_fld_flag = FALSE;
int      ep_part_btn_flag = FALSE;
int      ep_rev_btn_flag = FALSE;
int      ep_desc_flag = FALSE;
int      acl_flag;
int      workflow_flag;
int      end_move_to_state_btn_flag = FALSE;
int      change_files_flag = FALSE;
int      add_files_flag = FALSE;
short    PDU_delete_files = FALSE;
short    change_stat = TRUE;
char     current_state[50];
char     *trans_name = NULL;
char     *init_project = "";
char     *init_catalog = "";
char     *init_partnum = "";
char     *init_revision = "";
char     *init_parttype = "";
char     *ep_project = "";
char     *ep_catalog = "";
char     *en_itemname = "";
char     *ep_rev = "";
char     *ep_parttype = "";
char     *ep_desc = "";
char     *np_project = "";
char     *np_catalog = "";
char     *nn_itemname = "";
char     *np_rev = "";
char     *np_parttype = "";
char     *np_desc = "";
char     *stg_area = "";
char     PDU_attr_value[40];  /*Used to store the value generated by a ppl*/
MEMptr   PDU_part_frm_search_bufr = NULL;
MEMptr   states_bufr = NULL;
int             new_part_flag = FALSE;
int             all_flag;
int             no_headings;
int             end_np_cat_btn_flag = FALSE;
int             end_np_part_btn_flag = FALSE;
int             end_np_parttype_btn_flag = FALSE;
int             end_ep_proj_btn_flag = FALSE;
int             end_ep_cat_btn_flag = FALSE;
int             end_ep_part_fld_flag = FALSE;
int             end_ep_part_btn_flag = FALSE;
int             end_ep_rev_btn_flag = FALSE;
int             end_ep_parttype_btn_flag = FALSE;
int             end_ep_desc_fld_flag = FALSE;
int             end_ep_desc_btn_flag = FALSE;
int             end_stg_area_btn_flag = FALSE;
int             end_acl_wf_btn_flag = FALSE;
int             pdu_hold_stg_bufr_flag = FALSE;
int             pdu_hold_acl_bufr_flag = FALSE;
int             pdu_ep_stg_bufr_flag = FALSE;
int             pdu_ep_acl_bufr_flag = FALSE;
int             PDU_simmode_cat_bufr = FALSE;
int             PDU_part_flagged = FALSE;
char         ** headings;
char          * search_str = NULL;
MEMptr          PDU_hold_bufr = NULL;
MEMptr          PDU_ep_bufr= NULL;
MEMptr          PDU_hold_stg_bufr = NULL;
MEMptr          PDU_hold_acl_bufr = NULL;
MEMptr          PDU_ep_stg_bufr = NULL;
MEMptr          PDU_ep_acl_bufr = NULL;
MEMptr          PDU_ep_data_bufr = NULL;
short           PDU_dup_filename = FALSE;
short           PDU_read_only_file = FALSE;
int      seed_form_created = FALSE;
int      seed_form_displayed = FALSE;
int      user_seed_file = FALSE;

/* PDUpart_form.c */
/* PDUseed_file.c */


/* old ass_global.c */
/* Global assembly flags */
short        PDU_assembly_list = FALSE;     /* flag for the part listing mcf */
short        PDU_select_area = FALSE;       /* flag for part selection mcf */
short        PDU_keyin_area = FALSE;        /* flag for part selection fields */
short        PDU_get_assy = FALSE;          /* flag to get a new assy struct */
short        PDU_load_assy = FALSE;         /* flag for updating part fields */
short        PDU_assy_cmd = FALSE;          /* flag for updating assembly form
                                               after attach and detach */
short        PDU_use_suffix = TRUE;
short        PDU_new_assembly = TRUE;

/* Global row marker */
int        PDU_act_row;
short      PDU_second_row = FALSE;

/* Global assembly buffers */
MEMptr     PDU_assy_parts_bufr = NULL;
MEMptr     PDU_def_assy_bufr = NULL;
MEMptr     PDU_struct_bufr = NULL;

/* global form flags */
short        PDU_define_assy_created = FALSE;
short        PDU_define_assy_displayed = FALSE;

/* global assembly part identifiers */
char       *PDU_assy_catalog = NULL;
char       *PDU_assy_partid = NULL;
char       *PDU_assy_revision = NULL;
char       *PDU_assy_description = NULL;
char       *PDU_assy_parttype = NULL;

/* global form id for assy structure */
Form       PDU_struct_type;

/* global attach variables */
int        PDU_explode_depth = MAX_LEVEL;
int        PDU_save_level = MAX_LEVEL;

/* global expression variables */
char       *PDU_child_no;
char       *PDU_parent_no;
char       *PDU_first_level_child;
int        PDU_level_no;

/* global assembly linklists */
struct PDUassy_node       *PDU_assy_head = NULL;
struct PDUpath_node       *PDU_path_list = NULL;
struct PDUrev_assy	  *PDU_assy_ptr = NULL;
struct PDUrev_assy	  *current_rev_assy = NULL;
struct PDUrev_assy	  *PDU_save_ptr = NULL;
struct PDUparts_list      *PDU_save_part_list = NULL;
struct PDUparts_list      *PDU_checked_out_parts = NULL;
struct PDUassy_parts_list *PDU_modified_parts_list = NULL;
struct PDUfile_list       *PDU_copied_files = NULL;

/* PDUdef_assy.c */
int    prev_row = -1;
double prev_value = -1.0;

/*old fmgr_global.c */
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
short     PDU_load_file_buffer = FALSE;
short     PDU_activate_copy = FALSE;
short     PDU_param_cat = FALSE;
short     PDU_main_form_cat = FALSE;
short     PDU_files_deleted = FALSE;
short     PDU_chkout_single = FALSE;
short     PDU_auto_login = FALSE;

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
char     *PDU_value_list[605];

/* buffer pointers */
char    **PDU_data_col = NULL;
char    **PDU_data_row = NULL;
char    **PDU_data_format = NULL;

char     *PDU_popup_list_type = NULL;

char      salt[3];
Form      PDU_form_id = 0;
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
short PDU_search_format_displayed = FALSE;
short PDU_search_format_created = FALSE;
short PDU_load_search_data = FALSE;

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
char      *PDU_srch_catalog = NULL;

char      *PDU_save_act_catalog = NULL;
char      *PDU_save_act_partid = NULL;
char      *PDU_save_act_revision = NULL;
char      *PDU_save_act_description = NULL;
char      *PDU_save_act_filename = NULL;
char      *PDU_save_act_parttype = NULL;

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

/* PDUbufrs.c */
MEMptr       PDU_attr_bufr = NULL;
MEMptr       PDU_data_bufr = NULL;
MEMptr       PDU_acl_bufr = NULL;
MEMptr       PDU_stg_bufr = NULL;
MEMptr       PDU_file_data_bufr = NULL;
MEMptr       PDU_sav_file_data_bufr = NULL;
MEMptr       PDU_add_data_bufr = NULL;
MEMptr       PDU_copyof_attr_bufr = NULL;
MEMptr       PDU_copyof_data_bufr = NULL;
MEMptr       PDU_copyof_stg_bufr = NULL;
MEMptr       PDU_copyof_acl_bufr = NULL;
char      ** PDU_attr_row;
char      ** PDU_attr_col;
char      ** PDU_attr_format;
char      ** PDU_data_row;
char      ** PDU_data_col;
char      ** PDU_data_format;
char      ** PDU_acl_row;
char      ** PDU_acl_col;
char      ** PDU_acl_format;
char      ** PDU_stg_row;
char      ** PDU_stg_col;
char      ** PDU_stg_format;
int          file_rows = 0;
int          attr_rows = 0;
int          PDU_func_bufr_exists = FALSE;
int          PDU_part_checked_in = FALSE;
int          PDU_disable_move_state_btn = FALSE;
short        PDU_never_checked_in = FALSE;
short        NULL_DATA = FALSE;
short        PDU_disable_filedesc_col = FALSE;
short        PDU_disable_localfn_col = FALSE;
short        PDU_disable_storagefn_col = FALSE;
short        PDU_disable_filetype_col = FALSE;
short        PDU_filedesc_newfiles_disable = FALSE;
short        PDU_localfn_newfiles_disable = FALSE;
short        PDU_storagefn_newfiles_disable = FALSE;
short        PDU_filetype_newfiles_disable = FALSE;

/* PDUlogin.c */
int passwd = FALSE;

/* PDUsort_form.c */
 int             PDU_num_of_part_rows = 0;
 int             PDU_part_row;

/* PDUvalidate.c  */
int string_len = 0;

/* PDUbuffers.c */
int single_flag = FALSE;


/* old rpts_global.c */
MEMptr PDU_bom_attr_bufr = NULL;                /* buffer for BOM attributes */
MEMptr PDU_bom_data_bufr = NULL;                /* buffer for BOM data */
MEMptr PDU_bom_list_bufr = NULL;                /* value list buffer for BOM */
MEMptr PDU_bom_map_bufr = NULL;                 /* buffer for BOM mapping*/
MEMptr PDU_cat_attr_bufr = NULL;                /* value list buffer for BOM */
char   *PDU_report_name = NULL;                 /* report name */
char   *PDU_report_title = NULL;                /* dynamic title for form */
char   *PDU_output_file = NULL;                 /* output file for report */
Form   PDU_calling_form;                        /* calling from for reports */
char   *PDU_delete_reports = NULL;              /* pointer to reports needing to
                                                   deleted locally */
char   *PDU_store_catalog = NULL;               /* store catalog */
char   *PDU_store_partid = NULL;                /* store partid */
char   *PDU_store_revision = NULL;              /* store revision */
char   *PDU_store_description = NULL;           /* store description */
char   *PDU_bom_datatype = NULL;                /* store bom datatype */
char   *PDU_attr_datatype = NULL;               /* store attribute datatype */
char   *PDU_template = NULL;                    /* store RIS template */
short  PDU_select_bomattr = FALSE;
short  PDU_select_catattr = FALSE;
short  PDU_report_exists = FALSE;
int    PDU_store_row;

/* PDUbom_cnts.c */
char *catalog_attr = NULL;
char *bom_attr = NULL;
MEMptr bom_map = NULL;
int    change_cat = FALSE;

/* MRPinit_var.c */
struct MRPvar  *mrpvar = NULL;
char **string_buffer = NULL;
char **cd_str_buffer = NULL;
char **env_str_buffer = NULL;
char **flag_str_buffer = NULL;
char **file_str_buffer = NULL;
char **cat_str_buffer = NULL;
char **prt_str_buffer = NULL;
int MRPsingle_select = 0;
int MRPuser = 0;

/* rMRPinit_var.c */
struct rMRPvar  *rmrpvar = NULL;
struct PSUrpt   *psurpt = NULL;
int part_total = 0;
int PSU_list_total = 0;
int PSU_attr_total = 0;
int PSUmessage = PDM_C_PRODUCT;
int MRPlevel;
int MRPchange;
int MRPscroll_col;
int PSUjustification;
int current_form_num;
int ps_current_form_num;
FILE    *rMRPdbg_fileptr;
int     MRP_debug_on;
int RPT_list_position = 0;
char PSUdef_file[80];
char PSUdirectory[80];
char PSUworkflow[20];
char PSUsaname[14];
char PSUpart_acl[20];
char PSUems_file[80];
char *PSUtemplib;
long PSUcommand;
Form current_form_id;
Form ps_current_form_id;
Form psu_master_id;

/* PSUformat.c */
extern struct PDUforms forms;
Form psu_format_id;

int psu_format_created;
int psu_format_displayed;
int rpt_value_pulldown;
static int PSUmode;
static int position;
struct PSUattr *psuattr = NULL;
char **rpt_value_list = NULL;
int  sort_total;
int  subtotal;
int  total;
int  PSU_list_size;

/* display_rpt.c */
#define MAXLINE 2002

char PDUdba_stext[MAXLINE], PDUdba_errtxt[250], *PDUdba_get_msg();
double PDUdba_form_value;
int PDUdba_num_rows, PDUdba_total_lines, PDUdba_error, PDUdba_text_size=3; 
int PDUdba_notify();
Form PDUdba_output_fpt, PDUdba_text_fpt;
FILE *PDUdba_filnam_ptr;

/* PDMrtools.c */
struct part_dynamic_attrs *part_occur_list = NULL;
MEMptr       PDU_copyof_ret_bufr = NULL;
MEMptr       PDU_states_bufr = NULL;
MEMptr       add_data_bufr = NULL;

/* PDUdef_rpt.c */
struct PSUrpt *PDU_pdurpt = NULL;

/* pal/src/funk/PDMchekin.I */
MEMptr PDUchild_dyn_buffer = NULL;

/* pal/src/pdmr/PDMgetstat.c */

#define MAX_PARAM_IN_FORMULA 45

int PDU_ComputedID = FALSE;     /* Indicates whether 'partno' is computable */
char *attribs_in_ID = NULL;    /* Contains the columns in the Computable ID */
char *vals_of_attribs_in_ID = NULL;  /* Contains the values of */
                                     /* columns in the Computable ID  */
int     col_indxs[MAX_PARAM_IN_FORMULA];
int     NoColsInID;

/* pal/src/pdmr/CID.c */
char    **ConditionTable[2];
FILE    *CID_yyin;
char    *DLexp_cond = NULL;
int     NoExpressions, DLresult[10];
int     RetVal;

/* pal/src/pdmr/svs/svs.c */
int     NoSlctd = 0; /* Count of selected params */
int     NoCols = 0, NoParams = 0, NoRows = 0;
int     NoTables = 0, NoExp = 0;
int     result[MAX_SVS_COND];

char    CurrentSVSView[32];

char    ViewTable [MAX_SVS_PARAMS][MAX_SVS_COND][MAX_SVS_COND_LEN];
char    ViewParamList[MAX_SVS_PARAMS][SVS_NAME_LEN],
        TableColList[MAX_SVS_PARAMS][SVS_NAME_LEN*2],
        *VueColTypes[MAX_SVS_PARAMS];

char    exp_cond[MAX_SVS_COND_LEN];
double  **vals_of_cols = NULL, values[MAX_SVS_PARAMS];

FILE    *PDU_v_yyin, *PDU_c_yyin;

/* pal/src/pdmr/svs/svswrk.c */
int SVSon = FALSE;
char    CurrentSVSView[];
struct  PDUrefresh      *refresh;

/*  PDUkernal.I */
short PDU_activate_delete = TRUE;
short  PDU_activate_reffile_display = TRUE;
struct PDUref_info_node   *PDU_ref_parent_child_list = NULL;
struct PDUpath_list       *PDU_part_path_list = NULL;
short PDU_edit_display = FALSE;
int   PDU_exit_case = 0;
mode_t PDU_review_file_permissions = 0;
char   PDU_review_file[80];


short PDU_multiple_revs = FALSE;
short PDU_ex_help_init = FALSE;

/*  PDUtdseed.c */
int      topdown_seed_form_created = FALSE;
int      topdown_seed_form_displayed = FALSE;
int      topdown_user_seed_file = FALSE;
short    PDU_is_om_file = TRUE;

/* variables from external executable */
short    PDU_extadmin = FALSE;
short    PDU_extad_help_initialized_flag = FALSE;
char     PDU_msg_path[256];

char     *PDU_search_format = NULL_STRING;
int      PDU_format_pulldown;
int      PDU_save_command = 0;
IGRchar   *PDU_delete_checkin = NULL;
char     *PDU_file_suffix = NULL;

short PDU_ng_placement = FALSE;     /* non-graphic placement */
