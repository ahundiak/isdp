#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUerror.h"
#include "PDUform_def.h"
#include "PDUforms.h"
#include "PDUintdef.h"
#include <PDUfile_def.h>
#include "PDUstr.h"
#include "PDUerror.h"
#include "PDUprompt.h"
#include "PDUassy.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include <ctype.h>

/* Gadgets */

#define PROJECT_FIELD        33
#define CATALOG_FIELD        34
#define PARTNUM_FIELD        35
#define REVISION_FLD         36
#define DESC_FLD             37
#define PLACE_BTN              40
#define DELETE_BTN           41
#define SEARCH_BTN           42
#define DEFINE_ASSY_MCF_GRP  54
#define DEFINE_ASSY_MCF      17
#define KEYIN_SELECT_TGL     23
#define GROUP2               53
#define ASSY_KEYIN_GRP       75
#define ASSY_CAT_FLD         39
#define ASSY_PART_FLD        55
#define ASSY_REV_FLD         56
#define ASSY_DESC_FLD        57
#define ASSY_SELECT_GRP      64
#define PART_SEARCH_MCF      59
#define DEFINE_ASSY_BTN_GRP  65
#define PROJECT_LIST_BTN     66
#define CATALOG_LIST_BTN     67
#define PARTNUM_LIST_BTN     68
#define REVISION_LIST_BTN    69
#define ASSY_CAT_LIST_BTN    71
#define ASSY_PART_LIST_BTN   72
#define ASSY_REV_LIST_BTN    73
#define ASSY_OPTIONS_BTN     22
#define UPDATE               43

/* gadgets on local files form */
#define PROJECT_FLD              24
#define CATALOG_FLD              26
#define PARTNUM_FLD              27
#define PART_REV_FLD             28
#define PART_DESC_FLD            31
#define PART_FILE_FLD            29

/* Externs */

extern char * calloc();
extern char * realloc();
extern char      *PDU_assy_catalog;
extern char      *PDU_assy_partid;
extern char      *PDU_assy_revision;
extern char      *PDU_assy_description;
extern char      *PDU_assy_parttype;
extern char      *PDU_save_project;
extern char      *PDU_save_catalog;
extern char      *PDU_save_partid;
extern char      *PDU_save_revision;
extern char      *PDU_save_description;
extern char      *PDU_save_filename;
extern char      *PDU_save_parttype;
extern char      *PDU_usage_id;
extern char ***  PDU_update_struct;
extern char    * PDU_quantity;
extern char     *PDU_explode_BOM;
extern char     *PDU_incl_BOM;
extern char     *PDU_incl_ASM;
extern int       PDU_explode_depth;
extern int       PDU_save_level;
extern int       FIg_get_value();
extern int       FImcf_get_active_col();
extern int       PDU_search_type;
extern int       PDU_refresh_gadgets[7];
extern int       PDU_form_type;
extern int       PDMdebug_on;
extern int       PDU_act_row;
extern int       PDU_active_button;
extern int       PDU_level_no;
extern int       PDU_local_files_displayed;
extern short     PDU_select_area;
extern short     PDU_keyin_area;
extern short     PDU_define_assy_created;
extern short     PDU_define_assy_displayed;
extern short     PDU_assembly_list;
extern short     PDU_load_assy;
extern short     PDU_get_assy;
extern short     PDU_attach;
extern short     PDU_assy_perm_window;
extern short     PDU_display_dyn_attr;
extern MEMptr    PDU_assy_parts_bufr;
extern MEMptr    PDU_ret_bufr;
extern MEMptr    PDU_def_assy_bufr;
extern MEMptr    PDU_display_buffer;
extern MEMptr    PDU_struct_bufr;
extern MEMptr    PDU_hold_bufr;
extern Form      PDU_form_id;
extern Form      PDU_calling_form;
extern struct    PDUrefresh   *refresh;
extern struct    PDUforms     forms;
extern struct    PDUassy_node     *PDU_assy_head;

/* Global and static variables */

extern int    prev_row;
extern double prev_value;

extern struct part_dynamic_attrs *part_occur_list;

