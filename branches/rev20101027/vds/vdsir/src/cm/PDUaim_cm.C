#include <stdio.h>
#include <FI.h>
#include <PDUforms.h>
#include <PDUerror.h>
#include <PDUintdef.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUcommand.h>
#include <PDUstr.h>
#include <MEMerrordef.h>
#include <MEMstruct.h>
#include <PDMmessage.h>
#include "PDUproto.h"
#include "PDUprompt.h"
#include "PDUint.h"
#include "v_dbgmacros.h"

/* include for PDM Utilities Form */
#include "part_gadgets.h"
#include "SQLerrordef.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "msmacros.h"
#include "msdef.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "gr.h"
/*
#define vdsDEBUG
#define vdserrDEBUG
*/


/* #include "PDMproto.h" */
/* #include "helpifproto.h" */ /* solaris include, maybe */

/* CM forms */  /*??? this should eventually move somewhere like PDUform_def.h -ddd */

/* define statements */
#define CM_LIST_AR_FORM 
#define CM_MOVE_STATE_FORM 891

/* Postman Codes */
#define VDP_GET_AR 125
#define VDP_CHANGE_AR_STATE 126
#define VDP_MAKE_AR_CHECKING	133
/* CM Gadgets */
#define ARNUM	14
#define AIRNUM	13
#define AIRREV	15
#define FMRNUM	16
#define FMRREV	17
#define TITLE	18
#define CREDATE	19
#define AROBID	12
#define ARTBL	11

#define GETARBTN 22

/* Change Promotion Fiorm */
#define CP_ARTBL	11
#define CP_C_ARNUM	0
#define CP_C_AIRNUM	1
#define CP_C_AIRREV	2
#define CP_C_FMRNUM	3
#define CP_C_FMRREV	4
#define CP_C_TIT	5
#define CP_C_DATE	6
#define CP_C_OBID	7

/* AIM talking code */
#define VDP_BASELINE_MDC	122
#define VDP_GET_WORKING_ARS	130
#define VDP_MAKE_AR_CHECKING	133
#define VDP_MAKE_AR_RELEASED	134
#define VDP_MAKE_AR_IMPLEMENTS	135

/* nfm attributes used for CM */
#define CMENAB	"p_mrppart"
#define ARSEL	"p_mrpstruct"
#define DCCSEL	"p_explode"

/* CM states */
#define BASELINE	"Baseline"
#define RELEASE		"Release"
#define CHECKING	"Checking"
#define DEVELOPMENT	"Development"
#define AVD_CM_WFLOW	"CM WORKFLOWr9"

/* PDM Utilities Form Gadgets */
#define ROLL_THROUGH             47
#define CHECKIN_BTN              33
#define LOGOUT_BTN               82
#define MCF_LIST_GRP             65
#define LIST_MCF                 11
#define DELETE_LOCAL_BTN         36
#define DESIGN                   46
#define REV_STRUCT_BTN           49
#define CATALOG_BTN              50
#define PARTS_BTN                51
#define REPORTS_BTN              54
#define SEARCH_PARTS_BTN         19
#define LIST_FILES_BTN           66
#define LIST_PARTS_IN_CAT_BTN    56
#define USERNAME_FLD             86
#define SERVER_FLD               87
#define ENV_FLD                  88
#define PART_MCF_HEADING         30
#define PROJECT_LIST_BTN        108
#define CATALOG_LIST_BTN        109
#define PARTNUM_LIST_BTN        110
#define REVISION_LIST_BTN       111
#define FILENAME_LIST_BTN       112
#define WHERE_USED               52
#define STRUCTURE_LIST_GRP       71
#define STRUCTURE_MCF            57
#define REVIEW_DESIGN            72
#define PARM_PARTS_BTN           14
#define UPDATE_DATABASE          75
#define COPY_LOCAL_BTN           32
#define CHECKOUT_BTN             25
#define DELETE_PART              76
#define FLAG                     78
#define MOVE_STATE               77
#define SELECT_ALL               80
#define DESELECT_ALL             81
#define EDIT_ASSEMBLY_TGL        87
#if 1
#define REVISE_ASSEMBLY_BTN      89
#define ASSY_STRUCTURE_BTN       58
#else
#define REVISE_ASSEMBLY_BTN      58
#endif

/* Gadgets from other forms */
#define ASSY_SELECT_GRP          64
#define PART_SEARCH_MCF          59

/* Gadgets from TOPDOWN form */
#define TD_CATALOG       34
#define TD_PARTID        35
#define TD_REVISION      36
#define TD_FILENAME      37
#define TD_DESC          12

/* Gadgets for PDM State Form */

#define CURRENT		20   /* workflow, ACL, state */
#define NEW 		22
#define PARTS_MCF  	11
#define SELECT  	24
#define DESELECT	25

#define LIST_MCF	11

/* Global Variables */
static char *CMstate = NULL;

/* Externs */
extern char * calloc();
extern char * realloc();
extern short PDU_state_form_created;
extern short PDU_state_form_displayed;
extern short PDU_state_perm_window;
extern short PDU_second_row;
extern int PDU_command;
extern int PDU_selected_rows;
extern int PDU_local_files_displayed;
extern struct PDUforms      forms;
extern struct PDUrefresh      *refresh;
extern int PDU_mcf_list;
extern int *PDU_parts_index;
extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_states_bufr;
extern struct PDUacl_node *PDU_acl_list;
extern struct PDUacl_node *PDU_acl_group_list;
extern struct PDUforms forms;

/* Externs for the PDM Utilities Form */
extern char   * PDU_cat_sort_string;
extern char   * PDU_part_sort_string;
extern char    *PDU_dyn_cat_search;
extern char    *PDU_dyn_part_search;
extern char *** PDU_update_struct;
extern char    *PDU_save_project;
extern char    *PDU_save_catalog;
extern char    *PDU_save_partid;
extern char    *PDU_save_revision;
extern char    *PDU_save_description;
extern char    *PDU_save_filename;
extern char    *PDU_save_parttype;
extern char    *ep_project;
extern char    *ep_catalog;
extern char    *en_itemname;
extern char    *ep_rev;
extern char    *ep_desc;
extern char    *PDU_search_format;
extern int  *   PDU_gadget_labels;
extern int      PDU_refresh_gadgets[7];
extern int  *   PDU_parts_index;
extern int      PDU_command;
extern int      PDU_selected_rows;
extern int      PDU_checkout_type;
extern int      PDU_gadget_label;
extern int      PDU_mcf_list;
extern int      PDU_list_files;
extern int      PDU_form_type;
extern int      PDU_search_type;
extern int      FIg_get_text_length();
extern int      FIg_get_text();
extern int      FImcf_get_active_col();
extern int      FIfld_get_text();
extern int      FIg_get_type();
extern int      PDU_local_files_created;
extern int      PDU_local_files_displayed;
extern int      PDU_single_list_displayed;
extern int      PDU_single_list_created;
extern int      PDU_mcf_list_displayed;
extern int      PDU_mcf_list_created;
extern int      PDU_file_list_created;
extern int      PDU_file_list_displayed;
extern int      PDU_cat_list_displayed;
extern int      PDU_cat_list_created;
extern int      PDU_check_filename;
extern int      project_flag;
extern int      catalog_flag;
extern int      PDU_act_row;
extern int      PDU_login;
extern int      PDU_active_button;
extern int      bufr_flag;
extern int      PDMdebug_on;
extern int      PDU_list_cat;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_cat_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_move_to_state_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_active_list;
extern short    PDU_files_deleted;
extern short    PDU_list_filenames;
extern short    PDU_check_file_refresh;
extern short    PDU_select_area;
extern short    PDU_second_row;
extern short    PDU_structure_list;
extern short    PDU_load_file_buffer;
extern short    PDU_local_perm_window;
extern short    PDU_perm_window;
extern short    PDU_assy_perm_window;
extern short    PDU_where_used_perm_window;
extern short    PDU_activate_copy;
extern short    PDU_param_cat;
extern short    PDU_main_form_cat;
extern short    PDU_chkout_single;
extern short    PDU_edit_display;
extern short    PDU_extadmin;
extern short    PDU_flag_form_created;
extern short    PDU_flag_form_displayed;
extern short    PDU_flag_perm_window;
extern Form     PDU_form_id;
extern Form     PDU_calling_form;
extern Form     place_part_f;
extern Form     ModifyPartForm;
extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_storage_area;
extern MEMptr   PDU_parts_list_bufr;
extern MEMptr   PDU_login_data;
extern MEMptr   PDU_login_attrs;
extern MEMptr   PDU_wf_buffer;
extern MEMptr   PDU_assy_parts_bufr;
extern MEMptr   PDU_part_file_buffer;
extern MEMptr   PDU_delete_buffer;
extern MEMptr   PDUsearch_part_list;
extern struct   PDUrefresh   *refresh;
extern struct   PDUuser      *user;
extern struct   PDUforms     forms;

extern IGRchar *PDU_save;
extern IGRchar *PDU_delete_checkin;
extern MEMptr PDU_attach_buffer;
extern short PDU_active_part;
extern MEMptr PDU_detach_buffer;
extern MEMptr PDU_detach_macro_lib;
extern struct PDUattach_mac_node *PDU_attach_macro_lib;
extern short PDU_design_form_display;
extern struct PDUpart_node      *PDU_parts_id_list;
extern int POSTMAN_REQUEST_ON_CLIX();
extern int IsPmeEnabled();
extern int SrVDGetCMattrs();
extern int SrVDUpdCMattrs();
extern int SrVDGetCMState();
extern int CMar_form();
extern int EnablePME();
extern struct hostent *gethostbyname();
extern  inet_ntoa();
extern int IsRetOK();
extern int CMget_wflow_name();


static Form cm_move_state_form_id;  /*??? should eventually become part of structure in PDUforms.h -ddd*/

static Form cm_change_ar_form;  
static Form con_form_id;

/*??? eventually add to global form flags  in fmgr_global.c */
static short CM_state_form_created = FALSE;
static short CM_state_form_displayed = FALSE;
static short CM_state_perm_window = FALSE;
static int ChkOK = 0;
static int ForceConnect = 0;

struct  hostent {
       char    *h_name;        /* official name of host */
        char    **h_aliases;    /* alias list */
        int     h_addrtype;     /* host address type */
        int     h_length;       /* length of address */
        char    **h_addr_list;  /* list of addresses from name server */
#define h_addr  h_addr_list[0]  /* address, for backward compatiblity */
};


/*
 * Internet address (a structure for historical reasons)
 */
struct in_addr {
        unsigned long s_addr;
};


#define CLIX_CONNECT	-1
#define CLIX_DISCONNECT -2
#define PME     0
#define SIR     1

int ForceConn()
{
  return ForceConnect;
}

int CheckAllowed()
{
  return ChkOK;
}

/*********************************************************
* This section is for the Check Out or Retreive for design
* process in PDU.
*
*********************************************************/




/********************************************************
*
* Function: PDUext_checkout
*
*
*********************************************************/

int local_files_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status = PDM_S_SUCCESS;
  int             status1 = PDM_S_SUCCESS;
  int             column = 0;
  int             row = 0;
  int             act_row = 0;
  int             act_pos = 0;
  int             no_headings = 0;
  int             all_flag = 0;
  int             ptype_col = 0;
  int             select, pos = 0;
  int             length = 0;
  int             responses[1];
  int             level = 0;
  int             num_rows = 0;
  int             file_col = 0;
  int             desc_col = 0;
  int             type_col = 0;
  int             mcf_select = FALSE;
  int             part_count = 0;
  int             field = 0;
  int             state = 0;
  char          * strings[1];
  char         ** headings = NULL;
  char         ** list_row;
  char         ** data_row;
  char            type[5];
  char            answer[5];
  char            *prompt_str = NULL;
  char            *msg = NULL;
  char            *save_string = NULL;
  extern void     PDUclear_mcf();
  extern void     PDUreset_local_files_form();
  extern void     PDUset_edit_assy_toggle_after_select();
  MEMptr          ret_bufr = NULL;
  int           display = 0, response = 0;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[5], response_data[50], IsSuper[20];
  int RetOK = 0;
  char w_flow[20];

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  fp = forms.local_files_form_id;
  PDU_form_id = forms.local_files_form_id;
  PDU_check_filename = FALSE;
  PDU_list_filenames = FALSE;
  PDU_check_file_refresh = FALSE;
  PDU_command = 0;
  refresh->command = 0;
  PDU_local_files_displayed = TRUE;
  PDU_main_form_cat = FALSE;
  PDU_load_file_buffer = FALSE;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  PDU_part_sort_string = NULL;
  PDU_activate_copy = FALSE;
  PDU_list_cat = FALSE;

  PDUdismiss_subforms();

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug ("User selected the HELP button", 0);
         if (PDU_local_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.local_files_form_id);
           PDU_local_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         _pdm_status("PDUinitialize_help", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("local_files");
         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

        value = 0.0;
        f_label = 0;

        PDU_local_perm_window = TRUE;
        break;

    case FI_CANCEL:

         _pdm_debug ("User selected the CANCEL button", 0);

         if (forms.flag_form_id)
           {
           FIf_is_displayed(forms.flag_form_id, &display);
           if (display)
             {
             FIf_erase( forms.flag_form_id );
             FIf_delete( forms.flag_form_id );
             PDU_flag_form_displayed = FALSE;
             PDU_flag_form_created = FALSE;
             PDU_flag_perm_window = FALSE;
             }
           }

         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;
         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug ("User selected the RESET button", 0);
         PDUreset_local_files_form();

         PDU_command = 0;
         FIfld_pos_cursor(forms.local_files_form_id, CATALOG_FLD, 0,0,0,0,1,1);

         /* reset the refresh fields */
         PDUfill_in_string(&refresh->rev_project, "");
         PDUfill_in_string(&refresh->rev_catalog, "");
         PDUfill_in_string(&refresh->rev_partid, "");
         PDUfill_in_string(&refresh->rev_revision, "");
         PDUfill_in_string(&refresh->rev_description, "");
         PDUfill_in_string(&refresh->rev_filename, "");
         PDUfill_in_string(&refresh->rev_parttype, "");
          
         break;

    case LOGOUT_BTN:     

         FIg_disable(fp, LOGOUT_BTN);
         PDU_form_id = forms.local_files_form_id;
         break;

    /* Fields in the part selection area */

    case PROJECT_FLD:         /* Field Type:    ASCII    */

         refresh->rev_project = NULL;

         refresh->rev_filename = NULL;
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering PROJECT",0);

         status = PDUep_proj_fld();
         _pdm_status("PDUep_proj_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case CATALOG_FLD:         /* Field Type:    ASCII    */

         refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PARTNUM_FLD, "");
         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering CATALOG",0);

         PDU_main_form_cat = TRUE;

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case PARTNUM_FLD:     /* Sequenced to     */

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering PARTNUM",0);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case PART_REV_FLD:         /* Field Type:    ASCII    */

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering EP_REV_FLD",0);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case PART_FILE_FLD:         /* Field Type:    ASCII    */

         FIfld_get_text_length(fp, PART_FILE_FLD, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, PART_FILE_FLD, 0, 0, length, 
                       (unsigned char *)text, &select, &pos);
         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           refresh->rev_filename = NULL;
           break;
           }

         /* verify part is in part selection area */
         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         status = PDUvalid_filename(refresh->rev_catalog,
       				    refresh->rev_partid,
				    refresh->rev_revision,
				    text);
         _pdm_status("PDUvalid_filename", status);

        if (status != PDM_S_SUCCESS)
           {
           FIg_set_text(fp, PART_FILE_FLD, "");
           refresh->rev_filename = NULL;
           FIfld_pos_cursor(fp, PART_FILE_FLD, 0,0,0,0,1,1);
           PDUmessage(status, 's');
           break;
           }

         PDUfill_in_string(&refresh->rev_filename, text);

         break;

    case PART_DESC_FLD:         /* Field Type:    ASCII    */

/* 11/21/95 - TR 139528296 - MJG - check for NULL */

         if (refresh->rev_description)
           PDUfill_in_string(&save_string, refresh->rev_description);
         refresh->rev_description = NULL;

         _pdm_debug("Entering EP_DESC_BTN",0);

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           {
           if (save_string)
             {
             _pdm_debug("resetting desc", 0);
             PDUfill_in_string(&refresh->rev_description, save_string);
             FIg_set_text(fp, PART_DESC_FLD, refresh->rev_description);
             }
           break;
           }

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    /* Part Selection area list buttons */  

    case PROJECT_LIST_BTN: 
         PDU_active_button = PROJECT_LIST_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_filename = NULL;
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering LIST_PROJECTS",0);

         status = PDUep_proj_btn();
         _pdm_status("PDUep_proj_btn",status);