int define_assy_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             length;
  int             select;
  int             pos;
  int             status = PDM_S_SUCCESS;
  int             state;
  int             column;
  int             row;
  int             act_row;
  int             act_pos;
  int             num_rows;
  int             num_cols;
  int             type_col;
  int             mcf_select = FALSE;
  char            answer[2];
  char            **list_row;
  char            *msg = NULL;
  MEMptr          buffer = NULL;
  struct    PDUassy_node     *head = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  PDU_form_id = fp;
  PDU_load_assy = FALSE;
  PDU_calling_form = fp;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 value = 0.0;
 	 f_label = 0;

         _pdm_debug("converting form to permanent window", 0);
         FIf_cvrt_to_perm_win(forms.define_assy_form_id);
         PDU_assy_perm_window = TRUE;
         Help_topic("define_assy");
         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         PDU_assy_perm_window = TRUE;
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         PDU_attach = TRUE;
         PDU_assy_head = NULL;
         if (PDU_def_assy_bufr != NULL)
           {
           MEMclose(&PDU_def_assy_bufr);
           PDU_def_assy_bufr = NULL;
           }

         if (PDU_display_buffer != NULL)
           {
           MEMclose(&PDU_display_buffer);
           PDU_display_buffer = NULL;
           }

         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         if (PDU_hold_bufr)
           {
           MEMclose(&PDU_hold_bufr);
           PDU_hold_bufr = NULL;
           }

         /* free the link list */
         if (PDU_assy_head)
           {
           head = PDU_assy_head;

           while (PDU_assy_head)
              {
              PDU_assy_head = PDU_assy_head->next;
              free(head);
              head = PDU_assy_head;
              }
           PDU_assy_head = NULL;
           }
 
         _pdm_debug("User selected the cancel button", 0);

         if (PDU_define_assy_displayed == TRUE)
           {
           FIf_erase( fp );
           PDU_define_assy_displayed = FALSE;
           }
         if (PDU_define_assy_created == TRUE)
           {
           FIf_delete( fp );
           PDU_define_assy_created = FALSE;
           }

         if (PDU_save_catalog)
           PDUfill_in_string(&refresh->rev_catalog, PDU_save_catalog);
         if (PDU_save_partid)
           PDUfill_in_string(&refresh->rev_partid, PDU_save_partid);
         if (PDU_save_revision)
           PDUfill_in_string(&refresh->rev_revision, PDU_save_revision);
         if (PDU_save_description)
           PDUfill_in_string(&refresh->rev_description, PDU_save_description);
         if (PDU_save_parttype)
           PDUfill_in_string(&refresh->rev_parttype, PDU_save_parttype);
         PDU_save_catalog = NULL;
         PDU_save_partid = NULL;
         PDU_save_revision = NULL;
         PDU_save_description = NULL;
         PDU_save_parttype = NULL;

         refresh->rev_filename = NULL;
         PDU_form_id = forms.local_files_form_id;
         PDUrefresh_local_files_form();
         PDU_explode_depth = MAX_LEVEL;
         PDUfill_in_string(&PDU_explode_BOM, "Y");
         PDUfill_in_string(&PDU_incl_BOM, "Y");
         PDUfill_in_string(&PDU_incl_ASM, "Y");

         FIf_display(forms.local_files_form_id);
         PDU_local_files_displayed = TRUE;

         /*  ALR  9/20/93 Free global list of parts */

         if (part_occur_list)
          pdmfree_part_occurrence();

         break;

    case UPDATE:     /* Member of group FI_CTRL_GROUP */

         if ((refresh->rev_catalog == NULL)            ||
               (strcmp(refresh->rev_catalog, "") == 0) ||
               (refresh->rev_partid == NULL)           ||
               (strcmp(refresh->rev_partid, "") == 0)  ||
               (refresh->rev_revision == NULL)         ||
               (strcmp(refresh->rev_revision, "") == 0))
             {
             msg = (char *)PDUtranslate_message(PDM_I_ENTER_PART);
             FIg_set_text(fp,FI_MSG_FIELD,msg);
             PDUmessage(PDM_I_ENTER_PART, 's');
             FIg_set_state_off(fp, UPDATE);
             break;
             }

         PDUfill_in_string(&PDU_save_catalog, refresh->rev_catalog);
         PDUfill_in_string(&PDU_save_partid, refresh->rev_partid);
         PDUfill_in_string(&PDU_save_revision, refresh->rev_revision);
         PDUfill_in_string(&PDU_save_description, refresh->rev_description);
         PDUfill_in_string(&PDU_save_parttype, refresh->rev_parttype);

         if (PDU_assy_head == NULL)
           {
           FIfld_get_num_rows(fp, DEFINE_ASSY_MCF, &num_rows);
           if (num_rows > 0)
             {
             _pdm_debug("converting assembly buffer to linklist", 0);
             if ((PDU_def_assy_bufr != NULL) && (PDU_def_assy_bufr->rows > 1))
               {
               status = PDUassy_buffer_to_linklist(PDU_def_assy_bufr);
               _pdm_status("PDUassy_buffer_to_linklist", status);
  
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(PDM_E_BUFR_LINKLIST, 's');
                 PDU_assy_head = NULL;
                 break;
                 }
               }
             }
           }
         
         /* Create buffer from linked list */
         if (PDU_assy_head != NULL)
           {
           status = PDUassy_linklist_to_buffer(PDU_assy_head, &buffer);
           _pdm_status("PDUassy_linklist_to_buffer", status);
           PDU_assy_head = NULL;
           }
         else
           {
           msg = (char *)PDUtranslate_message(PDM_E_ASSEMBLY_NOT_FOUND);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_ASSEMBLY_NOT_FOUND, 's');

           if (PDU_hold_bufr && (PDU_hold_bufr->rows < 2))
             break;

           /* format a buffer with no rows */
           _pdm_debug("Assembly Structure is Empty", 0);

           status = PDUformat_buffer(PDU_CHILD_BUFR, &buffer);
           _pdm_status("PDUformat_buffer", status);

           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             return(status);
             }

           if (PDMdebug_on)
             MEMprint_buffer("assembly structure", buffer, PDU_DEBUG_FILE);
           }

         if (status != PDM_S_SUCCESS)
           break; 

         /* Call PDM function to update structure */
         status = PDMdefine_assembly_structure(refresh->rev_catalog,
                  refresh->rev_partid, refresh->rev_revision, 1, buffer);
         _pdm_status("PDMdefine_assembly_structure", status);

         PDUmessage(status, 's');

         /* set assembly selection area back to insert mode */
         PDUunfreeze_assy_refresh();

         /* freeze part selection area */
         if (PDU_keyin_area == TRUE)
           PDUfreeze_assy_part_area();

         FIf_reset(fp);
         FIg_display(fp, ASSY_KEYIN_GRP);
	 PDUfreeze_assy_mcf();
         FIg_disable(fp, UPDATE);

         /* free the link list */
         if (PDU_assy_head)
           {
           head = PDU_assy_head;

           while (PDU_assy_head)
              {
              PDU_assy_head = PDU_assy_head->next;
              free(head);
              head = PDU_assy_head;
              }
           PDU_assy_head = NULL;
           }

         /* reset form variables */
         PDU_usage_id = NULL;
         PDU_assy_catalog = NULL;
         PDU_assy_partid = NULL;
         PDU_assy_revision = NULL;
         PDU_assy_description = NULL;
         PDU_assy_parttype = NULL;
         refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         PDUfill_in_string(&PDU_quantity, "1.000000");
         PDU_attach = FALSE;
         PDU_act_row = -1;
         PDU_assembly_list = FALSE;
         PDU_select_area = FALSE;
         PDU_keyin_area = TRUE;
         PDUfill_in_string(&PDU_explode_BOM, "Y");
         PDUfill_in_string(&PDU_incl_BOM, "Y");
         PDUfill_in_string(&PDU_incl_ASM, "Y");
         /*PDU_explode_BOM = "Y";*/
         PDU_explode_depth = MAX_LEVEL;
         prev_row = -1;
         prev_value = -1.0;
         PDU_load_assy = FALSE;

         if (PDU_def_assy_bufr)
           {
           MEMclose(&PDU_def_assy_bufr);
           PDU_def_assy_bufr = NULL;
           }
 
         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }
 
         if (PDU_display_buffer != NULL)
           {
           MEMclose(&PDU_display_buffer);
           PDU_display_buffer = NULL;
           }

         if (PDU_hold_bufr)
           {
           MEMclose(&PDU_hold_bufr);
           PDU_hold_bufr = NULL;
           }

         /* disable command buttons */
         FIg_disable(forms.define_assy_form_id, DELETE_BTN);
         FIg_disable(forms.define_assy_form_id, PLACE_BTN);
         FIg_disable(forms.define_assy_form_id, SEARCH_BTN);

         if (status == PDM_E_CYCLIC_1STLEVEL)
          {
           msg = (char *)PDUtranslate_message(PDM_E_ASSEM_NOT_SAVED);
           FIg_set_text(fp, FI_MSG_FIELD,msg); 
           PDUmessage(PDM_E_ASSEM_NOT_SAVED, 's');
           }

         PDUmessage(status, 's');
         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         PDUdismiss_subforms();

         /* set assembly selection area back to insert mode */
         PDUunfreeze_assy_refresh();

         FIf_reset(fp);
         FIg_display(fp, ASSY_KEYIN_GRP);
         FIfld_pos_cursor(fp, CATALOG_FIELD, 0,0,0,0,1,1);

         /* free the link list */
         if (PDU_assy_head)
           {
           head = PDU_assy_head;

           while (PDU_assy_head)
              {
              PDU_assy_head = PDU_assy_head->next;
              free(head);
              head = PDU_assy_head;
              }
           PDU_assy_head = NULL;
           }

         /* reset form variables */
         PDU_assy_catalog = NULL;
         PDU_assy_partid = NULL;
         PDU_assy_revision = NULL;
         PDU_assy_description = NULL;
         PDU_assy_parttype = NULL;
         PDU_act_row = -1;
         PDU_assembly_list = FALSE;
         PDU_select_area = FALSE;
         PDU_keyin_area = TRUE;
         prev_row = -1;
         prev_value = -1.0;
         PDU_form_id = fp;
         PDU_load_assy = FALSE;
         PDU_calling_form = fp;
         refresh->rev_project = NULL;
         refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_parttype = NULL;
         refresh->rev_filename = NULL;

         PDU_usage_id = NULL;
         if (PDU_quantity)
           free(PDU_quantity);
         PDU_quantity = NULL;
         PDUfill_in_string(&PDU_quantity, "1.000000");
         PDU_attach = FALSE;
         PDU_explode_BOM = NULL;
         PDU_incl_BOM = NULL;
         PDUfill_in_string(&PDU_explode_BOM, "Y");
         PDUfill_in_string(&PDU_incl_BOM, "Y");
         PDUfill_in_string(&PDU_incl_ASM, "Y");
         PDU_explode_depth = MAX_LEVEL;
         PDU_save_project = NULL;
         PDU_save_catalog = NULL;
         PDU_save_partid = NULL;
         PDU_save_revision = NULL;
         PDU_save_filename = NULL;
         PDU_save_description = NULL;
         PDU_save_parttype = NULL;

         if (PDU_def_assy_bufr)
           {
           MEMclose(&PDU_def_assy_bufr);
           PDU_def_assy_bufr = NULL;
           }
 
         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }
 
         if (PDU_display_buffer != NULL)
           {
           MEMclose(&PDU_display_buffer);
           PDU_display_buffer = NULL;
           }

         if (PDU_hold_bufr)
           {
           MEMclose(&PDU_hold_bufr);
           PDU_hold_bufr = NULL;
           }

         /* disable command buttons */
         FIg_disable(forms.define_assy_form_id, DELETE_BTN);
         FIg_disable(forms.define_assy_form_id, PLACE_BTN);
         FIg_disable(forms.define_assy_form_id, ASSY_OPTIONS_BTN);
         FIg_disable(forms.define_assy_form_id, SEARCH_BTN);

         /* freeze part selection area */
         if (PDU_keyin_area == TRUE)
           PDUfreeze_assy_part_area();
	 PDUfreeze_assy_mcf();

         PDUmessage(PDM_S_SUCCESS, 's');
         break;

    case PROJECT_FIELD:      

         refresh->rev_project = NULL;

         PDUrefresh_gadgets_init();
         _pdm_debug("Entering PROJECT",0);

         status = PDUep_proj_fld();
         _pdm_status("PDUep_proj_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         break;

    case CATALOG_FIELD:     

         refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_parttype = NULL;

         FIg_set_text(fp, PARTNUM_FIELD, "");
         FIg_set_text(fp, REVISION_FLD, "");
         FIg_set_text(fp, DESC_FLD, "");

         PDU_save_catalog = NULL;
         PDU_save_partid = NULL;
         PDU_save_revision = NULL;
         PDU_save_description = NULL;
         PDU_save_parttype = NULL;

         PDUrefresh_gadgets_init();
         _pdm_debug("Entering CATALOG",0);

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         if (status != PDM_S_SUCCESS)
           break;

         status = PDUget_assembly(TRUE);
         _pdm_status("PDUget_assembly", status);

         break;

    case PARTNUM_FIELD:    

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_parttype = NULL;

         FIg_set_text(fp, REVISION_FLD, "");
         FIg_set_text(fp, DESC_FLD, "");

         PDU_load_assy = FALSE;
         PDUrefresh_gadgets_init();
         _pdm_debug("Entering PARTNUM",0);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status,'s');
           break;
           }

         status = PDUget_assembly(TRUE);
         _pdm_status("PDUget_assembly", status);

         break;

    case REVISION_FLD:  

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         FIg_set_text(fp, DESC_FLD, "");

         PDUrefresh_gadgets_init();
         _pdm_debug("Entering EP_REV_FLD",0);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status,'s');
           break;
           }

         status = PDUget_assembly(TRUE);
         _pdm_status("PDUget_assembly", status);

         break;

    case DESC_FLD:     
         break;
         /* Read Only */

    case PROJECT_LIST_BTN:
         PDU_active_button = PROJECT_LIST_BTN;
         
         PDU_load_assy = FALSE;
         PDUrefresh_gadgets_init();
         _pdm_debug("Entering LIST_PROJECTS",0);

         status = PDUep_proj_btn();
         _pdm_status("PDUep_proj_btn",status);

         PDUmessage(status,'s');
         break;

    case CATALOG_LIST_BTN:
         PDU_active_button = CATALOG_LIST_BTN;

         PDU_load_assy = FALSE;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_parttype = NULL;

         FIg_set_text(fp, PARTNUM_FIELD, "");
         FIg_set_text(fp, REVISION_FLD, "");
         FIg_set_text(fp, DESC_FLD, "");

         PDUrefresh_gadgets_init();
         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;

    case PARTNUM_LIST_BTN:
         PDU_active_button = PARTNUM_LIST_BTN;

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_parttype = NULL;

         FIg_set_text(fp, REVISION_FLD, "");
         FIg_set_text(fp, DESC_FLD, "");

         PDU_load_assy = FALSE;
         PDUrefresh_gadgets_init();
         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         break;

    case REVISION_LIST_BTN:
         PDU_active_button = REVISION_LIST_BTN;

         refresh->rev_description = NULL;
         FIg_set_text(fp, DESC_FLD, "");

         PDU_load_assy = FALSE;
         PDUrefresh_gadgets_init();
          _pdm_debug("Entering EP_REV_BTN",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         break;

    case DEFINE_ASSY_MCF:     /* Member of group DEFINE_ASSY_MCF_GRP  */

         FIfld_get_num_rows(fp, DEFINE_ASSY_MCF, &num_rows);
         if (num_rows == 0)
           {
           _pdm_debug("no rows in structure -- breaking", 0);
           break;
           }

         FIfld_get_active_row(fp, DEFINE_ASSY_MCF, &act_row, &act_pos);
         FImcf_set_active_col(fp, DEFINE_ASSY_MCF, 0, 0);
         FIfld_get_select(fp, DEFINE_ASSY_MCF, act_row, 0, &mcf_select);

         if (mcf_select == TRUE)
           {
           /* if any information is in the part selection area, save it */
           PDUsave_assy_part_selection_area();

           PDU_act_row = act_row;

           /* loop through columns in mcf to get data selected */
           for (column = 0; column < 4; ++column)
              {
              FImcf_set_active_col( fp, DEFINE_ASSY_MCF, column, column);
              FIfld_get_text_length(PDU_form_id,DEFINE_ASSY_MCF,act_row,column,
                                    &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL_STRING, sizeof (char) * length + 1);
              FIfld_get_text(PDU_form_id,DEFINE_ASSY_MCF,act_row,column,length,
                             (unsigned char *)text,&select, &pos);

              /* update the structure */
              switch (column)
                {
                case 0:
                     _pdm_debug("text = <%s>", text);
                     if ((text != NULL) && (strcmp(text, "") != 0))
                       {
                       sscanf(text, "%d", &PDU_level_no);
                       _pdm_debug("level number = <%d>", (char *)PDU_level_no);
                       break;
                       }
                     else
                       break;
                case 1:
                     PDUfill_in_string(&PDU_assy_catalog, text);
                     _pdm_debug("assembly catalog = <%s>", PDU_assy_catalog);
                     break;
                case 2:
                     PDUfill_in_string(&PDU_assy_partid, text);
                     _pdm_debug("assembly part num = <%s>", PDU_assy_partid);
                     break;
                case 3:
                     PDUfill_in_string(&PDU_assy_revision, text);
                     _pdm_debug("assembly revision = <%s>", PDU_assy_revision);
                     break;
                }
              }  /* end for column */
  
           PDUfill_in_string(&PDU_assy_description,"");
           FIg_enable(forms.define_assy_form_id, PLACE_BTN);

           /* query for assembly parttype */
           status = PDMquery_part_type(PDU_assy_catalog,
                        PDU_assy_partid, PDU_assy_revision, &buffer);
           _pdm_status("PDMquery_part_type", status);

           if ((buffer) && (status == PDM_S_SUCCESS))
             {
             MEMbuild_array(buffer);
             status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
             if (status != PDM_S_SUCCESS)
               return(status);

             PDUsetup_buffer(buffer, ROW, &list_row);

             PDUfill_in_string(&PDU_assy_parttype,
                         list_row[(buffer->columns * 0) + type_col]);
             _pdm_debug("parttype = <%s>", PDU_assy_parttype);
             MEMclose(&buffer);
             }
           else
             {
             PDUmessage(status, 's');
             _pdm_debug("failed to retrieve parttype", 0);
             MEMclose(&buffer);
             PDU_assy_parttype = NULL_STRING;
             }

           if (PDU_level_no == 1)
             FIg_enable(fp, DELETE_BTN);
           else
             FIg_disable(fp, DELETE_BTN);
           }
         else
           {
           PDU_assy_catalog = NULL_STRING;
           PDU_assy_partid = NULL_STRING;
           PDU_assy_revision = NULL_STRING;
           PDU_assy_description = NULL_STRING;
           PDU_act_row = -1;
           FIg_disable(fp, DELETE_BTN);

           /* restore information in the part selection area */
           PDUrestore_assy_part_selection_area();

           PDUcheck_assy_commands();
           }

         if (prev_row != act_row)
           prev_row = act_row;
         break;

    case KEYIN_SELECT_TGL:     
         FIg_get_state(fp, KEYIN_SELECT_TGL, &state);
         if (state == 0)
           {
           /* clear out the select mcf */
           FImcf_get_num_cols(fp, PART_SEARCH_MCF, &num_cols);
           FIfld_get_num_rows(fp, PART_SEARCH_MCF, &num_rows);
           for (row = 0; row < num_rows; ++row)
              for (column = 0; column < num_cols; ++column)
                 FIfld_set_text(fp, PART_SEARCH_MCF, row, column, "", FALSE);

           FIg_erase(fp, ASSY_SELECT_GRP);
           PDUunfreeze_assy_part_area();
           FIg_display(fp, ASSY_KEYIN_GRP);
           PDU_keyin_area = TRUE;
           PDU_select_area = FALSE;

           _pdm_debug("checking assy part selection area for data", 0);
           FIfld_get_text_length(PDU_form_id,ASSY_CAT_FLD,0,0, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(PDU_form_id,ASSY_CAT_FLD,0,0,length,
                          (unsigned char *)text,&select, &pos);
           PDUfill_in_string(&PDU_assy_catalog, text);

           FIfld_get_text_length(PDU_form_id,ASSY_PART_FLD,0,0, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(PDU_form_id,ASSY_PART_FLD,0,0,length,
                          (unsigned char *)text,&select, &pos);
           PDUfill_in_string(&PDU_assy_partid, text);

           FIfld_get_text_length(PDU_form_id,ASSY_REV_FLD,0,0, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(PDU_form_id,ASSY_REV_FLD,0,0,length,
                          (unsigned char *)text,&select, &pos);
           PDUfill_in_string(&PDU_assy_revision, text);

           FIfld_get_text_length(PDU_form_id,ASSY_DESC_FLD,0,0, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(PDU_form_id,ASSY_DESC_FLD,0,0,length,
                          (unsigned char *)text,&select, &pos);
           PDUfill_in_string(&PDU_assy_description, text);

           if ((PDU_assy_catalog) && (strlen(PDU_assy_catalog)))
             {
             FIg_set_text(fp, ASSY_CAT_FLD, PDU_assy_catalog);
             if ((PDU_assy_partid) && (strlen(PDU_assy_partid)))
               {
               FIg_set_text(fp, ASSY_PART_FLD, PDU_assy_partid);
               if ((PDU_assy_revision) && (strlen(PDU_assy_revision)))
                 {
                 FIg_set_text(fp, ASSY_REV_FLD, PDU_assy_revision);
                 if ((PDU_assy_description) && (strlen(PDU_assy_description)))
                   {
                   FIg_set_text(fp, ASSY_DESC_FLD, PDU_assy_description);
                   }
                 else PDU_assy_description = NULL_STRING;
                 }
               else 
                 {
                 PDU_assy_revision = NULL_STRING;
                 PDU_assy_description = NULL_STRING;
                 }
               }
             else 
               {
               PDU_assy_partid = NULL_STRING;
               PDU_assy_revision = NULL_STRING;
               PDU_assy_description = NULL_STRING;
               }
             }
           else 
             {
             PDU_assy_catalog = NULL_STRING;
             PDU_assy_partid = NULL_STRING;
             PDU_assy_revision = NULL_STRING;
             PDU_assy_description = NULL_STRING;
             }
           }
         else
           {
           /* clear out keyin fields */
/*
           FIfld_set_text(fp, ASSY_CAT_FLD, 0, 0, "", FALSE);
           FIfld_set_text(fp, ASSY_PART_FLD, 0, 0, "", FALSE);
           FIfld_set_text(fp, ASSY_REV_FLD, 0, 0, "", FALSE);
           FIfld_set_text(fp, ASSY_DESC_FLD, 0, 0, "", FALSE);

           PDUfill_in_string(&PDU_assy_catalog, "");
           PDUfill_in_string(&PDU_assy_partid, "");
           PDUfill_in_string(&PDU_assy_revision, "");
           PDUfill_in_string(&PDU_assy_description, "");
*/

           FIg_erase(fp, ASSY_KEYIN_GRP);
           FIg_display(fp, ASSY_SELECT_GRP);
           PDU_select_area = TRUE;
           PDU_keyin_area = FALSE;
           }

         if ((PDU_assy_catalog) && (strlen(PDU_assy_catalog)) &&
             (PDU_assy_partid) && (strlen(PDU_assy_partid)) &&
             (PDU_assy_revision) && (strlen(PDU_assy_revision)))
           FIg_enable(fp, PLACE_BTN);
         else
           FIg_disable(fp, PLACE_BTN);

         FIg_disable(fp, DELETE_BTN);
         if (PDU_act_row != -1)
           {
           FImcf_set_select(fp, DEFINE_ASSY_MCF, PDU_act_row, FALSE);
           PDU_act_row = -1;
           }

         /* check to see if an assembly has been selected */
         if ((!refresh->rev_catalog) || (!refresh->rev_partid) ||
             (!refresh->rev_revision))
           PDUfreeze_assy_part_area();
         else if ((strcmp(refresh->rev_catalog, "") == 0) ||
                  (strcmp(refresh->rev_partid, "") == 0) ||
                  (strcmp(refresh->rev_revision, "") == 0))
           PDUfreeze_assy_part_area();

         break;

    case ASSY_CAT_FLD:     /* Member of group ASSY_KEYIN_GRP  */

         PDU_assy_catalog = NULL;
         PDU_assy_partid = NULL;
         PDU_assy_revision = NULL;
         PDU_assy_description = NULL;
         PDU_assy_parttype = NULL;

         FIg_set_text(fp, ASSY_PART_FLD, "");
         FIg_set_text(fp, ASSY_REV_FLD, "");
         FIg_set_text(fp, ASSY_DESC_FLD, "");

         PDU_load_assy = TRUE;
         PDUassy_gadgets_init();

         _pdm_debug("Entering CATALOG",0);

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         PDUcheck_assy_commands();
         break;

    case ASSY_PART_FLD:     /* Member of group ASSY_KEYIN_GRP  */

         PDU_assy_partid = NULL;
         PDU_assy_revision = NULL;
         PDU_assy_description = NULL;
         PDU_assy_parttype = NULL;

         PDU_usage_id = NULL;

         FIg_set_text(fp, ASSY_REV_FLD, "");
         FIg_set_text(fp, ASSY_DESC_FLD, "");

         PDU_load_assy = TRUE;
         PDUassy_gadgets_init();

         _pdm_debug("Entering PARTNUM",0);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         PDUprint_assy_refresh();
         PDUcheck_assy_commands();
         break;

    case ASSY_REV_FLD:     /* Member of group ASSY_KEYIN_GRP  */

         PDU_assy_revision = NULL;
         PDU_assy_description = NULL;
         FIg_set_text(fp, ASSY_DESC_FLD, "");

         PDU_load_assy = TRUE;
         PDUassy_gadgets_init();

         _pdm_debug("Entering EP_REV_FLD",0);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         PDUcheck_assy_commands();
         break;

    case ASSY_DESC_FLD:     /* Member of group ASSY_KEYIN_GRP  */

         PDU_assy_description = NULL;
         PDU_load_assy = TRUE;
         PDUassy_gadgets_init();

         _pdm_debug("Entering EP_DESC_FLD",0);

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         break;

    case ASSY_CAT_LIST_BTN:
         PDU_active_button = ASSY_CAT_LIST_BTN;

         PDU_assy_partid = NULL;
         PDU_assy_revision = NULL;
         PDU_assy_parttype = NULL;
         PDU_assy_description = NULL;

         FIg_set_text(fp, ASSY_PART_FLD, "");
         FIg_set_text(fp, ASSY_REV_FLD, "");
         FIg_set_text(fp, ASSY_DESC_FLD, "");

         PDU_load_assy = TRUE;
         PDU_get_assy = TRUE;
         PDUassy_gadgets_init();

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         PDUmessage(status,'s');
         break;
 
    case ASSY_PART_LIST_BTN:
         PDU_active_button = ASSY_PART_LIST_BTN;

         PDU_assy_revision = NULL;
         PDU_assy_parttype = NULL;
         PDU_assy_description = NULL;

         FIg_set_text(fp, ASSY_REV_FLD, "");
         FIg_set_text(fp, ASSY_DESC_FLD, "");

         PDU_load_assy = TRUE;
         PDU_get_assy = TRUE;
         PDUassy_gadgets_init();

         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;

    case ASSY_REV_LIST_BTN:
         PDU_active_button = ASSY_REV_LIST_BTN;

         PDU_assy_description = NULL;
         FIg_set_text(fp, ASSY_DESC_FLD, "");

         PDU_load_assy = TRUE;
         PDU_get_assy = TRUE;
         PDUassy_gadgets_init();

         _pdm_debug("Entering EP_REV_BTN",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;

    case PART_SEARCH_MCF:
         FIfld_get_active_row(fp, PART_SEARCH_MCF, &act_row, &act_pos);
         FImcf_set_active_col(fp, PART_SEARCH_MCF, 0, 0);
         FIfld_get_select(fp, PART_SEARCH_MCF, act_row, 0, &mcf_select);

         if (mcf_select == TRUE)
           {
           /* loop through columns in mcf to get data selected */
           for (column = 0; column < 4; ++column)
              {
              FImcf_set_active_col( fp, PART_SEARCH_MCF, column, column);
              FIfld_get_text_length(PDU_form_id,PART_SEARCH_MCF,act_row,column,
                                    &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(PDU_form_id,PART_SEARCH_MCF,act_row,column,length,
                             (unsigned char *)text,&select, &pos);

              /* update the structure */
              switch (column)
                {
                case 0:
                     PDUfill_in_string(&PDU_assy_catalog, text);
                     _pdm_debug("assembly catalog = <%s>", PDU_assy_catalog);
                     FIfld_set_text( fp, ASSY_CAT_FLD, 0, 0, text, FALSE);
                     break;
                case 1:
                     PDUfill_in_string(&PDU_assy_partid, text);
                     _pdm_debug("assembly part num = <%s>", PDU_assy_partid);
                     FIfld_set_text( fp, ASSY_PART_FLD, 0, 0, text, FALSE);
                     break;
                case 2:
                     PDUfill_in_string(&PDU_assy_revision, text);
                     _pdm_debug("assembly revision = <%s>", PDU_assy_revision);
                     FIfld_set_text( fp, ASSY_REV_FLD, 0, 0, text, FALSE);
                     break;
                case 3:
                     PDUfill_in_string(&PDU_assy_description,text);
                     _pdm_debug("assembly description = <%s>",
                                PDU_assy_description);
                     FIfld_set_text( fp, ASSY_DESC_FLD, 0, 0, text, FALSE);
                     break;
                }
              }  /* end for column */

              /* query for parttype */
              status = PDMquery_part_type(PDU_assy_catalog, PDU_assy_partid,
                                PDU_assy_revision, &buffer);
              _pdm_status("PDMquery_part_type", status);
           
              if ((buffer) && (status == PDM_S_SUCCESS))
                {
                MEMbuild_array(buffer);
                status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
                if (status != PDM_S_SUCCESS)
                  return(status);
           
                PDUsetup_buffer(buffer, ROW, &list_row);
           
                PDUfill_in_string(&PDU_assy_parttype,
                            list_row[(buffer->columns * 0) + type_col]);
                _pdm_debug("parttype = <%s>", PDU_assy_parttype);
                MEMclose(&buffer);
                }
              else
                {
                MEMclose(&buffer);
                _pdm_debug("failed to retrieve parttype", 0);
                PDUmessage(status, 's');
                PDU_assy_parttype = NULL_STRING;
                }
           }  /* end if select */
         else
           {
           PDU_assy_catalog = NULL;
           PDU_assy_partid = NULL;
           PDU_assy_revision = NULL;
           PDU_assy_description = NULL;
           PDU_assy_parttype = NULL_STRING;
           }

         PDUcheck_assy_commands();

         break;

    case DELETE_BTN:     /* Member of group DEFINE_ASSY_BTN_GRP */

         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         if (PDU_act_row == -1) 
           {
           msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
           FIg_set_text(fp,FI_MSG_FIELD,msg);
           PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
           FImcf_set_select(fp, DEFINE_ASSY_MCF, PDU_act_row, FALSE);
           PDU_act_row = -1;
           break;
           }

         /* if the PDU_def_assy_bufr has not been converted to a linked
            list, convert it */
         if (PDU_assy_head == NULL)
           {
           _pdm_debug("converting assembly buffer to linklist", 0);
           if ((PDU_def_assy_bufr != NULL) && (PDU_def_assy_bufr->rows > 1))
             {
             status = PDUassy_buffer_to_linklist(PDU_def_assy_bufr);
             _pdm_status("PDUassy_buffer_to_linklist", status);
  
             if (status != PDM_S_SUCCESS)
               {
               PDUmessage(PDM_E_BUFR_LINKLIST, 's');
               PDU_assy_head = NULL;
               break;
               }
             }
           }

         /* check the level number of the part */
         if (PDU_level_no != 1)
           {
           msg = (char *)PDUtranslate_message(PDM_E_DEL_FIRST);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_DEL_FIRST, 's');
           FImcf_set_select(fp, DEFINE_ASSY_MCF, PDU_act_row, FALSE);
           PDU_act_row = -1;
           break;
           }

         /* disable command buttons */
         FIg_disable(fp, FI_CANCEL);
         FIg_disable(fp, UPDATE);
         FIg_disable(fp, FI_HELP);
         FIg_disable(fp, FI_RESET);

         /* confirm operation on the assembly structure */
         msg = (char *)PDUtranslate_message(PDP_P_DELETE_PART_IN_ASSY);
         UI_prompt(msg);
         do
           {
           status = PDUget_keyin(answer);

           if ((answer) && (strlen(answer) > 0) && (strcmp(answer,"")) &&
               (strcmp(answer,"y")) && (strcmp(answer,"Y")) &&
               (strcmp(answer,"n")) && (strcmp(answer,"N")))
             {
             status = PDM_E_INVALID_INPUT;
             PDUmessage(status,'s');
             }
           }
         while (status == PDM_E_INVALID_INPUT);
         UI_prompt(NULL_STRING);

         _pdm_debug("answer = <%s>", answer);

         if ((!strlen(answer)) || 
             (strcmp(answer, "y")== 0) || (strcmp(answer, "Y")==0))
           {
           FImcf_set_select(fp, DEFINE_ASSY_MCF, PDU_act_row, FALSE);

           status = PDUdelete_assy_part();
           _pdm_status("PDUdelete_assy_part", status);

           FIg_disable(forms.define_assy_form_id, DELETE_BTN);
           PDU_act_row = -1;
           }
         if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_NOT_DELETED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_NOT_DELETED, 's');
           FImcf_set_select(fp, DEFINE_ASSY_MCF, PDU_act_row, FALSE);
           FIg_disable(forms.define_assy_form_id, DELETE_BTN);
           PDU_act_row = -1;
           }


           /* set assembly variables to NULL */
           _pdm_debug("resetting assembly variables", 0);
           PDU_assy_catalog = NULL_STRING;
           PDU_assy_partid = NULL_STRING;
           PDU_assy_revision = NULL_STRING;
           PDU_assy_description = NULL_STRING;

         if ((PDU_select_area == TRUE) || (PDU_keyin_area == TRUE))
           {
           /* restore part data */
           PDUrestore_assy_part_selection_area();

           if (strcmp(PDU_assy_partid, "") == 0)
             {
             FIg_disable(fp, PLACE_BTN);
             FIg_disable(fp, DELETE_BTN);
             }
           }

         if ((strcmp(answer, "n")!= 0) && (strcmp(answer, "N")!=0))
           PDUmessage(status, 's');

         /* enable command buttons */
         FIg_enable(fp, FI_CANCEL);
         FIg_enable(fp, UPDATE);
         FIg_enable(fp, FI_HELP);
         FIg_enable(fp, FI_RESET);

         refresh->status = status;
         break;

    case SEARCH_BTN:     /* Member of group DEFINE_ASSY_BTN_GRP */

         if (PDU_assy_parts_bufr != NULL)
           {
           MEMclose(&PDU_assy_parts_bufr);
           PDU_assy_parts_bufr = NULL;
           }
         FIg_get_state(fp, KEYIN_SELECT_TGL, &state);
         if (state == 0)
           {
           FIg_erase(fp, ASSY_KEYIN_GRP);

           /* clear out keyin fields */
           FIfld_set_text(fp, ASSY_CAT_FLD, 0, 0, "", FALSE);
           FIfld_set_text(fp, ASSY_PART_FLD, 0, 0, "", FALSE);
           FIfld_set_text(fp, ASSY_REV_FLD, 0, 0, "", FALSE);
           FIfld_set_text(fp, ASSY_DESC_FLD, 0, 0, "", FALSE);

           PDUfill_in_string(&PDU_assy_catalog, "");
           PDUfill_in_string(&PDU_assy_partid, "");
           PDUfill_in_string(&PDU_assy_revision, "");
           PDUfill_in_string(&PDU_assy_description, "");
           PDUfill_in_string(&PDU_assy_parttype, "");

           FIg_set_state(fp, KEYIN_SELECT_TGL, 1);
           FIg_display(fp, ASSY_SELECT_GRP);
           PDU_keyin_area = FALSE;

           if ((PDU_assy_catalog) && (strlen(PDU_assy_catalog)))
             {
             FIg_set_text(fp, ASSY_CAT_FLD, PDU_assy_catalog);
             if ((PDU_assy_partid) && (strlen(PDU_assy_partid)))
               {
               FIg_set_text(fp, ASSY_PART_FLD, PDU_assy_partid);
               if ((PDU_assy_revision) && (strlen(PDU_assy_revision)))
                 {
                 FIg_set_text(fp, ASSY_REV_FLD, PDU_assy_revision);
                 if ((PDU_assy_description) && (strlen(PDU_assy_description)))
                   {
                   FIg_set_text(fp, ASSY_DESC_FLD, PDU_assy_description);
                   }
                 else PDU_assy_description = NULL_STRING;
                 }
               else 
                 {
                 PDU_assy_revision = NULL_STRING;
                 PDU_assy_description = NULL_STRING;
                 }
               }
             else 
               {
               PDU_assy_partid = NULL_STRING;
               PDU_assy_revision = NULL_STRING;
               PDU_assy_description = NULL_STRING;
               }
             }
           else 
             {
             PDU_assy_catalog = NULL_STRING;
             PDU_assy_partid = NULL_STRING;
             PDU_assy_revision = NULL_STRING;
             PDU_assy_description = NULL_STRING;
             }
           }

         PDU_search_type = PARTS;
         PDU_form_id = forms.define_assy_form_id;
         PDU_form_type = DEFINE_ASSY_FORM;

         if (PDU_select_area == TRUE)
           {
           /* clear out the select mcf */
           FImcf_get_num_cols(fp, PART_SEARCH_MCF, &num_cols);
           FIfld_get_num_rows(fp, PART_SEARCH_MCF, &num_rows);
           for (row = 0; row < num_rows; ++row)
              for (column = 0; column < num_cols; ++column)
                 FIfld_set_text(fp, PART_SEARCH_MCF, row, column, "", FALSE);
           }

        /* save the information that is in the refresh */
        if (refresh->rev_catalog)
           PDUfill_in_string(&PDU_save_catalog, refresh->rev_catalog);
         else
           PDU_save_catalog = NULL;

         if (refresh->rev_partid)
           PDUfill_in_string(&PDU_save_partid, refresh->rev_partid);
         else
           PDU_save_partid = NULL;

         if (refresh->rev_revision)
           PDUfill_in_string(&PDU_save_revision, refresh->rev_revision);
         else
           PDU_save_revision = NULL;

         if (refresh->rev_description)

           PDUfill_in_string(&PDU_save_description, refresh->rev_description);
         else
           PDU_save_description = NULL;

         if (refresh->rev_filename)
           PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
         else
           PDU_save_filename = NULL;

         if (refresh->rev_parttype)
           PDUfill_in_string(&PDU_save_parttype, refresh->rev_parttype);
         else
           PDU_save_parttype = NULL;

         _pdm_debug("calling part selection form", 0);
         FIf_erase(fp);
         SelectOrPlacePart(TRUE, TRUE, fp);

         break;

    case PLACE_BTN:        /* Member of group DEFINE_ASSY_BTN_GRP */

         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         if ((PDU_act_row == -1) && (PDU_select_area != TRUE) &&
             (PDU_keyin_area != TRUE))
           {
           msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
           break;
           }

	 if ((PDU_assy_catalog == NULL) ||
             (strcmp(PDU_assy_catalog, "") == 0) ||
             (PDU_assy_partid == NULL) ||
             (strcmp(PDU_assy_partid, "") == 0) ||
             (PDU_assy_revision == NULL) ||
             (strcmp(PDU_assy_revision, "") == 0))
            {
            status = PDM_E_NO_PARTS_SELECTED;
            PDUmessage(status, 's');
            msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            break;
            }

         _pdm_debug("PDU_assy_catalog = <%s>", PDU_assy_catalog);
         _pdm_debug("PDU_assy_partid = <%s>", PDU_assy_partid);
         _pdm_debug("PDU_assy_revision = <%s>", PDU_assy_revision);
         _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
         _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
         _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);

         /* check for cyclic placement */
         if (PDU_struct_bufr)
           {
           MEMclose(&PDU_struct_bufr);
           PDU_struct_bufr = NULL;
           }

         /* copy refresh rev fields to act fields */
         PDUfill_in_string(&refresh->act_catalog, refresh->rev_catalog);
         PDUfill_in_string(&refresh->act_partid, refresh->rev_partid);
         PDUfill_in_string(&refresh->act_revision, refresh->rev_revision);

         status = PDUis_cyclic_placement(PDU_assy_catalog, PDU_assy_partid,
                                         PDU_assy_revision, &PDU_struct_bufr);
         _pdm_status("PDUis_cyclic_placement", status);

         if (status == 1)
           {
           PDUmessage(PDM_E_CYCLIC_1STLEVEL, 's');
           break;
           }

         /* reset refresh fields */
         refresh->act_catalog = NULL;
         refresh->act_partid = NULL;
         refresh->act_revision = NULL;

         /* if the PDU_def_assy_bufr has not been converted to a linked
            list, convert it */
         if (PDU_assy_head == NULL)
           {
           _pdm_debug("converting assembly buffer to linklist", 0);
           if ((PDU_def_assy_bufr != NULL) && (PDU_def_assy_bufr->rows > 1))
             {
             status = PDUassy_buffer_to_linklist(PDU_def_assy_bufr);
             _pdm_status("PDUassy_buffer_to_linklist", status);

             if (status != PDM_S_SUCCESS)
               {
               msg = (char *)PDUtranslate_message(PDM_E_BUFR_LINKLIST);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               PDUmessage(PDM_E_BUFR_LINKLIST, 's');
               PDU_assy_head = NULL;
               break;
               }
             }
           }

         /* reset the usage id */
         /*PDU_usage_id = NULL_STRING;*/

         /* call function to add part to assembly structure */
         status = PDUadd_part_to_assy_structure();
         _pdm_status("PDUadd_part_to_assy_structure", status);

         break;

    case ASSY_OPTIONS_BTN:

         FIf_erase(forms.define_assy_form_id);
         PDU_define_assy_displayed = FALSE;
         PDU_calling_form = forms.define_assy_form_id;

         status = PDUdesign_options_form();
         _pdm_status("PDUdesign_options_form", status);

         break;

  } /* END switch ( g_label ) */

  return(status);
} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the define assembly
   form. */

int PDUdefine_assy_form()
{
  int  sts = PDM_S_SUCCESS;
  int  level;
  char *state = NULL;
  char *msg = NULL;

  if (PDU_define_assy_displayed == TRUE)
    return(sts);

  PDU_define_assy_created = FALSE;
  PDU_define_assy_displayed = FALSE;

  PDU_assy_head = NULL;
  PDU_usage_id = NULL;
  PDU_assy_catalog = NULL;
  PDU_assy_partid = NULL;
  PDU_assy_revision = NULL;
  PDU_assy_description = NULL;
  if (PDU_quantity)
    free(PDU_quantity);
  PDU_quantity = NULL;
  PDUfill_in_string(&PDU_quantity, "1.000000");
  PDU_attach = FALSE;
  PDU_act_row = -1;
  PDU_assembly_list = FALSE;
  PDU_select_area = FALSE;
  PDU_keyin_area = TRUE;
  PDU_explode_BOM = NULL;
  PDU_incl_BOM = NULL;
  PDU_incl_ASM = NULL;
  PDUfill_in_string(&PDU_explode_BOM, "Y");
  PDUfill_in_string(&PDU_incl_BOM, "Y");
  PDUfill_in_string(&PDU_incl_ASM, "Y");
  PDU_explode_depth = MAX_LEVEL;
  PDU_load_assy = FALSE;
  prev_row = -1;
  prev_value = -1.0;
  PDU_save_project = NULL;
  PDU_save_catalog = NULL;
  PDU_save_partid = NULL;
  PDU_save_revision = NULL;
  PDU_save_filename = NULL;
  PDU_save_description = NULL;
  PDU_assy_perm_window = FALSE;
  PDU_display_dyn_attr = TRUE;
  if (PDU_struct_bufr)
    {
    MEMclose(&PDU_struct_bufr);
    PDU_struct_bufr = NULL;
    }
  if (PDU_hold_bufr)
    {
    MEMclose(&PDU_hold_bufr);
    PDU_hold_bufr = NULL;
    }

  sts = FIf_new(DEFINE_ASSY_FORM, "define_assy", 
                define_assy_notification_routine, &forms.define_assy_form_id);

  _pdm_debug("Creating define assembly form", 0);
  PDU_define_assy_created = TRUE;

  /* disable gadgets that require a part in the refresh */
  FIg_disable(forms.define_assy_form_id, DELETE_BTN);
  FIg_disable(forms.define_assy_form_id, PLACE_BTN);

  if ((refresh->rev_project != NULL) &&
      (strcmp(refresh->rev_project, "")  != 0))
    {
    FIfld_set_text(forms.define_assy_form_id, PROJECT_FIELD, 0, 0, 
                   refresh->rev_project, FALSE);
    }

  if ((refresh->rev_catalog != NULL) &&
      (strcmp(refresh->rev_catalog, "")  != 0) &&
      (refresh->rev_partid != NULL) &&
      (strcmp(refresh->rev_partid, "") != 0) &&
      (refresh->rev_revision != NULL) &&
      (strcmp(refresh->rev_revision, "") != 0))
    {
    FIfld_set_text(forms.define_assy_form_id, CATALOG_FIELD, 0, 0, 
                   refresh->rev_catalog, FALSE);
    FIfld_set_text(forms.define_assy_form_id, PARTNUM_FIELD, 0, 0, 
                   refresh->rev_partid, FALSE);
    FIfld_set_text(forms.define_assy_form_id, REVISION_FLD, 0, 0, 
                   refresh->rev_revision, FALSE);

    if ((refresh->rev_description != NULL) &&
        (strcmp(refresh->rev_description, "") != 0))
      FIfld_set_text(forms.define_assy_form_id, DESC_FLD, 0, 0, 
                     refresh->rev_description, FALSE);

    _pdm_debug("parttype = <%s>", refresh->rev_parttype);

    if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
      {
      _pdm_debug("filename = <%s>", refresh->rev_filename);
      sts = PDUis_file_open(refresh->rev_filename);
      _pdm_status("PDUis_file_open", sts);
      if (sts == 1)
        {
        PDUmessage(PDM_E_OPEN_FILE_NOT_ALLOWED, 's');
        FIf_delete(forms.define_assy_form_id);
        return(PDM_E_OPEN_FILE_NOT_ALLOWED);
        }
      }

    /* validate access */
    sts = PDMvalidate_user_access("PDMUpdate Assembly Structure", NULLSTR,
           refresh->rev_catalog, NULLSTR, refresh->rev_partid,
           refresh->rev_revision );
    _pdm_status ("PDMvalidate_user_access", sts);

     if (sts != PDM_S_SUCCESS)
       {
       PDUmessage(sts, 's');
       return(sts);
       }

    sts = PDUget_file_status(refresh->rev_catalog, refresh->rev_partid,
                             refresh->rev_revision, &state);
    _pdm_status("PDUget_file_status", sts);

    if (sts != PDM_S_SUCCESS)
      {
      PDUmessage(sts, 's');
      return(sts);
      }

    if ((state) && (strcmp(state, "I") != 0) && (strcmp(state, "") != 0))
      {
      FIf_delete(forms.define_assy_form_id);
      PDU_define_assy_created = FALSE;
      PDUmessage(PDM_I_PART_CHECKIN, 's');
      msg = (char *)PDUtranslate_message(PDM_I_PART_CHECKIN);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg); 
      return(PDM_S_SUCCESS);
      }

      /* get the max level of display from the database */
      sts = PDUget_max_level(&level);
      _pdm_status("PDUget_max_level", sts);
    
      if (sts != PDM_S_SUCCESS)
        {
        PDUmessage(sts, 's');
        FIf_display(forms.local_files_form_id);
        PDU_local_files_displayed = TRUE;
        return(sts);
        }

      _pdm_debug("level = %d", (char *)level);
      _pdm_debug("setting PDU_explode_depth", 0);
      PDU_explode_depth = level;
      _pdm_debug("setting PDU_save_level", 0);
      PDU_save_level = level;

      _pdm_debug("explode_depth = %d", (char *)PDU_explode_depth);
      sts = PDMget_assembly_structure(refresh->rev_catalog,
                                    refresh->rev_partid, refresh->rev_revision,
                                    PDU_explode_depth, &PDU_def_assy_bufr, 0);
      _pdm_status("PDMget_assembly_structure", sts);

      if (!PDU_def_assy_bufr)
        {
        sts = PDM_E_RETRIEVE_ASSEMBLY;
        PDU_define_assy_created = FALSE;
        PDUmessage(sts, 's');
        refresh->status = sts;
        return(sts);
        }

      if ((sts != PDM_S_SUCCESS) && (sts != PDM_E_PART_NOT_ASSEMBLY))
        {
        PDU_define_assy_created = FALSE;
        PDUmessage(sts, 's');
        refresh->status = sts;
        return(sts);
        }

      if (PDMdebug_on)
        MEMprint_buffer("non-graphic assembly buffer", PDU_def_assy_bufr, 
                        PDU_DEBUG_FILE);

      MEMsplit_copy_buffer(PDU_def_assy_bufr, &PDU_hold_bufr, 0);

      /* load the assembly structure into the form */
      if ((PDU_def_assy_bufr == NULL) || (PDU_def_assy_bufr->rows == 1))
        {
        msg = (char *)PDUtranslate_message(PDM_I_ATOMIC_PART);
        FIg_set_text(forms.define_assy_form_id, FI_MSG_FIELD,msg); 
        PDUmessage(PDM_I_ATOMIC_PART, 's');
        }
      else
        {
        sts = PDUload_assembly_structure();
        _pdm_status("PDUload_assembly_structure", sts);
        }

    PDUmessage(sts, 's');

    /* freeze refresh area */
    PDUfreeze_assy_refresh();
    FIg_enable(forms.define_assy_form_id, SEARCH_BTN);

    FIg_enable(forms.define_assy_form_id, UPDATE);
    }
  else
    {
    /* freeze part selection area */
    if (PDU_keyin_area == TRUE)
      PDUfreeze_assy_part_area();

    FIg_disable(forms.define_assy_form_id, UPDATE);
    FIg_disable(forms.define_assy_form_id, SEARCH_BTN);
    }

  FIf_erase(forms.local_files_form_id);
  PDU_local_files_displayed = FALSE;

  /* Display the define assembly form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the define assembly form", 0);
  sts = FIf_display(forms.define_assy_form_id);
  PDU_define_assy_displayed = TRUE;
  PDU_form_id = forms.define_assy_form_id;

  if ((refresh->rev_catalog == NULL) || (strcmp(refresh->rev_catalog, "") == 0))
    {
    FIfld_pos_cursor(forms.define_assy_form_id, CATALOG_FIELD, 0,0,0,0,1,1);
    FIg_disable(forms.define_assy_form_id, ASSY_OPTIONS_BTN);
    }
  else
    {
    FIg_set_text(forms.define_assy_form_id,CATALOG_FIELD,refresh->rev_catalog);

    if ((refresh->rev_partid==NULL) || (strcmp(refresh->rev_partid, "")==0))
      FIfld_pos_cursor(forms.define_assy_form_id, PARTNUM_FIELD, 0,0,0,0,1,1);
    else
      FIg_set_text(forms.define_assy_form_id, PARTNUM_FIELD,
                       refresh->rev_partid);
    }

  refresh->status = PDM_S_SUCCESS;
  return(PDM_S_SUCCESS);
}

int PDUrefresh_gadgets_init()
{
  /* initialize PDU_refresh_gadgets */
  PDU_refresh_gadgets[0] = PROJECT_FIELD;
  PDU_refresh_gadgets[1] = CATALOG_FIELD;
  PDU_refresh_gadgets[2] = PARTNUM_FIELD;
  PDU_refresh_gadgets[3] = REVISION_FLD;
  PDU_refresh_gadgets[5] = DESC_FLD;
  return(PDM_S_SUCCESS);
}

int PDUassy_gadgets_init()
{
  /* initialize PDU_refresh_gadgets */
  PDU_refresh_gadgets[0] = 0;
  PDU_refresh_gadgets[1] = ASSY_CAT_FLD;
  PDU_refresh_gadgets[2] = ASSY_PART_FLD;
  PDU_refresh_gadgets[3] = ASSY_REV_FLD;
  PDU_refresh_gadgets[5] = ASSY_DESC_FLD;
  return(PDM_S_SUCCESS);
}

int PDUprint_assy_refresh()
{
  if (!(refresh->rev_catalog))
    PDUfill_in_string(&refresh->rev_catalog, NULL_STRING);
  if (!(refresh->rev_partid))
    PDUfill_in_string(&refresh->rev_partid, NULL_STRING);
  if (!(refresh->rev_revision))
    PDUfill_in_string(&refresh->rev_revision, NULL_STRING);
  if (!(refresh->rev_description))
    PDUfill_in_string(&refresh->rev_description, NULL_STRING);

  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug("refresh->rev_description = <%s>", refresh->rev_description);

  if (!(PDU_assy_catalog))
    PDUfill_in_string(&PDU_assy_catalog, NULL_STRING);
  if (!(PDU_assy_partid))
    PDUfill_in_string(&PDU_assy_partid, NULL_STRING);
  if (!(PDU_assy_revision))
    PDUfill_in_string(&PDU_assy_revision, NULL_STRING);
  if (!(PDU_assy_description))
    PDUfill_in_string(&PDU_assy_description, NULL_STRING);

  _pdm_debug("PDU_assy_catalog = <%s>", PDU_assy_catalog);
  _pdm_debug("PDU_assy_partid = <%s>", PDU_assy_partid);
  _pdm_debug("PDU_assy_revision = <%s>", PDU_assy_revision);
  _pdm_debug("PDU_assy_description = <%s>", PDU_assy_description);
  return(PDM_S_SUCCESS);
}