/*
         if ((status == PDM_S_SUCCESS) && ((!refresh->rev_catalog) ||
             (refresh->rev_catalog && (strcmp(refresh->rev_catalog, "") == 0))))
            FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[1],0,0,0,0,1,1);
         else  if (status != PDM_S_SUCCESS)
            FIg_set_state_off(fp, PROJECT_LIST_BTN);
*/

         PDUmessage(status,'s');
         break; 

    case CATALOG_LIST_BTN:
         PDU_active_button = CATALOG_LIST_BTN;

         PDU_check_file_refresh = TRUE;
         PDU_main_form_cat = TRUE;

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PARTNUM_FLD, "");
         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering EP_CAT_BTN", 0);

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;
  
    case PARTNUM_LIST_BTN:
         PDU_active_button = PARTNUM_LIST_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;

    case REVISION_LIST_BTN:
         PDU_active_button = REVISION_LIST_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering EP_REV_BTN",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;
  
    case FILENAME_LIST_BTN:
         PDU_active_button = FILENAME_LIST_BTN;

         PDUdismiss_subforms();

         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           {
           FIg_set_state_off(fp, PDU_active_button);
           PDU_active_button = -1;
           break;
           }

         /* call PDM function to retrieve a list of filenames */
         if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &PDU_ret_bufr);
         _pdm_status("PDMget_filenames", status);

         if ( status != PDM_S_SUCCESS )
           {
           PDUmessage(status, 's');
           msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           MEMclose(&PDU_ret_bufr);
           FIg_set_state_off(fp, FILENAME_LIST_BTN);
           break;
           }

         if (PDU_ret_bufr == NULL)
           {
           msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_NO_PART_FILES, 's');
           FIg_set_state_off(fp, FILENAME_LIST_BTN);
           break;
           }

         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = forms.local_files_form_id;
         PDU_gadget_labels[0] = PART_FILE_FLD;
         PDU_update_struct[0] = &refresh->rev_filename;

         all_flag = FALSE;
         no_headings = 1;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_cofilename");

         PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
         PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);
         PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

         PDUfree_string_array(&headings, no_headings);

         PDU_list_filenames = TRUE;
         status = PDUsingle_list_form();
         break;

    /* Multicolumn field for listing parts/files */

    case LIST_MCF:     /* Member of group MCF_LIST_GRP  */

         FIfld_get_active_row(fp, LIST_MCF, &act_row, &act_pos);
         _pdm_debug("active row = %d", (char *)act_row);

         if (PDU_parts_list_bufr == NULL)
           break; 

         FImcf_set_active_col(fp, LIST_MCF, 0, 0);
         FIfld_get_select(fp, LIST_MCF, act_row, 0, &mcf_select);

         /* check the value of the first column */
         FIfld_get_text_length(fp, LIST_MCF, act_row, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, LIST_MCF, act_row, 0, length, 
                       (unsigned char *)text, &select, &pos);
         _pdm_debug("text = <%s>", text);

         if (mcf_select == TRUE)
           {
           /* Mark the global array for the row selected */
           PDU_parts_index[act_row] = act_row;
           _pdm_debug("PDU_selected_rows (before incr)= %d", 
                       (char *)PDU_selected_rows);
           PDU_selected_rows = PDU_selected_rows + 1;
           _pdm_debug("PDU_selected_rows (after incr) = %d", 
                       (char *)PDU_selected_rows);

           if (text && (strcmp(text, "") != 0))
             {
             /* loop through columns in mcf to get data selected */
             for (column = 0; column < 7; ++column)
                {
                FIfld_get_text_length(fp, LIST_MCF, act_row, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, act_row, column, length, 
                              (unsigned char *)text, &select, &pos);
  
                /* update the structure and the part selection area */
                switch (column)
                  {
                  case 0:
                      if (refresh->rev_catalog && 
                         (strcmp(text, refresh->rev_catalog) != 0))
                        {
                        status = PDMquery_catalog_type(text, type);
                        _pdm_status("PDMquery_catalog_type", status);
                        _pdm_debug("catalog type = <%s>", type);
                     
                        if ((strcmp(type, "P") == 0) ||
                            (strcmp(type, "CID") == 0) ||
                            (strcmp(type, "PXT") == 0) ||
                            (strcmp(type, "EID") == 0))
                          PDU_param_cat = TRUE;
                        else
                          PDU_param_cat = FALSE;
                        }
                      PDUfill_in_string(&refresh->rev_catalog, text);
                      _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                      FIfld_set_text( fp, CATALOG_FLD, 0, column, text, FALSE);
                      break;
                  case 1:
                      PDUfill_in_string(&refresh->rev_partid, text);
                      _pdm_debug("part num = <%s>", refresh->rev_partid);
                      FIfld_set_text( fp, PARTNUM_FLD, 0, column, text, FALSE);
                      break;
                  case 2:
                      PDUfill_in_string(&refresh->rev_revision, text);
                      _pdm_debug("revision = <%s>", refresh->rev_revision);
                      FIfld_set_text( fp, PART_REV_FLD, 0, column, text, FALSE);
                      break;
                  case 3:
                      PDUfill_in_string(&refresh->rev_description,text);
                      _pdm_debug("description = <%s>",refresh->rev_description);
                      FIfld_set_text(fp, PART_DESC_FLD, 0, column, text, FALSE);
                      break;
                  case 5:
                      PDUfill_in_string(&refresh->rev_filename,text);
                      _pdm_debug("filename = <%s>", refresh->rev_filename);
                      FIfld_set_text(fp, PART_FILE_FLD, 0, column, text, FALSE);
                      break;
                  }
                PDUfree_string(&text);
                }  /* end for column */

             /* check for blank rows - multiple files */
             for (row = act_row + 1; row < PDU_parts_list_bufr->rows; ++row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);
                if (strcmp(text, "") == 0)
                  {
                  if (PDU_parts_index[row] == -1)
                    PDU_selected_rows = PDU_selected_rows + 1;
                  PDU_parts_index[row] = row;
                  _pdm_debug("PDU_selected_rows = <%d>", 
                              (char *)PDU_selected_rows);
                  FImcf_set_select(fp, LIST_MCF, row, TRUE);
                  }
                else
                  {
                  _pdm_debug("multiple files not found", 0);
                  break;
                  }
                }
             }
           else  /* text = NULL_STRING, a multiple file was selected */
             {
             _pdm_debug("searching backwards for the associated part", 0);
             for (row = act_row - 1; row >= 0; --row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);

                if (PDU_parts_index[row] == -1)
                  PDU_selected_rows = PDU_selected_rows + 1;
                PDU_parts_index[row] = row;
                _pdm_debug("PDU_selected_rows = <%d>", 
                           (char *)PDU_selected_rows);
                FImcf_set_select(fp, LIST_MCF, row, TRUE);

                if (strcmp(text, "") != 0)
                  {
                  /* loop through columns in mcf to get part info */
                  for (column = 0; column < 7; ++column)
                     {
                     FIfld_get_text_length(fp, LIST_MCF, row, column, &length);
                     text = (char *) malloc (sizeof (char) * length + 1);
                     memset(text, NULL, sizeof (char) * length + 1);
                     FIfld_get_text(fp, LIST_MCF, row, column, length, 
                                   (unsigned char *)text, &select, &pos);
       
                     /* update the structure and the part selection area */
                     switch (column)
                       {
                       case 0:
                          PDUfill_in_string(&refresh->rev_catalog, text);
                          _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                          FIfld_set_text(fp,CATALOG_FLD,0,column,text, FALSE);
                          break;
                      case 1:
                          PDUfill_in_string(&refresh->rev_partid, text);
                          _pdm_debug("part num = <%s>", refresh->rev_partid);
                          FIfld_set_text(fp,PARTNUM_FLD,0,column, text, FALSE);
                          break;
                      case 2:
                          PDUfill_in_string(&refresh->rev_revision, text);
                          _pdm_debug("revision = <%s>", refresh->rev_revision);
                          FIfld_set_text(fp,PART_REV_FLD,0,column,text, FALSE);
                          break;
                      case 3:
                          PDUfill_in_string(&refresh->rev_description,text);
                          _pdm_debug("description = <%s>",refresh->rev_description);
                          FIfld_set_text(fp,PART_DESC_FLD,0,column,text,FALSE);
                          break;
                      case 5:
                          PDUfill_in_string(&refresh->rev_filename,text);
                          _pdm_debug("filename = <%s>", refresh->rev_filename);
                          FIfld_set_text(fp,PART_FILE_FLD,0,column,text,FALSE);
                          break;
                      }
                    PDUfree_string(&text);
                    }  /* end for column */
                  break;
                  }
                }
             /* check for multiple files below the active row */
             for (row = act_row + 1; row < PDU_parts_list_bufr->rows; ++row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);
                if (strcmp(text, "") == 0)
                  {
                  if (PDU_parts_index[row] == -1)
                    PDU_selected_rows = PDU_selected_rows + 1;
                  PDU_parts_index[row] = row;
                  _pdm_debug("PDU_selected_rows = <%d>", 
                             (char *)PDU_selected_rows);
                  FImcf_set_select(fp, LIST_MCF, row, TRUE);
                  }
                else
                  {
                  _pdm_debug("multiple files not found", 0);
                  break;
                  }
                }
             }

           /* update parttype in structure */
           MEMbuild_array(PDU_parts_list_bufr);
           PDUsetup_buffer(PDU_parts_list_bufr,ROW, &list_row);
           status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", 
                                      &ptype_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_parttype, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + ptype_col]);

           }  /* end if select */
         else
           {
           PDU_parts_index[act_row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

           if (strcmp(text, "") == 0)
             {
             /* find the associated part */
             for (row = act_row - 1; row < PDU_parts_list_bufr->rows; --row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);

                if (PDU_parts_index[row] != -1)
                  PDU_selected_rows = PDU_selected_rows - 1;
                PDU_parts_index[row] = -1;
                _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
                FImcf_set_select(fp, LIST_MCF, row, FALSE);

                if (strcmp(text, "") != 0)
                  {
                  _pdm_debug("associated part found", 0);
                  break;
                  }
               }
             }

           /* check for multiple files */
           for (row = act_row + 1; row < PDU_parts_list_bufr->rows; ++row)
              {
              _pdm_debug("row = <%d>", (char *)row);
              FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                            (unsigned char *)text, &select, &pos);
              if (strcmp(text, "") == 0)
                {
                if (PDU_parts_index[row] != -1)
                  PDU_selected_rows = PDU_selected_rows - 1;
                PDU_parts_index[row] = -1;
                _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
                FImcf_set_select(fp, LIST_MCF, row, FALSE);
                }
              else if (strcmp(text, "") != 0)
                {
                _pdm_debug("no more multiple files found", 0);
                break;
                }
              }

           /* check for parametric catalog */
           if (strcmp(refresh->rev_catalog, "") != 0)
             {
             status = PDMquery_catalog_type(refresh->rev_catalog, type);
             _pdm_status("PDMquery_catalog_type", status);
             _pdm_debug("catalog type = <%s>", type);
         
             if ((strcmp(type, "P") == 0) ||
                 (strcmp(type, "CID") == 0) ||
                 (strcmp(type, "PXT") == 0) ||
                 (strcmp(type, "EID") == 0))
               PDU_param_cat = TRUE;
             else
               PDU_param_cat = FALSE;
             }
           }

         if (PDU_selected_rows > 0)
           {
           if (PDU_param_cat == FALSE)
             {
             PDUenable_local_files_gadgets();
             FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
#if 1
	     FIg_enable(forms.local_files_form_id, ASSY_STRUCTURE_BTN);
#endif
             FIg_enable(forms.local_files_form_id, PARTS_BTN);
             }
           else
             {
             PDUdisable_local_files_gadgets();
             FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
#if 1
             FIg_disable(forms.local_files_form_id, ASSY_STRUCTURE_BTN);
#endif
             FIg_disable(forms.local_files_form_id, PARTS_BTN);
             FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
             }
           FIg_enable(forms.local_files_form_id, MOVE_STATE);
           }

         /* check to see if delete button should be enabled */
         FIg_disable(fp, DELETE_LOCAL_BTN);
         if (PDU_selected_rows > 0)
           {
           _pdm_debug("resetting delete button", 0);
           for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
              FIfld_get_select(fp, LIST_MCF, row, 0, &mcf_select);
              if (mcf_select == TRUE)
                {
                FIfld_get_text_length(fp, LIST_MCF, row, 6, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 6, length, 
                              (unsigned char *)text, &select, &pos);
                _pdm_debug("test = <%s>", text);
                if ((strcmp(text, "CHECKED OUT") == 0) ||
                    (strcmp(text, "COPIED TO LOCAL") == 0) ||
                    (strcmp(text, "CHECKED OUT & COPIED") == 0) ||
		    (strcmp(text, "CHECKED OUT & ATTACHED") == 0) ||
		    (strcmp(text, "COPIED & ATTACHED") == 0) ||
		    (strcmp(text, "CHECKED OUT, COPIED & ATTACHED") == 0) ||
                    (strcmp(text, "CHECKED OUT & ATTACH") == 0))
                  {
                  FIg_enable(fp, DELETE_LOCAL_BTN);
                  PDUfree_string(&text);
                  break;
                  }
                }
              PDUfree_string(&text);
              }
           }
         else
           FIg_disable(fp, DELETE_LOCAL_BTN);

	 PDUset_edit_assy_toggle_after_select();

         break;

    case STRUCTURE_MCF: 

         FIfld_get_active_row(fp, STRUCTURE_MCF, &act_row, &act_pos);
         FImcf_set_active_col(fp, STRUCTURE_MCF, 0, 0);
         FIfld_get_select(fp, STRUCTURE_MCF, act_row, 0, &mcf_select);
         _pdm_debug("active row = %d", (char *)act_row);

         if (mcf_select == TRUE)
           {
           /* clear out the refresh */
           refresh->rev_project = NULL_STRING;
           refresh->rev_catalog = NULL_STRING;
           refresh->rev_partid = NULL_STRING;
           refresh->rev_revision = NULL_STRING;
           refresh->rev_description = NULL_STRING;
           refresh->rev_filename = NULL_STRING;

           FIg_set_text(fp, PROJECT_FLD, "");
           FIg_set_text(fp, CATALOG_FLD, "");
           FIg_set_text(fp, PARTNUM_FLD, "");
           FIg_set_text(fp, PART_REV_FLD, "");
           FIg_set_text(fp, PART_DESC_FLD, "");
           FIg_set_text(fp, PART_FILE_FLD, "");

           /* Mark the global array for the row selected */
           PDU_parts_index[act_row] = act_row;
           PDU_selected_rows = PDU_selected_rows + 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           
           /* loop through columns in mcf to get data selected */
           for (column = 1; column < 4; ++column)
              {
              FIfld_get_text_length(fp,STRUCTURE_MCF,act_row, column, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, STRUCTURE_MCF, act_row, column, length, 
                            (unsigned char *)text, &select, &pos);

              /* update the structure and the part selection area */
              switch (column)
                {
                case 1:
                     PDUfill_in_string(&refresh->rev_catalog, text);
                     _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                     FIfld_set_text( fp, CATALOG_FLD, 0, column, text, FALSE);
                     break;
                case 2:
                     PDUfill_in_string(&refresh->rev_partid, text);
                     _pdm_debug("part num = <%s>", refresh->rev_partid);
                     FIfld_set_text( fp, PARTNUM_FLD, 0, column, text, FALSE);
                     break;
                case 3:
                     PDUfill_in_string(&refresh->rev_revision, text);
                     _pdm_debug("revision = <%s>", refresh->rev_revision);
                     FIfld_set_text( fp, PART_REV_FLD, 0, column, text, FALSE);
                     break;
                }
              PDUfree_string(&text);
              }  /* end for column */

           MEMbuild_array(PDU_parts_list_bufr);
           PDUsetup_buffer(PDU_parts_list_bufr,ROW, &list_row);

           _pdm_debug("getting the filename", 0);
           status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                           refresh->rev_revision, &ret_bufr);
           _pdm_status("PDMget_filenames", status);
       
           if ( status != PDM_S_SUCCESS )
             {
             msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
             MEMclose(&ret_bufr);
             PDUmessage(PDM_E_NO_PART_FILES, 's');
             break;
             }
       
           if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
             {
             msg = (char *) PDUtranslate_message(PDM_E_FILE_NOT_FOUND);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_FILE_NOT_FOUND, 's');
             break;
             }
  
           MEMbuild_array(ret_bufr);
           PDUsetup_buffer(ret_bufr, ROW, &data_row);
           status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
           if (status != PDM_S_SUCCESS)
             break;
       
           PDUfill_in_string(&refresh->rev_filename, 
                             data_row[(ret_bufr->columns * 0) + file_col]);
           if (refresh->rev_filename && (strcmp(refresh->rev_filename,"") != 0))
             {
             _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
             FIg_set_text(fp, PDU_refresh_gadgets[6], refresh->rev_filename);
             }
/*
           status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", 
                                      &file_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_filename, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + file_col]);
           FIg_set_text(forms.local_files_form_id, PART_FILE_FLD, 
                          refresh->rev_filename);
*/

           _pdm_debug("getting the description", 0);
           status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemdesc", 
                                      &desc_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_description, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + desc_col]);
           FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, 
                          refresh->rev_description);

           _pdm_debug("getting the parttype", 0);
           status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", 
                                      &type_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_parttype, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + type_col]);

           _pdm_debug("checking part status for delete local button", 0);
           status = PDMrcheck_part_status(refresh->rev_catalog,
                                          refresh->rev_partid,
                                          refresh->rev_revision);
           _pdm_status("PDMrcheck_part_status", status);
           if ((status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
               (status == PDM_I_CHECKED_OUT_BY_YOU))
             {
             _pdm_debug("enabling delete local button", 0);
             FIg_enable(fp, DELETE_LOCAL_BTN);
             }
           PDUmessage(PDM_S_SUCCESS, 's');
           }  /* end if select */
         else
           {
           PDU_parts_index[act_row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }

         if (PDU_selected_rows > 0)
           {
           if (PDU_param_cat == FALSE)
             {
             PDUenable_local_files_gadgets();
             FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
#if 1
             FIg_enable(forms.local_files_form_id, ASSY_STRUCTURE_BTN);
#endif	     
             FIg_enable(forms.local_files_form_id, PARTS_BTN);
             }
           else
             {
             PDUdisable_local_files_gadgets();
             FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
#if 1
             FIg_enable(forms.local_files_form_id, ASSY_STRUCTURE_BTN);
#endif
             FIg_disable(forms.local_files_form_id, PARTS_BTN);
             FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
             }
           FIg_enable(forms.local_files_form_id, MOVE_STATE);
           }

         _pdm_debug("checking edit assembly toggle", 0);
         if (PDU_selected_rows > 1)
           {
           FIg_disable(fp, EDIT_ASSEMBLY_TGL);
           PDU_chkout_single = FALSE;
           PDU_edit_display = FALSE;
           }
         else
           {
           FIg_enable(fp, EDIT_ASSEMBLY_TGL);
           PDU_chkout_single = TRUE;
	   FIg_get_state(fp, EDIT_ASSEMBLY_TGL, &state);
	   if (state == 1)
             PDU_edit_display = TRUE;
           else
             PDU_edit_display = FALSE;
           }

         break;

    case SEARCH_PARTS_BTN:     
         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);
         PDU_form_id = forms.local_files_form_id;
         PDU_form_type = LOCAL_FILES_FORM;
         PDU_search_type = FILES;

         PDUclear_mcf();

         _pdm_debug("saving refresh information", 0);
         PDU_save_project = NULL_STRING;
         PDU_save_catalog = NULL_STRING;
         PDU_save_partid = NULL_STRING;
         PDU_save_revision = NULL_STRING;
         PDU_save_description = NULL_STRING;
         PDU_save_filename = NULL_STRING;
         PDU_save_parttype = NULL_STRING;

         if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") != 0))
           PDUfill_in_string(&PDU_save_project, refresh->rev_project);
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&PDU_save_catalog, refresh->rev_catalog);
         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
           PDUfill_in_string(&PDU_save_partid, refresh->rev_partid);
         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&PDU_save_revision, refresh->rev_revision);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&PDU_save_description, refresh->rev_description);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
         if ((refresh->rev_parttype) && 
             (strcmp(refresh->rev_parttype, "") != 0))
           PDUfill_in_string(&PDU_save_parttype, refresh->rev_parttype);

         PDU_selected_rows = 0;
	 FIf_erase(fp);
         _pdm_debug("calling part selection form", 0);
         SelectOrPlacePart(TRUE, TRUE, fp);

         break;

    case LIST_PARTS_IN_CAT_BTN:

         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);

         if ((refresh->rev_catalog == NULL) || 
             (strcmp(refresh->rev_catalog, "") == 0))
           {
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_I_ENTER_CATALOG, 's');
           break;
           }

         PDUclear_mcf();
         PDU_selected_rows = 0;

         PDU_dyn_cat_search = NULL_STRING;
         PDU_dyn_part_search = NULL_STRING;
         status = PDMsearch_parts_in_catalog(refresh->rev_catalog,
                                             &PDU_parts_list_bufr);
         _pdm_status("PDMsearch_parts_in_catalog", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         catalog_flag = TRUE;
         status = PDUload_local_files_form();
         _pdm_status("PDUload_local_files_form", status);

         break;

    case LIST_FILES_BTN:     
         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);
         break;

    case WHERE_USED:

         if (PDU_selected_rows > 0)
           part_count = PDUcount_selected_parts();
         else
           part_count = 0;
 
         if (part_count > 1)
           {
           PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
 
         if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();
 
         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         PDUclear_mcf();
 
         status = PDMrget_imm_parents(refresh->rev_catalog,
              refresh->rev_partid, refresh->rev_revision, &PDU_parts_list_bufr);
         _pdm_status("PDMrget_imm_parents", status);

         if (status != PDM_S_SUCCESS)
           {
           if (status == SQL_I_NO_ROWS_FOUND)
             status = PDM_E_NO_PARENTS;
           PDUmessage(status, 's');
           MEMclose(&PDU_parts_list_bufr);
           PDU_parts_list_bufr = NULL;
           break;
           }

         if (!PDU_parts_list_bufr)
           {
           _pdm_debug("buffer is NULL", 0);
           PDUmessage(PDM_E_NO_PARENTS, 's');
           break;
           }

         if (PDU_parts_list_bufr->rows == 0)
           {
           _pdm_debug("no rows in buffer", 0);
           PDUmessage(PDM_E_NO_PARENTS, 's');
           MEMclose(&PDU_parts_list_bufr);
           PDU_parts_list_bufr = NULL;
           break;
           }

         if (PDM_debug_on)
           MEMprint_buffer("where_used", PDU_parts_list_bufr, PDU_DEBUG_FILE);

         catalog_flag = TRUE;
         if (PDU_parts_list_bufr)
           {
           status = PDUload_local_files_form();
           _pdm_status("PDUload_local_files_form", status);
           }

         break;

    case ROLL_THROUGH:  
         break;

    /* Buttons from file operations button palette */

    case CHECKIN_BTN:        

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

         /* put the checkin command on the queue */
         PDU_command = PDC_M_CHECKIN;
         responses[0] = EX_CMD_KEY;
         strings[0] = "PDChInPr";
  
         status = PDUprepare_queue ( responses, strings, 1 );
         _pdm_status("PDUprepare_queue (checkin part)",status);

         break;
         
    case CHECKOUT_BTN:       

         _pdm_debug("entering case for CHECKOUT", 0);
         PDU_command = PDC_M_CHECKOUT;

         /* reset file buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

         PDU_checkout_type = NONACT;

         if (PDU_selected_rows > 1)
           {
           _pdm_debug("checking out multiple parts", 0);
           status = PDUcheckout();
           _pdm_debug("PDUcheckout", status);

	   if (status != PDM_S_SUCCESS)
             PDUmessage(status, 's');

           break;
           }

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            break;
            }

          /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);
 
         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if ((status == PDM_I_CHECKED_IN) ||
             (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
             (status == PDM_I_ATTACHED_TO_LOCAL_ASSY))
           {
           /* put the checkout command on the queue */
           PDU_command = PDC_M_CHECKOUT;
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDChOtPr";
    
           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (checkout part)",status);
           }
         else
           {
           PDUmessage(status, 's');
           break;
           }
  
         break;

    case COPY_LOCAL_BTN:
         
	 _pdm_debug("entering case for COPY_LOCAL", 0);

         /* reset file buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

         if ((PDU_mcf_list) && (PDU_selected_rows > 1))
           {
           /* put the copy command on the queue */
           PDU_command = PDC_M_COPY;
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDCpFlTLc";
   
           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (checkout part)",status);
           break;
           }

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

          /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);
 
         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if ((status == PDM_I_CHECKED_IN) ||
             (status == PDM_I_ATTACHED_TO_LOCAL_ASSY) ||
             (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
           {
           /* put the copy command on the queue */
           PDU_command = PDC_M_COPY;
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDCpFlTLc";
   
           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (checkout part)",status);
           break;
           } 
         else
           {
           PDUmessage(status, 's');
           break;
           }

    case DELETE_LOCAL_BTN:   

         if (PDU_selected_rows > 1)
           {
           _pdm_debug("entering delete local for multiple part selection", 0);

           /* call function to pull out the files for deletion */
           status = PDUcreate_delete_buffer();
           _pdm_status("PDUcreate_delete_buffer", status);

           if (status != PDM_S_SUCCESS)
             {
	     PDUmessage(status, 's');
             break;
             }

           if ((PDU_delete_buffer) && (PDU_delete_buffer->rows > 0))
             {
             PDUmessage(PDC_M_DELETE_FILE, 'c');

	     status = PDUdelete_file();
             _pdm_status("PDUdelete_file", status);

             if (status != PDM_S_SUCCESS)
	       PDUmessage(status, 's');

             if (PDU_delete_buffer)
               {
               MEMclose(&PDU_delete_buffer);
               PDU_delete_buffer = NULL;
               }
             }
           else
             if (PDU_delete_buffer)
               {
               MEMclose(&PDU_delete_buffer);
               PDU_delete_buffer = NULL;
               }

           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

           if ((PDU_selected_rows > 0) || ((PDU_part_file_buffer) &&
               (PDU_part_file_buffer->rows > 0)))
             {
	     /* reset the parts index for cancel part check out */
             _pdm_debug("resetting PDU_parts_index", 0);
	     for (row = 0; row < PDU_parts_list_bufr->rows; ++ row)
                {
                if (PDU_parts_index[row] > 10000)
                  {
                  PDU_parts_index[row] = PDU_parts_index[row] - 10000;
                  _pdm_debug("resetting row %d", (char *)PDU_parts_index[row]);
                  }
                }

             /* call function to display parts for confirmation */
             if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
               {
               PDU_command = PDC_M_CANCEL_CHECKOUT;
	       status = PDUcancel_list_form();
               _pdm_status("PDUcancel_list_form", status);
               }
             else
               if (PDU_part_file_buffer)
                 {
                 MEMclose(&PDU_part_file_buffer);
                 PDU_part_file_buffer = NULL;
                 }
             }

           break;
           }

         _pdm_debug("entering delete local files for single part selection", 0);
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

	 /* check the status of the part */
         status = PDMrcheck_part_status(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);

         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

	 /* if the part if checked out to this WS, cancel part checkout */
	 if (status == PDM_I_CHECKED_OUT_BY_YOU)
           {
           /* make sure the file is local */
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file is checked out */
             {
             _pdm_debug("inside case where file is local for checked out", 0);
             if (PDU_part_file_buffer)
               {
               MEMclose(&PDU_part_file_buffer);
               PDU_part_file_buffer = NULL;
               }
 
             status = PDUload_file_buffer(refresh->rev_catalog,
                                          refresh->rev_partid,
                                          refresh->rev_revision,
                                          refresh->rev_description, "");
             _pdm_status("PDUload_file_buffer", status);
 
             if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
               {
               PDU_command = PDC_M_CANCEL_CHECKOUT;
               status = PDUcancel_list_form();
               _pdm_status("PDUcancel_list_form", status);
               }
             else
               if (PDU_part_file_buffer)
                 {
                 MEMclose(&PDU_part_file_buffer);
                 PDU_part_file_buffer = NULL;
                 }

             /* put the cancel checkout command on the queue */
/*
             PDU_command = PDC_M_CANCEL_CHECKOUT;
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDCnPrChOt";
  
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (cancel checkout)", status);
*/

             if (PDU_delete_buffer)
               {
               MEMclose(&PDU_delete_buffer);
               PDU_delete_buffer = NULL;
               }
             break;
             }
           else
             {
             _pdm_debug("inside case where file is not local for checked out", 0);
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
	     PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             _pdm_debug("breaking", 0);
             break;
             }
           }

	 /* if the part is copied by you, delete the local file */
         else if (status == PDM_I_COPIED_TO_LOCAL_BY_YOU)
           {
           /* make sure the file is local */
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file has been copied */
             {
             _pdm_debug("inside case where file is local for copied", 0);
             /* call function to create delete buffer */
             status = PDUcreate_delete_buffer();
             _pdm_status("PDUcreate_delete_buffer", status);
  
             if (status != PDM_S_SUCCESS)
               {
	       PDUmessage(status, 's');
               break;
               }
  
             /* put the delete local files command on the queue */
             PDU_command = PDC_M_DELETE_FILE;
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDDlLcFl";
      
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (checkout part)",status);

             if (PDU_part_file_buffer)
               {
               MEMclose(&PDU_part_file_buffer);
               PDU_part_file_buffer = NULL;
               }
             }
           else
             {
             _pdm_debug("inside case where file is not local for copied", 0);
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
	     PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             _pdm_debug("breaking", 0);
             break;
             }
           }
         else
           PDUmessage(status, 's');

         break;
         
    case DESIGN:        

         _pdm_debug("entering case for design", 0);
         __DBGpr_com("entering case for design");
         PDU_command = PDC_M_CHECKOUT_ACTIVATE;

         /* format the buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

	 /* call function to loop through the rows */
         if (PDU_selected_rows > 1)
           {
           _pdm_debug("entering design for multiple part selection", 0);
           PDU_checkout_type = NONACT;

           status = PDUformat_buffer (PDU_PART_FILE_BUFFER, 
                                      &PDU_part_file_buffer);
           _pdm_status("PDUformat_buffer", status);
         
           if (status != PDM_S_SUCCESS)
             {
	     _pdm_debug("error formatting PDU_part_file_buffer", 0);
	     PDU_load_file_buffer = FALSE;;
             }
           else
             {
	     _pdm_debug("PDU_part_file_buffer successfully formatted", 0);
	     PDU_load_file_buffer = TRUE;
             }

           PDUmessage(PDC_M_CHECKOUT, 'c');
           PDU_checkout_type = NONACT;

	   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
	   __DBGpr_str( "HI w_flow", w_flow);
           status = CMar_form( refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision );
           status = PDUcheckout();
           _pdm_status("PDUcheckout", status);

	   if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
	     MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
	     __DBGpr_com( " breaking because of ");
             break;
             }

           /* call function to display list of parts that may be activated */
           if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
             {
             PDUpart_file_list_form();

             status = WaitForEvent();
             _pdm_status("WaitForEvent", status);

             if (!status)
               {
                _pdm_debug("part listing form was cancelled", 0);
                PDUmessage(PDM_E_CMD_CANCELLED, 's');
                break;
               }
             }
           else
             {
             MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
             }

           break;
           }

         _pdm_debug("entering design for single part selection", 0);
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
           {
         _pdm_debug("before calling PDUload_refresh_from_parts_lis:", 0);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
             status = PDUload_refresh_from_parts_list();
             if (status == PDM_E_GENERATE_PARTS_LIST)
               {
               msg = (char *) PDUtranslate_message(PDM_E_GENERATE_PARTS_LIST);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               break;
               }
           }

          if ((refresh->rev_parttype) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0) &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0))
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_NONGRAPHIC);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
            break;
            }

         _pdm_debug("before calling PDUcheck_part_data_for_utilities:", 0);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

         _pdm_debug("before calling PDUcheckout:", 0);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

         /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);

         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if (status == PDM_I_NEVER_CHECKED_IN)
           {
           /* go ahead and activate the part */
           FIf_erase(forms.local_files_form_id);
           __DBGpr_str("part retrieved", refresh->rev_partid);
	   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
	   __DBGpr_str( " w_flow ", w_flow);
	   // TR1364 follow CM changes only for AVD_CM_W_FLOW
	   // SSR 7 SEP
	   //if(!strcmp(w_flow, AVD_CM_WFLOW))
	   if(!strcasecmp(w_flow, "Y"))
	   {
	     status = SrValidateforRet(refresh->rev_catalog, 
	     			refresh->rev_partid, refresh->rev_revision);
	     if(status)
	     {
	       FIf_display(forms.local_files_form_id);
	       break;
	     } 
	     
	     status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper); 
	     if(!strcmp(CMmng, "Y"))
	     {
	       status = CMar_form( refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision );
               do
               {
                 ex$wait_for_input( response = &response,
                                  buffer = response_data,
                                  mode = EX_ALL_ASCII_MODE,
                                  byte = &status );
               } while ( response != EX_FORM_FINISHED );

               if(IsRetOK() == 0 )
               {
                 UI_status("No ARs/DCC selected; Couldnot open a file.");
                 FIf_display(forms.local_files_form_id);
                 break;
               }
               status = SrVDGetCMattrs(refresh->rev_catalog,
	                               refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper);
               if(strcmp(ARsel, "Y") && !strcmp(DCCsel, "Y"))
               {
               /* AR is not selected AND DCC is not selected */
                 UI_status("No ARs selected; Couldnot open file.");
                 FIf_display(forms.local_files_form_id);
                 break;
               }
             }
	   }
           PDU_command = PDC_M_ACTIVATE_PART;
           __DBGpr_com("about to PDUactivate in PDM_I_NEVER_CHECKED_IN");
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
	   /* tls show CM form  we need to make it wait some how*/
	   /* we need to check the state also */
           /* SSR should call CMload_ar_form; to show working ARs and also give an option to query available ARs */
  	   /*status = CMstate_form();*/
           /*printf("\n USR %s", refresh->username);*/
           break;
           }

         else if (status == PDM_I_CHECKED_OUT_BY_YOU)
           {
           /* go ahead and activate the part */
           FIf_erase(forms.local_files_form_id);
	   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
	   __DBGpr_str( " w_flow ", w_flow);
	   // TR1364 follow CM changes only for AVD_CM_W_FLOW
	   // SSR 7 SEP
	   //if(!strcmp(w_flow, AVD_CM_WFLOW))
	   if(!strcasecmp(w_flow, "Y"))
	   {
           status = SrValidateforRet(refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision);
           if(status)
           {
             FIf_display(forms.local_files_form_id);
             break;
           }

           __DBGpr_str("2part retrieved", refresh->rev_partid);
           status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper);

           if(!strcmp(CMmng, "Y"))
           {
             status = CMar_form( refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision );
             do
             {
               ex$wait_for_input( response = &response,
                                  buffer = response_data,
                                  mode = EX_ALL_ASCII_MODE,
                                  byte = &status );
             } while ( response != EX_FORM_FINISHED );
             if(IsRetOK() == 0 )
             {
               UI_status("No ARs/DCC selected; Couldnot open a file.");
               FIf_display(forms.local_files_form_id);
               break;
             }

             status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper);
             if(strcmp(ARsel, "Y") && !strcmp(DCCsel, "Y"))
             {
               UI_status("No ARs selected; Couldnot open file.");
               FIf_display(forms.local_files_form_id);
               break;
             }
           }
	   }
           PDU_command = PDC_M_ACTIVATE_PART;
           __DBGpr_com("about to PDUactive PDM_I_CHECKED_OUT_BY_YOU");
  	   /*status = CMstate_form();*/
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
	   /* tls show CM form */
	   /* we need to check the state also */
           /*status = WaitForEvent();*/
           /*printf("\n USR %s", refresh->username);*/
           break;
           }

         else if (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER)
           {
           PDUmessage(status, 's');
           break;
           }

         else if ((status != PDM_I_CHECKED_IN) &&
                  (status != PDM_I_CHECKED_OUT_BY_YOU) &&
                  (status != PDM_I_NEVER_CHECKED_IN) &&
                  (status != PDM_I_COPIED_TO_LOCAL_BY_YOU) &&
                  (status != PDM_I_ATTACHED_TO_LOCAL_ASSY) &&
                  (status != PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
           {
           PDUmessage(status, 's');
           break;
           }

         PDU_checkout_type = ACT;
         PDU_load_file_buffer = TRUE;

           FIf_erase(forms.local_files_form_id);
	   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
	   __DBGpr_str( " w_flow ", w_flow);
	   // TR1364 follow CM changes only for AVD_CM_W_FLOW
	   // SSR 7 SEP
	   //if(!strcmp(w_flow, AVD_CM_WFLOW))
	   if(!strcasecmp(w_flow, "Y"))
	   {
           status = SrValidateforRet(refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision);
           if(status)
           {
             FIf_display(forms.local_files_form_id);
             break;
           }

           __DBGpr_str("3part retrieved", refresh->rev_partid);
           status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper);
           if(!strcmp(CMmng, "Y"))
           {
             status = CMar_form( refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision );
             do
             {
               ex$wait_for_input( response = &response,
                                  buffer = response_data,
                                  mode = EX_ALL_ASCII_MODE,
                                  byte = &status );
             } while ( response != EX_FORM_FINISHED );
             if(IsRetOK() == 0 )
             {
               UI_status("No ARs/DCC selected; Couldnot open a file.");
               FIf_display(forms.local_files_form_id);
               break;
             }

             status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper);
             if(strcmp(ARsel, "Y") && !strcmp(DCCsel, "Y"))
             {
               UI_status("No ARs selected; Couldnot open file.");
               FIf_display(forms.local_files_form_id);
               break;
             }
           }
	   }
         __DBGpr_com("PDUcheckout a file");
         status = PDUcheckout();
         _pdm_status("PDUcheckout", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           if (PDU_part_file_buffer)
             {
             PDU_part_file_buffer = NULL;
             MEMclose(&PDU_part_file_buffer);
             }
	   // TR 1274 SSR 7 OCT 99
	   FIf_display(forms.local_files_form_id);
           break;
           }

         /* call function to display list of parts that may be activated */
         if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
           {
           PDUpart_file_list_form();

           status = WaitForEvent();
           _pdm_status("WaitForEvent", status);

           if (!status)
             {
              _pdm_debug("part listing form was cancelled", 0);
              PDUmessage(PDM_E_CMD_CANCELLED, 's');
              break;
             }
           }
         else
           {
           /* put activate command on the queue */
           FIf_erase(forms.local_files_form_id);
	   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
	   __DBGpr_str( " w_flow ", w_flow);
	   // TR1364 follow CM changes only for AVD_CM_W_FLOW
	   // SSR 7 SEP
	   //if(!strcmp(w_flow, AVD_CM_WFLOW))
	   if(!strcasecmp(w_flow, "Y"))
	   {
           __DBGpr_com("before 3rd PDUactivate.");
           status = SrValidateforRet(refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision);
           if(status)
             break;


           if(!strcmp(CMmng, "Y"))
           {
             status = CMar_form( refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision );
             do
             {
               ex$wait_for_input( response = &response,
                                  buffer = response_data,
                                  mode = EX_ALL_ASCII_MODE,
                                  byte = &status );
             } while ( response != EX_FORM_FINISHED );
             if(IsRetOK() == 0 )
             {
               UI_status("No ARs/DCC selected; Couldnot open a file.");
               FIf_display(forms.local_files_form_id);
               break;
             }

             status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng, 
                                   DCCsel, Mdc, IsSuper);
             if(strcmp(ARsel, "Y") && !strcmp(DCCsel, "Y"))
             {
               UI_status("No ARs selected; Couldnot open file.");
               FIf_display(forms.local_files_form_id);
               break;
             }
           }
	   }
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
           /*printf("\n USR %s", refresh->username);*/
           }


         /*printf("\n USR %s", refresh->username);*/
         break;

    case REVIEW_DESIGN:  

	 _pdm_debug("entering case for REVIEW_DESIGN", 0);
	 PDU_activate_copy = TRUE;

         /* format the buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

         if (PDU_selected_rows > 1)
           {
	   _pdm_debug("entering review design for multiple part selection", 0);

           status = PDUformat_buffer (PDU_PART_FILE_BUFFER,
                                      &PDU_part_file_buffer);
           _pdm_status("PDUformat_buffer", status);

           if (status != PDM_S_SUCCESS)
             {
             _pdm_debug("error formatting PDU_part_file_buffer", 0);
             PDU_load_file_buffer = FALSE;
             }
           else
             {
             _pdm_debug("PDU_part_file_buffer successfully formatted", 0);
             PDU_load_file_buffer = TRUE;
             }

	   PDUmessage(PDC_M_COPY, 'c');

           status = PDUcopy_file();
           _pdm_status("PDUcopy_file", status);

           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             if (status != PDM_E_COPY_FILES)
               {
	       MEMclose(&PDU_part_file_buffer);
               PDU_part_file_buffer = NULL;
               break;
               }
             }

           /* call function to display list of parts that may be activated */
	   if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
             {
             PDUpart_file_list_form();

             status = WaitForEvent();
             _pdm_status("WaitForEvent", status);

             if (!status)
               {
                _pdm_debug("part listing form was cancelled", 0);
                PDUmessage(PDM_E_CMD_CANCELLED, 's');
                break;
               }
             }
           else
             {
             MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
             }

           break;
           }

	 _pdm_debug("entering review design for single part selection", 0);
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
           {
             status = PDUload_refresh_from_parts_list();
             if (status == PDM_E_GENERATE_PARTS_LIST)
               {
               msg = (char *) PDUtranslate_message(PDM_E_GENERATE_PARTS_LIST);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               break;
               }
           }

          if ((refresh->rev_parttype) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0) &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0))
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_NONGRAPHIC);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
            break;
            }

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

         /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);

         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if ((status == PDM_I_CHECKED_OUT_BY_YOU) ||
             (status == PDM_I_COPIED_TO_LOCAL_BY_YOU))
           {
           /* check to see if file is already local */
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file is checked out */
             {
	     /* go ahead and activate the part */
             FIf_erase(forms.local_files_form_id);
             PDU_command = PDC_M_ACTIVATE_PART;

             status = PDUconvert_file_before_review();
             _pdm_status("PDUconvert_file_before_review", status);

             PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
             status = PDUactivate();
             _pdm_status("PDUactivate", status);
             }
           }

         else if ((status == PDM_I_CHECKED_IN) ||
                  (status == PDM_I_ATTACHED_TO_LOCAL_ASSY) ||
                  (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
           {
           _pdm_debug("copying file for review design", 0);
           PDUmessage(PDC_M_COPY, 'c');
           status = PDUcopy_file();
           _pdm_status("PDUcopy_file", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           /* activate the part */
           FIf_erase(forms.local_files_form_id);
           PDU_command = PDC_M_ACTIVATE_PART;

           status = PDUconvert_file_before_review();
           _pdm_status("PDUconvert_file_before_review", status);

           PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
           break;
           }
	  
         else if (status == PDM_I_NEVER_CHECKED_IN)
           {
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file is checked out */
             {
             _pdm_debug("activating new file", 0);
             /* go ahead and activate the part */
             FIf_erase(forms.local_files_form_id);
             PDU_command = PDC_M_ACTIVATE_PART;

             status = PDUconvert_file_before_review();
             _pdm_status("PDUconvert_file_before_review", status);

             PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
             status = PDUactivate();
             _pdm_status("PDUactivate", status);
             break;
             }
           else if (status == PDM_E_FILE_NULL)
             {
             PDUmessage(PDM_E_NO_PART_FILES, 's');
             break;
             }
           else
             {
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
             PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             break;
             }
           }

        else
          {
          PDUmessage(status, 's');
          break;
          }

         break;

    case REV_STRUCT_BTN:      /* same as LIST PART STRUCTURE */

         if (PDU_selected_rows > 0)
           part_count = PDUcount_selected_parts();
         else
           part_count = 0;

         if (part_count > 1)
           {
           PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         /*if (PDU_selected_rows == 1)*/
         if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         PDUmessage(PDM_E_CLEAR_FIELD, 's');
	 
         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         if (refresh->rev_parttype &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0) &&
             (strcmp(refresh->rev_parttype, "M") != 0) &&
             (strcmp(refresh->rev_parttype, "m") != 0) &&
             (strcmp(refresh->rev_parttype, "P") != 0) &&
             (strcmp(refresh->rev_parttype, "p") != 0) &&
             (strcmp(refresh->rev_parttype, "A") != 0) &&
             (strcmp(refresh->rev_parttype, "a") != 0) &&
             (strcmp(refresh->rev_parttype, "N") != 0) &&
             (strcmp(refresh->rev_parttype, "n") != 0) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0))
           {
           msg = (char *) PDUtranslate_message(PDM_E_INVALID_PARTTYPE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_INVALID_PARTTYPE, 's');
           break;
           }
         else if (!refresh->rev_parttype)
           {
           _pdm_debug("ERROR: refresh->rev_parttype is NULL", 0);
           msg = (char *) PDUtranslate_message(PDM_E_INVALID_PARTTYPE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_INVALID_PARTTYPE, 's');
           break;
           }
          
         PDUclear_mcf();

         status = PDMvalidate_user_access("PDMReview Assembly Structure",
                    NULLSTR, refresh->rev_catalog, NULLSTR, refresh->rev_partid,
                    refresh->rev_revision );
         _pdm_status ("PDMvalidate_user_access", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }

         /* get the max level of display from the database */
         status = PDUget_max_level(&level);
         _pdm_status("PDUget_max_level", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status);
           break;
           }

         /* retrieve the structure of the part in the refresh */

         _pdm_debug("retrieving structure of part <%s>", refresh->rev_partid);
         status = PDMget_assembly_structure(refresh->rev_catalog, 
                                    refresh->rev_partid, refresh->rev_revision, 
                                    level, &PDU_parts_list_bufr, 0);
         _pdm_status("PDMget_assembly_structure", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         if (!(PDU_parts_list_bufr))
           {
	   PDUmessage(PDM_E_RETRIEVE_ASSEMBLY, 's');
           break;
           }

         if ((PDU_parts_list_bufr) && (PDU_parts_list_bufr->rows == 1))
           {
           PDUmessage(PDM_E_PART_NOT_ASSEMBLY, 's');
           msg = (char *) PDUtranslate_message(PDM_E_PART_NOT_ASSEMBLY);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         status = PDUdisplay_review_structure(PDU_parts_list_bufr);
         _pdm_status("PDUdisplay_review_structure", status);

         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);

         break;

    /* Buttons from Entities button palette */

    case CATALOG_BTN:        
         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;

         status = PDUcatalog_name_form();
         _pdm_status("PDUcatalog_name_form", status);
         break;

    case PARTS_BTN:         
         refresh->rev_filename = NULL;

         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;

         status = PDUpart_form();
         _pdm_status("PDUpart_form", status);
         break;

    case REPORTS_BTN:        
         PDU_active_button = -1;
         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;
         PDU_calling_form = fp;
         PDUreports_form();

         break;

    case PARM_PARTS_BTN:
         refresh->rev_filename = NULL;

         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;

         status = PDUparametric_part_form(NULL_STRING);
         _pdm_status("PDUparametric_part_form", status);
         break;


    case UPDATE_DATABASE:        

         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         status = PDUcheck_part("update database", POST_DATABASE);
         _pdm_status("PDUcheck_part", status);

         PDUmessage(status, 's');
         break;


    case DELETE_PART:        

         _pdm_debug("entering case for delete part", 0);

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         if (((refresh->rev_partid == NULL)            ||
             (strcmp(refresh->rev_partid, "") == 0)) &&
             (PDU_selected_rows == 0))
           {
           PDUmessage(PDM_I_ENTER_PART, 's');
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         _pdm_debug("calling UI_prompt", 0);
         prompt_str = (char *) PDUtranslate_message(PDP_P_DELETE_PART);
         UI_prompt(prompt_str);
         do
           {
           status = PDUget_keyin(answer);
       
           if ((answer) && (strlen(answer) > 0) &&
               (strcmp(answer,"y")) && (strcmp(answer,"Y")) &&
               (strcmp(answer,"n")) && (strcmp(answer,"N")))
             {
             status = PDM_E_INVALID_INPUT;
             }
           }
         while (status == PDM_E_INVALID_INPUT);
         UI_prompt(NULL_STRING);
      
         _pdm_debug("answer = <%s>", answer);
       
         if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
           return(PDM_E_CMD_CANCELLED);
       
         PDU_command = PDC_M_DELETE_ELEMENT;

         status = PDUcheck_part("delete_part", PDC_M_DELETE_ELEMENT);
         _pdm_status("PDUcheck_part", 0);

         PDUmessage(status, 's');

         if (PDU_mcf_list && PDU_parts_list_bufr)
           {
           status1 = PDUupdate_buffer_after_delete_part();
           _pdm_status("PDUupdate_buffer_after_delete_part", status1);
           }

         if (status == PDM_S_SUCCESS)
           PDUmessage(status1, 's');

         break;

    case FLAG:        
         _pdm_debug("entering case for flag part", 0);

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         if (((refresh->rev_partid == NULL)            ||
             (strcmp(refresh->rev_partid, "") == 0))   &&
             (PDU_selected_rows == 0))
           {
           PDUmessage(PDM_I_ENTER_PART, 's');
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         FIg_set_state_off(fp, FLAG);
         PDUflag_form();

         break;

    case MOVE_STATE:        

         _pdm_debug("entering case for move to next state", 0);
         __DBGpr_com("entering case for move to next state");
 
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();
 
         if (((refresh->rev_partid == NULL)            ||
             (strcmp(refresh->rev_partid, "") == 0))   &&
             (PDU_selected_rows == 0))
           {
           PDUmessage(PDM_I_ENTER_PART, 's');
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         status = PDUstate_form();
         _pdm_status("PDUstate_form", status);

         PDUmessage(status, 's');

         break;

    case SELECT_ALL:        

         _pdm_debug("entering SELECT_ALL", 0);

         if (PDU_mcf_list)
           field = LIST_MCF;
         else if (PDU_structure_list)
           field = STRUCTURE_MCF;

         FIfld_get_num_rows(fp, field, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         PDU_selected_rows = num_rows;
 
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_set_select(fp, field, row, TRUE);
            PDU_parts_index[row] = row;
            }

         /* check to see if delete button should be enabled */
         FIg_disable(fp, DELETE_LOCAL_BTN);
         if (PDU_selected_rows > 0)
           {
           _pdm_debug("resetting delete button", 0);
           for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
              FIfld_get_select(fp, LIST_MCF, row, 0, &mcf_select);
              if (mcf_select == TRUE)
                {
                FIfld_get_text_length(fp, LIST_MCF, row, 6, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 6, length, 
                              (unsigned char *)text, &select, &pos);
                _pdm_debug("test = <%s>", text);
                if ((strcmp(text, "CHECKED OUT") == 0) ||
                    (strcmp(text, "COPIED TO LOCAL") == 0) ||
                    (strcmp(text, "CHECKED OUT & COPIED") == 0) ||
		    (strcmp(text, "CHECKED OUT & ATTACHED") == 0) ||
		    (strcmp(text, "COPIED & ATTACHED") == 0) ||
		    (strcmp(text, "CHECKED OUT, COPIED & ATTACHED") == 0) ||
                    (strcmp(text, "CHECKED OUT & ATTACH") == 0))
                  {
                  FIg_enable(fp, DELETE_LOCAL_BTN);
                  PDUfree_string(&text);
                  break;
                  }
                }
              PDUfree_string(&text);
              }
           }
         else
           FIg_disable(fp, DELETE_LOCAL_BTN);

         FIg_disable(fp, EDIT_ASSEMBLY_TGL);
         PDU_edit_display = FALSE;
         PDU_chkout_single = FALSE;

         if (PDU_param_cat == FALSE)
           {
           PDUenable_local_files_gadgets();
           FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
           FIg_enable(forms.local_files_form_id, PARTS_BTN);
           }
         else
           {
           PDUdisable_local_files_gadgets();
           FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
           FIg_disable(forms.local_files_form_id, PARTS_BTN);
           FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
           }
         FIg_enable(forms.local_files_form_id, MOVE_STATE);

         break;

    case DESELECT_ALL:

         _pdm_debug("entering DESELECT_ALL", 0);

         if (PDU_mcf_list)
           field = LIST_MCF;
         else if (PDU_structure_list)
           field = STRUCTURE_MCF;

         FIfld_get_num_rows(fp, field, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         PDU_selected_rows = 0;
 
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_set_select(fp, field, row, FALSE);
            PDU_parts_index[row] = -1;
            }

         FIg_disable(fp, DELETE_LOCAL_BTN);
         PDU_chkout_single = TRUE;
         FIg_enable(fp, EDIT_ASSEMBLY_TGL);
	 FIg_get_state(fp, EDIT_ASSEMBLY_TGL, &state);
	 if (state == 1)
           PDU_edit_display = TRUE;
         else
           PDU_edit_display = FALSE;
         PDUcheck_file_commands();

         break;

    case EDIT_ASSEMBLY_TGL:

         FIg_get_state(fp, EDIT_ASSEMBLY_TGL, &state);
         _pdm_debug("assembly toggle = %d", (char *)state);

         if (state)
           PDU_edit_display = 1;
         else
           PDU_edit_display = 0;

         break;

#if 1
    case ASSY_STRUCTURE_BTN:


         if (PDU_param_cat == TRUE)
           {
           msg = (char *) PDUtranslate_message(PDM_E_PARAMETRIC_STRUCTURE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_PARAMETRIC_STRUCTURE, 's');
           break;
           }

         if (PDU_selected_rows > 0)
           part_count = PDUcount_selected_parts();
         else
           part_count = 0;

         if (part_count > 1)
           {
           PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         /*if (PDU_selected_rows == 1)*/
         if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         status = PDUdefine_assy_form();
         _pdm_status("PDUdefine_assy_form", status);
         break;
#endif	 
    case REVISE_ASSEMBLY_BTN:

          if (PDU_selected_rows > 0)
            part_count = PDUcount_selected_parts();
          else
            part_count = 0;

          if (part_count > 1)
            {
            PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
            msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
              PDUload_refresh_from_parts_list();

          PDUmessage(PDM_E_CLEAR_FIELD, 's');

          status = PDUverify_part_data(forms.local_files_form_id);
          _pdm_status("PDUverify_part_data", status);
          if (status != PDM_S_SUCCESS)
            break;

          /* get the file status of the part */
          status = PDMrcheck_part_status(refresh->rev_catalog,
                          refresh->rev_partid, refresh->rev_revision);
          _pdm_status("PDMrcheck_part_status", status);

          if ((status != PDM_I_NEVER_CHECKED_IN) &&
              (status != PDM_I_CHECKED_IN))
            {
            PDUmessage(PDM_I_PART_CHECKIN, 's');
            msg = (char *)PDUtranslate_message(PDM_I_PART_CHECKIN);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          status = PDMvalidate_user_access("PDMCheck Out Part", NULLSTR,
                refresh->rev_catalog, NULLSTR, refresh->rev_partid,
                refresh->rev_revision );
          _pdm_status ("PDMvalidate_user_access", status);

          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            msg = (char *)PDUtranslate_message(status);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          FIf_erase(fp);
          PDU_local_files_displayed = FALSE;

          PDU_command = PDC_M_REVISE_ASSEMBLY;
          PDUrevise_assembly_form();
          break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */


/*
IGRint  PDUactivate ()
  {
  IGRint        status;
  IGRint        stat;
  IGRint        bufsiz;
  IGRint        msg;
  IGRint        responses[5];
  IGRchar       *strings [5];
  IGRchar       active_filename[DI_PATH_MAX];
  IGRchar       answer[10];
  IGRchar       output_var[100];
  IGRchar       tmp_filename[15];
  IGRchar       *prompt_msg = NULL;
  IGRchar       *save_filename = NULL;
  IGRshort      read_only = FALSE;
  struct        GRmd_env mod_env;
  extern        int PDU_command;
  extern        short PDU_edit_display;

  _pdm_debug("In the function PDUactivate", 0);

  PDUmessage(PDC_M_ACTIVATE_PART, 'c');
  refresh->command = PDC_M_ACTIVATE_PART;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  if (forms.local_files_form_id)
    FIf_erase(forms.local_files_form_id);

  bufsiz = sizeof(mod_env);
  gr$get_module_env(msg = &msg, sizbuf = bufsiz, buffer = &mod_env);
  di$give_pathname(osnum = mod_env.md_id.osnum,
                   pathname = active_filename);
  _pdm_debug("active_filename = <%s>", active_filename);

  _pdm_debug("checking to see if active file is read-only", 0);
  strcpy(tmp_filename, active_filename + 1);
  PDUfill_in_string(&save_filename, refresh->act_filename);
  PDUfill_in_string(&refresh->act_filename, tmp_filename);
  _pdm_debug("refresh->act_filename = <%s>", refresh->act_filename);

  status = PDUcheck_file_permissions();
  _pdm_status("PDUcheck_file_permissions", status);
  if (!status)
    {
    _pdm_debug("file is read-only; do not prompt to save", 0);
    read_only = TRUE;
    }
  _pdm_debug("resetting refresh->act_filename to <%s>", save_filename);
  PDUfill_in_string(&refresh->act_filename, save_filename);
  if (save_filename)
    free(save_filename);

  if ((strncmp(active_filename, ":PduDummyFile",9) != 0) && (!read_only))
  {
  strcpy(output_var, active_filename);
  prompt_msg = (char *)PDUtranslate_message_and_vars(PDP_P_SAVE_FILE,
                   output_var);
  UI_prompt(prompt_msg);
  do
    {
    status = PDUget_keyin(answer);
    if ( (strcmp(answer, "Y") != 0) &&
         (strcmp(answer, "y") != 0) && (strcmp(answer, "n") != 0) &&
         (strcmp(answer, "N") != 0) && (strcmp(answer, "") != 0) )
         {
         status = PDM_E_INVALID_INPUT;
         }

    else
      status = PDM_S_SUCCESS;
    }

   while (status == PDM_E_INVALID_INPUT);

   UI_prompt("");
   if (strcmp(answer, "") == 0)
     PDUfill_in_string(&PDU_save, "n");
   else
     PDUfill_in_string(&PDU_save, answer);
   }
 else
   {
   PDUfill_in_string(&PDU_save, "n");
   }

  if ((strncmp(active_filename, ":PduDummyFile",9) != 0) && (!read_only))
  {
  if (prompt_msg)
    {
    free(prompt_msg);
    prompt_msg = NULL;
    }
  if ((strcmp(PDU_save, "y") == 0) || (strcmp(PDU_save, "Y") == 0))
    {
    strcpy(output_var, active_filename);
    prompt_msg = (char *)PDUtranslate_message_and_vars(PDP_P_CHECKIN_PART,
                     output_var);
    }
  else
    {
    prompt_msg = (char *)PDUtranslate_message(PDP_P_DELETE_LOCAL);
    }
  UI_prompt(prompt_msg);
  do
    {
    status = PDUget_keyin(answer);
    if ( (strcmp(answer, "Y") != 0) &&
         (strcmp(answer, "y") != 0) && (strcmp(answer, "n") != 0) &&
         (strcmp(answer, "N") != 0) && (strcmp(answer, "") != 0) )
         {
         status = PDM_E_INVALID_INPUT;
         }

    else
      status = PDM_S_SUCCESS;
    }

   while (status == PDM_E_INVALID_INPUT);

   UI_prompt("");
   if (strcmp(answer, "") == 0)
     PDUfill_in_string(&PDU_delete_checkin, "n");
   else
     PDUfill_in_string(&PDU_delete_checkin, answer);
   }
 else
   {
   PDUfill_in_string(&PDU_delete_checkin, "n");
   }

  _pdm_debug("PDU_delete_checkin = <%s>", PDU_delete_checkin);

 if ((strcmp(refresh->rev_parttype, "M") == 0) ||
     (strcmp(refresh->rev_parttype, "m") == 0))
   {
   status = PDM_I_RET_FILE_MACRO;
   PDUmessage(status, 's');
   FIf_display(forms.local_files_form_id);
   return(status);
   }

  status = PDUverify_file( refresh->rev_filename );
  _pdm_status("PDUverify_file", status);

  if ( status != PDM_E_FILE_NULL )
    {
    _pdm_debug("activating file %s", refresh->rev_filename);

    if ( status == PDM_E_FILE_NOT_FOUND )
      {
      _pdm_debug("Case 1", 0);


     stat = PDMcheck_if_checkedin(
                                  refresh->rev_catalog,
                                  refresh->rev_partid,
                                  refresh->rev_revision
                                 );

    _pdm_debug("Status is %d", (char *)stat);

    if ((stat == PDM_E_NOTCHECK_IN) || (stat == PDM_S_SUCCESS) ||
       (stat == PDM_E_PART_CHECKED_OUT) || (stat == PDM_E_ASSEMBLY_CHECKED_OUT))
      {
       _pdm_debug("New part being activated", 0);
       PDUmessage(PDM_I_CREATING_NEW_FILE, 's');
      }

    else
      {
      PDUmessage(stat, 's');
      _pdm_debug("Part can not be activated", 0);
      FIf_display(forms.local_files_form_id);
      return (stat);
      }

    status = PDUseed_form();
    _pdm_status("PDUseed_form", status);

    return(status);
     }

    else
      {
      _pdm_debug("Case 2", 0);

      status = PDUcheck_if_graphic(refresh->rev_filename);
      _pdm_status("PDUcheck_if_graphic", status);

      if (status != PDM_S_SUCCESS)
        {
        status = PDM_I_RET_FILE_ASCII;
        FIf_display(forms.local_files_form_id);
        PDUmessage(status, 's');
        return(status);
        }

      _pdm_debug("Initializing global buffers to NULL", 0);
      if (PDU_detach_buffer)
        {
         status = MEMclose(&PDU_detach_buffer);
         PDU_detach_buffer = NULL;
        }

      if (PDU_attach_buffer)
        {
         MEMclose(&PDU_attach_buffer);
         PDU_attach_buffer = NULL;
        }

      if (PDU_attach_macro_lib)
         PDUfree_attach_mac_list();

      if (PDU_detach_macro_lib)
        {
         MEMclose(&PDU_detach_macro_lib);
         PDU_detach_macro_lib = NULL;
        }


      PDU_parts_id_list = NULL;
      if ((PDU_edit_display) && (PDU_command != PDC_M_CHECKOUT_ACTIVATE))
      {
      responses[0] = EX_CMD_KEY;
      responses[1] = STRING;
      responses[2] = STRING;
      responses[3] = STRING;
      responses[4] = EX_CMD_KEY;

      strings[0] = "PDMnDp";
      strings[1] = refresh->rev_filename;
      strings[2] = PDU_delete_checkin;
      strings[3] = PDU_save;
      strings[4] = "EXRtFl";

      status = PDUprepare_queue ( responses, strings, 5 );
      PDU_command = PDC_M_ACTIVATE_PART;
      }
      else
      {
      responses[0] = STRING;
      responses[1] = STRING;
      responses[2] = STRING;
      responses[3] = EX_CMD_KEY;

      strings[0] = refresh->rev_filename;
      strings[1] = PDU_delete_checkin;
      strings[2] = PDU_save;
      strings[3] = "EXRtFl";

      status = PDUprepare_queue ( responses, strings, 4 );
      PDU_command = PDC_M_ACTIVATE_PART;
      }

     }

  PDU_active_part = TRUE;
  PDU_design_form_display = FALSE;
  status = PDM_S_SUCCESS;
  }
  else
  {
  _pdm_debug("No file assosciated with this part", 0);
   FIf_display(forms.local_files_form_id);
  PDUmessage(PDM_E_NO_PART_FILES, 's');
  }

  return (status);
  }

*/


int PDUcheckout()
{
char    *command_string = NULL;
int     command_type;
int     status = PDM_S_SUCCESS;
char    *msg = NULL;

  _pdm_debug("In the function PDUcheckout", 0);

  _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

  if (PDU_checkout_type == ACT)
    {
    if ((refresh->rev_catalog == NULL) || (strcmp(refresh->rev_catalog, "")==0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_I_ENTER_CATALOG;
      return(status);
      }

    if ((refresh->rev_partid == NULL) || (strcmp(refresh->rev_partid, "") ==0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_I_ENTER_PART;
      return(status);
      }
 
    if ((refresh->rev_revision == NULL) ||
        (strcmp(refresh->rev_revision, "")==0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_I_ENTER_REVISION;
      return(status);
      }

    if ((refresh->rev_filename == NULL) ||
        (strcmp(refresh->rev_filename, "")==0))
      {
      msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_E_ENTER_FILENAME;
      return(status);
      }

    status = PDUext_checkout();
    _pdm_status(" PDUext_checkout (and activate)", 0);

    refresh->status = status;

    if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id))
      {
      FIg_enable(forms.local_files_form_id, CHECKIN_BTN);
      FIg_enable(forms.local_files_form_id, DESIGN);
      FIg_enable(forms.local_files_form_id, REVIEW_DESIGN);
      }
    else
      {
      PDUmessage(status, 's');
      return(status);
      }
    }
  else
    {
    PDUfill_in_string(&command_string, "check out");
    command_type = CHECKOUT;
 

    if ((PDU_structure_list) && (PDU_selected_rows > 1))
      {
      status = PDUcheckout_structure(command_string, command_type);
      _pdm_status("PDUcheckout_structure", status);
      }
    else
      {
      status = PDUcheck_part(command_string, command_type);
      _pdm_status("PDUcheck_part", status);
      }

    if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id))
      {
      FIg_enable(forms.local_files_form_id, CHECKIN_BTN);
      FIg_enable(forms.local_files_form_id, DESIGN);
      FIg_enable(forms.local_files_form_id, REVIEW_DESIGN);
      FIg_enable(forms.local_files_form_id, DELETE_LOCAL_BTN);
      }
    }

   

  return(status);
}  /* end PDUcheckout */




/*********************************************************
* This is the beginning of the State Change Functions
*
*
*********************************************************/


/*********************************************************
* Function: cm_state_notification_routine
* Form notif for move state form
*
*
*
*
***********************************************************/
int cm_state_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int   status = PDM_S_SUCCESS, sts;
  int   select, pos, length, resp;
  int   row = 0;
  int   mcf_select = FALSE;
  int   num_rows = 0;
  short obid_found = FALSE;
  static char *arobid = NULL;
  /*char *msg = NULL; SSR 21 JAN */
  char *errmsg;
  long mesg;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  /*FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING); */

  __DBGpr_com("in cm_state_notification_routine ");
  fp = cm_move_state_form_id; /*??? will become like forms.cm_move_state_form_id */

  switch ( g_label )
  {   

    case FI_CANCEL:     
      PDUmessage(PDM_E_CMD_CANCELLED, 's');

      _pdm_debug("User selected the cancel button", 0);
                               
      if (CM_state_form_displayed == TRUE)
        FIf_erase( fp );
      if (CM_state_form_created == TRUE)
        FIf_delete( fp );

      CM_state_form_displayed = FALSE;
      CM_state_form_created = FALSE;

      if(PDU_state_form_created == TRUE)
      {
      FIf_display(forms.move_state_form_id);
      FIg_disable( forms.move_state_form_id, FI_EXECUTE );
      PDU_state_form_created = TRUE;
      }
      if(PDU_mcf_list_displayed == TRUE)
      {
        FIg_disable(forms.mcf_list_form_id, FI_ACCEPT );
      }
      

      if(IsPmeEnabled() == TRUE && ForceConn()==1)
      {
           status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
          if ( !status)
          {
            EnablePME(0);
            UI_status("Disconnected From AIM server");
          }
      }
      ChkOK = 0;
      resp = EX_FORM_FINISHED;
      ex$putque( msg = &mesg,
                 response = &resp);

      break; 


    case FI_EXECUTE:

      ChkOK = 0;  // Do not allow move to checking
      _pdm_debug("User selected the execute button", 0);

      _pdm_debug("User selected the Checking state.", 0);

      _pdm_debug("getting the AR Obid", 0);
      FIfld_get_num_rows(fp, CP_ARTBL, &num_rows);
      _pdm_debug("num_rows = %d", (char *)num_rows);
      /*FImcf_set_active_col(fp, AROBID, 0, 0);*/
      if(PDU_state_form_created == TRUE)
        FIg_disable( forms.move_state_form_id, FI_EXECUTE );
      if(PDU_mcf_list_displayed == TRUE)
        FIg_disable(forms.mcf_list_form_id, FI_ACCEPT );
 
      for (row = 0; row < num_rows; ++row)
      {
        FIfld_get_select(fp, CP_ARTBL, row, 0, &mcf_select);
        if (mcf_select)
        {
           FIfld_get_text_length(fp,CP_ARTBL,row, CP_C_OBID, &length);
           arobid = (char *) malloc (sizeof (char) * length + 1);
           memset(arobid, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp, CP_ARTBL, row, CP_C_OBID, length, 
				(unsigned char *)arobid, &select, &pos);

           if (strcmp(arobid, "") == 0)
           {
             /* if FIRST row is selected, 
              * Update the DCC variable to TRUE */
             _pdm_debug("no state selected", 0);
	     /* SSR 21 JAN
             PDUmessage(PDM_E_SELECT_STATE, 's');
             msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE); */
             /*FIg_set_text(fp, FI_MSG_FIELD, msg);*/
             break;
           }
           _pdm_debug("arobid = <%s>", arobid);
           /* Go to Aim for every row and update relns. */
           if(PDU_state_form_created == TRUE)
             FIg_enable( forms.move_state_form_id, FI_EXECUTE );
           if(PDU_mcf_list_displayed == TRUE)
             FIg_enable(forms.mcf_list_form_id, FI_ACCEPT );
           __DBGpr_str("AROBID", arobid );
	   status = CMChangeARState( arobid, CHECKING );
           /* If not success; disable the execute button from move state form,
            * show status in msg field. */
           if(status)
           {
             if(PDU_state_form_created == TRUE)
             {
               FIg_disable( forms.move_state_form_id, FI_EXECUTE );
               FIg_set_text(forms.move_state_form_id, FI_MSG_FIELD, 
                            "Could not change AR status in AIM" );
             }
             if(PDU_mcf_list_displayed == TRUE)
             {
               FIg_disable( forms.mcf_list_form_id, FI_ACCEPT );
               FIg_set_text(forms.mcf_list_form_id, FI_MSG_FIELD, 
                            "Could not change AR status in AIM" );
             }
           }
	   ChkOK = 1; // Ahanged AR state; allowe move state

	 }
       }

       FIf_erase( fp );
       /* if (CM_state_form_created == TRUE) */
       FIf_delete( fp );

       CM_state_form_displayed = FALSE;
       CM_state_form_created = FALSE;

       FIf_display(forms.move_state_form_id);
       PDU_state_form_created = TRUE;
       /* PDU_local_files_displayed = TRUE; */

       if(IsPmeEnabled() == TRUE)
       {
         if(ForceConn() ==1)
         {
           status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
           if ( !status)
           {
             EnablePME(0);
             UI_status("Disconnected From AIM server");
           }
         }
       }
      //ChkOK = 1;
      resp = EX_FORM_FINISHED;
      ex$putque( msg = &mesg,
                 response = &resp);
       break; 
  } /* END switch ( g_label ) */

  return status;

} /* END cm_notification_routine() */



/*********************************************************
* Function: state_notification_routine
* Move state form by PDU, override state btn for CM AIM 
*
*
*
*
***********************************************************/
int state_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int     status = PDM_S_SUCCESS;
  int     select, pos, length;
  int     row = 0;
  int     mcf_select = FALSE;
  int     num_rows = 0;
  int     num_rows2 = 0;
  int     column = 0, response;
  short   found = FALSE;
  short   state_found = FALSE;
  short   row_deleted = FALSE;
  static char *text = NULL;
  static char *state = NULL;
  char    *msg = NULL;
  char    *catalog = NULL;
  char    *partid = NULL;
  char    *revision = NULL;
  extern void PDUselect_row_in_list_mcf();
  char response_data[50], w_flow[20];

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  fp = forms.move_state_form_id;

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
         value = 0.0;

         _pdm_debug ("User selected the HELP button", 0);
         if (PDU_state_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.move_state_form_id);
           PDU_state_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         Help_topic("movestate");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
         PDUmessage(PDM_E_CMD_CANCELLED, 's');

         _pdm_debug("User selected the cancel button", 0);

         if (PDU_state_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_state_form_created == TRUE)
           FIf_delete( fp );

         PDU_state_form_displayed = FALSE;
         PDU_state_form_created = FALSE;
         PDU_state_perm_window = FALSE;

         if (PDU_acl_list)
           {
           _pdm_debug("freeing PDU_acl_list", 0);
           status = PDUfree_acl_structure(&PDU_acl_list);
           _pdm_status("PDUfree_acl_structure", status);
           PDU_acl_group_list = NULL;
           }
         if (PDU_acl_group_list)
           {
           _pdm_debug("freeing PDU_acl_group_list", 0);
           status = PDUfree_acl_structure(&PDU_acl_group_list);
           _pdm_status("PDUfree_acl_structure", status);
           PDU_acl_group_list = NULL;
           }

         FIf_display(forms.local_files_form_id);
         PDU_local_files_displayed = TRUE;

         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */
 
         value = 0.0;
         f_label = 0;
  
         PDU_state_perm_window = TRUE;
         break;

    case FI_EXECUTE:

         _pdm_debug("entering EXECUTE button", 0);

         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         found = FALSE;
         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (mcf_select)
              {
              found = TRUE;
              break;
              }
            }
/*
         if (found == FALSE)
           {
           PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           }
*/

         if (found)
           {
           _pdm_debug("checking for to-state", 0);
           FIfld_get_num_rows(fp, NEW, &num_rows2);
           _pdm_debug("num_rows2 = %d", (char *)num_rows2);
           FImcf_set_active_col(fp, NEW, 0, 0);
  
           state_found = FALSE;
           for (row = 0; row < num_rows2; ++row)
              {
              FIfld_get_select(fp, NEW, row, 0, &mcf_select);
              if (mcf_select)
                {
                state_found = TRUE;
                FIfld_get_text_length(fp, NEW, row, 0, &length);
                state = (char *) malloc (sizeof (char) * length + 1);
                memset(state, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, NEW, row, 0, length,
                              (unsigned char *)state, &select, &pos);
                _pdm_debug("state = <%s>", state);
  
                if (strcmp(state, "") == 0)
                  {
                  _pdm_debug("no state selected", 0);
                  PDUmessage(PDM_E_SELECT_STATE, 's');
                  msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE);
                  FIg_set_text(fp, FI_MSG_FIELD, msg);
                  break;
                  }

		/* TLS set the CMstate value*/
		CMstate = (char *)malloc (sizeof (char) * length + 1 );
		strcpy(CMstate, state );

                }
              }
           if (!state_found)
             {
             PDUmessage(PDM_E_SELECT_STATE, 's');
             msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             break;
             }
           }

         _pdm_debug("deleting non-selected rows", 0);
         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         row_deleted = 0;

         for (row = 0; row <= num_rows; ++row)
            {
            if (row_deleted)
              --row;
            row_deleted = 0;
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (!mcf_select)
              {
              row_deleted = 1;
              for (column = 0; column < 3; ++column)
                {
                FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, PARTS_MCF, row, column, 
                               length, (unsigned char *)text, &select, &pos);
 
                if (column == 0)
                  {
                  PDUfill_in_string(&catalog, text);
                  _pdm_debug("catalog = <%s>", catalog);
                  }
                else if (column == 1)
                  {
                  PDUfill_in_string(&partid, text);
                  _pdm_debug("part num = <%s>", partid);
                  }
                else if (column == 2)
                  {
                  PDUfill_in_string(&revision, text);
                  _pdm_debug("revision = <%s>", revision);
                  }
                }
              _pdm_debug("deleting row %d", (char *)row);
              FIfld_delete_rows(fp, PARTS_MCF, row, 1);
              FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
              FIfld_set_num_rows(fp, PARTS_MCF, num_rows);
              _pdm_debug("num_rows = %d", (char *)num_rows);
              _pdm_debug("active row = %d", (char *)row);

              _pdm_debug("moving row to end of acl_list",0);
              status = PDUremove_node_from_group_list(catalog, partid,
                                                      revision);
              _pdm_status("PDUremove_node_from_group_list", status);
                 
              }
            }

         _pdm_debug("processing selected rows", 0);
         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         FImcf_set_active_col(fp, PARTS_MCF, 0, 0);

         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (mcf_select)
              {
              for (column = 0; column < 4; ++column)
                {
                FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, PARTS_MCF, row, column, length,
                              (unsigned char *)text, &select, &pos);

                if (column == 0)
                  {
                  PDUfill_in_string(&refresh->rev_catalog, text);
                  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                  }
                else if (column == 1)
                  {
                  PDUfill_in_string(&refresh->rev_partid, text);
                  _pdm_debug("part num = <%s>", refresh->rev_partid);
                  }
                else if (column == 2)
                  {
                  PDUfill_in_string(&refresh->rev_revision, text);
                  _pdm_debug("revision = <%s>", refresh->rev_revision);
                  }
                else if (column == 3)
                  {
                  PDUfill_in_string(&refresh->rev_description,text);
                  _pdm_debug("description = <%s>",refresh->rev_description);
                  }
                }

              _pdm_debug("calling move to next state", 0);

              /* slj - Here is one potential place for AII code */
              /* add the CM stuff as a seperate function and check */
              /* the return status before calling PDUmulti_move_state(state)*/

              /* SSR */
          /* Depending on State call CM functions */
          /*printf("\n to call CMmake_transition");
          status = CMmake_transition();*/
          __DBGpr_str("state", CMstate);
	   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
	   __DBGpr_str( " w_flow ", w_flow);
	   // TR1364 follow CM changes only for AVD_CM_W_FLOW
	   // SSR 7 SEP
	   //if(!strcmp(w_flow, AVD_CM_WFLOW))
	   if(!strcasecmp(w_flow, "Y"))
	   {
          if(!strcmp(CMstate, DEVELOPMENT))
          {
            status = CMReject();
            if(status)
            {
              UI_status("Couldnot Change AR States in AIM.");
              break;
            }
          }
          if(!strcmp(CMstate, BASELINE))
          {
            status = CMBaseline();
            if(status)
            {
              UI_status("Couldnot Baseline M D C.");
              break;
            }
          }
          if(!strcmp(CMstate, RELEASE))
          {
            status = CMRelease();
            if(status)
            {
              UI_status("Couldnot Revise M D C.");
              break;
            }
          }
          if(!strcmp(CMstate, CHECKING))
          {
            status = CMstate_form();
            do
            {
              ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
            } while( response != EX_FORM_FINISHED );
            if(ChkOK == 0)
            {
              UI_status("Couldnot move to Checking.");
              break;
            }
          }
	  }// END TR 1364 SSR 7 SEP
              __DBGpr_com("in PDUmulti_move_state");
              status = PDUmulti_move_state(state);
              _pdm_status("PDUmulti_move_state", status);

              PDUmessage(status, 's');
              } 
            }

         _pdm_debug("checking for failure", 0);
         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (mcf_select)
              {
              PDUmessage(PDM_E_NOT_TRANSITIONED, 's');
              break;
              }
            }

         if (PDU_acl_list)
           {
           status = PDUfree_acl_structure(&PDU_acl_group_list);
           _pdm_status("PDUfree_acl_structure", status);
           PDU_acl_group_list = NULL;

           /* allow user time to read any error messages */
           sleep(2);
           for (row = 0; row < num_rows; ++row)
              for (column = 0; column < 4; ++column)
                 FIfld_set_text(forms.move_state_form_id, PARTS_MCF, row,
                                column, "", FALSE);

           status = PDUgroup_parts_for_transition();
           _pdm_status("PDUgroup_parts_for_transition", status);

           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           status = PDUload_move_state_form();
           _pdm_status("PDUload_move_state_form", status);
           }
         else
           {
           _pdm_debug("all parts have been moved; exiting", 0);

           if (PDU_acl_group_list)
             {
             status = PDUfree_acl_structure(&PDU_acl_group_list);
             _pdm_status("PDUfree_acl_structure", status);
             PDU_acl_group_list = NULL;
             }

           if (PDU_state_form_displayed == TRUE)
             FIf_erase( fp );
           if (PDU_state_form_created == TRUE)
             FIf_delete( fp );
  
           PDU_state_form_displayed = FALSE;
           PDU_state_form_created = FALSE;
           PDU_state_perm_window = FALSE;

           /*           
           FIf_display(forms.local_files_form_id);
           PDU_local_files_displayed = TRUE;
           */
           }

         break;

    case CURRENT:   /* READ ONLY FIELD */
         break;

    case NEW:

         _pdm_debug("entering NEW listing field", 0);

         FIfld_get_num_rows(fp, NEW, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         FImcf_set_active_col(fp, NEW, 0, 0);

         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, NEW, row, 0, &mcf_select);
            if (mcf_select)
              {
              FIfld_get_text_length(fp, NEW, row, 0, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, NEW, row, 0, length,
                            (unsigned char *)text, &select, &pos);
              _pdm_debug("text = <%s>", text);
	      CMstate = (char *)malloc (sizeof (char) * length + 1 );
              strcpy(CMstate, text);

              if (strcmp(text, "") == 0)
                {
                _pdm_debug("text field is empty", 0);
                break;
                }
              }
            }
          /*
          *printf("\n CAT %s, PART %s, REV %s, STATE %s", 
          *          refresh->rev_catalog, refresh->rev_partid,
          *          refresh->rev_revision, CMstate );
          */
          /*if(!strcmp(CMstate, CHECKING))
          *{
          *  FIg_disable(fp, FI_EXECUTE );
          *  status = CMstate_form();
          *  if(status)
          *    FIg_disable(fp, FI_EXECUTE );
          *}
          * Moved to execute */
         break;

    case SELECT:

         _pdm_debug("entering SELECT button", 0);

         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);

         for (row = 0; row < num_rows; ++row)
            FImcf_set_select(fp, PARTS_MCF, row, TRUE);

         break;

    case DESELECT:

         _pdm_debug("entering DESELECT button", 0);

         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);

         for (row = 0; row < num_rows; ++row)
            FImcf_set_select(fp, PARTS_MCF, row, FALSE);

         break;

    case PARTS_MCF:

         _pdm_debug("entering PARTS_MCF", 0);

         FIfld_get_active_row(fp, PARTS_MCF, &row, &pos);
         FImcf_set_active_col(fp, PARTS_MCF, 0, 0);
         FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
         _pdm_debug("active row = %d", (char *)row);

         _pdm_debug("getting part information", 0);
         for (column = 0; column < 3; ++column)
           {
           FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp, PARTS_MCF, row, column, length,
                         (unsigned char *)text, &select, &pos);

           if (column == 0)
             {
             PDUfill_in_string(&catalog, text);
             _pdm_debug("catalog = <%s>", catalog);
             }
           else if (column == 1)
             {
             PDUfill_in_string(&partid, text);
             _pdm_debug("part num = <%s>", partid);
             }
           else if (column == 2)
             {
             PDUfill_in_string(&revision, text);
             _pdm_debug("revision = <%s>", revision);
             }
           }

         _pdm_debug("finding matching row on main form", 0);
         if (PDU_mcf_list)
           PDUselect_row_in_list_mcf(catalog, partid, revision, mcf_select);

         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */


/*********************************************************
* Function: PDUstate_form
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/

int PDUstate_form()
{
  int  sts = PDM_S_SUCCESS;

  PDU_acl_list = NULL;
  PDU_acl_group_list = NULL;

  __DBGpr_com("in PDUstate_form" );
  if ((PDU_parts_list_bufr) && (PDU_selected_rows > 0))
    {
    sts = PDUprocess_state_form_parts();
    _pdm_status("PDUprocess_state_form_parts", sts);
    }
  else
    {
    sts = PDUprocess_individual_state_form_part(refresh->rev_catalog,
						refresh->rev_partid,
						refresh->rev_revision,
						refresh->rev_description,
						refresh->rev_filename,
						refresh->rev_parttype);
    _pdm_status("PDUprocess_individual_state_form_part", sts);
    }

  if (sts != PDM_S_SUCCESS)
    return(sts);

  if (!PDU_acl_group_list)
    {
    _pdm_debug("acl_list is empty", 0);
    return(PDM_S_SUCCESS);
    }

  if (PDU_state_form_created == TRUE)
    {
    _pdm_debug("form has already been created", 0);
    return(PDM_S_SUCCESS);
    }

  PDU_state_form_created = FALSE;
  PDU_state_form_displayed = FALSE;
  PDU_state_perm_window = FALSE;

  sts = FIf_new(MOVE_STATE_FORM, "movestate", state_notification_routine,
                &forms.move_state_form_id);


  _pdm_debug("Creating state form", 0);
  PDU_state_form_created = TRUE;

  if (PDU_acl_group_list)
    {
    _pdm_debug("loading parts into form", 0);
    sts = PDUload_move_state_form();
    _pdm_status("PDUload_move_state_form", sts);
    if (sts != PDM_S_SUCCESS)
      {
      FIf_delete(forms.move_state_form_id);
      PDU_state_form_created = FALSE;
      PDU_state_form_displayed = FALSE;
      PDU_state_perm_window = FALSE;
      return(sts);
      }
    }

  FIf_erase(forms.local_files_form_id);
  PDU_local_files_displayed = FALSE;

  /* Display the state form and set the displayed state to TRUE. */
  _pdm_debug("Displaying the state form", 0);

  sts = FIf_display(forms.move_state_form_id);
  PDU_state_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  return(PDM_S_SUCCESS);
}