int PDUcheck_assy_commands()
{
  _pdm_debug("in the function PDUcheck_assy_commands", 0);

  if (!(PDU_assy_catalog))
    PDUfill_in_string(&PDU_assy_catalog, NULL_STRING);
  if (!(PDU_assy_partid))
    PDUfill_in_string(&PDU_assy_partid, NULL_STRING);
  if (!(PDU_assy_revision))
    PDUfill_in_string(&PDU_assy_revision, NULL_STRING);
  if (!(PDU_assy_description))
    PDUfill_in_string(&PDU_assy_description, NULL_STRING);
  if (!(PDU_assy_parttype))
    PDUfill_in_string(&PDU_assy_parttype, NULL_STRING);

  _pdm_debug("PDU_assy_catalog = <%s>", PDU_assy_catalog);
  _pdm_debug("PDU_assy_partid = <%s>", PDU_assy_partid);
  _pdm_debug("PDU_assy_revision = <%s>", PDU_assy_revision);
  _pdm_debug("PDU_assy_description = <%s>", PDU_assy_description);
  _pdm_debug("PDU_assy_parttype = <%s>", PDU_assy_parttype);

  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);

  _pdm_debug("PDU_act_row = %d", (char *)PDU_act_row);

  if ((PDU_assy_catalog != NULL) &&
      (strcmp(PDU_assy_catalog, "") != 0) &&
      (PDU_assy_partid != NULL) &&
      (strcmp(PDU_assy_partid, "") != 0) &&
      (PDU_assy_revision != NULL) &&
      (strcmp(PDU_assy_revision, "") != 0) &&
      (refresh->rev_catalog != NULL) &&
      (strcmp(refresh->rev_catalog, "")  != 0) &&
      (refresh->rev_partid != NULL) &&
      (strcmp(refresh->rev_partid, "") != 0) &&
      (refresh->rev_revision != NULL) &&
      (strcmp(refresh->rev_revision, "") != 0))
    {
    FIg_enable(forms.define_assy_form_id, PLACE_BTN);
    FIg_enable(forms.define_assy_form_id, SEARCH_BTN);

    /* check the parttype */
/*
    if (PDU_assy_parttype &&
       (strcmp(PDU_assy_parttype, "P") == 0) ||
       (strcmp(PDU_assy_parttype, "p") == 0) ||
       (strcmp(PDU_assy_parttype, "N") == 0) ||
       (strcmp(PDU_assy_parttype, "n") == 0))
      {
      PDU_attach = FALSE;
      _pdm_debug("setting PDU_attach to FALSE for N and P parts", 0);
      }
*/
    }
  else
    {
    FIg_disable(forms.define_assy_form_id, PLACE_BTN);

    if ((!(strlen(refresh->rev_catalog))) &&
        (!(strlen(refresh->rev_partid))) &&
        (!(strlen(refresh->rev_revision))))
      FIg_disable(forms.define_assy_form_id, SEARCH_BTN);
    }

  if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog, "") != 0))
    FIg_enable(forms.define_assy_form_id, ASSY_OPTIONS_BTN);
  else
    FIg_disable(forms.define_assy_form_id, ASSY_OPTIONS_BTN);

  /* unselect the row in the assembly listing area */
  if (PDU_act_row != -1)
    {
    _pdm_debug("deselecting row in assembly listing area", 0);
    FImcf_set_select(forms.define_assy_form_id, DEFINE_ASSY_MCF, PDU_act_row, 
                     FALSE);
    PDU_act_row = -1;
    }

  PDU_usage_id = NULL;

  return(PDM_S_SUCCESS);
}