/*********************************************************
* Function: CMChangeARState
*
* Send a command to AIM to change the state of the AR.
*
***********************************************************/
int CMChangeARState( arobid, arstate )
	char *arobid;
	char *arstate;
{
  int status = 0;
  int inlen=0; 
  int index=0;
  int outlen=0; 
  int code=0; 
  int dstat=0; 
  int mfail=0, i, response;
  char inbuf[512], response_data[50]; 
  char *errmsg=NULL;
  char *outbuf=NULL;

  /* Now fill the postman buffer with the 
   	1. code
   	2. catalog
  	3. part number
	4. revision 
	5. AR Obid
   */

  if( IsPmeEnabled() == FALSE )
  {
    status = CMAimConnect();
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
    } while( response != EX_FORM_FINISHED );
  }

  if( IsPmeEnabled() == FALSE )
  {
    status =1;
    return status;
  }

  code = 133; /* VDP_MAKE_AR_CHECKING;  133 */
  inlen = 0;
  index = 0;
/* inbuf is arobid-cat-part-rev */
  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;

  strcpy( &inbuf[index], arobid );
  inlen += strlen(arobid) +1;
  index = inlen;
  
  strcpy( &inbuf[index], refresh->rev_catalog );
  inlen += strlen(refresh->rev_catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_partid );
  inlen += strlen(refresh->rev_partid) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_revision );
  inlen += strlen(refresh->rev_revision) +1;
  index = inlen;

  __DBGpr_com("making VDP_MAKE_AR_CHECKING ");
  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

  if(dstat != 0)
  {
    if(dstat == 12345)
      UI_status("AIM connection was reset by server.");
    if(errmsg) __DBGpr_str("errmsg", errmsg );
       	status = 1;
    return status;
  }

  if (mfail != 0 )
  {
  	if(*errmsg)
  	{
              __DBGpr_str("ERROR 1 ", errmsg );
        }
        status = mfail;
        return status;
  }

  if(IsPmeEnabled() == TRUE)
  {
    
    status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                &errmsg);
    if ( !status)
      EnablePME(0);
    UI_status("Disconnected From AIM server");
  }


  return status;

}



/*********************************************************
* Function: CMmake_transition
*
*
*
***********************************************************/
int CMmake_transition()
{
  int  sts = 0;

  printf("\n in CMmake_transition");
  /* TLS 
    1. Check the CMEnabled Flag to see if we 
       can Configuration Manage the file. 
    2. Also check the state   SSR
    3. Must to check AIM connection.
   */
  /* if( CMenable == TRUE ) this attribute name may change 
   * It is better to see if the MDC exists for the file if yes proceed 
   * else return success.*/
 
    if(!strcmp(CMstate, CHECKING ))
      sts = CMstate_form(); 
    printf("\n sts after checking %d", sts);

    if(!strcmp(CMstate, BASELINE))
      sts = CMBaseline();
    printf("\n sts after baseline %d", sts);

    if(!strcmp(CMstate, RELEASE))
      sts = CMRelease();
    printf("\n sts after release %d",sts);

  return sts;

}

/*********************************************************
* Function: CMGetArs
*
*
*
***********************************************************/
int CMGetArs( catalog, partno, rev, aimcode, outbuf )
  char *catalog;
  char *partno;
  char *rev;
  int  aimcode;
  char **outbuf;
{
  int status = 0;
  int inlen=0;
  int outlen=0;
  int code=0;
  int dstat=0;
  int mfail=0;
  int index=0, index1=0, numARs=0, response=0;
  int i = 0;
  char inbuf[512], response_data[50];
  char *errmsg=0;


   /*
     Send Cmd to AIM through Postman to:
     1. fill the in buffer with the code ( =  )
     2. fill the in buffer with the catalog, partno and rev

    */

   __DBGpr_com("CMGetArs START");
    if( IsPmeEnabled() == FALSE )
    {
      status = CMAimConnect();
      do
      {
        ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
      } while( response != EX_FORM_FINISHED );
    }
    if( IsPmeEnabled() == FALSE )
    {
      status = 1;
      return status;
    }

     code = aimcode;
    //printf("\n I am in here with code %d, cAT %s, part %s",code,catalog,partno);

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     strcpy( &inbuf[index], catalog );
     inlen += strlen(catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], partno );
     inlen += strlen(partno) +1;
     index = inlen;

     strcpy( &inbuf[index], rev );
     inlen += strlen(rev) +1;
     index = inlen;

    /*__DBGpr_int("inlen ", inlen);*/
    /* printf("inlen %d", inlen);*/

    UI_status( "Querying AIM database for ARs..." );
    __DBGpr_com("Sending the VDP_GET_AR command to AIM.");

    /*for ( i=0;i<inlen;i++)
     printf(" %c", inbuf[i]);*/

     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   outbuf, &mfail, &errmsg);

     /*__DBGpr_int("dstat ", dstat); */
     if(dstat != 0)
     {
       /*__DBGpr_int("dstat is bad. dstat ", dstat);*/
       if(dstat == 12345)
         UI_status("AIM connection reset by server.");
       __DBGpr_int("dstat is bad. dstat", dstat);
       __DBGpr_str("errmsg", errmsg );
       UI_status( "Couldnot Query AIM database for ARs." );
       status = 1;
       return status;
     }

     if (mfail != 0 )
     {
       if(errmsg)
       {
         /*__DBGpr_str("errmsg ", errmsg);*/
         __DBGpr_str("errmsg", errmsg);
       }
       __DBGpr_int("mfail is bad.  mfail ", mfail);
       UI_status( "Couldnot Query AIM database for ARs." );
       status = 1;
       return status;
     }
    UI_status( "" );

  memcpy( &numARs, outbuf[0], sizeof(int));
  __DBGpr_int( "number of Wroking ARs found is ", numARs );

  __DBGpr_com("CMGetArs END");
return 0;


}


/*********************************************************
* Function: CMstate_form
*
* This function loads/creates, initializes, and displays 
* the form displays the list of working ARs when a user tries to select a state
*
*
***********************************************************/
int CMstate_form()
{
  int  sts = 0, resp;
  char *outbuf = NULL;
  int  numARs = 0, index1=0, i=0, response;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[5], response_data[50], IsSuper[20];
  long msg;

  CM_state_form_created = FALSE;
  CM_state_form_displayed = FALSE;
  CM_state_perm_window = FALSE;

  __DBGpr_com("START CMstate_form");
  /*printf("\n CAT %s, PART %s, REV %s", refresh->rev_catalog, 
         refresh->rev_partid, refresh->rev_revision);*/

  sts = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                       refresh->rev_revision, ARsel, CMmng,
		       DCCsel, Mdc, IsSuper);
  if(sts)
  {
    __DBGpr_com("couldnot get CM attrs.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    return 1;
  }

  //printf("\n ar %s, cm %s, dcc %s", ARsel, CMmng, DCCsel );
    /* If File is not CM managed, don'n go to aim and get ARs */
  if(strcmp(CMmng, "Y"))
  {
    __DBGpr_com("File is not CM managed.");
    if(PDU_state_form_created == TRUE)
      FIg_enable( forms.move_state_form_id, FI_EXECUTE );
    if(PDU_mcf_list_displayed == TRUE)
        FIg_enable(forms.mcf_list_form_id, FI_ACCEPT );
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 1;
    return 0;
  }

  if(CMstate) __DBGpr_str("STATE", CMstate );

  /* If these revisions are correct, 
   * send them to SIR and get list of Working ARs, 
   * function GetARs() with proper code  Get list from SIr and populate form
   */

  if(strcmp(Mdc, "Y"))
  {
    UI_status("DAD information incorrect; Post the file.");
    __DBGpr_com("M D C doesn't exist.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    return 1;
  }
  if(strcmp(ARsel, "Y") && strcmp(DCCsel, "N") )
  {
    UI_status("No ARs selected; Cannot change state.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
              response = &resp);
    ChkOK = 0;
    return 1;
  }
    /* Check for AIM conenction */
  if(IsPmeEnabled()==FALSE)
  {
   sts = CMAimConnect();
   do
   {
     ex$wait_for_input( response = &response,
                        buffer = response_data,
                        mode = EX_ALL_ASCII_MODE,
                        byte = &sts );
   } while ( response != EX_FORM_FINISHED );

  }

  if(IsPmeEnabled() == FALSE)
  {
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    return 0;
  }

  sts = FIf_new(CM_MOVE_STATE_FORM, "CMMvSt.frm", 
                cm_state_notification_routine, &cm_move_state_form_id);
  if(cm_move_state_form_id == NULL)
  {
    printf("\nCould not Create form <CMMvSt.frm>.");
    return 1;
  }

    UI_status("Getting ARs from AIM. . .");
    sts = CMGetArs ( refresh->rev_catalog, refresh->rev_partid, 
                     refresh->rev_revision , VDP_GET_WORKING_ARS, &outbuf);
    if( sts )
    {
         resp = EX_FORM_FINISHED;
         ex$putque( msg = &msg,
                    response = &resp);
      return sts;
    }

  /* extract outbuf */
    memcpy( &numARs, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);
    __DBGpr_int("1. no of ars ", numARs );

    if(numARs)
    {
 /* Set the nos of rows = numARs extra for the default entry */
      FIfld_set_num_rows( cm_move_state_form_id, CP_ARTBL, numARs );

      for ( i=0; i<numARs; i++)
      {
        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_ARNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_AIRNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_AIRREV, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                  i, CP_C_FMRNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_FMRREV, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_TIT, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_DATE, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_OBID, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

      }
      FIfld_set_text( cm_move_state_form_id, 9, 0, 0, 
                    "Select ARs to move the state.", FALSE );
    }

  _pdm_debug("Creating CM state form", 0);
  CM_state_form_created = TRUE;
  /*
  * if (PDU_acl_group_list)
  *  {
  *  _pdm_debug("loading ARs into CM form", 0);
  *   sts = CMload_move_state_form();
  *  _pdm_status("CMload_move_state_form", sts);
  *  if (sts != PDM_S_SUCCESS)
  *    {
  *    FIf_delete(cm_move_state_form_id);
  *    CM_state_form_created = FALSE;
  *    CM_state_form_displayed = FALSE;
  *    CM_state_perm_window = FALSE;
  *    return(sts);
  *    }
  *  }
  **/
  /*FIf_erase(forms.local_files_form_id);
   * PDU_local_files_displayed = FALSE;
   **/

  /* Display the state form and set the displayed state to TRUE. */
  _pdm_debug("Displaying the CM state form", 0);

  sts = FIf_display(cm_move_state_form_id);
  CM_state_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  if(outbuf) free(outbuf);
  return(0);
}

/*********************************************************
* Function: CMload_move_state_form
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
void CMload_move_state_form()
{

  int i=0;
  int status = 0;
  int numARs = 0;
  int index1 = 0;
  char *outbuf = NULL;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0;
  char inbuf[512]; 
  char *errmsg=NULL;


  /* TLS
     1. Query AIM for the list of ARs Working to show on this form.
     	Use the catalog, partno and revision to get the MDC object,
	then use the MDC object to find the related ARs.

     2. When the AIM Outbuffer returns, parse the buffer to get
	the list of ARs and display the list on the form.
   */


   __DBGpr_com("in CMload_move_state_form");
  /* call the function to query AIM */
  status = CMGetArs(&outbuf);

  /* check the status */

  /* parse the buffer for the number of ARs being displayed */
  memcpy( &numARs, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);

  /* parse the buffer for the list of ARs and add to form */
  for ( i = 0; i < numARs; i++ )
  {

    /* store the results on the form */
    _pdm_debug("writing to Change Promotion", 0);

    _pdm_debug("AR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, ARNUM, i, 0,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("AIR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, AIRNUM, i, 1,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("AIR Revision = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, AIRREV, i, 2,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("FMR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, FMRNUM, i, 3,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("FMR Revision = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, FMRREV, i, 4,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("Title = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, TITLE, i, 5,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("Creation Date = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, CREDATE, i, 6,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("OBID = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, AROBID, i, 7,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

  }

/* Change the AR relaiton ship to checking */
  code = 133; /*VDP_MAKE_AR_CHECKING;  122*/

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_catalog );
     inlen += strlen(refresh->rev_catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_partid );
     inlen += strlen(refresh->rev_partid) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_revision );
     inlen += strlen(refresh->rev_revision) +1;
     index = inlen;



     __DBGpr_com("trying to talk with AIM");
     UI_status("Changing AR MDC relations in AIM");
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     if(dstat != 0)
     {
       if(dstat == 12345)
         UI_status("AIM connection reset by server.");
       status = 1;
     }

     if (mfail != 0 )
     {
       if(errmsg)
       {
        __DBGpr_str("ERROR 2 %s", errmsg );
       }
       status = mfail;
     }
/*
  for ( i = 0; i < *numARs; i++ )
  {
  	(*ARItm)[i].ARNo[0] = '\0';
        (*ARItm)[i].AIRNo[0] = '\0';
        (*ARItm)[i].AIRRev[0] = '\0';
        (*ARItm)[i].FMRNo[0] = '\0';
        (*ARItm)[i].FMRRev[0] = '\0';
        (*ARItm)[i].Title[0] = '\0';
        (*ARItm)[i].ChgState[0] = '\0';
        (*ARItm)[i].CreDate[0] = '\0';
        (*ARItm)[i].Obid[0] = '\0';

        strcpy((*ARItm)[i].ARNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].ARNo) +1;

        strcpy((*ARItm)[i].AIRNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].AIRNo) +1;

        strcpy((*ARItm)[i].AIRRev, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].AIRRev) +1;

        strcpy((*ARItm)[i].FMRNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].FMRNo) +1;

        strcpy((*ARItm)[i].FMRRev, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].FMRRev) +1;

        strcpy((*ARItm)[i].Title, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].Title) +1;

        strcpy((*ARItm)[i].ChgState, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].ChgState) +1;


        strcpy((*ARItm)[i].CreDate, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].CreDate) +1;


        strcpy((*ARItm)[i].Obid, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].Obid) +1;

  }
*/

}
/************************************************************
* Function CMReject
* IF a state is back to development, change the ARs selcted to WORKING
***************************************************/
int CMReject()
{
  int status = 0, sts=0;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0, response=0;
  char inbuf[512]; 
  char *errmsg=NULL, *outbuf =NULL;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[2], response_data[50], IsSuper[20];

  __DBGpr_com("BEGIN CMReject");

  status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                          refresh->rev_revision,
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  //printf("\n CMattrs are CMmng %s, Mdc %s, ARsel %s", CMmng, Mdc, ARsel);
  if(strcmp(CMmng, "Y"))
  {
    status =0;
    goto wrapup;
  }
  if(strcmp(Mdc, "Y"))
  {
    UI_status("File was not Posted.");
    status = 1;
    goto wrapup;
  }
  if(strcmp(ARsel, "Y"))
  {
    status =0;
    goto wrapup;
  }
  /*Establish AIM connection */
  if( IsPmeEnabled() == FALSE )
  {
    status = CMAimConnect();
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
    } while( response != EX_FORM_FINISHED );
  }
  if(IsPmeEnabled() == FALSE)
  {
    status = 1;
    UI_status("Not Connected to AIM.");
    goto wrapup;
  }
  code = 137; /*VDP_BASELINE_MDC;  122*/

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  /* inbuf cat-part-rev  */
  strcpy( &inbuf[index], refresh->rev_catalog );
  inlen += strlen(refresh->rev_catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_partid );
  inlen += strlen(refresh->rev_partid) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_revision );
  inlen += strlen(refresh->rev_revision) +1;
  index = inlen;

  __DBGpr_com("trying to talk with AIM ");
  UI_status("Changing AR relationships in AIM.");
  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

  //printf("\n dstat %d, mfail %d", dstat, mfail);
  if(dstat != 0)
  {
    if(dstat == 12345)
      UI_status("AIM connection reset by server.");
    if(errmsg) __DBGpr_str("errmsg ", errmsg );
    UI_status("Could not change AR relationships in AIM.");
    status = 1;
    goto wrapup;
  }

  if (mfail != 0 )
  {
    if(errmsg) __DBGpr_str("ERROR %s", errmsg );
    UI_status("Could not change AR relationships in AIM.");
    status = 1;
    goto wrapup;
  }

wrapup:
  if(IsPmeEnabled() == TRUE)
  {
    if(ForceConn() == 1)
    {
    sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
    if ( !sts)
      {
      EnablePME(0);
    UI_status("Disconnected From AIM server");
      }
    }
  }
  __DBGpr_com("END CMReject.");
  //SSR 21 JAN
  if(errmsg) free(errmsg);
  if(outbuf) free(outbuf);
  return status;
}

/**********************************************************
* Function CMBaseline
* if file is CMEnabled, 1. baseline MDC, 2. Change the relation
* If not ; Just baseline the MDC
**********************************************************/

int CMBaseline()
{
  int status = 0, sts=0;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0, response=0;
  char inbuf[512]; 
  char *errmsg=NULL, *outbuf =NULL;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[2], response_data[50], IsSuper[20];

  __DBGpr_com("PDUaim_cm.c.CMBaseline START ");
  /* Check for MDC existance */

  status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                          refresh->rev_revision,
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  /* No movement to Baseline if PART is Superseeded */
  if(!strcasecmp(IsSuper, "Y"))
  {
    UI_status("Part is superseded; Cannot change state of the part.");
    status = 1;
    goto wrapup;
  }
  if(strcmp(Mdc, "Y"))
  {
    status =0;
    goto wrapup;
  }
  if( IsPmeEnabled() == FALSE )
  {
    status = CMAimConnect();
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
    } while( response != EX_FORM_FINISHED );
  }
  if(IsPmeEnabled() == FALSE)
  {
    status = 1;
    goto wrapup;
  }

  code = 122; /*VDP_BASELINE_MDC;  122*/

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  /* inbuf cat-part-rev  */
  strcpy( &inbuf[index], refresh->rev_catalog );
  inlen += strlen(refresh->rev_catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_partid );
  inlen += strlen(refresh->rev_partid) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_revision );
  inlen += strlen(refresh->rev_revision) +1;
  index = inlen;

  __DBGpr_com("trying to talk with AIM for VDP_BASELINE_MDC");
  UI_status("Baselining M D C in AIM.");
  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

  if(dstat != 0)
  {
    if(dstat == 12345)
      UI_status("AIM connection reset by server.");
    if(errmsg) __DBGpr_str("errmsg ", errmsg );
    UI_status("Could not baseline M D C.");
    status = 1;
    goto wrapup;
  }

  if (mfail != 0 )
  {
    if(errmsg)
    {
      __DBGpr_str("ERROR 2 ", errmsg );
    }
    status = mfail;
    UI_status("Could not baseline M D C.");
    status = 1;
    goto wrapup;
  }
  /* Create buffer for updating relations  do this only if file is CMEnabled*/

  /* If the file is CM managed, change the AR MDC relation in AIM to 
   * RELEASED */

  if( strcmp( CMmng, "Y" ))
  {
    status =  0;
    goto wrapup;
  }

  if(!strcmp(ARsel, "Y"))
  {
    inlen = 0;
    index = 0;
    *inbuf = NULL;
    code = VDP_MAKE_AR_RELEASED; /* 134 */

    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* inbuf arobid-cat-part-rev */
    strcpy( &inbuf[index], refresh->rev_catalog );
    inlen += strlen(refresh->rev_catalog) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_partid );
    inlen += strlen(refresh->rev_partid) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_revision );
    inlen += strlen(refresh->rev_revision) +1;
    index = inlen;

    UI_status("Changing AR MDC relations in AIM");
    __DBGpr_com("trying to talk with AIM for VDP_MAKE_AR_RELEASED");
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

    if(dstat != 0)
    {
      if(dstat == 12345)
        UI_status("AIM connection reset by server.");
      if(errmsg) __DBGpr_str("errmsg ", errmsg );
      status = 1;
      UI_status("Could not change M D C AR relation.");
      goto wrapup;
    }

    if (mfail != 0 )
    {
      if(errmsg)
      {
        __DBGpr_str("ERROR 2 ", errmsg );
      }
      status = 1;
      UI_status("Could not change M D C AR relation.");
      goto wrapup;
    }
  }


  wrapup:
    if(IsPmeEnabled() == TRUE)
    {
      if(ForceConn() == 1)
      {
        sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
        if ( !sts)
          EnablePME(0);
        UI_status("Disconnected From AIM server");
      }
    }

    // 21 JAN SSR
    if(errmsg) free(errmsg);
    if(outbuf) free(outbuf);
    __DBGpr_com("PDUaim_cm.c.CMBaseline END ");
    return status;
}

/********************************************
* Function CMRelease
* this is to Release the part.
* in SIR it changes the relaitonship to implemented
*****************************************************/
int CMRelease()
{

  int status = 0, sts;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0, response=0;
  char inbuf[512], response_data[50];
  char *errmsg=NULL, *outbuf =NULL;
  char ARsel[2], CMmng[2], NDCCsel[2], Mdc[2], IsSuper[20];

  __DBGpr_com("PDUaim_cm.c.CMRelease START ");

  status = SrVDGetCMattrs( refresh->rev_catalog, refresh->rev_partid,
                           refresh->rev_revision, ARsel,
                           CMmng, NDCCsel, Mdc, IsSuper);
  /* Donot Release if PART is Superseede */
  if(!strcasecmp(IsSuper, "Y"))
  {
    UI_status("Part is superseded; Can not change state of part.");
    return 1;
  }
  
  if(strcmp(Mdc, "Y"))
  {
    UI_status("M D C doesnot exist; Can not change state of the part.");
    return 1;
  }

  if( !strcmp(ARsel, "Y"))
  {
    if( IsPmeEnabled() == FALSE )
    {
      status = CMAimConnect();
      do
      {
        ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
      } while( response != EX_FORM_FINISHED );
    }
    if(IsPmeEnabled() == FALSE)
    {
      status = 1;
      goto wrapup;
    }
    __DBGpr_com("ARs selcted.");

    code = VDP_MAKE_AR_IMPLEMENTS;  /* 135 */

    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* inbuf arobid-cat-part-rev */

    strcpy( &inbuf[index], refresh->rev_catalog );
    inlen += strlen(refresh->rev_catalog) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_partid );
    inlen += strlen(refresh->rev_partid) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_revision );
    inlen += strlen(refresh->rev_revision) +1;
    index = inlen;



    __DBGpr_com("trying to talk with AIM to VDP_MAKE_AR_IMPLEMENTS");
    UI_status("Modifying AR MDC relations in AIM.");
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

    if(dstat != 0)
    {
      if(dstat == 12345)
        UI_status("AIM connection reset by server.");
      if(errmsg) __DBGpr_str("errmsg", errmsg );
      UI_status("Could not change M D C AR relation.");
      status = 1;
      goto wrapup;
    }

    if (mfail != 0 )
    {
      if(errmsg)
      {
        __DBGpr_str("ERROR 2", errmsg );
      }
      status = 1;
      UI_status("Could not change M D C AR relation.");
      goto wrapup;
    }
  }/* End if ARsel == Y */


  /* Update the CMemabled flag to CM managed */

  SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid, 
                      refresh->rev_revision, CMENAB, "Y" );


  wrapup:
    if(IsPmeEnabled() == TRUE)
    {
      if(ForceConn() == 1)
      {
        sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
        if ( !sts)
          EnablePME(0);
        UI_status("Disconnected From AIM server");
      }
    }
  __DBGpr_com("PDUaim_cm.c.CMRelease END ");
  //SSR 21JAN
  if(errmsg) free(errmsg);
  if(outbuf) free(outbuf);
  return status;
}