int PDUrestore_assy_part_selection_area()
{
  _pdm_debug("in the function PDUrestore_assy_part_selection_area", 0);

  if (PDU_save_catalog)
    PDUfill_in_string(&PDU_assy_catalog, PDU_save_catalog);
  if (PDU_save_partid)
    PDUfill_in_string(&PDU_assy_partid, PDU_save_partid);
  if (PDU_save_revision)
    PDUfill_in_string(&PDU_assy_revision, PDU_save_revision);
  if (PDU_save_description)
    PDUfill_in_string(&PDU_assy_description, PDU_save_description);

  PDU_save_catalog = NULL;
  PDU_save_partid = NULL;
  PDU_save_revision = NULL;
  PDU_save_description = NULL;

  return(PDM_S_SUCCESS);
}

int PDUsave_assy_part_selection_area()
{
  if ((PDU_assy_catalog) && (strcmp(PDU_assy_catalog, "") != 0))
    PDUfill_in_string(&PDU_save_catalog, PDU_assy_catalog);

  if ((PDU_assy_partid) && (strcmp(PDU_assy_partid, "") != 0))
    PDUfill_in_string(&PDU_save_partid, PDU_assy_partid);

  if ((PDU_assy_revision) && (strcmp(PDU_assy_revision, "") != 0))
    PDUfill_in_string(&PDU_save_revision, PDU_assy_revision);

  if ((PDU_assy_description) && (strcmp(PDU_assy_description,"")!=0))
    PDUfill_in_string(&PDU_save_description, PDU_assy_description);

  PDU_assy_catalog = NULL;
  PDU_assy_partid = NULL;
  PDU_assy_revision = NULL;
  PDU_assy_description = NULL;

  return(PDM_S_SUCCESS);
}

int PDUfreeze_assy_mcf()
{
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 0, FI_REVIEW);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 1, FI_REVIEW);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 2, FI_REVIEW);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 3, FI_REVIEW);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 4, FI_REVIEW);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 5, FI_REVIEW);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 6, FI_REVIEW);
  return(PDM_S_SUCCESS);
}

int PDUunfreeze_assy_mcf()
{
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 0, FI_SINGLE_SELECT
);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 1, FI_SINGLE_SELECT
);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 2, FI_SINGLE_SELECT
);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 3, FI_SINGLE_SELECT
);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 4, FI_SINGLE_SELECT
);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 5, FI_SINGLE_SELECT
);
  FIfld_set_mode(forms.define_assy_form_id, DEFINE_ASSY_MCF, 6, FI_SINGLE_SELECT
);
  return(PDM_S_SUCCESS);
}