/*********************************************************
* Function: PDUselect_row_in_list_mcf
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
void PDUselect_row_in_list_mcf(cat, part, rev, row_select)
  char    *cat;
  char    *part;
  char    *rev;
  int     row_select;
{
  int                           column;
  int                           row;
  int                           length;
  int                           field;
  int                           select, pos;
  int                           index;
  static char                   *text;
  char                          *catalog = NULL;
  char                          *partid = NULL;
  char                          *revision = NULL;
  Form                          form;

  _pdm_debug("in the function PDUselect_row_in_list_mcf", 0);

  form = forms.local_files_form_id;
  field = LIST_MCF;

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     _pdm_debug("row = %d", (char *)row);
     for (column = 0; column < 3; ++column)
        {
        FIfld_get_text_length(form, field, row, column, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(form, field, row, column, length,
                      (unsigned char *)text, &select, &pos);

        if (column == 0) PDUfill_in_string(&catalog, text);
        else if (column == 1) PDUfill_in_string(&partid, text);
        else if (column == 2) PDUfill_in_string(&revision, text);
        PDUfree_string(&text);
        }

        _pdm_debug("checking cat/part/rev for NULL", 0);
        if ( catalog && partid && revision &&
             (strcmp(cat, catalog) == 0) &&
             (strcmp(part, partid) == 0) &&
             (strcmp(rev, revision) == 0) )
          {
          if (row_select)
            {
            _pdm_debug("selecting row", 0);
            if (PDU_parts_index[row] == -1)
              {
              FImcf_set_select(form,field,row,row_select);
              PDU_parts_index[row] = row;
              PDU_selected_rows = PDU_selected_rows + 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
            }
          else
            {
            _pdm_debug("deselecting row", 0);
            if (PDU_parts_index[row] != -1)
              {
              FImcf_set_select(form,field,row,row_select);
              PDU_parts_index[row] = -1;
              PDU_selected_rows = PDU_selected_rows - 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
            }
         
          break;
          }
     /* clear out fields */
     catalog = NULL_STRING;
     partid = NULL_STRING;
     revision = NULL_STRING;
     }

  index = row;

  /* check for multiple files */
  for (row = index + 1; row < PDU_parts_list_bufr->rows; ++row)
     {
     _pdm_debug("row = <%d>", (char *)row);
     FIfld_get_text_length(form, LIST_MCF, row, 0, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(form, LIST_MCF, row, 0, length, (unsigned char *)text,
                    &select, &pos);
     if (strcmp(text, "") == 0)
       {
       if (row_select)
         {
         _pdm_debug("selecting row", 0);
         if (PDU_parts_index[row] == -1)
           {
           FImcf_set_select(form,field,row,row_select);
           PDU_parts_index[row] = row;
           PDU_selected_rows = PDU_selected_rows + 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
         }
       else
         {
         _pdm_debug("deselecting row", 0);
         if (PDU_parts_index[row] != -1)
           {
           FImcf_set_select(form,field,row,row_select);
           PDU_parts_index[row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
         }
       }
     else
       {
       _pdm_debug("multiple files not found", 0);
       break;
       }
     PDUfree_string(&text);
     }

  return;
}

 
/*********************************************************
* Function: PDUmulti_move_state
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUmulti_move_state(to_state) 
  char  *to_state;
{
  int   status = PDM_S_SUCCESS;
  int   sts = PDM_S_SUCCESS;
  char   *status_msg = NULL;
  char   *msg = NULL;
  int    num_rows = 0;
  char   new_msg[50];
 
  _pdm_debug("PDUmulti_move_state", 0);
  __DBGpr_str("START in PDUmulti_move_state with", to_state);

  PDU_command = PDC_M_USER_APPROVED;

  _pdm_debug("validating access", 0);
  msg = (char *) PDUtranslate_message(PDU_command);

  new_msg[0] = '\0';
  strcpy(new_msg, "PDM");
  strcat(new_msg, msg);

  status = PDMvalidate_user_access ( new_msg, NULLSTR, refresh->rev_catalog, 
                        NULLSTR, refresh->rev_partid, refresh->rev_revision);
  _pdm_status("PDMvalidate_user_access", status);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  PDUmessage(PDS_M_GET_TRANS, 's');

  status = PDMget_trans(refresh->rev_catalog, 
                        refresh->rev_partid, 
                        refresh->rev_revision);
  _pdm_status("PDMget_trans",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  PDUunlock_item(refresh->rev_catalog, 
                 refresh->rev_partid, 
                 refresh->rev_revision);
  
  

  status = PDUmake_transition(to_state);
  _pdm_status("PDUmake_transition", status);
  PDUmessage(status, 's');
 
  /* TLS  CMSTATE */
  /*printf("\n to call CMmake_transition");
  *status = CMmake_transition();
  *_pdm_status("CMmake_transition", status);
  *Moved this to case NEW easy to roll back on failure in AIM*/
  PDUmessage(status, 's');

  PDUunlock_item(refresh->rev_catalog, 
                 refresh->rev_partid, 
                 refresh->rev_revision);

  _pdm_debug("setting the state", 0);
  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  if (PDU_mcf_list && PDU_parts_list_bufr)
    {
    status = PDUupdate_form_after_checkin_out(0);
    _pdm_status("PDUupdate_form_after_checkin_out", status);
    }
  if (PDU_state_form_displayed)
    {
    FIfld_get_num_rows(forms.move_state_form_id, PARTS_MCF, &num_rows);
    if (num_rows > 0)
      {
      status = PDUupdate_state_form_after_move_state();
      _pdm_status("PDUupdate_state_form_after_move_state", status);
      }
    }

  if (PDU_states_bufr)
    {
    MEMclose(&PDU_states_bufr);
    PDU_states_bufr = NULL;
    }
 
  __DBGpr_com("END PDUmulti_move_state ");
  return(status);
}

/*********************************************************
* Function: PDUprocess_state_form_parts
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUprocess_state_form_parts()
{
  int    status = PDM_S_SUCCESS;
  int    err_status = PDM_S_SUCCESS;
  int    row = 0;
  int    cat_col = 0;
  int    part_col = 0;
  int    rev_col = 0;
  int    desc_col = 0;
  int    type_col = 0;
  int    file_col = 0;
  char   catalog[21];
  char   partid[41];
  char   revision[41];
  char   filename[15];
  char   parttype[5];
  char   description[256];
  char   prev_cat[21];
  char   prev_part[41];
  char   prev_rev[41];
  char   aclname[21];
  char   state[40];
  char   workflow[21];
  char   **data_row = NULL;
  char   *file_status = NULL;

  _pdm_debug("PDUprocess_state_form_parts", 0);

  catalog[0] = '\0';
  partid[0] = '\0';
  revision[0] = '\0';
  filename[0] = '\0';
  parttype[0] = '\0';
  description[0] = '\0';
  prev_cat[0] = '\0';
  prev_part[0] = '\0';
  prev_rev[0] = '\0';

  PDU_acl_list = NULL;
  PDU_acl_group_list = NULL;

  if (!PDU_parts_list_bufr)
    return(PDM_E_NULL_BUFFER);

  MEMbuild_array(PDU_parts_list_bufr);
  status = PDUget_buffer_col(PDU_parts_list_bufr,"n_catalogname",&cat_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemname", &part_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemrev", &rev_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemdesc", &desc_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &type_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  PDUsetup_buffer(PDU_parts_list_bufr, ROW, &data_row);
  _pdm_debug("rows = %d", (char *)PDU_parts_list_bufr->rows);

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     if (PDU_parts_index[row] != -1)
       {
       _pdm_debug("row = %d", (char *)row);
  
       _pdm_debug("getting part information", 0);
       strcpy(catalog, 
              data_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
       strcpy(partid, 
              data_row[(PDU_parts_list_bufr->columns * row) + part_col]);
       strcpy(revision, 
              data_row[(PDU_parts_list_bufr->columns * row) + rev_col]);
       strcpy(filename, 
              data_row[(PDU_parts_list_bufr->columns * row) + file_col]);
       strcpy(description, 
              data_row[(PDU_parts_list_bufr->columns * row) + desc_col]);
       strcpy(parttype, 
              data_row[(PDU_parts_list_bufr->columns * row) + type_col]);

       _pdm_debug("catalog = <%s>", catalog);
       _pdm_debug("partid = <%s>", partid);
       _pdm_debug("revision = <%s>", revision);

       if ((strcmp(prev_cat, catalog) == 0) &&
           (strcmp(prev_part, partid) == 0) &&
           (strcmp(prev_rev, revision) == 0))
         {
         _pdm_debug("previous part equal current part", 0);
         continue;
         }

       strcpy(prev_cat, 
              data_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
       strcpy(prev_part,
              data_row[(PDU_parts_list_bufr->columns * row) + part_col]);
       strcpy(prev_rev, 
              data_row[(PDU_parts_list_bufr->columns * row) + rev_col]);

       _pdm_debug("prev_cat = <%s>", prev_cat);
       _pdm_debug("prev_part = <%s>", prev_part);
       _pdm_debug("prev_rev = <%s>", prev_rev);

       _pdm_debug("checking to see if part is checked in", 0);
       status = PDUget_file_status(catalog, partid, revision, &file_status);
       _pdm_status("PDUget_file_status", status);
       if ((file_status) && (strcmp(file_status, "") != 0) && 
           (strcmp(file_status, "I") != 0))
         {
         PDUmessage(PDM_I_PART_CHECKIN, 's');
         err_status = PDM_I_PART_CHECKIN;
         continue;
         }
      
       _pdm_debug("getting acl information for part", 0);
       status = PDMgetacl_info(catalog, partid, revision, aclname, state,
                               workflow);
       _pdm_status("PDMgetacl_info", status);
  
       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }
  
       _pdm_debug("aclname = <%s>", aclname);
       _pdm_debug("state = <%s>", state);
       _pdm_debug("workflow = <%s>", workflow);
       
       _pdm_debug("loading acl information into linklist", 0);
       status = PDUadd_node_to_acl_list(catalog, partid, revision,
                                    description, filename, parttype,
                                    aclname, state, workflow, &PDU_acl_list);
       _pdm_status("PDUadd_node_to_acl_list", status);
       }
     }

  if (PDU_acl_list == NULL)
    {
    PDUmessage(err_status, 's');
    return(err_status);
    }
  
  _pdm_debug("grouping parts", 0);
  status = PDUgroup_parts_for_transition();
  _pdm_status("PDUgroup_parts_for_transition", status);

  return(status);
}

/*********************************************************
* Function: PDUadd_node_to_acl_list
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUadd_node_to_acl_list(catalog, partid, revision, description, filename,
                            parttype, aclname, state, workflow, node)
char   catalog[21];
char   partid[41];
char   revision[41];
char   description[256];
char   filename[15];
char   parttype[5];
char   aclname[21];
char   state[41];
char   workflow[21];
struct PDUacl_node **node;
{
  int   status = PDM_S_SUCCESS;
  struct PDUacl_node *tail, *temp, *head;

  _pdm_debug("in the function PDUadd_node_to_acl_list", 0);

  temp = NULL;
  tail = NULL;
  head = NULL;
 
  temp = (struct PDUacl_node *)malloc(sizeof(struct PDUacl_node));
  temp->next = NULL;
  temp->catalog[0] = '\0';
  temp->partid[0] = '\0';
  temp->revision[0] = '\0';
  temp->description[0] = '\0';
  temp->filename[0] = '\0';
  temp->parttype[0] = '\0';
  temp->aclname[0] = '\0';
  temp->state[0] = '\0';
  temp->workflow[0] = '\0';
 
  strcpy((temp->catalog), catalog);
  strcpy((temp->partid), partid);
  strcpy((temp->revision), revision);
  strcpy((temp->description), description);
  strcpy((temp->filename), filename);
  strcpy((temp->parttype), parttype);
  strcpy((temp->aclname), aclname);
  strcpy((temp->state), state);
  strcpy((temp->workflow), workflow);
 
  if (*node)
    {
    _pdm_debug("adding node", 0);
    tail = *node;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    {
    _pdm_debug("creating beginning node", 0);
    *node = temp;
    }
 
  if ((*node) && PDM_debug_on)
    PDUprint_acl_list(*node);

  return(status);
}

/*********************************************************
* Function: PDUprint_acl_list
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUprint_acl_list(node)
struct PDUacl_node *node;
{
int    status = PDM_S_SUCCESS;
FILE  *pdu_debug_file, *fopen();
struct PDUacl_node *list = NULL;
 
  _pdm_debug("in the function PDUprint_acl_list", 0);
 
  if (!node)
    {
    _pdm_debug("ACL Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }

  list = node;
 
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (list)
    {
    fprintf(pdu_debug_file, "catalog     = %s\n", list->catalog);
    fprintf(pdu_debug_file, "partid      = %s\n", list->partid);
    fprintf(pdu_debug_file, "revision    = %s\n", list->revision);
    fprintf(pdu_debug_file, "description = %s\n", list->description);
    fprintf(pdu_debug_file, "filename    = %s\n", list->filename);
    fprintf(pdu_debug_file, "parttype    = %s\n", list->parttype);
    fprintf(pdu_debug_file, "aclname     = %s\n", list->aclname);
    fprintf(pdu_debug_file, "state       = %s\n", list->state);
    fprintf(pdu_debug_file, "workflow    = %s\n", list->workflow);
    fprintf(pdu_debug_file, "\n");
    list = list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
}

int PDUgroup_parts_for_transition()
{
  int   status = PDM_S_SUCCESS;
  int   row = 0;
  struct  PDUacl_node *current_node = NULL, *next_node = NULL;
  char  aclname[21];
  char  state[41];
  char  workflow[21];

  _pdm_debug("in the function PDUgroup_parts_for_transition", 0);

  if (!PDU_acl_list)
    return(PDM_E_NULL_BUFFER);

  aclname[0] = '\0';
  state[0] = '\0';
  workflow[0] = '\0';

  current_node = PDU_acl_list;

  row = 0;

  while (current_node)
    {
    /*
     * TR 139525986. 29/may/95 - raj.
     * Node 'current_node' is freed in PDUdelete_node_from_acl_list()
     * Contents are unpredictable after this. Store next node.
     */
    next_node = current_node->next;

    if (row == 0)
      {
      strcpy(aclname, current_node->aclname);
      strcpy(state, current_node->state);
      strcpy(workflow, current_node->workflow);

      _pdm_debug("adding first row to group_list", 0);
      status = PDUadd_node_to_acl_list( current_node->catalog,
					current_node->partid,
					current_node->revision,
					current_node->description,
					current_node->filename,
					current_node->parttype,
					current_node->aclname,
					current_node->state,
					current_node->workflow,
					&PDU_acl_group_list);
      _pdm_status("PDUadd_node_to_acl_list", status);

      _pdm_debug("deleting first row from acl_list", 0);
      status = PDUdelete_node_from_acl_list(current_node->catalog,
                                            current_node->partid,
                                            current_node->revision,
                                            &PDU_acl_list);
      _pdm_status("PDUdelete_node_from_acl_list", status);
      ++row;
      }
    else
      {
      if ((strcmp(aclname, current_node->aclname) == 0) &&
          (strcmp(state, current_node->state) == 0) &&
          (strcmp(workflow, current_node->workflow) == 0))
        {
        _pdm_debug("adding matching row to group_list", 0);
        status = PDUadd_node_to_acl_list( current_node->catalog,
					  current_node->partid,
					  current_node->revision,
					  current_node->description,
					  current_node->filename,
					  current_node->parttype,
					  current_node->aclname,
					  current_node->state,
					  current_node->workflow,
					  &PDU_acl_group_list);
        _pdm_status("PDUadd_node_to_acl_list", status);

        _pdm_debug("deleting matching row from acl_list", 0);
        status = PDUdelete_node_from_acl_list(current_node->catalog,
                                              current_node->partid,
                                              current_node->revision,
					      &PDU_acl_list);
        _pdm_status("PDUdelete_node_from_acl_list", status);
        }
      }

/* TR 139525986. See above.		*/
/*  current_node = current_node->next;	*/

    current_node = next_node;
    }

  if ((PDU_acl_list) && PDM_debug_on)
    {
    _pdm_debug("printing original acl list", 0);
    PDUprint_acl_list(PDU_acl_list);
    }

  if ((PDU_acl_group_list) && PDM_debug_on)
    {
    _pdm_debug("printing grouped acl list", 0);
    PDUprint_acl_list(PDU_acl_group_list);
    }

  return(status);
}

/*********************************************************
* Function: PDUdelete_node_from_acl_list
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUdelete_node_from_acl_list(catalog, partid, revision, acl_list)
char   *catalog;
char   *partid;
char   *revision;
struct PDUacl_node  **acl_list;
{
  int   status = PDM_S_SUCCESS;
  struct PDUacl_node  *current_node = NULL;
  struct PDUacl_node  *prev_node = NULL;

  _pdm_debug("in the function PDUdelete_node_from_acl_list", 0);

  if (!(*acl_list))
    {
    _pdm_debug("acl_list is empty", 0);
    return(PDM_E_NULL_BUFFER);
    }

  _pdm_debug("part to delete is:", 0);
  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("partid = <%s>", partid);
  _pdm_debug("revision = <%s>", revision);
 
  current_node = *acl_list;
  prev_node = *acl_list;
 
  while (current_node)
    {
    if ((strcmp(current_node->catalog, catalog) != 0) ||
        (strcmp(current_node->partid, partid) != 0) ||
        (strcmp(current_node->revision, revision) != 0))
      {
      _pdm_debug("moving to next node", 0);
      prev_node = current_node;
      current_node = current_node->next;
      }
    else
      {
      /* drop node from linklist */
      _pdm_debug("current_node->catalog = <%s>", current_node->catalog);
      _pdm_debug("current_node->partid = <%s>", current_node->partid);
      _pdm_debug("current_node->revision = <%s>", current_node->revision);

      if ((*acl_list)->next == NULL)
        {
        _pdm_debug("deleting last node in list: list is NULL", 0);
        free(*acl_list);
        *acl_list = NULL;
        }
      else if ((strcmp((*acl_list)->catalog, catalog) == 0) &&
               (strcmp((*acl_list)->partid, partid) == 0) &&
               (strcmp((*acl_list)->revision, revision) == 0))
        {
        _pdm_debug("deleting first node in list", 0);
        *acl_list = current_node->next;
        free(current_node);
        }
      else
        {
        _pdm_debug("deleting middle node in list", 0);
        prev_node->next = current_node->next;
        free(current_node);
        }
      break;
      }
    }
  
  if ((*acl_list) && PDM_debug_on)
    PDUprint_acl_list(*acl_list);

  return(status);
}

/*********************************************************
* Function: PDUprocess_individual_state_form_part
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUprocess_individual_state_form_part(catalog, partid, revision,
                                          description, filename, parttype)
char   *catalog;
char   *partid;
char   *revision;
char   *description;
char   *filename;
char   *parttype;
{
  int    status = PDM_S_SUCCESS;
  char   aclname[20];
  char   state[40];
  char   workflow[20];
  char   *file_status = NULL;

  _pdm_debug("in the function PDUprocess_individual_state_form_part", 0);

  PDU_acl_list = NULL;
  PDU_acl_group_list = NULL;

  _pdm_debug("checking to see if part is checked in", 0);
  status = PDUget_file_status(catalog, partid, revision, &file_status);
  _pdm_status("PDUget_file_status", status);
  if ((file_status) && (strcmp(file_status, "") != 0) && 
      (strcmp(file_status, "I") != 0))
    return(PDM_I_PART_CHECKIN);
 
  _pdm_debug("getting acl information for part", 0);
  status = PDMgetacl_info(catalog, partid, revision, aclname, state, workflow);
  _pdm_status("PDMgetacl_info", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  _pdm_debug("aclname = <%s>", aclname);
  _pdm_debug("state = <%s>", state);
  _pdm_debug("workflow = <%s>", workflow);
  
  _pdm_debug("loading acl information into linklist", 0);
  status = PDUadd_node_to_acl_list(catalog, partid, revision,
                                   description, filename, parttype,
                                   aclname, state, workflow, &PDU_acl_list);
  _pdm_status("PDUadd_node_to_acl_list", status);

  _pdm_debug("grouping part", 0);
  status = PDUgroup_parts_for_transition();
  _pdm_status("PDUgroup_parts_for_transition", status);

  return(status);
}

/*********************************************************
* Function: PDUload_move_state_form
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUload_move_state_form()
{
  int    status = PDM_S_SUCCESS;
  int    status1 = PDM_S_SUCCESS;
  struct PDUacl_node *acl_list = NULL;
  char   catalog[21];
  char   partid[41];
  char   revision[41];
  char   **dummy_col;
  char   **dummy_format;
  char   **dummy_row;
  char   **data_row;
  MEMptr attr_bufr = NULL;
  MEMptr states_bufr = NULL;
  MEMptr new_states = NULL;
  int    no_headings = 0;
  int    all_flag = 0;
  int    row = 0;
  int    num_rows = 0;
  int    column = 0;
  char   **headings = NULL;
  extern int PDUload_move_state_form();

  _pdm_debug("in the function PDUload_move_state_form", 0);

  catalog[0] = '\0';
  partid[0] = '\0';
  revision[0] = '\0';

  if (!PDU_acl_group_list)
    return(PDM_E_NULL_BUFFER);

  acl_list = PDU_acl_group_list;

  while (acl_list)
    {
    _pdm_debug("acl_list->workflow = <%s>", acl_list->workflow);
    _pdm_debug("acl_list->aclname = <%s>", acl_list->aclname);
    _pdm_debug("acl_list->state = <%s>", acl_list->state);

    _pdm_debug("writing to current state fields", 0);
    FIfld_set_text(forms.move_state_form_id, CURRENT, 0, 0, 
                            acl_list->workflow, FALSE);
    FIfld_set_text(forms.move_state_form_id, CURRENT, 0, 1, 
                            acl_list->aclname, FALSE);
    FIfld_set_text(forms.move_state_form_id, CURRENT, 0, 2, 
                            acl_list->state, FALSE);
    _pdm_debug("moving pointer to next node", 0);
    acl_list = acl_list->next;
    }

  acl_list = PDU_acl_group_list;

  while (acl_list)
    {
    /* save current catalog and part info */
    strcpy(catalog, acl_list->catalog);
    strcpy(partid, acl_list->partid);
    strcpy(revision, acl_list->revision);

    _pdm_debug("retrieving transitions", 0);
    status = PDMget_trans(acl_list->catalog,
			  acl_list->partid,
			  acl_list->revision);
    _pdm_status("PDMget_trans",status);
    acl_list = acl_list->next;
    if (status != PDM_S_SUCCESS)
      {
      if (acl_list)
        {
        _pdm_debug("calling PDMget_trans for next node", 0);
        continue;
        }
      else
        {
        if (PDU_acl_list)
          {
          status = PDUfree_acl_structure(&PDU_acl_group_list);
          _pdm_status("PDUfree_acl_structure", status);
          PDU_acl_group_list = NULL;
    
          /* allow user time to read any error messages */
          sleep(2);
          for (row = 0; row < num_rows; ++row)
             for (column = 0; column < 4; ++column)
                FIfld_set_text(forms.move_state_form_id, PARTS_MCF, row,
                               column, "", FALSE);
    
          status = PDUgroup_parts_for_transition();
          _pdm_status("PDUgroup_parts_for_transition", status);
    
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
    
          status = PDUload_move_state_form();
          _pdm_status("PDUload_move_state_form", status);
          }
        else
          {
          _pdm_debug("no more parts to move; exiting", 0);
    
          if (PDU_acl_group_list)
            {
            status1 = PDUfree_acl_structure(&PDU_acl_group_list);
            _pdm_status("PDUfree_acl_structure", status1);
            PDU_acl_group_list = NULL;
            }
          return(status);
          }
        }
      }
    else if (status == PDM_S_SUCCESS)
      {
      _pdm_debug("transitions were successfully retrieved", 0);
      break;
      }
    }
 
  PDUunlock_item(catalog, partid, revision);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&dummy_row, &dummy_col,
                                &dummy_format, &attr_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&data_row, &dummy_col,
                                &dummy_format, &states_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUdelete_current_state_from_states_buffer(states_bufr, &new_states);
  _pdm_status("PDUdelete_current_state_from_states_buffer", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  MEMclose(&states_bufr);
  states_bufr = NULL;

  PDUsetup_single_buffer(new_states);
 
  all_flag = FALSE;
  no_headings = 1;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);
 
  PDUfill_in_string(&headings[0], "n_statename");

  PDUsetup_popup_list(headings, no_headings, all_flag, new_states);
 
  PDUfree_string_array(&headings, no_headings);
 
  PDU_second_row = FALSE;

  PDUbufr_to_mcf(new_states, forms.move_state_form_id, NEW);
  FIfld_set_active_row(forms.move_state_form_id, NEW, 0, 0);
  FIfld_set_num_rows(forms.move_state_form_id, NEW, (new_states->rows));

  if (new_states->rows == 1)
    {
    _pdm_debug("selecting row", 0);
    FImcf_set_select(forms.move_state_form_id, NEW, 0, TRUE);
    }

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  acl_list = PDU_acl_group_list;
  status = PDUload_acl_parts_mcf(acl_list);
  _pdm_status("PDUload_acl_parts_mcf", status);

  return(status);
}

/*********************************************************
* Function: PDUupdate_state_form_after_move_state
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUupdate_state_form_after_move_state()
{
  int  status = PDM_S_SUCCESS;
  int  row = 0;
  int  column = 0;
  int  num_rows = 0;
  int  select, pos, length;
  int  field;
  char  *catalog = NULL;
  char  *partid = NULL;
  char  *revision = NULL;
  static char *text = NULL;
  Form form;
 

  _pdm_debug("in the function PDUupdate_state_form_after_move_state", 0);

  form = forms.move_state_form_id;
  field = PARTS_MCF;

  FIfld_get_num_rows(form, field, &num_rows);
  for (row = 0; row < num_rows; ++row)
     {
     _pdm_debug("searching for matching row in MCF", 0);
     _pdm_debug("row = %d", (char *)row);
     for (column = 0; column < 3; ++column)
        {
        FIfld_get_text_length(form, field, row, column, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(form, field, row, column, length,
                      (unsigned char *)text, &select, &pos);

        if (column == 0) PDUfill_in_string(&catalog, text);
        else if (column == 1) PDUfill_in_string(&partid, text);
        else if (column == 2) PDUfill_in_string(&revision, text);
        PDUfree_string(&text);
        }

     _pdm_debug("checking cat/part/rev for NULL", 0);
     if ( catalog && partid && revision &&
          (strcmp(refresh->rev_catalog, catalog) == 0) &&
          (strcmp(refresh->rev_partid, partid) == 0) &&
          (strcmp(refresh->rev_revision, revision) == 0) )
       {
       _pdm_debug("deselecting row", 0);
       FImcf_set_select(form,field,row,FALSE);
       }
     }

  return(status);
}

/*********************************************************
* Function: PDUremove_node_from_group_list
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUremove_node_from_group_list(catalog, partid, revision)
  char   *catalog;
  char   *partid;
  char   *revision;
{

  int   status = PDM_S_SUCCESS;
  struct PDUacl_node *acl_list = NULL;

  _pdm_debug("PDUremove_node_from_group_list", 0);

  acl_list = PDU_acl_group_list;

  while (acl_list)
    {
    if ((strcmp(catalog, acl_list->catalog) == 0) &&
        (strcmp(partid, acl_list->partid) == 0) &&
        (strcmp(revision, acl_list->revision) == 0))
      {
      _pdm_debug("adding part back to PDU_acl_list", 0);
      status = PDUadd_node_to_acl_list( acl_list->catalog,
                                        acl_list->partid,
                                        acl_list->revision,
                                        acl_list->description,
                                        acl_list->filename,
                                        acl_list->parttype,
                                        acl_list->aclname,
                                        acl_list->state,
                                        acl_list->workflow,
                                        &PDU_acl_list);
      _pdm_status("PDUadd_node_to_acl_list", status);

      _pdm_debug("removing part from PDU_acl_group_list", 0);
      status = PDUdelete_node_from_acl_list(acl_list->catalog,
                                            acl_list->partid,
                                            acl_list->revision,
                                            &PDU_acl_group_list);
      _pdm_status("PDUdelete_node_from_acl_list", status);
      break;
      }
    acl_list = acl_list->next;
    }

  return(status);
}

/*********************************************************
* Function: PDUdelete_current_state_from_states_buffer
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUdelete_current_state_from_states_buffer(states_bufr, temp_buffer)
MEMptr states_bufr;
MEMptr *temp_buffer;
{
  int   status = PDM_S_SUCCESS;
  int   row = 0;
  int   statename_col = 0;
  int   trans_col = 0;
  int   stateno_col = 0;
  int   status_col = 0;
  int   char_index = 0;
  char  cur_status[20];
  char  statename[41];
  char  transname[41];
  char  part_status[20];
  char  stateno[5];
  char  **data_row;
  char  *line = NULL;
  
  _pdm_debug("in the function PDUdelete_current_state_from_states_buffer", 0);

  if (!states_bufr)
    return(PDM_E_NULL_BUFFER);

  status = PDUformat_buffer (PDU_STATES_BUFFER, temp_buffer);
  _pdm_status("PDUformat_buffer", status);
 
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }
 
  line = (char*) malloc ((*temp_buffer)->row_size);

  status = MEMbuild_array(states_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
 
  status = PDUget_buffer_col(states_bufr, "n_statename", &statename_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUget_buffer_col(states_bufr, "n_stateno", &stateno_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUget_buffer_col(states_bufr, "n_transitionname", &trans_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUget_buffer_col(states_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  PDUsetup_buffer(states_bufr, ROW, &data_row);

  cur_status[0] = '\0';
  for (row = 0; row < states_bufr->rows; ++row)
     {
     strcpy(cur_status, data_row[(states_bufr->columns * row) + status_col]);
     _pdm_debug("current status = <%s>", cur_status);
    
     if (strcmp(cur_status, "CURRENT STATE") != 0)
       {
       _pdm_debug("getting data from buffer", 0);
       strcpy(statename, data_row[(states_bufr->columns * row)+statename_col]);
       strcpy(transname, data_row[(states_bufr->columns * row) + trans_col]);
       strcpy(stateno, data_row[(states_bufr->columns * row) + stateno_col]);
       strcpy(part_status, data_row[(states_bufr->columns * row) + status_col]);

       memset (line, NULL, (*temp_buffer)->row_size);
       char_index = 0;

       if (strlen (statename ))
         PDUadd_buffer_string(line, &char_index, statename);
       else
         line[char_index++] = '\1';

       if (strlen (stateno ))
         PDUadd_buffer_string(line, &char_index, stateno);
       else
         line[char_index++] = '\1';

       if (strlen (transname ))
         PDUadd_buffer_string(line, &char_index, transname);
       else
         line[char_index++] = '\1';

       if (strlen (part_status ))
         PDUadd_buffer_string(line, &char_index, part_status);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);
       status = MEMwrite (*temp_buffer, line);
       _pdm_status("MEMwrite", status);
 
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       }
     }

  if (PDM_debug_on)
    MEMprint_buffer("new states buffer", *temp_buffer, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

/*********************************************************
* Function: PDUload_acl_parts_mcf
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
int PDUload_acl_parts_mcf(parts_list)
struct  PDUacl_node  *parts_list;
{

  int  status = PDM_S_SUCCESS;
  int  row = 0;
  int  num_rows = 0;
  Form form;

  _pdm_debug("in the function PDUload_acl_parts_mcf", 0);

  if (!parts_list)
    {
    _pdm_debug("parts list is NULL", 0);
    return(PDM_E_NULL_BUFFER);
    }

  form = forms.move_state_form_id;

  while (parts_list)
    {
    FIfld_set_text(form, PARTS_MCF, row, 0, parts_list->catalog, FALSE);
    FIfld_set_text(form, PARTS_MCF, row, 1, parts_list->partid, FALSE);
    FIfld_set_text(form, PARTS_MCF, row, 2, parts_list->revision, FALSE);
    FIfld_set_text(form, PARTS_MCF, row, 3, parts_list->description, FALSE);
    ++row;
    parts_list = parts_list->next;
    }

  FIfld_set_num_rows(form, PARTS_MCF, row);
  _pdm_debug("num rows = %d", (char *)row);
  num_rows = row;

  for (row = 0; row < num_rows; ++row)
     FImcf_set_select(form, PARTS_MCF, row, TRUE);

  return(status);
}

int PDUfree_acl_structure(acl_list)
struct PDUacl_node **acl_list;
{
  struct PDUacl_node * head = NULL;
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUfree_acl_structure", 0);
 
  if (*acl_list)
    {
    head = *acl_list;
    while (*acl_list)
      {
      *acl_list = (*acl_list)->next;
      free(head);
      head = *acl_list;
      }
    *acl_list = NULL;
    }
  else
    status = PDM_E_NULL_BUFFER;
  return(status);
}



int conct_notification( f_label, g_label, fp )
 int f_label; /* The label of the form */
 int g_label; /* The label of the gadget */
 Form fp;

{
  int			status, state;
  char			*errmsg;
  unsigned char			server_name[25];
  struct hostent	*h;
  long			msg;
  char			srerrmsg[80]; 
  int			sel, pos, resp;
  char			err_msg[100]; 

  __DBGpr_com("conct_notification START");
	switch ( g_label )
	{ 
	 case FI_CANCEL :
	     FIf_erase ( con_form_id);
             FIf_delete ( con_form_id );
             resp = EX_FORM_FINISHED;
             ex$putque( msg = &msg,
                        response = &resp);
             status = 1;
	     break; 
	 
	 case FI_ACCEPT: 
	     FIfld_get_text ( con_form_id, 16, 0, 0, 30, server_name, &sel, &pos);
	     server_name[24] = '\0'; 
	     if ((h=gethostbyname(server_name)) == NULL) 
	     {  /* get the host info */
	       sprintf ( srerrmsg, "%s", "Server not recognised. Could not connect");
               UI_status ( srerrmsg );
               /*if (MS_init ( (&MS_msg), EX_F_Var1, NULL, NULL, 0, -1 ) )
               *{
               *  MS_fix_type( &MS_msg, "%s" );
               *  sprintf( (MS_msg.variables), (MS_msg.for_type), srerrmsg );
               *  MS_out_msg ( &MS_msg, NULL, 0,
               *         -1, MS_IMMEDIATE, MS_IMMEDIATE, 0);
               *}*/

	       FIf_erase ( con_form_id); 
	       FIf_delete ( con_form_id); 
               resp = EX_FORM_FINISHED;
               ex$putque( msg = &msg,
                        response = &resp);
	       return 1;
	     } 
	     
	     UI_status("Connecting to AIM server....");
	     status = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT,
		 	(char *)inet_ntoa(*((struct in_addr *)h->h_addr)),
		 	NULL,
			NULL,
			NULL,
			&errmsg);
	     
	     if ( !status)
	     {
	       EnablePME(1);
	       UI_status(" Connected to AIM server");
               VDPPutAimName(server_name);
               ForceConnect = 1;
	     } 
	     else
	     {
	       EnablePME(0);
	       UI_status( " Failed to Connect to AIM server" );
	     } 
	     
	     FIg_get_state (con_form_id, 12, &state);
	     
	     if(state == 1) ConnectAIM(PME) ;
	     if(state == 0) ConnectAIM(SIR);
	     
	     FIf_erase ( con_form_id );
	     FIf_delete ( con_form_id );
             resp = EX_FORM_FINISHED;
             ex$putque( msg = &msg,
                        response = &resp );
             status = 0;
	     break; 
	}   /* end switch*/
  __DBGpr_com("conct_notification END");

        return status;
}

int CMAimConnect ()
{
  int			status;

  __DBGpr_com("in CMAimConnect" );
      status = FIf_new ( 101, "AIMlogin", conct_notification, &con_form_id);
      if(con_form_id == NULL)
      {
        __DBGpr_com("Not able to create form <AIMlogin>.");
        return 1;
      }
      status = FIf_display( con_form_id );
      FIfld_set_text( con_form_id, 9, 0, 0, "Enter the server name", FALSE );


  __DBGpr_com("END CMAimConnect");
  if(status != FI_SUCCESS)
    status = FALSE;
  else
    status = TRUE;

  return status;
}
 
/*******************************************************************
* SrCMCopySim()
* Function to take care about copy similar of a part.
* Nothing to worry about if it is a new part.
* If it is a revision, if old file is under CM control, MDC is baselined
* Revisioning is allowed only in Baseline and Release states.
*******************************************************************/
int SrCMCopySim()
{
  int status = 0, response, index=0, inlen=0, dstat, mfail, outlen, code;
  char  *outbuf=NULL, *errmsg = 0;
  char state[20], ARsel[2], CMmng[2], NDCCsel[2], Mdc[5], response_data[50];
  char inbuf[50], err[180], IsSuper[20], w_flow[20], cr_flag[2];
  int sts;

 __DBGpr_com("START SrCMCopySim ");
if((!strcmp(refresh->new_catalog,""))|| refresh->new_catalog == NULL ||
   (!strcmp(refresh->new_partid,""))|| refresh->new_partid == NULL ||
   (!strcmp(refresh->new_revision,""))|| refresh->new_revision == NULL ||
   (!strcmp(refresh->rev_catalog,""))|| refresh->rev_catalog == NULL ||
   (!strcmp(refresh->rev_partid,""))|| refresh->rev_partid == NULL ||
   (!strcmp(refresh->rev_revision,""))|| refresh->rev_revision == NULL )
  goto wrapup;

//TR1364 nothing to do if old file is not from AVD_CM_W_FLOW
// SSR 7sep99
   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
   __DBGpr_str( " w_flow ", w_flow);
   //if(strcmp(w_flow, AVD_CM_WFLOW))
   if(strcasecmp(w_flow, "Y"))
   {
    __DBGpr_com(" Old part is not from CM workflow");
    status = 0;
    goto wrapup;
  }
/* Check if the process is new part creation */
  if (strcmp(refresh->new_partid, refresh->rev_partid))
  {
    __DBGpr_com(" New Part generation");
    status = 0;
    goto wrapup;
  }

  status = SrVDGetCMState( refresh->rev_catalog, refresh->rev_partid,
                           refresh->rev_revision, state); 

  __DBGpr_str("state", state );
  /*if(strcmp(state, BASELINE) || strcmp(state, RELEASE) )
  {
    sprintf(err, "File can not be revised in %s state", state);
    __DBGpr_str("er ",err);
    UI_status(err);
    status = 1;
    goto wrapup;
  }*/

  status = SrVDGetCMattrs( refresh->rev_catalog, refresh->rev_partid,
                           refresh->rev_revision, ARsel, CMmng, NDCCsel, Mdc, IsSuper);

  __DBGpr_str("Mdc ", Mdc);
  if(strcmp(Mdc, "Y"))
  {
    __DBGpr_com("M D C not exist ");
    // SSR 05 Jan TR # 1604
    // Add prompt to check for superseding.
    /*
    UI_prompt("Is Part being Superceded? Y/N");
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_CHAR_MODE,
                       byte = &status );
    }while(strcasecmp(response_data, "Y") &&
           strcasecmp(response_data, "N"));
    __DBGpr_str( " response data ", response_data);
    UI_prompt("");*/
    
    /*
    SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid,
                      refresh->rev_revision, "p_mrpfieldupd", "Y" ); 
    AS part of 1604 */
    status = 0;
    goto wrapup;
  }

  __DBGpr_str(" CMmng ", CMmng);
  if(strcmp(CMmng, "Y"))
  {
    __DBGpr_com("File is not CM managed.");
    /*
    UI_prompt("Is Part being Superceded? Y/N");
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_CHAR_MODE,
                       byte = &status );
    }while(strcasecmp(response_data, "Y") &&
           strcasecmp(response_data, "N"));
    __DBGpr_str( " response data ", response_data);
    UI_prompt("");
    */
    /*SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid,
                      refresh->rev_revision, "p_mrpfieldupd", response_data ); 
    As part of 1604 */
    status = 0;
    goto wrapup;
  }
  /* SSR 12 JAN 1604 check if old file is Superceded if yes ERROR */
  if(!strcasecmp(IsSuper, "Y"))
  {  
    status = 1;
    UI_status (" ERROR: Revising a Superceded file.");
    __DBGpr_com(" ERROR: Revising a Superceded file.");
    goto wrapup;
  }
  if(IsPmeEnabled() == FALSE)
  {
    status = CMAimConnect();
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
    } while( response != EX_FORM_FINISHED );

  }
  if(IsPmeEnabled() == FALSE)
  {
    UI_status("Not conencted to AIM.");
    status = 1;
    goto wrapup;
  }
 
  code = 136; /*VDP_CM_REVISE_MDC*/

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;
/* inbuf cat-part-rev  */
     strcpy( &inbuf[index], refresh->rev_catalog );
     inlen += strlen(refresh->rev_catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_partid );
     inlen += strlen(refresh->rev_partid) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_revision );
     inlen += strlen(refresh->rev_revision) +1;
     index = inlen;

     /* DCC flag is needed for AIM to revise MDC with Minor design changes
      * when no ARs are selected.Send always "Y" to abe AIM able to revise */
     strcpy( &inbuf[index], "N" );
     inlen += strlen("N") +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->new_revision );
     inlen += strlen(refresh->new_revision) +1;
     index = inlen;

     __DBGpr_int("trying to talk with AIM for VDP_CM_REVISE_MDCwith code", code);
     UI_status("Revising M D C in AIM.");
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     if(dstat != 0)
     {
      if(dstat == 12345)
        UI_status("AIM connection reset by server.");
       __DBGpr_int("dstat ", dstat);
       if(errmsg) __DBGpr_str("errmsg ", errmsg );
       UI_status("Could not Revise M D C.");
       status = 1;
       goto wrapup;
     }

     if (mfail != 0 )
     {
       if(errmsg)
       {
        __DBGpr_str("ERROR 2", errmsg );
       }
       __DBGpr_int("mfail ", mfail);
       status = mfail;
       UI_status("Could not Revise M D C.");
       UI_status("New Part not created.");
       status = 1;
       goto wrapup;
     }


     /* Set the flag IsSuperseded */
     SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid,
                      refresh->rev_revision, "p_mrpfieldupd", "Y" ); 

  wrapup:
     if(IsPmeEnabled() == TRUE)
     {
       if(ForceConn() == 1)
       {
         sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
          if ( !sts)
            EnablePME(0);
          UI_status("Disconnected From AIM server");
        }
      }
 __DBGpr_com("END SrCMCopySim ");
    return status;
}
int SrValidateforRet( char *cat, char *part, char *rev )
{
  int status =0;
  char state[20];

  __DBGpr_com("BEGIN SrValidateforRet.");
  status = SrVDGetCMState( cat, part, rev, state );
  if(strcmp(state, DEVELOPMENT))
  {
    __DBGpr_str("state ", state);
    UI_status("File can not be retrieved in this state.");
    status =1;
  }
wrapup:
  __DBGpr_com("END SrValidateforRet.");
  return status;
}
