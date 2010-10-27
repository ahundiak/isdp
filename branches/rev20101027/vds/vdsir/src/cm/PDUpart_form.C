#include <stdio.h>
#include <string.h>
#include <FI.h>
#include <tools.h>
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SQLerrordef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDMcommand.h"
#include "part_gadgets.h"
#include "PDUform_def.h"
#include <exdef.h>
#include <PDUcommand.h>
#include <PDUprompt.h>
#include <PDMmessage.h>
/*#include <PDUproto.h>*/
#include <PDMproto.h>
#include "v_dbgmacros.h"
/*
#define vdsDEBUG
#define vdserrDEBUG
*/


/* The #DEFINES for the gadgets on this form are in part_gadgets.h */
/* Globals */
static char RevCat[50];
static char RevPart[50];
static char RevRev[10];
static char RevCm[2];
static int  IsMDCRev = 0;
#define BASELINE        "Baseline"
#define RELEASE         "Release"
#define CHECKING        "Checking"
#define DEVELOPMENT     "Development"

/* Externs */

extern int    PDM_debug_on;
extern int    PDU_single_list_displayed;
extern int    PDU_single_list_created;
extern int    PDU_mcf_list_displayed;
extern int    PDU_mcf_list_created;
extern int    PDU_command;
extern int    PDU_check_filename;
extern int    PDMdebug_on;
extern int    PDU_refresh_gadgets[7];
extern int    PDU_validate_access;
extern char * calloc();
extern char * realloc();
extern char *** PDU_update_struct;
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern int FIg_get_type();
extern int PDU_form_type;
extern int PDU_search_type;
extern Form PDU_calling_form;
extern Form PDU_struct_type;
extern Form PDU_form_id;
extern MEMptr PDU_ep_bufr;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_display_buffer;
extern MEMptr PDU_design_parts_bufr;
extern MEMptr PDU_ep_data_bufr;
extern MEMptr PDU_copyof_ret_bufr;
extern struct PDUrefresh    *refresh;
extern struct PDUforms      forms;
extern int *PDU_gadget_labels;
extern int PDUinit_stack();
extern int PDUpush_into_stack();
extern int PDUdelete_form_stack();
extern int PDUget_top_of_stack();
extern int * PDU_stack;
extern int PDUprint_stack();
extern MEMptr       PDU_attr_bufr;
extern MEMptr       PDU_data_bufr;
extern MEMptr       PDU_acl_bufr;
extern MEMptr       PDU_stg_bufr;
extern MEMptr       PDU_file_data_bufr;
extern MEMptr       PDU_sav_file_data_bufr;
extern MEMptr       PDU_add_data_bufr;
extern MEMptr       PDU_states_bufr;
extern char      ** PDU_attr_row;
extern char      ** PDU_attr_col;
extern char      ** PDU_attr_format;
extern char      ** PDU_data_row;
extern char      ** PDU_data_col;
extern char      ** PDU_data_format;
extern char      ** PDU_acl_row;
extern char      ** PDU_acl_col;
extern char      ** PDU_acl_format;
extern char      ** PDU_stg_row;
extern char      ** PDU_stg_col;
extern char      ** PDU_stg_format;
extern char      *PDU_value_list[605];
extern int       PDU_value_pulldown;
extern MEMptr    PDU_list_bufr;
extern MEMptr    PDU_hold_bufr;
extern int       PDU_active_button;
extern char    * PDU_save_project;
extern char    * PDU_save_catalog;
extern char    * PDU_save_partid;
extern char    * PDU_save_revision;
extern char    * PDU_save_parttype;
extern char    * PDU_save_description;
extern char    * PDU_save_filename;
extern short     PDU_disable_filedesc_col;
extern short     PDU_disable_localfn_col;
extern short     PDU_disable_storagefn_col;
extern short     PDU_disable_filetype_col;
extern short     PDU_filedesc_newfiles_disable;
extern short     PDU_localfn_newfiles_disable;
extern short     PDU_storagefn_newfiles_disable;
extern short     PDU_filetype_newfiles_disable;
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
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_list_cat;
extern int      PDU_add_files;
extern int      PDU_simmode_copy;
extern int      PDU_simmode_checkin;
extern int      mode_change_flag;
extern int      part_operations_created;
extern int      part_operations_displayed;
extern int      change_part;
extern int      checked_in;
extern int      enter_part;
extern int      new_mode;
extern int      similar_mode;
extern int      change_mode;
extern int      review_mode;
extern int      new_file;
extern int      pt_flag;
extern int      bufr_flag;
extern int      existing_file;
extern int      np_cat_btn_flag;
extern int      ep_part_fld_flag;
extern int      ep_part_btn_flag;
extern int      ep_rev_btn_flag;
extern int      ep_desc_flag;
extern int      acl_flag;
extern int      workflow_flag;
extern int      end_move_to_state_btn_flag;
extern int      change_files_flag;
extern int      add_files_flag;
extern int      PDU_part_flagged;
extern int      end_ep_parttype_btn_flag;
extern int      end_stg_area_btn_flag;
extern int      new_part_flag;
extern int      end_acl_wf_btn_flag;
extern int      PDU_simmode_cat_bufr;
extern short    PDU_delete_files;
extern short    change_stat;
extern char     *trans_name;
extern char     *init_project;
extern char     *init_catalog;
extern char     *init_partnum;
extern char     *init_revision;
extern char     *init_parttype;
extern char     *ep_project;
extern char     *ep_catalog;
extern char     *en_itemname;
extern char     *ep_rev;
extern char     *ep_parttype;
extern char     *ep_desc;
extern char     *np_project;
extern char     *np_catalog;
extern char     *nn_itemname;
extern char     *np_rev;
extern char     *np_parttype;
extern char     *np_desc;
extern char     *stg_area;
extern char     *PDU_attr_name;
extern char     PDU_attr_value[40];  /*Used to store the value generated by a ppl*/
extern MEMptr   PDU_part_frm_search_bufr;
extern MEMptr   states_bufr;


/* Initialize the Part Operations Form */

void PDUpart_operations_init()
{
   PDU_refresh_gadgets[0] = EP_PROJECT_FLD;
   PDU_refresh_gadgets[1] = EP_CATALOG_FLD;
   PDU_refresh_gadgets[2] = EP_PARTNUM_FLD;
   PDU_refresh_gadgets[3] = EP_REV_FLD;
   PDU_refresh_gadgets[4] = EP_PARTTYPE_FLD;
   PDU_refresh_gadgets[5] = EP_DESC_FLD;
   
   np_project = NULL_STRING;
   np_catalog = NULL_STRING;
   nn_itemname = NULL_STRING;
   np_rev = NULL_STRING;
   np_desc = NULL_STRING;
   np_rev = NULL_STRING;
   np_parttype = NULL_STRING;
   
   ep_project = NULL_STRING;
   ep_catalog = NULL_STRING;
   en_itemname = NULL_STRING;
   ep_rev = NULL_STRING;
   ep_desc = NULL_STRING;
   ep_rev = NULL_STRING;
   ep_parttype = NULL_STRING;
   
   refresh->new_project = NULL_STRING;
   refresh->new_catalog = NULL_STRING;
   refresh->new_partid = NULL_STRING;
   refresh->new_revision = NULL_STRING;
   refresh->new_parttype = NULL_STRING;
   refresh->new_description = NULL_STRING;

   PDUfill_in_string1(&PDU_save_project, refresh->rev_project);
   PDUfill_in_string1(&PDU_save_catalog, refresh->rev_catalog);
   PDUfill_in_string1(&PDU_save_partid, refresh->rev_partid);
   PDUfill_in_string1(&PDU_save_revision, refresh->rev_revision);
   PDUfill_in_string1(&PDU_save_parttype, refresh->rev_parttype);
   PDUfill_in_string1(&PDU_save_description, refresh->rev_description);

   /* reset part field flags */
   end_np_cat_btn_flag = FALSE;
   end_np_part_btn_flag = FALSE;
   end_np_parttype_btn_flag = FALSE;
   end_ep_proj_btn_flag = FALSE;
   end_ep_cat_btn_flag = FALSE;
   end_ep_part_fld_flag = FALSE;
   end_ep_part_btn_flag = FALSE;
   end_ep_rev_btn_flag = FALSE;
   end_ep_parttype_btn_flag = FALSE;
   end_ep_desc_fld_flag = FALSE;
   end_ep_desc_btn_flag = FALSE;
   end_stg_area_btn_flag = FALSE;
   end_acl_wf_btn_flag = FALSE;
   end_move_to_state_btn_flag = FALSE;

     new_mode = TRUE;
     review_mode = FALSE;
     similar_mode = FALSE;
     change_mode = FALSE;

     FIg_erase(forms.part_operations_form_id,STORAGE_AREA_BTN);
     FIg_erase(forms.part_operations_form_id,ACL_NAME_BTN);

     /* Set SIMILAR, CHANGE, and REVIEW mode buttons' state to OFF */
     FIg_set_state_off(forms.part_operations_form_id,SIMILAR_MODE_BTN);
     FIg_set_state_off(forms.part_operations_form_id,CHANGE_MODE_BTN);
     FIg_set_state_off(forms.part_operations_form_id,REVIEW_MODE_BTN);

     /* Set the NEW mode buttons' state to ON */
     FIg_set_state_on(forms.part_operations_form_id,NEW_MODE_BTN);

     if (PDU_command == PDC_M_CREATE_TOP_DOWN)
        {
        /* Disable all command except the ADD and SEARCH commands */

        FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_BTN);
        FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);
        FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);
        FIg_disable(forms.part_operations_form_id, SEARCH_BTN);
        FIg_disable(forms.part_operations_form_id, SIMILAR_MODE_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_MODE_BTN);
        FIg_disable(forms.part_operations_form_id, REVIEW_MODE_BTN);
        }

     /* Erase SIMILAR_MODE_GRP */
     FIg_erase(forms.part_operations_form_id, SIMILAR_MODE_GRP);

     /* Erase CHANGE_MODE_GRP */
     FIg_erase(forms.part_operations_form_id, CHANGE_MODE_GRP);

     /* Erase all gadgets associated with the Existing Part Palette */
     FIg_erase(forms.part_operations_form_id, EXISTING_PART_GRP);
     FIg_erase(forms.part_operations_form_id, EXISTING_PART_BEZ);


     /* Erase the "Existing File Information" text on the File Information
        Palette */
     FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT); 
 
     /* Modify and display FILE_INFO_MCF */
     FIfld_set_num_vis_rows(forms.part_operations_form_id, FILE_INFO_MCF,6);
     FIg_display(forms.part_operations_form_id, FILE_INFO_MCF);

     /* Display the "New File Information" text on the File Information
        Palette */
     FIg_display(forms.part_operations_form_id, NEW_FILE_TXT);

     /* Disable all command except the ADD command */
     FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
     FIg_disable(forms.part_operations_form_id, DELETE_BTN);
     FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
     FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
     FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
     FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);
     FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);

     if (PDU_command != PDC_M_CREATE_TOP_DOWN)
       FIg_enable(forms.part_operations_form_id, SIMILAR_MODE_BTN);

     FIfld_pos_cursor(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
}

int part_operations_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text = NULL_STRING;
  int             max_row_length = 0;
  int             select_flag;
  int             string_len;
  int             attr_row = 0;
  void            PDMcancel_modify();
  void            PDUreset_part_form_flags();
  void            PDUclose_part_form_buffers();
  int           * fn;
  int             responses[1];
  int             i;
  int             top;
  int             column = 0;
  int             col_count;
  int             selected_part_rows = 0;
  int             rows = 0;
  int             act_row = 0;
  int             max_row = 0;
  int             max_rows = 0;
  int             no_headings;
  int             all_flag;
  int             col = 0;
  int             row = 0;
  int             pos = 0;
  long            attribute;
  int             status = PDM_S_SUCCESS;
  int             mcf_select = FALSE;
  int             n_name_col;
  int             n_syn_col;
  int             file_info_col;
  int             p_filedesc_col;
  int             n_cofilenm_col;
  int             n_status_col;
  int             found = 0;
  int             n_cifilenm_col;
  int             n_filetype_col;
  int             list_row;
  int             active_row = 0; 
  int             n_cisaname_col;
  int             value_row = 0;
  int             state = 0;
  int             length, select;
  int             row_selected = 0;
  int             num_rows = 0;
  int             desc_col = 0;
  int             name_col = 0;
  int             type_col = 0;
  int             file_col = 0;
  int             null_col = 0;
  char          * max_row_text = NULL;
  char          * cisaname_text = NULL;
  char          * strings[1];
  char          * cifile_text = NULL;
  char          * filedesc_text = NULL;
  char          * filetype_text = NULL;
  char          * partnum = NULL;
  char          * filename = NULL;
  char          * filetype = NULL;
  char          * filedesc = NULL;
  char          * str = NULL;
  char          * required = NULL;
  char         ** data_col;
  char         ** data_row;
  char         ** add1_data_col;
  char         ** PDU_attr_data_col;
  char         ** PDU_attr_data_row;
  char         ** fn_bufr_col;
  char         ** fn_bufr_row;
  char         ** headings;
  char         ** mcf_list_data = NULL;
  char         ** mcf_cat = NULL;
  char         ** mcf_part = NULL;
  char         ** mcf_rev = NULL;
  char         ** mcf_desc = NULL;
  char         ** mcf_flag = NULL;
  char            spec_char;
  char            type[5];
  char          * cofile_text = NULL;
  char          * value_text = NULL;
  char          * attr_text = NULL;
  char         ** attr_bufr_row;
  char         ** attr_bufr_col;
  char         ** attr_bufr_format;
  char         ** states_bufr_row;
  char         ** states_bufr_col;
  char         ** states_bufr_format;
  char         ** file_data_row = NULL;
  char         ** file_data_col = 0;
  char         ** sav_file_data_row = 0;
  char         ** sav_file_data_col = 0;
  char            *part_state = NULL;
  MEMptr          attr_bufr = NULL;
  MEMptr          states_bufr1 = NULL;
  MEMptr          filename_bufr = NULL;
  MEMptr          ep_data_bufr = NULL;
  MEMptr          ret_bufr = NULL;
  char         ** ep_data_bufr_row;
  char         ** ep_data_bufr_col;
  char         ** ep_data_bufr_format;
  char           *msg = NULL;
  char           *to_state = NULL;
  char            answer[2];
  int             state_col = 0;
  short           read = 1;
  short           write = 1;
  short           update = 1;
  short         filedesc_write = TRUE;
  short         filetype_write = TRUE;
  short         cifile_write = TRUE;
  short         cofile_write = TRUE;
  short         filedesc_read = TRUE;
  short         filetype_read = TRUE;
  short         cifile_read = TRUE;
  short         cofile_read = TRUE;
  short         filedesc_update = TRUE;
  short         filetype_update = TRUE;
  short         cifile_update = TRUE;
  short         cofile_update = TRUE;
  char new_catalog[50], new_partid[50], new_revision[50];
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[5], IsSuper[20];
 
  f_label = 0;
  PDU_form_id = forms.part_operations_form_id;

  PDUdismiss_subforms();

/* TR# 13941 5400. Only reset PDU_command if it is not = TOPDOWN  - MJG */
  if (PDU_command != PDC_M_CREATE_TOP_DOWN)
    PDU_command = 0;

  if (change_stat)
    FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,NULL_STRING);
  else
    change_stat = TRUE;

  switch ( g_label )
  {
    case SIMMODE_COPY_TGL:
        
         _pdm_debug("ENTER: SIMMODE_COPY_TGL",0);
         __DBGpr_com("In SIMMODE_COPY_TGL ");

         FIg_get_state(PDU_form_id,SIMMODE_COPY_TGL,&state);
         
         if (state == 0)
            {
            _pdm_debug("The SIMMODE_COPY_TGL is set to DO NOT COPY",0);

            PDU_simmode_copy = FALSE;
            FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);

            FIg_reset(fp, SIMILAR_MODE_MCF);
            FIg_display(fp, SIMILAR_MODE_MCF);
            }
         else if (state == 1)
            {
            _pdm_debug("The SIMMODE_COPY_TGL is set to COPY",0);
                                         
            FIg_display(PDU_form_id,SIMMODE_CHECKIN_TGL);
            PDU_simmode_copy = TRUE;

            _pdm_debug("ep_catalog = <%s>", ep_catalog);
            _pdm_debug("en_itemname = <%s>", en_itemname);
            _pdm_debug("ep_rev = <%s>", ep_rev);

            if ((strcmp(ep_catalog, "") == 0) ||
                (strcmp(en_itemname, "") == 0) ||
                (strcmp(ep_rev, "") == 0))
               {
               _pdm_debug("breaking; a part has not been entered yet", 0);
               status = PDM_I_ENTER_PART;
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               PDUmessage(status, 's');
               break;
               }

            if (PDMdebug_on)
              MEMprint_buffer("PDU_ep_data_bufr", PDU_ep_data_bufr, 
                              PDU_DEBUG_FILE);

            if (!PDU_ep_data_bufr)
              {
              PDUmessage(PDM_E_NULL_BUFFER, 's');
              break;
              }
   
            status = MEMbuild_array(PDU_ep_data_bufr);
            _pdm_status("MEMbuild_array", status);
   
            if (status != MEM_S_SUCCESS)
               {
               status = PDM_E_BUILD_BUFFER_ARRAY;
               PDUmessage(status,'s');
               break;
               }
  
            found = TRUE;
            status = PDUget_buffer_col(PDU_ep_data_bufr, "n_itemname", &name_col);
            if (status != PDM_S_SUCCESS)
              found = FALSE;
   
            if (found)
              {
              PDUsetup_buffer(PDU_ep_data_bufr, ROW, &data_row);
     
              PDUfill_in_string(&partnum, 
                          data_row[(PDU_ep_data_bufr->columns * 0) + name_col]);
              _pdm_debug("partnum = <%s>", partnum);
              if (partnum && (strcmp(partnum, "") != 0) && 
                 (strcmp(partnum, en_itemname) == 0))
                {
                _pdm_debug("using existing buffer", 0);
                status = PDUget_buffer_col(PDU_ep_data_bufr,"n_cofilename",
                                           &file_col);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status, 's');
                  break;
                  }
                status = PDUget_buffer_col(PDU_ep_data_bufr, "p_filedesc",
                                           &desc_col);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status, 's');
                  break;
                  }
                status = PDUget_buffer_col(PDU_ep_data_bufr, "n_filetype",
                                           &type_col);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status, 's');
                  break;
                  }
       
                for (row = 0; row < PDU_ep_data_bufr->rows; ++row)
                   {
                   PDUfill_in_string(&filedesc, 
                        data_row[(PDU_ep_data_bufr->columns * row) + desc_col]);
                   PDUfill_in_string(&filename, 
                        data_row[(PDU_ep_data_bufr->columns * row) + file_col]);
                   PDUfill_in_string(&filetype, 
                        data_row[(PDU_ep_data_bufr->columns * row) + type_col]);
     
                   FIfld_set_text(fp,SIMILAR_MODE_MCF,row,0,filedesc,FALSE);
                   FIfld_set_text(fp,SIMILAR_MODE_MCF,row,1,filename,FALSE);
                   FIfld_set_text(fp,SIMILAR_MODE_MCF,row,4,filetype,FALSE);
                   }
                 }
               }

             if ((!found) || ((strcmp(partnum, en_itemname) != 0)))
               {
               _pdm_debug("retrieving filename buffer", 0);
               if (filename_bufr)
                 {
                 status = MEMclose(&filename_bufr);
                 _pdm_status("MEMclose",status);
  
                 if (status != MEM_S_SUCCESS)
                    {
                    PDUmessage(status,'s');
                    break;
                    }
  
                 filename_bufr = NULL; 
                 }

              status = PDMget_filenames(ep_catalog,en_itemname,ep_rev,
                                        &filename_bufr);
              _pdm_status("PDMget_filenames", status);
  
              if ( status != PDM_S_SUCCESS )
                 {
                 msg = (char *) PDUtranslate_message(status);
                 FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                 PDUmessage(status, 's');
                 MEMclose(&filename_bufr);
                 break;
                 }
  
              status = MEMbuild_array(filename_bufr);
              _pdm_status("MEMbuild_array",status);
  
              if (status != MEM_S_SUCCESS)
                 {
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 PDUmessage(status,'s');
                 break;
                 }
  
              fn_bufr_col = (char **) filename_bufr->column_ptr;
              fn_bufr_row = (char **) filename_bufr->data_ptr;
  
              status = PDUget_col_number(filename_bufr,"n_cofilename",
                                         fn_bufr_col, &n_cofilenm_col);
              _pdm_status("PDUget_col_number",status);
  
              if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status,'s');
                 break;
                 }
  
              for (i = 0; i < filename_bufr->rows; ++i)
                  {
                  FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,i,1,
                                 fn_bufr_row[(filename_bufr->columns *
                                 i) + n_cofilenm_col],FALSE);
                  }
                }

             /* Add a blank row past the last row that contains an old local
                filename so the user can add a file with having to copy an
                old local filename */

             FIfld_get_num_rows(fp, SIMILAR_MODE_MCF, &num_rows);
             FIfld_set_text(fp,SIMILAR_MODE_MCF, num_rows,0,"",FALSE);
             FIfld_set_text(fp,SIMILAR_MODE_MCF, num_rows,1,"",FALSE);
             FIfld_set_text(fp,SIMILAR_MODE_MCF, num_rows,2,"",FALSE);
             FIfld_set_text(fp,SIMILAR_MODE_MCF, num_rows,3,"",FALSE);
             FIfld_set_text(fp,SIMILAR_MODE_MCF, num_rows,4,"",FALSE);
             }


         _pdm_debug("LEAVING: SIMMODE_COPY_TGL",0);
         break;

    case SIMMODE_CHECKIN_TGL:

         _pdm_debug("ENTER: SIMMODE_CHECKIN_TGL",0);

         FIg_get_state(PDU_form_id,SIMMODE_CHECKIN_TGL,&state);

         if (state == 0)
            {
            _pdm_debug("The SIMMODE_CHECKIN_TGL is set to DO NOT CHECKIN",0);
            PDU_simmode_checkin = FALSE;
            }
         else if (state == 1)
            {
            _pdm_debug("The SIMMODE_CHECKIN_TGL is set to CHECKIN",0);
            PDU_simmode_checkin = TRUE;
            }

         _pdm_debug("LEAVING: SIMMODE_CHECKIN_TGL",0);
         break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug ("User selected the HELP button", 0);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         Help_topic("part_form");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

      if(IsMDCRev)
      {
      /*printf("\n cat %s, part %s, rev %s", RevCat, RevPart, RevRev);*/
      status = SrVDUpdCMattrs( RevCat, RevPart,
                             RevRev, "p_incpartrpt", "N");
      status = SrVDUpdCMattrs( RevCat, RevPart,
                             RevRev, "p_mrpstruct", "N");
      status = SrVDUpdCMattrs( RevCat, RevPart,
                             RevRev, "p_explode", "Y");
      status = SrVDUpdCMattrs( RevCat, RevPart,
                             RevRev, "p_mrpfieldupd", "N");
      status = SrVDUpdCMattrs( RevCat, RevPart,
                             RevRev, "p_mrppart", RevCm);
      if(status) __DBGpr_com("could not update CM attrs");
      }
         PDUdismiss_subforms();
 
         _pdm_debug("ep_catalog = <%s>", ep_catalog);
         _pdm_debug("en_itemname = <%s>", en_itemname);

         if ((change_mode == TRUE) || (review_mode == TRUE) ||
             (similar_mode == TRUE)) 
            {
            if (((ep_catalog != NULL) && (strcmp(ep_catalog,"") != 0)) &&
               ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0)) &&
               (PDU_attr_bufr) && (PDU_data_bufr))
               {
               status = PDMcancel_modify_part(ep_catalog,
 					      en_itemname,
                                              ep_rev,
                                              PDU_attr_bufr, PDU_data_bufr);

               _pdm_status("PDMcancel_modify_part",status);

               if (status == PDM_S_SUCCESS)
                  {
                  fn = (int *)PDMcancel_modify;
                  exitdel(fn);
                  }
               else
                  {
                  PDUmessage(status,'s');
                  break;
                  }
               }

            /*Enable gadgets that were disable during change_mode because
              the part was locked*/

            FIg_enable(PDU_form_id,EP_PROJECT_FLD);
            FIg_enable(PDU_form_id,EP_CATALOG_FLD);
            FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
            FIg_enable(PDU_form_id,EP_REV_FLD);
            FIg_enable(PDU_form_id,EP_PROJECT_BTN);
            FIg_enable(PDU_form_id,EP_CATALOG_BTN);
            FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
            FIg_enable(PDU_form_id,EP_REV_BTN);
         }
          /* Erase the displayed form */

         FIf_erase (forms.part_operations_form_id);
         FIf_delete (forms.part_operations_form_id);
         forms.part_operations_form_id = 0;

	 PDUreset_part_form_flags();
         PDUclose_part_form_buffers();

         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
            {
            refresh->status = PDM_I_FORM_CANCEL;
            responses[0] = MOVE_ON;
            strings[0] = "";
            PDUprepare_queue(responses, strings, 1);
            break;
            }

         if (PDU_command != PDC_M_CREATE_TOP_DOWN)
           {
           PDUrefresh_local_files_form();
           FIf_display(forms.local_files_form_id);
           }

         /* added JBP  to terminate any attribute functions that might be */
         /* waiting on input */
         responses[0] = TERMINATE;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         /* Put the mode initializations in a separate file and call these 
            files according to the mode selected. */
 
         if ((change_mode) || (review_mode) || (similar_mode))
            {
            if (((ep_catalog != NULL) && (strcmp(ep_catalog,"") != 0)) &&
               ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0)) &&
               (PDU_attr_bufr) && (PDU_data_bufr))
               {
               status = PDMcancel_modify_part(ep_catalog,
 					      en_itemname,
                                              ep_rev,
                                              PDU_attr_bufr, PDU_data_bufr);

               _pdm_status("PDMcancel_modify_part",status);

               if (status == PDM_S_SUCCESS)
                  {
                  fn = (int *)PDMcancel_modify;
                  exitdel(fn);
                  }
               else
                  {
                  PDUmessage(status,'s');
                  break;
                  }
               }
            }

         np_project = NULL_STRING;
         np_catalog = NULL_STRING;
         nn_itemname = NULL_STRING;
         np_rev = NULL_STRING;
         np_desc = NULL_STRING;
         np_rev = NULL_STRING;
         np_parttype = NULL_STRING;
          
         ep_project = NULL_STRING;
         ep_catalog = NULL_STRING;
         en_itemname = NULL_STRING;
         ep_rev = NULL_STRING;
         ep_desc = NULL_STRING;
         ep_rev = NULL_STRING;
         ep_parttype = NULL_STRING;
          
         refresh->new_project = NULL_STRING;
         refresh->new_catalog = NULL_STRING;
         refresh->new_partid = NULL_STRING;
         refresh->new_revision = NULL_STRING;
         refresh->new_parttype = NULL_STRING;
         refresh->new_description = NULL_STRING;
 
         /*if (!new_mode)*/
           refresh->rev_project = NULL_STRING;
           refresh->rev_catalog = NULL_STRING;
           refresh->rev_partid = NULL_STRING;
           refresh->rev_revision = NULL_STRING;
           refresh->rev_parttype = NULL_STRING;
           refresh->rev_description = NULL_STRING;

           PDU_save_project = NULL_STRING;
           PDU_save_catalog = NULL_STRING;
           PDU_save_partid = NULL_STRING;
           PDU_save_revision = NULL_STRING;
           PDU_save_description = NULL_STRING;
           PDU_save_parttype = NULL_STRING;
 
         if (new_mode == TRUE)
            {
            PDUnew_mode();
            }

         else if (similar_mode == TRUE)
            {
            _pdm_debug("calling reset for similar mode", 0);
            PDUsimilar_mode();
            }

         else if (change_mode == TRUE)
            {
            _pdm_debug("calling reset for change mode", 0);
            PDUchange_mode();
            }
    
         else if (review_mode == TRUE)
            {
            PDUreview_mode();
            }

         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           {
           /* Disable all commands except the ADD and SEARCH commands */
   
           FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
           FIg_disable(forms.part_operations_form_id, DELETE_BTN);
           FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
           FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
           FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
           FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);
           FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);
           FIg_disable(forms.part_operations_form_id, SEARCH_BTN);
           FIg_disable(forms.part_operations_form_id, SIMILAR_MODE_BTN);
           FIg_disable(forms.part_operations_form_id, CHANGE_MODE_BTN);
           FIg_disable(forms.part_operations_form_id, REVIEW_MODE_BTN);
           }

         end_np_cat_btn_flag = FALSE;
         end_np_part_btn_flag = FALSE;
         end_np_parttype_btn_flag = FALSE;
         end_ep_proj_btn_flag = FALSE;
         end_ep_cat_btn_flag = FALSE;
         end_ep_part_fld_flag = FALSE;
         end_ep_part_btn_flag = FALSE;
         end_ep_rev_btn_flag = FALSE;
         end_ep_desc_fld_flag = FALSE;
         end_ep_desc_btn_flag = FALSE;
         end_move_to_state_btn_flag = FALSE;
         pdu_hold_stg_bufr_flag = FALSE;
         pdu_hold_acl_bufr_flag = FALSE;
         pdu_ep_stg_bufr_flag = FALSE;
         pdu_ep_acl_bufr_flag = FALSE;
         PDU_list_cat = FALSE;

         FIg_disable(fp, MOVE_STATE_BTN);
         PDUclose_part_form_buffers();

         break;

    case MOVE_STATE_BTN:     /* Sequenced to     */

         _pdm_debug("ENTER CASE: MOVE_STATE_BTN",0);
         __DBGpr_com("ENTER CASE: MOVE_STATE_BTN");
     
         _pdm_debug("ep_catalog = <%s>", ep_catalog);
         _pdm_debug("en_itemname = <%s>", en_itemname);
         _pdm_debug("ep_rev = <%s>", ep_rev);
     
         if ((strcmp(ep_catalog,"") == 0) || (strcmp(en_itemname,"") == 0) ||
             (strcmp(ep_rev,"") == 0))
           {
           PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
           break;
           }
     
         _pdm_debug("checking to see if part is checked in", 0);
         __DBGpr_com("checking to see if part is checked in");
         status = PDUget_file_status(ep_catalog,en_itemname,ep_rev,&part_state);
         _pdm_status("PDUget_file_status", status);
         if ((part_state) && (strcmp(part_state, "") != 0) && 
             (strcmp(part_state, "I") != 0))
           {
           PDUmessage(PDM_I_PART_CHECKIN, 's');
           break;
           }
     
         status = PDMcancel_modify_part(ep_catalog,en_itemname,ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);
         __DBGpr_com("DMcancel_modify_part");

         fn = (int *)PDMcancel_modify;
         exitdel(fn);

         status = PDMget_trans(ep_catalog,en_itemname,ep_rev);
         _pdm_status("PDMget_states",status);
         __DBGpr_com("PDMget_states");

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            break;
            }

         if (PDMdebug_on)
         MEMprint_buffers("THE PDU_states_bufr",PDU_states_bufr,PDU_DEBUG_FILE);

         status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&attr_bufr_row,
                                 &attr_bufr_col,&attr_bufr_format,
                                 &attr_bufr);

         status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&states_bufr_row,
                                 &states_bufr_col,&states_bufr_format,
                                 &states_bufr1);

         end_move_to_state_btn_flag = TRUE;

         status = PDUdelete_current_state_from_states_buffer(states_bufr1, 
                                                             &states_bufr);
         _pdm_status("PDUdelete_current_state_from_states_buffer", status);
         __DBGpr_com("PDUdelete_current_state_from_states_buffer");
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
 
        MEMclose(&states_bufr1);
        states_bufr1 = NULL;

        if (states_bufr->rows == 1)
          {
          status = MEMbuild_array(states_bufr);
          _pdm_status("MEMbuild_array",status);
    
          if (status != MEM_S_SUCCESS)
            {
            PDUmessage(PDM_E_BUILD_BUFFER_ARRAY, 's');
            break;
            }
    
          PDUsetup_buffer(states_bufr, ROW, &data_row);
          status = PDUget_buffer_col(states_bufr, "n_statename", &state_col);

          PDUfill_in_string(&to_state,
                            data_row[(states_bufr->columns*0) + state_col]);
          msg = (char*)PDUtranslate_message_and_vars(PDP_P_TRANS_PART,to_state);
          UI_prompt(msg);
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
          /*printf("\n answer %s", answer );*/

/*
          if (msg)
            {
            free(msg);
            msg = NULL;
            }
*/
          msg = (char*)PDUtranslate_message(PDM_E_CLEAR_FIELD);
          UI_prompt(msg);
    
          _pdm_debug("answer = <%s>", answer);
    
          if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
             {
             status = PDM_E_CMD_CANCELLED;
             end_move_to_state_btn_flag = FALSE;
             PDUmessage(status,'s');
             break;
             }
          }


       if(to_state)
       {
          __DBGpr_str("to_state ", to_state);
          if(!strcmp(to_state, RELEASE))
          {
            __DBGpr_com("Releasing Part.");
            status = CMRelease();
            if(status)
              break;
          }
       }
       status = PDMcancel_modify_part(ep_catalog,en_itemname,ep_rev,
                                      PDU_attr_bufr, PDU_data_bufr);
       _pdm_status("PDMcancel_modify_part",status);
       __DBGpr_com("PDMcancel_modify_part");

       fn = (int *)PDMcancel_modify;
       exitdel(fn);

       PDUsetup_single_buffer(states_bufr);

       PDU_form_id = forms.part_operations_form_id;

       PDU_gadget_labels[0] = STATE_NAME_FLD;
    
       all_flag = FALSE;
       no_headings = 3;
       headings = (char **) malloc (sizeof (char *) * no_headings);
       memset((char *)headings, NULL, sizeof (char *) * no_headings);
    
       PDUfill_in_string(&headings[0], "n_statename");
       PDUfill_in_string(&headings[1], "n_stateno");
       PDUfill_in_string(&headings[2], "n_transitionname");
    
       PDUsetup_popup_list(headings, no_headings, all_flag, states_bufr);
       _pdm_status("PDUsetup_popup_list",status);
       __DBGpr_com("PDUsetup_popup_list");
    
       PDUfree_string_array(&headings,no_headings);
    
       all_flag = FALSE;
       no_headings = 1;
       headings = (char **) malloc (sizeof (char *) * no_headings);
       memset((char *)headings, NULL, sizeof (char *) * no_headings);
    
       PDUfill_in_string(&headings[0], "n_statename");
    
       PDUsetup_form_fields(headings, no_headings, all_flag, states_bufr);
       _pdm_status("PDUsetup_form_fields",status);
    
       PDUfree_string_array(&headings,no_headings);
   
       msg = (char *)PDUtranslate_message(PDM_I_PART_TRANSITION); 
       status = PDUmcf_list_form(msg);
       _pdm_status("PDUmcf_list_form",status);
       __DBGpr_com("PDUmcf_list_form");
    
       break;

    case ADD_TO_PROJECT_BTN:     /* Member of group PART_OPERATIONS_GRP  */

         _pdm_debug("ENTER CASE: ADD_TO_PROJECT_BTN",0);

         if ((refresh->rev_project == NULL) ||
             (strcmp(refresh->rev_project, "")  == 0))
           {
           msg = (char *) PDUtranslate_message(PDM_E_PROJECT_FLD_BLANK);
           FIg_set_text(fp,FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_PROJECT_FLD_BLANK, 's');
           break;
           }

         status = PDUverify_part_data(fp);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         responses[0] = EX_CMD_KEY;
   
         strings[0] = "PDAdPrPj";
   
         status = PDUprepare_queue (responses, strings, 1);
         _pdm_status("PDUprepare_queue",status);

         break;

    case SEARCH_BTN:     /* Member of group PART_OPERATIONS_GRP  */

    _pdm_debug("ENTER CASE: SEARCH_BTN",0);

         PDU_form_id = 0;
         PDU_form_type = PART_FORM;
         PDU_search_type = PARTS;
         PDU_calling_form = forms.part_operations_form_id;

         FIf_erase(forms.part_operations_form_id);

         _pdm_debug("calling part selection form", 0);

         SelectOrPlacePart(TRUE, FALSE, fp);

         break;

    case DELETE_BTN:     /* Member of group PART_OPERATIONS_GRP  */
                             /* Sequenced to    */
    _pdm_debug("ENTER CASE: DELETE_BTN",0);

    _pdm_debug("ep_catalog = <%s>", ep_catalog);
    _pdm_debug("en_itemname = <%s>", en_itemname);
    _pdm_debug("ep_rev = <%s>", ep_rev);

    if (((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0)) ||
       ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0)) ||
       ((ep_rev == NULL) || (strcmp(ep_rev,"") == 0)))
       {
       msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
       FIg_set_text(fp,FI_MSG_FIELD, msg);
       PDUmessage(PDM_E_NO_PARTS_SELECTED , 's');
       break;
       }

    responses[0] = EX_CMD_KEY;

    strings[0] = "PDDlPr";

    status = PDUprepare_queue (responses, strings, 1);
    _pdm_status("PDUprepare_queue",status);

    if (status != PDM_S_SUCCESS)
      _pdm_debug("PDUprepare_queue FAILED", 0);

    if (status == 0)
       break;

    break;

    case ADD_BTN:     /* Member of group PART_OPERATIONS_GRP  */

    _pdm_debug("ENTER CASE: ADD_BTN",0);
    __DBGpr_com("In ADD_BTN ");

    if ((strcmp(np_catalog,"") == 0) || (strcmp(nn_itemname,"") == 0) ||
        (strcmp(np_rev,"") == 0))
      {
      msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
      FIg_set_text(fp,FI_MSG_FIELD, msg);
      PDUmessage(PDM_E_NO_PARTS_SELECTED , 's');
      FIg_set_state_off(forms.part_operations_form_id,ADD_BTN);
      break;
      }
    if (strcmp(np_parttype, "") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_E_ENTER_PARTTYPE);
      FIg_set_text(fp,FI_MSG_FIELD, msg);
      PDUmessage(PDM_E_ENTER_PARTTYPE , 's');
      FIg_set_state_off(forms.part_operations_form_id,ADD_BTN);
      break;
      }

    if (PDU_attr_bufr)
      {
      _pdm_debug("checking to see if filename is required", 0);
      MEMbuild_array(PDU_attr_bufr);
      PDUsetup_buffer(PDU_attr_bufr, ROW, &data_row);
      attr_row = PDUfind_attr_in_buffer(PDU_attr_bufr, "n_cofilename");
      if (attr_row != -1)
        {
        status = PDUget_buffer_col(PDU_attr_bufr, "n_null", &null_col);
        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }
        PDUfill_in_string(&required,
               data_row[(PDU_attr_bufr->columns * attr_row)+null_col]);
        _pdm_debug("required = <%s>", required);

        if ((required) && (strcmp(required,"N")==0)) /* data cannot be NULL */
          {
          /* check to see if a filename has been filled in */

          if (new_mode)
            {
            FIfld_get_text_length(fp, FILE_INFO_MCF, 0,1, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text,NULL,sizeof (char) * length + 1);
            FIfld_get_text (fp, FILE_INFO_MCF, 0, 1, length+1,
                            (unsigned char *)text, &select_flag, &pos );
            }
	  else if (similar_mode)
            {
            FIfld_get_text_length(fp, SIMILAR_MODE_MCF, 0,2, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text,NULL,sizeof (char) * length + 1);
            FIfld_get_text (fp, SIMILAR_MODE_MCF, 0, 2, length+1,
                          (unsigned char *)text, &select_flag, &pos );
            }
          if (!text)
            {
            PDUfill_in_string(&PDU_attr_name, "Local Filename");
            PDUmessage(PDM_E_REQ_ATTR_VALUE, 's');
            break;
            }
          if ((text) && (strcmp(text, "") == 0))
            {
            PDUfill_in_string(&PDU_attr_name, "Local Filename");
            PDUmessage(PDM_E_REQ_ATTR_VALUE, 's');
            break;
            }
          }
        }

      _pdm_debug("checking to see if cifilename is required", 0);
      MEMbuild_array(PDU_attr_bufr);
      PDUsetup_buffer(PDU_attr_bufr, ROW, &data_row);
      attr_row = PDUfind_attr_in_buffer(PDU_attr_bufr, "n_cifilename");
      if (attr_row != -1)
        {
        status = PDUget_buffer_col(PDU_attr_bufr, "n_null", &null_col);
        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }
        PDUfill_in_string(&required,
               data_row[(PDU_attr_bufr->columns * attr_row)+null_col]);
        _pdm_debug("required = <%s>", required);

        if ((required) && (strcmp(required,"N")==0)) /* data cannot be NULL */
          {
          /* check to see if a cifilename has been filled in */

          if (new_mode)
            {
            FIfld_get_text_length(fp, FILE_INFO_MCF, 0,2, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text,NULL,sizeof (char) * length + 1);
            FIfld_get_text (fp, FILE_INFO_MCF, 0, 2, length+1,
                            (unsigned char *)text, &select_flag, &pos );
            }
	  else if (similar_mode)
            {
            FIfld_get_text_length(fp, SIMILAR_MODE_MCF, 0,3, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text,NULL,sizeof (char) * length + 1);
            FIfld_get_text (fp, SIMILAR_MODE_MCF, 0, 3, length+1,
                          (unsigned char *)text, &select_flag, &pos );
            }
          if (!text)
            {
            PDUfill_in_string(&PDU_attr_name, "Storage Filename");
            PDUmessage(PDM_E_REQ_ATTR_VALUE, 's');
            break;
            }
          if ((text) && (strcmp(text, "") == 0))
            {
            PDUfill_in_string(&PDU_attr_name, "Storage Filename");
            PDUmessage(PDM_E_REQ_ATTR_VALUE, 's');
            break;
            }
          }
        }
      }
    else
      _pdm_debug("not checking if filename is required; attr_bufr is NULL", 0);

    if (similar_mode == TRUE) 
      {
      if ((strcmp(ep_catalog,"") == 0) || (strcmp(en_itemname,"") == 0) ||
          (strcmp(ep_rev,"") == 0))
        {
        msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
        FIg_set_text(fp,FI_MSG_FIELD, msg);
        PDUmessage(PDM_E_NO_PARTS_SELECTED , 's');
        break;
        }

   /*printf("\n catalog %s, part %s, rev %s", ep_catalog,en_itemname,ep_rev);*/
      if (strcmp(ep_parttype, "") == 0)
        {
        msg = (char *) PDUtranslate_message(PDM_E_ENTER_PARTTYPE);
        FIg_set_text(fp,FI_MSG_FIELD, msg);
        PDUmessage(PDM_E_ENTER_PARTTYPE , 's');
        FIg_set_state_off(forms.part_operations_form_id,ADD_BTN);
        break;
        }
      if (PDU_simmode_copy)
        {
        _pdm_debug("verifying filename for similar mode copy", 0);
        FIfld_get_num_rows(fp, SIMILAR_MODE_MCF, &num_rows);
        cofile_text = NULL_STRING;
        found = FALSE;
        for (row = 0; row < num_rows; ++row)
           {
           FIfld_get_text_length(fp,SIMILAR_MODE_MCF, row, 2, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp, SIMILAR_MODE_MCF, row, 2, length,
                          (unsigned char *)text, &select, &pos);
           PDUfill_in_string1(&cofile_text,text);
           _pdm_debug("cofile_text = <%s>", cofile_text);
   
           if ((cofile_text) && (strcmp(cofile_text, "") != 0))
             {
             _pdm_debug("filename found", 0);
             found = TRUE;
             break;
             }
           }
        if (!found)
           {
           _pdm_debug("no filenames found in MCF", 0);
           PDUmessage(PDM_E_FILENAME_BLANK, 's');
           msg = (char *) PDUtranslate_message(PDM_E_FILENAME_BLANK);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           FIg_set_state_off(forms.part_operations_form_id,ADD_BTN);
           break;
           }
        }
      }

    if (new_mode)
       {
       PDUfill_in_string(&refresh->rev_project,refresh->new_project);
       PDUfill_in_string(&refresh->rev_catalog,np_catalog);
       PDUfill_in_string(&refresh->new_parttype,np_parttype);
       }

    if (PDU_command != PDC_M_CREATE_TOP_DOWN)
      {
/*
      if (new_mode)
        {
        refresh->command = PDC_M_CREATE_ELEMENT;
        strings[0] = "PDAdPr";
        }
      else if (similar_mode)
        {
        refresh->command = PDC_M_CREATE_LIKE_PART;
        strings[0] = "PDCpCPr";
        }
*/

      /* New CM function call to handle events */
      /*printf("\n NEW %s\t%s\t%s\nOLD%s\t%s\t%s",
       *      refresh->new_catalog, refresh->new_partid, refresh->new_revision,
       *      refresh->rev_catalog, refresh->rev_partid, refresh->rev_revision);
       **/
      
      if ( similar_mode )
      {
        __DBGpr_com("in similar_mode");
	status = SrCMCopySim();
	if ( status )
	{
	  __DBGpr_com( "Couldnot Revise M D C.");
	  break;
	}
	
	strcpy(RevCat, refresh->new_catalog);
	strcpy(RevPart, refresh->new_partid);
	strcpy(RevRev, refresh->new_revision);
	status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision, ARsel, CMmng,
                                   DCCsel, Mdc, IsSuper);
	strcpy(RevCm, "Y");
	// SSR 12 JAN TR 1604
        //if(strcmp(CMmng, "Y"))
        //  strcpy(RevCm, "N");
        IsMDCRev = 1;
        if(strcmp(RevPart, refresh->rev_partid))// New part generation
          strcpy(RevCm, "N"); // New part is not CM managed.
        else
	  strcpy(RevCm, CMmng);// Old part; copy existing flag.
      }

      refresh->command = PDC_M_CREATE_ELEMENT;
      strings[0] = "PDAdPr";
      responses[0] = EX_CMD_KEY;

      status = PDUprepare_queue (responses, strings, 1);
      _pdm_status("PDUprepare_queue",status);
      }
    else
      {
      _pdm_debug("entering case for add topdown part", 0);
      /* get the filename */
      FIfld_get_text_length(fp, FILE_INFO_MCF, 0, 1, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text(fp, FILE_INFO_MCF, 0, 1, length,(unsigned char *)text, 
                     &select, &pos);
      _pdm_debug("text = <%s>", text);

      if ((text == NULL) || (strcmp(text, "") == 0))
         {
         PDUmessage(PDM_E_FILENAME_BLANK, 's');
         msg = (char *) PDUtranslate_message(PDM_E_FILENAME_BLANK);
         FIg_set_text(fp, FI_MSG_FIELD, msg);
         break;
         }

      refresh->status = PDM_S_SUCCESS;
      responses[0] = MOVE_ON;
      strings[0] = "";
      PDUprepare_queue(responses, strings, 1);
      break;
      }

    /* SSR try to update the new flage here */
    if (status != PDM_S_SUCCESS)
      _pdm_debug("PDUprepare_queue FAILED", 0);

    if (status == 0)
       break;

    PDUmessage(status,'s');

    break;

    case WHERE_USED_BTN:     /* Member of group PART_OPERATIONS_GRP  */

    _pdm_debug("ENTER CASE: WHERE_USED_BTN",0);

    _pdm_debug("ep_catalog = <%s>", ep_catalog);
    _pdm_debug("en_itemname = <%s>", en_itemname);
    _pdm_debug("ep_rev = <%s>", ep_rev);
    _pdm_debug("ep_parttype = <%s>", ep_parttype);

    if ((strcmp(ep_catalog,"") != 0) &&
        (strcmp(en_itemname,"") != 0) &&
        (strcmp(ep_rev,"") != 0))
       {
       FIf_erase(forms.part_operations_form_id);
       PDU_calling_form = forms.part_operations_form_id;
       PDUreports_form();
       }
    else
       {
       PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
       msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
       FIg_set_text(fp, FI_MSG_FIELD, msg);
       }

       break;

    case CHANGE_BTN:     /* Member of group PART_OPERATIONS_GRP  */

    _pdm_debug("ENTER CASE: CHANGE_BTN",0);

    if (change_mode != TRUE)
      break;

    if ((strcmp(ep_catalog,"") == 0) || (strcmp(en_itemname,"") == 0) ||
        (strcmp(ep_rev,"") == 0))
       {
       status = PDM_I_ENTER_PART;
       msg = (char *) PDUtranslate_message(status);
       FIg_set_text(fp, FI_MSG_FIELD, msg);
       PDUmessage(status, 's');
       FIg_set_state_off(forms.part_operations_form_id,CHANGE_BTN);
       break;
       }

    if (strcmp(ep_parttype, "") == 0)
      {
      status = PDM_E_ENTER_PARTTYPE;
      msg = (char *) PDUtranslate_message(status);
      FIg_set_text(fp, FI_MSG_FIELD, msg);
      PDUmessage(status, 's');
      FIg_set_state_off(forms.part_operations_form_id,ADD_BTN);
      }

    change_part = TRUE;

    responses[0] = EX_CMD_KEY;
    strings[0] = "PDCPr";

    status = PDUprepare_queue (responses, strings, 1);
    _pdm_status("PDUprepare_queue",status);

    PDUmessage(status,'s');

    break;

    case FLAG_CANCELFLAG_BTN:     /* Member of group PART_OPERATIONS_GRP  */

    _pdm_debug("ENTER CASE: FLAG_CANCELFLAG_BTN",0);

         FIg_display(fp, FLAG_OPERATIONS_GRP);
         FIg_enable(fp,FLAG_OPERATIONS_GRP);

         break;

    case DELETE_FILES_BTN:     /* Member of group PART_OPERATIONS_GRP  */

    _pdm_debug("ENTER CASE: DELETE_FILES_BTN",0);

    if ((change_mode == TRUE) &&
        (strcmp(ep_catalog,"") == 0) ||
        (strcmp(en_itemname,"") == 0) ||
        (strcmp(ep_rev,"") ==  0))
       {
       msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
       FIg_set_text(fp, FI_MSG_FIELD, msg);
       PDUmessage(PDM_I_ENTER_PART, 's');
       break;
       }

      /* Check if any files were selected to be deleted */

      FIfld_get_num_rows(fp,EXISTING_FILES_MCF,&num_rows);

      for (i=0; i < num_rows; ++i)
          {
          FIfld_set_active_row(fp,EXISTING_FILES_MCF, i,0);
          FImcf_get_select(fp,EXISTING_FILES_MCF,i, &row_selected);

          if (row_selected == TRUE)
             {
             found = 1;
             break;
             }
          }

       if (found == 0)
          {
          msg = (char *) PDUtranslate_message(PDM_E_SELECT_FILE);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_SELECT_FILE, 's');
          break;
          }
 
    responses[0] = EX_CMD_KEY;

    strings[0] = "PDDlFl";

    status = PDUprepare_queue (responses, strings, 1);
    _pdm_status("PDUprepare_queue",status);

    if (status != PDM_S_SUCCESS)
      _pdm_debug("PDUprepare_queue FAILED", 0);

    if (status == 0)
       break;

    break;

    case ATTRIBUTE_VALUE_MCF:     /* Sequenced to     */

    _pdm_debug("ENTER CASE: ATTRIBUTE_VALUE_MCF",0);

    if ((new_mode == TRUE) || (similar_mode == TRUE))
       {
       _pdm_debug("np_catalog = <%s>", np_catalog);

       if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) 
          {
          msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_I_ENTER_CATALOG, 's');
          break;
          }
       }

    else if (change_mode == TRUE) 
       {
       _pdm_debug("ep_catalog = <%s>", ep_catalog);

       if ((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0)) 
          {
          msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_I_ENTER_CATALOG, 's');
          break;
          }
       }

       FImcf_get_active_col(fp, ATTRIBUTE_VALUE_MCF, &col, &pos);
       FIfld_get_active_row(fp, ATTRIBUTE_VALUE_MCF, &row, &pos);
       _pdm_debug("active column = %d", col);
       _pdm_debug("active row = %d", row);

       if (col == 0)
          {
          /* check attr_name for "*" */
          FIfld_get_text_length(fp,ATTRIBUTE_VALUE_MCF, row, col, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, ATTRIBUTE_VALUE_MCF, row, col, length, 
                         (unsigned char *)text, &select, &pos);
          PDUfill_in_string(&attr_text, text);
          if (text[0] == '*')
             {
             /* strip off '*' from front of attr_name */
             attr_text = attr_text + 1;
             FIfld_pos_cursor(fp, ATTRIBUTE_VALUE_MCF, row, pos, 0, 0, 0, 0);
/*
 * TR 139526080. 30/may/95 - raj.
 *
 * The pull down list created by GRcreate_pull_down_list() does not get
 * cancelled when the RIGHT_BUTTON is pressed.
 *
 * This happens on Solaris SPARC, too. Fix for this is needed from GRNUC.
 *
 * The Pull down list 'PDU_value_pulldown' is created with MAX_ROWS
 * number of rows in function PDUpart_form(), PDUpart_form.c, this
 * number is usually greater than the number of text strings to be
 * placed in the list, which come form 'PDU_list_bufr'.
 *
 * This means that blank rows are displayed in the pulldownlist after the
 * text strings. This is generally okay since the processing routine (?)
 * does not allow these rows to be selected.
 *
 * However, on Intel Solaris (SPARC too), the pulldownlist does not get
 * cancelled when RIGHT_BUTTON is pressed. Instead, control returns from
 * GRproc_pull_down_list (called below) and the pulldownlist still stays up.
 *
 * At this point the user is allowed select blank rows with unpredictable
 * results since the blank row number used to index into 'PDU_value_list'
 * under case VALUE_LIST_FIELD: will be out of bounds.
 *
 * Kludge. Create a new pulldownlist with exactly the same number of rows
 * as in 'PDU_list_buffer'. No blank rows, no problems.
 *
 */
               {
                 int status, buffer_number, row;
                 char **attr_data;

                 /*
                  * Find the list size (no. of text string to be displayed)
                  * from 'PDU_list_bufr'.
                  */
                 status = MEMbuild_array(PDU_attr_bufr); 
                 _pdm_status("MEMbuild_array(PDU_attr_bufr)", status);
                 if (status != MEM_S_SUCCESS)
                    return(PDM_E_BUILD_BUFFER_ARRAY);

		 /*
                  * see 'attr_text' name is a synonym or name and
                  * get the attribute's index in buffer PDU_attr_bufr.
                  */
		 row = PDUfind_attr_by_synonym(attr_text, PDU_attr_bufr);
		 if (row == -1 )
		   row = PDUfind_attr_in_buffer(PDU_attr_bufr, attr_text);

                 /* get buffer no from PDU_attr_bufr */
                 attr_data = (char **)PDU_attr_bufr->data_ptr; 
                 sscanf
                 (
                 attr_data[(PDU_attr_bufr->columns * row) + PDU_NFM_LISTNO_COL],
                 "%d",
                 &buffer_number
                 );
                 _pdm_debug("buffer_number = %d ", buffer_number);

                 if (buffer_number >= 1)
                 {
                    int		save_pulldown;
                    static int	local_pulldown = -1;
                    int		list_size;

		    status = MEMreset_buffer_no(PDU_list_bufr,
                                                buffer_number);
		    _pdm_status("MEMreset_buffer_no", status);

		    if (status != MEM_S_SUCCESS)
		      return(PDM_E_RESET_BUFFER);
		 
		    list_size = PDU_list_bufr->rows;

                    /* save exisiting pull down list. */
                    save_pulldown = PDU_value_pulldown;

                    /* create new pull down list. */
                    /* First, delete the previous one,
                       stored in static var. local_pulldown. */
                    if (local_pulldown != -1)
                    {
                      GRdelete_pull_down_list(local_pulldown);
                      local_pulldown = -1;
                    }

                    GRcreate_pull_down_list(PART_FORM,
                              forms.part_operations_form_id,
                              VALUE_LIST_FIELD,
                              list_size, VIS_ROWS,
                              NULL,
                              0, 1, &local_pulldown);

                    /* Assign locally created pulldownlist to
                       golbal var. to be used in fn. below. */
                    PDU_value_pulldown = local_pulldown;

                    status = PDUprocess_pulldown_list(attr_text,
                                                      PDU_attr_bufr,
                                                      PDU_list_bufr);

                    /* restore saved value of global var. */
                    PDU_value_pulldown = save_pulldown;
                 }
                 else	/* Business as usual */
                 {
             status = PDUprocess_pulldown_list(attr_text,PDU_attr_bufr,
                                               PDU_list_bufr);
                 }
               }	/* end of local block added by raj */
             }
          else
             {
             FIfld_pos_cursor(fp, ATTRIBUTE_VALUE_MCF, row, pos, 1, 1, 0, 0);
             break;
             }
          }
       else
          {
          FIfld_get_text_length(fp,ATTRIBUTE_VALUE_MCF, row, col, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, ATTRIBUTE_VALUE_MCF, row, col, length, 
                         (unsigned char *)text, &select, &pos);
          PDUfill_in_string(&value_text, text);
          if (value_text == NULL) 
             PDUfill_in_string1(&value_text, "");
          _pdm_debug("value_text = <%s>", value_text);


          _pdm_debug("getting attribute name", 0);
          FIfld_get_text_length(fp,ATTRIBUTE_VALUE_MCF, row,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp, ATTRIBUTE_VALUE_MCF, row, 0, length, 
                         (unsigned char *)text, &select, &pos);
          PDUfill_in_string(&attr_text, text);
          _pdm_debug("attr_text = <%s>", attr_text);

          if ((attr_text == NULL) || (strcmp(attr_text, "") == 0))
             break;

          str = strstr(attr_text, "(min:");

          if (str)
             {
             /* Attribute is a range */
             /* Strip off the min and max value text that was appended to the
                attribute when added to the catalog attributes */
             *((char *) strstr(attr_text, "(min:")) = '\0';
             *((char *) strrchr(attr_text, ' ')) = '\0';
             }

          if ((value_text) && (strlen(value_text)))
            {
            status = PDUvalidate_data_value(attr_text, value_text,
                                          PDU_attr_bufr, PDU_list_bufr);
            _pdm_status("PDUvalidate_data_value", status);

            if (status == PDM_E_REQATTR_NOT_FOUND)
               {
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               PDUmessage(status, 's');
               break;
               }
  
            if (status == PDM_E_AT_MAXLEVEL)
               {
               FIfld_set_text(forms.part_operations_form_id,
                              ATTRIBUTE_VALUE_MCF,value_row,1,"50",FALSE);
               PDUfill_in_string(&value_text, "50");
               status = PDM_S_SUCCESS;
               }
  
            if (status == PDM_E_INVALID_INPUT)
               {
               PDUmessage(status, 's');
               FIfld_set_text(fp, ATTRIBUTE_VALUE_MCF, row, col, "", FALSE);
               break;
               }

            if (status == PDM_E_FAILURE)
               {
               status = PDM_E_ATTR_VALUE_GEN_FUNC;
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               PDUmessage(status, 's');
               FIfld_set_text(fp, ATTRIBUTE_VALUE_MCF, row, col, "", FALSE);
               break;
               }
            if (status != PDM_S_SUCCESS)
               {
               PDUmessage(status, 's');
               msg = (char *) PDUtranslate_message(PDM_E_BAD_DATA);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIfld_set_text(fp, ATTRIBUTE_VALUE_MCF,value_row,1,"",FALSE);
               break;
               }
             }
             
          FImcf_set_active_col(fp, ATTRIBUTE_VALUE_MCF, 1,1);

          status = MEMbuild_array(PDU_attr_bufr);
          _pdm_status("MEMbuild_array",status);

          if (status != MEM_S_SUCCESS)
             {
             status = PDM_E_BUILD_BUFFER_ARRAY;
             msg = (char *) PDUtranslate_message(status);
             FIg_set_text(fp, FI_MSG_FIELD,msg);
             PDUmessage(status, 's');
             break;
             }

          PDU_attr_data_col = (char **) PDU_attr_bufr->column_ptr;
          PDU_attr_data_row = (char **) PDU_attr_bufr->data_ptr;

          status = PDUget_col_number(PDU_attr_bufr,"n_name",PDU_attr_data_col,
                            &n_name_col);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
          status =PDUget_col_number(PDU_attr_bufr,"n_synonym",PDU_attr_data_col,
                            &n_syn_col);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }

          _pdm_debug("checking attr for *", 0);
          if (attr_text[0] == '*')
            attr_text = attr_text + 1;
          _pdm_debug("attr_text = <%s>", attr_text);

          for (i = 0; i < PDU_attr_bufr->rows; i++)
             {
             if (strcmp(PDU_attr_data_row[(PDU_attr_bufr->columns * i) +                                n_syn_col], attr_text) == 0)
                {
                _pdm_debug("writing value_text <%s> to buffer", value_text);
                _pdm_debug("column = %d", i + 1);
                status = MEMwrite_data(PDU_data_bufr,value_text,1,i + 1);
                if (PDU_data_bufr->rows > 1)
                  status = MEMwrite_data(PDU_data_bufr,value_text,2,i + 1);
                if (status != MEM_S_SUCCESS)
                   {
                   status = PDM_E_WRITE_BUFFER;
                   msg = (char *) PDUtranslate_message(status);
                   FIg_set_text(fp, FI_MSG_FIELD,msg);
                   PDUmessage(status, 's');
                   break;
                   }
                else 
                   {
                   found = 1;
                   }
                }
             else if (strcmp(PDU_attr_data_row[(PDU_attr_bufr->columns * i) +                              n_name_col], attr_text) == 0)
                {
                _pdm_debug("writing value_text <%s> to buffer", value_text);
                _pdm_debug("column = %d", i + 1);
                status = MEMwrite_data(PDU_data_bufr,value_text,1,i + 1);
                if (PDU_data_bufr->rows > 1)
                  status = MEMwrite_data(PDU_data_bufr,value_text,2,i + 1);
                if (status != MEM_S_SUCCESS)
                   {
                   status = PDM_E_WRITE_BUFFER;
                   msg = (char *) PDUtranslate_message(status);
                   FIg_set_text(fp, FI_MSG_FIELD,msg);
                   PDUmessage(status, 's');
                   break;
                   }
                else
                   {
                   found = 1;
                   }
                }

             if (found == 1)
                break;
             } 

           if (PDMdebug_on)
             MEMprint_buffer("PDUdata_bufr", PDU_data_bufr, PDU_DEBUG_FILE);

           /* Set number of row in ATTRIBUTE_VALUE_MCF */
           FIfld_get_num_rows(fp, ATTRIBUTE_VALUE_MCF, &num_rows);
           FIfld_set_num_rows(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                              num_rows);

           /*FIfld_set_active_char(fp, ATTRIBUTE_VALUE_MCF,0,0,0);*/
           }

           break;


    case FLAG_ARCHIVE_BTN:     /* Member of group FLAG_OPERATIONS_GRP  */

         _pdm_debug("ENTER CASE: FLAG_ARCHIVE_BTN",0);

         status = PDUverify_part_data(fp);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         FIg_get_state(fp, FLAG_CANCELFLAG_TGL, &state);

         if (state == 0)
            {
            _pdm_debug("Flag part for archive", 0);
            responses[0] = EX_CMD_KEY;
            strings[0] = "PDFlPrAr";

            status = PDUprepare_queue (responses, strings, 1);
            _pdm_status("PDUprepare_queue",status);
            }
         else
            {
            _pdm_debug("unflag part for archive", 0);
            responses[0] = EX_CMD_KEY;
            strings[0] = "PDCnFlAr";

            status = PDUprepare_queue (responses, strings, 1);
            _pdm_status("PDUprepare_queue",status);
            }

         break;

    case FLAG_DELETE_BTN:     /* Member of group FLAG_OPERATIONS_GRP  */

         _pdm_debug("ENTER CASE: FLAG_DELETE_BTN",0);

         status = PDUverify_part_data(fp);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         FIg_get_state(fp, FLAG_CANCELFLAG_TGL, &state);

         if (state == 0)
            {
            _pdm_debug("Flag part for delete", 0);
            responses[0] = EX_CMD_KEY;
            strings[0] = "PDFlPrDl";

            status = PDUprepare_queue (responses, strings, 1);
            _pdm_status("PDUprepare_queue",status);
            }
         else
            {
            _pdm_debug("unflag part for delete", 0);
            responses[0] = EX_CMD_KEY;
            strings[0] = "PDCnFlDl";

            status = PDUprepare_queue (responses, strings, 1);
            _pdm_status("PDUprepare_queue",status);
            }

         break;

    case FLAG_BACKUP_BTN:     /* Member of group FLAG_OPERATIONS_GRP  */

         _pdm_debug("ENTER CASE: FLAG_BACKUP_BTN",0);

         status = PDUverify_part_data(fp);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         FIg_get_state(fp, FLAG_CANCELFLAG_TGL, &state);

         if (state == 0)
           {
           _pdm_debug("Flag part for backup", 0);
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDFlPrBc";

           status = PDUprepare_queue (responses, strings, 1);
           _pdm_status("PDUprepare_queue",status);
           }
         else
           {
           _pdm_debug("unflag part for backup", 0);
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDCnFlBc";

           status = PDUprepare_queue (responses, strings, 1);
           _pdm_status("PDUprepare_queue",status);
           }

         break;

    case FLAG_RESTORE_BTN:     /* Member of group FLAG_OPERATIONS_GRP  */

         _pdm_debug("ENTER CASE: FLAG_RESTORE_BTN",0);

         status = PDUverify_part_data(fp);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         FIg_get_state(fp, FLAG_CANCELFLAG_TGL, &state);

         if (state == 0)
           {
           _pdm_debug("Flag part for restore", 0);
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDFlPrRs";

           status = PDUprepare_queue (responses, strings, 1);
           _pdm_status("PDUprepare_queue",status);
           }
         else
           {
           _pdm_debug("unflag part for restore", 0);
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDCnFlRs";

           status = PDUprepare_queue (responses, strings, 1);
           _pdm_status("PDUprepare_queue",status);
           }

         break;


    case FLAG_CANCELFLAG_TGL:     /* Member of group FLAG_OPERATIONS_GRP  */     
         break;

    case DELETE_FILES_TGL:     /* Member of group FLAG_OPERATIONS_GRP  */     
     
         FIg_get_state(fp, DELETE_FILES_TGL, &state);
         if (state)
           {
           _pdm_debug("setting mode to multi select", 0);
           FIg_enable(fp, EXISTING_FILES_MCF);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 0, FI_MULTI_SELECT);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 1, FI_MULTI_SELECT);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 2, FI_MULTI_SELECT);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 3, FI_MULTI_SELECT);

           FIg_display(forms.part_operations_form_id, EXISTING_FILES_MCF);

           FIg_erase(fp, NEW_FILES_MCF);

           PDU_delete_files = TRUE;

           FIg_enable(fp, DELETE_FILES_BTN);

           msg = (char *) PDUtranslate_message(PDM_I_SELECT_ROWS_TO_DELETE);
           FIg_set_text(fp, FI_MSG_FIELD,msg);

           /* disable all other commands */
           FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
           FIg_disable(forms.part_operations_form_id, DELETE_BTN);
           FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
           FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
           FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
           FIg_disable(forms.part_operations_form_id, ADD_BTN);
           FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);
           FIg_disable(forms.part_operations_form_id, SEARCH_BTN);

           /* disable ep part fields */
           FIg_disable(forms.part_operations_form_id, EP_REV_BTN);
           FIg_disable(forms.part_operations_form_id, EP_REV_FLD);
           FIg_disable(forms.part_operations_form_id, EP_DESC_FLD);
           FIg_disable(forms.part_operations_form_id, EP_PARTTYPE_BTN);
           FIg_disable(forms.part_operations_form_id, EP_PARTTYPE_FLD);
           FIg_disable(forms.part_operations_form_id, ATTRIBUTE_VALUE_MCF);
           }
         else
           {
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 0, FI_INSERT);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 1, FI_INSERT);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 2, FI_INSERT);
           FIfld_set_mode(fp, EXISTING_FILES_MCF, 3, FI_INSERT);

           FIg_display(forms.part_operations_form_id, EXISTING_FILES_MCF);

           FIg_display(fp, NEW_FILES_MCF);
           FIg_display(fp, NEW_FILES_TEXT);

           PDU_delete_files = FALSE;

           FIg_disable(fp, DELETE_FILES_BTN);

           /* enable all other commands */
           FIg_enable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
           FIg_enable(forms.part_operations_form_id, DELETE_BTN);
           FIg_enable(forms.part_operations_form_id, WHERE_USED_BTN);
           FIg_enable(forms.part_operations_form_id, CHANGE_BTN);
           FIg_enable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
           FIg_enable(forms.part_operations_form_id, MOVE_STATE_BTN);
           FIg_enable(forms.part_operations_form_id, SEARCH_BTN);

           /* enable ep part fields */
           FIg_enable(forms.part_operations_form_id, EP_REV_BTN);
           FIg_enable(forms.part_operations_form_id, EP_REV_FLD);
           FIg_enable(forms.part_operations_form_id, EP_DESC_FLD);
           FIg_enable(forms.part_operations_form_id, EP_PARTTYPE_BTN);
           FIg_enable(forms.part_operations_form_id, EP_PARTTYPE_FLD);
           FIg_enable(forms.part_operations_form_id, ATTRIBUTE_VALUE_MCF);
           }

         break;

    case FILE_INFO_MCF:     /* Sequenced to     */

    _pdm_debug("ENTER CASE: FILE_INFO_MCF:",0);

      _pdm_debug("np_catalog = <%s>", np_catalog);
      _pdm_debug("nn_itemname = <%s>", nn_itemname);
      _pdm_debug("np_rev = <%s>", np_rev);
      _pdm_debug("cisaname_text = <%s>", cisaname_text);
      _pdm_debug("np_parttype = <%s>", np_parttype);

      if (((new_mode == TRUE) || (similar_mode == TRUE)) &&
          ((strcmp(np_parttype,"N") != 0) &&
          (strcmp(np_parttype,"n") != 0)))
        {
         if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) 
            {
            msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
            FIg_set_text(PDU_form_id, FI_MSG_FIELD,msg);
            FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
            break;
            }

         FIfld_get_active_row(fp,FILE_INFO_MCF, &act_row,&pos);
         _pdm_debug("active row = %d", (char *)act_row);

         FImcf_get_active_col(fp,FILE_INFO_MCF, &file_info_col,&pos);
         _pdm_debug("active column = %d", (char *)file_info_col);

	 _pdm_debug("getting data from FILE_INFO_MCF", 0);
         FIfld_get_text_length(fp,FILE_INFO_MCF,act_row,file_info_col,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         /*memset(text, NULL, sizeof (char) * length + 1);*/
	 text[0] = '\0';
         FIfld_get_text(fp, FILE_INFO_MCF, act_row, file_info_col,
                                 length,(unsigned char *)text, &select, &pos);

         if (!text)
           PDUfill_in_string(&text, NULL_STRING);

         _pdm_debug("entering case for file_info_col = %d",(char *)file_info_col);
         if (file_info_col == 0)
            {
            _pdm_debug("File Description Selected = <%s>", text);
            PDUfill_in_string1(&filedesc_text, text);

            if ((filedesc_text == NULL) || (strcmp(filedesc_text,"") == 0))
              {
              if (PDU_data_bufr && (act_row == 0))
                {
                _pdm_debug("resetting filedesc field in data buffer", 0);
                MEMbuild_array(PDU_data_bufr);
                PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
                PDUget_buffer_col(PDU_data_bufr, "p_filedesc", &column);
                MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
                if (PDU_data_bufr->rows > 1)
                  MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
                }
              break;
              }

            string_len = strlen(filedesc_text);

            if (string_len > 40)
               {
               msg = (char *) PDUtranslate_message(PDM_E_IDENTIFIER_TOO_LONG);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,0,"",FALSE);
               PDUmessage(PDM_E_IDENTIFIER_TOO_LONG,'s');
               break;
               }

            if (PDU_data_bufr && (act_row == 0))
              {
              _pdm_debug("resetting filedesc field in data buffer", 0);
              MEMbuild_array(PDU_data_bufr);
              PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
              PDUget_buffer_col(PDU_data_bufr, "p_filedesc", &column);
              MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
              if (PDU_data_bufr->rows > 1)
                MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
              }
            }
         else if (file_info_col == 1)
            {
            _pdm_debug("Local Filename Selected = <%s>", text);
            PDUfill_in_string1(&cofile_text, text);
 
            if ((cofile_text == NULL) || (strcmp(cofile_text,"") == 0)) 
              break;

            FIfld_get_num_rows(forms.part_operations_form_id, FILE_INFO_MCF,
                               &max_rows);

            /* Test to see if the local filename is unique to the part */
            for (i = 0; i < max_rows; ++i)
                {
                if (i != act_row)
                {
                _pdm_debug("CALL: FIfld_get_text_length",0);
                FIfld_get_text_length(forms.part_operations_form_id,
                                      FILE_INFO_MCF, i,1,
                                      &max_row_length);

                max_row_text = (char *) malloc (sizeof (char) * 
                               max_row_length + 1);
                memset(max_row_text,NULL, (sizeof(char) * max_row_length + 1));

                _pdm_debug("CALL: FIfld_get_text",0);
                FIfld_get_text (forms.part_operations_form_id,
                                FILE_INFO_MCF, i, 1,
                                max_row_length+1,(unsigned char *)max_row_text,
                                &select_flag, &pos );

                if (strcmp(cofile_text,max_row_text) == 0)
                   {
                   msg=(char*)PDUtranslate_message(PDM_E_LOCAL_FILE_NOT_UNIQUE);
                   FIg_set_text(fp, FI_MSG_FIELD,msg);
                   FIfld_set_text(fp, FILE_INFO_MCF,act_row,1,"",FALSE);
                   PDUmessage(PDM_E_LOCAL_FILE_NOT_UNIQUE, 's');
                   status = PDM_E_LOCAL_FILE_NOT_UNIQUE;
                   break;
                   }
                }
                }

             if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS) &&
                (status != MEM_S_SUCCESS))
                break;

            string_len = strlen(cofile_text);

            if (string_len > 14)
               {
               msg = (char *) PDUtranslate_message(PDM_E_LOC_FN_TOO_LONG);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,1,"",FALSE);
               PDUmessage(PDM_E_LOC_FN_TOO_LONG,'s');
               break;  
               }
    
            status = PDUcheck_char(cofile_text,&spec_char);
            _pdm_status("PDUcheck_char",status);

            if (status != PDM_S_SUCCESS)
               {
               msg = (char *) PDUtranslate_message(PDM_E_INVALID_CHAR_IN_LOCFN);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,1,"",FALSE);
               PDUmessage(PDM_E_INVALID_CHAR_IN_LOCFN,'s');
               break;
               }
            if (PDU_command == PDC_M_CREATE_TOP_DOWN)
              {
              _pdm_debug("check to see if file already exists for TOPDOWN", 0);
              status = PDUverify_file(cofile_text);
              _pdm_status("PDUverify_file", status);
              if (status == PDM_S_SUCCESS)
                {
                _pdm_debug("file exists: display prompt", 0);
                msg = (char *) PDUtranslate_message_and_vars(
                             PDP_P_FILE_EXISTS, cofile_text);

                UI_prompt(msg);
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
                if (msg)
                  {
                  free(msg);
                  msg = NULL;
                  }
                msg = (char *) PDUtranslate_message(PDM_E_CLEAR_FIELD);
                UI_prompt(msg);
      
                _pdm_debug("answer = <%s>", answer);
                if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
                  {
                  msg = (char *) PDUtranslate_message(PDM_E_CLEAR_FIELD);
                  FIg_set_text(fp, FI_MSG_FIELD,msg);
                  FIfld_set_text(fp, FILE_INFO_MCF,act_row,1,"",FALSE);
                  PDUmessage(PDM_E_CLEAR_FIELD,'s');
                  cofile_text = NULL;
                  break;
                  }
                }
              }
            }
         else if (file_info_col == 2)
            {
            _pdm_debug("Storage Filename Selected = <%s>", text);
            PDUfill_in_string1(&cifile_text, text);

            if ((cifile_text == NULL) || (strcmp(cifile_text,"") == 0)) 
              break;

            string_len = strlen(cifile_text);

            if (string_len > 14)
               {
               msg = (char *) PDUtranslate_message(PDM_E_STG_FN_TOO_LONG);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,2,"",FALSE);
               PDUmessage(PDM_E_STG_FN_TOO_LONG,'s');
               break;
               }

            status = PDUcheck_char(cifile_text,&spec_char);
            _pdm_status("PDUcheck_char",status);

            if (status != PDM_S_SUCCESS)
               {
               msg = (char *) PDUtranslate_message(PDM_E_INVALID_CHAR_IN_STGFN);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,2,"",FALSE);
               PDUmessage(PDM_E_INVALID_CHAR_IN_STGFN,'s');
               break;
               }

            FIfld_get_num_rows(forms.part_operations_form_id, FILE_INFO_MCF,
                               &max_rows);

            /* Test to see if the storage filename is unique to the part */
            for (i = 0; i < max_rows; ++i)
                {
                if (i != act_row)
                {
                FIfld_get_text_length(fp, FILE_INFO_MCF, i,2, &max_row_length);
                max_row_text = (char *) malloc (sizeof (char) *
                               max_row_length + 1);
                memset(max_row_text,NULL, (sizeof(char) * max_row_length + 1));
                FIfld_get_text (fp, FILE_INFO_MCF, i, 2, max_row_length+1, 
                                (unsigned char *)max_row_text, &select_flag,
                               &pos );

                if (strcmp(cifile_text,max_row_text) == 0)
                   {
                   msg = (char *) PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                   FIg_set_text(fp, FI_MSG_FIELD,msg);
                   FIfld_set_text(fp, FILE_INFO_MCF,act_row,2,"",FALSE);
                   PDUmessage(PDM_E_STG_FN_NOT_UNIQUE, 's');
                   status = PDM_E_STG_FN_NOT_UNIQUE;
                   break;
                   }
                }
                } 

            if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS)) 
               break;

            /* Verify storage filename is unique */
            FIfld_get_text_length(fp,STORAGE_AREA_FLD, 0, 0, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL, sizeof (char) * length + 1);
            FIfld_get_text(fp,STORAGE_AREA_FLD,0,0,length,(unsigned char *)text, &select, &pos);
           PDUfill_in_string1(&cisaname_text,text);
            _pdm_debug("cisaname_text = <%s>", cisaname_text);
  
            msg = (char *) PDUtranslate_message(PDS_M_VALIDATE_STG_FILENAME);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            PDUmessage(PDS_M_VALIDATE_STG_FILENAME, 's');

            if ((cisaname_text == NULL) || (strcmp(cisaname_text, "") == 0) ||
                (cifile_text == NULL) || (strcmp(cifile_text, "") == 0))
              {
              _pdm_debug("cannot check for dup storage area, value is NULL", 0);
              }
            else
              {
              status = PDMrcheck_dup_sa_fname(np_catalog,nn_itemname,np_rev,
                                              cifile_text,cisaname_text);
              _pdm_status("PDMrcheck_dup_sa_fname",status);

              if (status != PDM_S_SUCCESS)
                 {
                 FIfld_set_text(PDU_form_id,FILE_INFO_MCF,act_row,2,"",FALSE);
                 PDUmessage(PDM_E_STG_FN_NOT_UNIQUE, 's');
                 break;
                 }
              else if (status == PDM_S_SUCCESS)
                 FIg_set_text(fp,FI_MSG_FIELD,NULL_STRING);
              }
            }
         else if (file_info_col == 3)
            {
            _pdm_debug("Filetype Selected = <%s>", text);
            PDUfill_in_string1(&filetype_text, text);

            if ((filetype_text == NULL) || (strcmp(filetype_text,"") == 0))
              {
              if (PDU_data_bufr && (act_row == 0))
                {
                _pdm_debug("resetting filetype field in data buffer", 0);
                MEMbuild_array(PDU_data_bufr);
                PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
                PDUget_buffer_col(PDU_data_bufr, "n_filetype", &column);
                MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
                if (PDU_data_bufr->rows > 1)
                  MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
                }
              break;
              }

            if ((strcmp(filetype_text,"M") == 0) ||
                (strcmp(filetype_text,"m") == 0))
               {
               msg=(char *)PDUtranslate_message(PDM_E_INVALID_FILETYPE);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               PDUmessage(PDM_E_INVALID_FILETYPE, 's');
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,3,"",FALSE);
               sleep(4);
               break;
               }

            string_len = strlen(filetype_text);

            if (string_len > 5)
               {
               msg = (char *) PDUtranslate_message(PDM_E_FILETYPE_TOO_LONG);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               PDUmessage(PDM_E_FILETYPE_TOO_LONG, 's');
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,3,"",FALSE);
               break;
               }

            status = PDUcheck_char(filetype_text,&spec_char);
            _pdm_status("PDUcheck_char",status);

            if (status != PDM_S_SUCCESS)
               {
               msg=(char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_FILETYPE);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               PDUmessage(PDM_E_INVALID_CHAR_IN_FILETYPE, 's');
               FIfld_set_text(fp, FILE_INFO_MCF,act_row,3,"",FALSE);
               break;
               }

            if (PDU_data_bufr && (act_row == 0))
              {
              _pdm_debug("resetting filetype field in data buffer", 0);
              MEMbuild_array(PDU_data_bufr);
              PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
              PDUget_buffer_col(PDU_data_bufr, "n_filetype", &column);
              MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
              if (PDU_data_bufr->rows > 1)
                MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
              }
            }
         }
         _pdm_debug("BREAKING at end of function",0);
         break;

    case STORAGE_AREA_BTN:     

         _pdm_debug("Entering STORAGE_AREA_BTN",0);

         PDU_active_button = STORAGE_AREA_BTN;

         status = PDUstg_area_btn();
         _pdm_status("PDUstg_area_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case ACL_NAME_BTN:     

         _pdm_debug("Entering ACL_NAME_BTN",0);

         PDU_active_button = ACL_NAME_BTN;
 
         status = PDUacl_workflow_btn();
         _pdm_status("PDUacl_workflow_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case STATE_NAME_FLD:         /* Field Type:    ASCII    */

         /* This field is always non-selectable */

         break;

    case NP_PROJECT_FLD:     /* Member of group NEW_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering NP_PROJECT_FLD",0);

       status = PDUnp_proj_fld();
       _pdm_status("PDUnp_proj_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case NP_CATALOG_FLD:     /* Member of group NEW_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering NP_CATALOG_FLD",0);

       status = PDUnp_cat_fld();
       _pdm_status("PDUnp_cat_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case NP_PARTNUM_FLD:     /* Member of group NEW_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering NP_PARTNUM_FLD",0);

       status = PDUnp_part_fld();
       _pdm_status("PDUnp_part_fld",status);

       if (status == 0)
          break;

       if (status == PDM_S_SUCCESS)
        FIfld_pos_cursor(fp,NP_REV_FLD,0,0,0,0,0,0);
       else
        FIfld_pos_cursor(fp,NP_PARTNUM_FLD,0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case NP_REV_FLD:     /* Member of group NEW_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering NP_REV_FLD",0);

       status = PDUnp_rev_fld();
       _pdm_status("PDUnp_rev_fld",status);

       if (status == 0)
          break;

       if (status == PDM_S_SUCCESS)
        FIfld_pos_cursor(fp,NP_DESC_FLD,0,0,0,0,0,0);
       else
        FIfld_pos_cursor(fp,NP_REV_FLD,0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case NP_PARTTYPE_FLD:     /* Member of group NEW_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering NP_PARTTYPE_FLD",0);

       if (refresh->new_parttype)
         PDUfill_in_string1(&PDU_save_parttype, refresh->new_parttype);
       else
         PDUfill_in_string1(&PDU_save_parttype, "");
       _pdm_debug("PDU_save_parttype = <%s>", PDU_save_parttype);

       status = PDUnp_parttype_fld();
       _pdm_status("PDUnp_parttype_fld",status);

       if (status == 0)
          break;

       if (status == PDM_S_SUCCESS)
        FIfld_pos_cursor(fp,NP_DESC_FLD,0,0,0,0,0,0);
       else
        FIfld_pos_cursor(fp,NP_PARTTYPE_FLD,0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case NP_DESC_FLD:     /* Member of group NEW_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering NP_DESC_FLD",0);

       status = PDUnp_desc_fld();
       _pdm_status("PDUnp_desc_fld",status);

       if (status == PDM_I_ENTER_CATALOG)
         {
         FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
         break;
         }

       if (status == 0)
          {
          if (new_mode == TRUE)
             FIfld_pos_cursor(PDU_form_id,FILE_INFO_MCF,0,0,0,0,0,0);
          else if (similar_mode == TRUE)
             FIfld_pos_cursor(PDU_form_id,SIMILAR_MODE_MCF,0,0,0,0,0,0);
          break;
          }

       if (status == PDM_S_SUCCESS)
         {
          _pdm_debug("Position cursor according to mode", 0);
         if (new_mode == TRUE)
           FIfld_pos_cursor(PDU_form_id,FILE_INFO_MCF,0,0,0,0,0,0);
         else if (similar_mode == TRUE)
           FIfld_pos_cursor(PDU_form_id,SIMILAR_MODE_MCF,0,0,0,0,0,0);
         }
       else
           FIfld_pos_cursor(PDU_form_id,NP_DESC_FLD,0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case NP_PARTTYPE_BTN:     /* Member of group NEW_PART_GRP  */

       _pdm_debug("Entering NP_PARTTYPE_BTN",0);

       if (refresh->new_parttype)
         PDUfill_in_string1(&PDU_save_parttype, refresh->new_parttype);
       else
         PDUfill_in_string1(&PDU_save_parttype, "");
       _pdm_debug("PDU_save_parttype = <%s>", PDU_save_parttype);

       PDU_active_button = NP_PARTTYPE_BTN;

       status = PDUnp_parttype_btn();

       _pdm_status("PDUnp_parttype_btn",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case NP_PARTNUM_BTN:     /* Member of group NEW_PART_GRP  */

       /* call PDM function to retrieve a list of partids */

       _pdm_debug("Entering NP_PARTNUM_BTN",0);

       PDU_active_button = NP_PARTNUM_BTN;

       status = PDUnp_part_btn();
       _pdm_status("PDUnp_part_btn",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case NP_CATALOG_BTN:     /* Member of group NEW_PART_GRP  */
       _pdm_debug("Entering NP_CATALOG_BTN",0);

       PDU_active_button = NP_CATALOG_BTN;

       status = PDUnp_cat_btn();
       _pdm_status("PDUnp_cat_btn",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case NP_PROJECT_BTN:     /* Member of group NEW_PART_GRP  */

       _pdm_debug("Entering NP_PROJECT_BTN",0);

       PDU_active_button = NP_PROJECT_BTN;

       status = PDUnp_proj_btn();
       _pdm_status("PDUnp_proj_btn",status);

       if (status == PDM_S_SUCCESS)
          FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case NEW_MODE_BTN:     /* Member of group MODE_OF_OPERATION_GRP  */

       _pdm_debug("Entering NEW_MODE_BTN",0);

      if (new_mode == TRUE)
         break;

      PDUdismiss_subforms();

         /* TR 139417712 - MJG  terminate any attribute functions that might be
         waiting for input */
         responses[0] = TERMINATE;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

      mode_change_flag = TRUE;

      FIg_erase(fp,EXISTING_FILE_TXT);

      if (change_mode == TRUE)
         {
         FIg_erase(fp,CHANGE_MODE_GRP);

         /* erase delete files toggle */
         FIg_erase(fp, DELETE_FILES_TGL);
         FIg_set_state_off(fp, DELETE_FILES_TGL);
         PDU_delete_files = FALSE;
         }

      if (similar_mode)
         FIg_erase(fp,SIMILAR_MODE_GRP);

      if ((change_mode == TRUE) || (similar_mode == TRUE))
         {
         if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0))
            {
            status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                           PDU_attr_bufr, PDU_data_bufr);
            _pdm_status("PDMcancel_modify_part",status);

            if (status != PDM_S_SUCCESS)
               {
               PDUmessage(status,'s');
               mode_change_flag = FALSE;
               break;
               }
            }
         }

         FIg_erase(fp, EXISTING_PART_GRP);
         FIg_erase(fp, EXISTING_PART_BEZ);

        FIg_display(fp, NEW_PART_BEZ);
        FIg_display(fp, NEW_PART_GRP);

        FIg_erase(fp, FLAG_OPERATIONS_GRP);

        FIg_reset(fp, FILE_INFO_MCF);
        FImcf_get_attr(fp,FILE_INFO_MCF, &attribute);

        attribute |= FI_DISPLAY_VSCROLL;

        FImcf_set_attr(fp,FILE_INFO_MCF, attribute);

        FIg_display(fp, FILE_INFO_GRP);

        /* Disable all command except the ADD and SEARCH commands */

        FIg_disable(fp, ADD_TO_PROJECT_BTN);
        FIg_disable(fp, DELETE_BTN);
        FIg_disable(fp, WHERE_USED_BTN);
        FIg_disable(fp, CHANGE_BTN);
        FIg_disable(fp, FLAG_CANCELFLAG_BTN);
        FIg_disable(fp, DELETE_FILES_BTN);
        FIg_disable(fp, MOVE_STATE_BTN);

        /* Enable the ADD and SEARCH commands */
        FIg_enable(fp, ADD_BTN);
        FIg_enable(fp, SEARCH_BTN);

        /* Set the Part Attribute Palette to allow for data entry */
        FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,0, FI_SINGLE_SELECT);
        FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,1, FI_INSERT);

        /* Redisplay the gadgets after changing the field mode */
        FIg_display(fp, ATTRIBUTE_VALUE_MCF);

        /* Set File Information Palette to allow for data entry */
        if (PDU_disable_filedesc_col == FALSE)
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,0, FI_INSERT);
           }
        else
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,0, FI_REVIEW);
           FIfld_set_text(fp, FILE_INFO_MCF,0, 0, "NOT WRITEABLE",FALSE);
           }

        if (PDU_disable_localfn_col == FALSE)
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,1, FI_INSERT);
           }
        else
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,1, FI_REVIEW);
           FIfld_set_mode(fp,FILE_INFO_MCF,2, FI_REVIEW);
           FIfld_set_text(fp, FILE_INFO_MCF,0, 1, "NOT WRITEABLE",FALSE);
           FIfld_set_text(fp, FILE_INFO_MCF,0, 2, "NOT WRITEABLE",FALSE);
           }

        if (PDU_disable_storagefn_col == FALSE)
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,2, FI_INSERT);
           }
        else
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,2, FI_REVIEW);
           FIfld_set_text(fp, FILE_INFO_MCF,0, 2, "NOT WRITEABLE",FALSE);
           }

        if (PDU_disable_filetype_col == FALSE)
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,3, FI_INSERT);
           }
        else
           {
           FIfld_set_mode(fp,FILE_INFO_MCF,3, FI_REVIEW);
           FIfld_set_text(fp, FILE_INFO_MCF,0, 3, "NOT WRITEABLE",FALSE);
           }

        /* Redisplay the gadgets after changing the field mode */
        FIg_display(fp, NEW_FILE_TXT);
        FIg_display(fp, FILE_INFO_GRP);

        _pdm_debug("np_project = <%s>", np_project);
        _pdm_debug("np_catalog = <%s>", np_catalog);
        _pdm_debug("ep_project = <%s>", ep_project);
        _pdm_debug("ep_catalog = <%s>", ep_catalog);
        _pdm_debug("en_itemname = <%s>", en_itemname);

         if (((en_itemname != NULL) && (strcmp(en_itemname,"") != 0)) ||
            ((change_mode == TRUE) || (review_mode == TRUE)))
            {
            /* Find maximum number of rows */
            FIfld_get_num_rows(fp, ATTRIBUTE_VALUE_MCF, &max_rows);
            PDUremove_data(fp,ATTRIBUTE_VALUE_MCF, max_rows,2);
            FIg_reset(fp,ATTRIBUTE_VALUE_MCF);
            FIfld_set_active_row(fp,ATTRIBUTE_VALUE_MCF, 0, 0);

            FIfld_set_text(fp,STORAGE_AREA_FLD,0,0, "",FALSE);
            FIfld_set_text(fp,STATE_NAME_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,WORKFLOW_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,ACL_NAME_FLD,0,0,"", FALSE);

            /* redisplay fields to get rid of underscores */
#ifdef sparc
            FIg_display(fp,WORKFLOW_FLD);
            FIg_display(fp,ACL_NAME_FLD);
#endif
            }

         if (similar_mode == TRUE)
            {
            new_mode = TRUE;
            similar_mode = FALSE;
            change_mode = FALSE;
            review_mode = FALSE;
   
            if (((np_catalog != NULL) && (strcmp(np_catalog,"") != 0)) &&
                ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0))) 
               {
               _pdm_debug("part attributes are already loaded", 0);
               }

            if (((np_catalog != NULL) && (strcmp(np_catalog,"") != 0)) &&
                ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0))) 
               {
               bufr_flag = TRUE;

               if (PDU_ret_bufr)
                  {
                  MEMclose(&PDU_ret_bufr);
                  PDU_ret_bufr = NULL;
                  }

               status = PDUvalid_catalog(np_project,np_catalog);
               _pdm_debug("PDUvalid_catalog", status);

               if (status != PDM_S_SUCCESS)
                 {
                 FIg_set_text(fp, NP_CATALOG_FLD, NULL_STRING);
                 np_catalog = NULL_STRING;
                 refresh->new_catalog = NULL_STRING;
                 PDUprocess_valid_catalog_status(status);
                 break;
                 }

               bufr_flag = FALSE;

               PDUfill_in_string1(&refresh->new_catalog,np_catalog);

               status = PDUpull_from_bufr();
               _pdm_status("PDUpull_from_bufr",status);

               if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status,'s');
                  mode_change_flag = FALSE;
                  break;
                  }
               }
            else if ((ep_catalog != NULL) && (strcmp(ep_catalog,"") != 0))
               {
               /* This is done so the mapping between a project in the New
                  Part Palette will not cause mapping to fail with the
                  catalog brought over from the Existing Part Palette.*/
 
               if ((np_project != NULL) && (strcmp(np_project,"") != 0))
                  FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
                
               FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,ep_catalog,FALSE);
               PDUfill_in_string1(&np_catalog,ep_catalog);
               PDUfill_in_string1(&refresh->new_catalog,ep_catalog);

               bufr_flag = TRUE;

               if (PDU_ret_bufr)
                  {
                  MEMclose(&PDU_ret_bufr);
                  PDU_ret_bufr = NULL;
                  }

               status = PDUvalid_catalog(np_project,np_catalog);
               _pdm_debug("PDUvalid_catalog", status);
   
               if (status != PDM_S_SUCCESS)
                 {
                 FIg_set_text(fp, NP_CATALOG_FLD, NULL_STRING);
                 np_catalog = NULL_STRING;
                 refresh->new_catalog = NULL_STRING;
                 PDUprocess_valid_catalog_status(status);
                 break;
                 }

               bufr_flag = FALSE;

               PDUfill_in_string1(&refresh->new_catalog,np_catalog);

               if (PDU_hold_bufr != NULL)
                  {
                  MEMclose(&PDU_hold_bufr);
                  PDU_hold_bufr = NULL;
                  }

               status = MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_hold_bufr,
                                                   1);
               _pdm_status("MEMsplit_copy_buffer",status);

               if (status != MEM_S_SUCCESS)
                  {
                  PDUmessage(status,'s');
                  break;
                  }

               status = PDUpull_from_bufr();
               _pdm_status("PDUpull_from_bufr",status);

               if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status,'s');
                  mode_change_flag = FALSE;
                  break;
                  }
               FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
               }
            else
               FIfld_set_text(fp,NP_CATALOG_FLD,0, 0, "", FALSE);
            FIg_set_text(PDU_form_id, NP_PARTTYPE_FLD, np_parttype);
            }
         else if ((change_mode == TRUE) || (review_mode == TRUE))
            {
            new_mode = TRUE;
            similar_mode = FALSE;
            change_mode = FALSE;
            review_mode = FALSE;
   
            FIfld_set_text(fp,NP_PROJECT_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,NP_CATALOG_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,NP_PARTNUM_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,NP_REV_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,NP_PARTTYPE_FLD,0,0,"", FALSE);
            FIfld_set_text(fp,NP_DESC_FLD,0,0,"", FALSE);

            np_project = NULL_STRING;
            np_catalog = NULL_STRING;
            nn_itemname = NULL_STRING;
            np_rev = NULL_STRING;
            np_desc = NULL_STRING;
            np_parttype = NULL_STRING;

            if ((ep_catalog != NULL) && (strcmp(ep_catalog,"") != 0))
               {
               FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,ep_catalog,FALSE);
               PDUfill_in_string1(&np_catalog,ep_catalog);
               PDUfill_in_string1(&refresh->new_catalog,ep_catalog);

               bufr_flag = TRUE;
               if (PDU_ret_bufr)
                  {
                  MEMclose(&PDU_ret_bufr);
                  PDU_ret_bufr = NULL;
                  }
               status = PDUvalid_catalog(np_project,np_catalog);
               _pdm_debug("PDUvalid_catalog", status);
               if (status != PDM_S_SUCCESS)
                 {
                 FIg_set_text(fp, NP_CATALOG_FLD, NULL_STRING);
                 np_catalog = NULL_STRING;
                 refresh->new_catalog = NULL_STRING;
                 PDUprocess_valid_catalog_status(status);
                 break;
                 }
               bufr_flag = FALSE;

               if (PDU_hold_bufr != NULL)
                  {
                  MEMclose(&PDU_hold_bufr);
                  PDU_hold_bufr = NULL;
                  }

               status = MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_hold_bufr, 1);
               _pdm_status("MEMsplit_copy_buffer",status);

               if (status != MEM_S_SUCCESS)
                  {
                  PDUmessage(status,'s');
                  break;
                  }

               status = PDUpull_from_bufr();
               _pdm_status("PDUpull_from_bufr",status);

               if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status,'s');
                  mode_change_flag = FALSE;
                  break;
                  }

               _pdm_debug("np_parttype = <%s>", np_parttype);
               if ((strcmp(np_parttype,"N") != 0) &&
                   (strcmp(np_parttype,"n") != 0))
                  FIg_display(PDU_form_id,FILE_INFO_GRP);
               else
                  FIg_erase(PDU_form_id,FILE_INFO_GRP);
               }
            else
               FIfld_set_text(fp,NP_CATALOG_FLD,0, 0, "", FALSE);
            FIg_set_text(PDU_form_id, NP_PARTTYPE_FLD, np_parttype);
            }

         FIfld_set_text(fp,EP_PROJECT_FLD,0,0,"", FALSE);
         FIfld_set_text(fp,EP_CATALOG_FLD,0,0,"", FALSE);
         FIfld_set_text(fp,EP_PARTNUM_FLD,0,0,"", FALSE);
         FIfld_set_text(fp,EP_REV_FLD,0,0,"", FALSE);
         FIfld_set_text(fp,EP_PARTTYPE_FLD,0,0,"", FALSE);
         FIfld_set_text(fp,EP_DESC_FLD,0,0,"", FALSE);

         ep_project = NULL_STRING;
         ep_catalog = NULL_STRING;
         en_itemname = NULL_STRING;
         ep_rev = NULL_STRING;
         ep_desc = NULL_STRING;
         ep_parttype = NULL_STRING;

         refresh->rev_project = NULL_STRING;
         refresh->rev_catalog = NULL_STRING;
         refresh->rev_partid = NULL_STRING;
         refresh->rev_revision = NULL_STRING;
         refresh->rev_parttype = NULL_STRING;
         refresh->rev_description = NULL_STRING;

         /* Set SIMILAR, CHANGE, and REVIEW mode buttons' state to OFF */

         FIg_set_state_off(fp,SIMILAR_MODE_BTN);
         FIg_set_state_off(fp,CHANGE_MODE_BTN);
         FIg_set_state_off(fp,REVIEW_MODE_BTN);

         _pdm_debug("np_catalog = <%s>", np_catalog);
         _pdm_debug("nn_itemname = <%s>", nn_itemname);
         _pdm_debug("np_rev = <%s>", np_rev);
         _pdm_debug("np_desc = <%s>", np_desc);
  
         if (change_mode != TRUE)
            {
            if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0))
               FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
            }

        if ((np_catalog != NULL) && (strcmp(np_catalog,"") != 0))
          {
          status = PDUcheck_for_np_defaults(PDU_data_bufr);
          _pdm_status("PDUcheck_for_np_defaults", status);
          if (status != PDM_S_SUCCESS)
            _pdm_debug("error checking for defaults for np_catalog", 0);

          _pdm_debug("checking for pdmlibraries catalog", 0);
          if (strcmp(np_catalog, "pdmlibraries") == 0)
            {
            PDUfill_in_string1(&np_parttype, "M");
            PDUfill_in_string1(&refresh->new_parttype,np_parttype);
            FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);
            FIg_set_text(PDU_form_id,NP_PARTTYPE_FLD, np_parttype);
            }
          _pdm_debug("checking for pdmseedfiles catalog", 0);
          if (strcmp(np_catalog, "pdmseedfiles") == 0)
            {
            PDUfill_in_string1(&np_parttype, "G");
            PDUfill_in_string1(&refresh->new_parttype,np_parttype);
            FIg_set_text(PDU_form_id,NP_PARTTYPE_FLD, np_parttype);
            }

          if (PDU_attr_bufr)
            {
            status = PDUcheck_parttype_privileges(PDU_attr_bufr, 
                                           &update, &read, &write);
            _pdm_status("PDUcheck_parttype_privileges", status);
            if (status != PDM_S_SUCCESS)
              _pdm_debug("error checking parttype privs for np_catalog", 0);
         
            if (!write)
              {
              _pdm_debug("parttype is NO WRITE", 0);
              FIg_disable(fp, NP_PARTTYPE_FLD);
              FIg_disable(fp, NP_PARTTYPE_BTN);
              }
            }
          }

        if ((strcmp(np_parttype,"N") != 0) && (strcmp(np_parttype,"n") != 0))
           {
           FIg_display(fp, NEW_FILE_TXT);
           FIg_display(fp, FILE_INFO_GRP);
           }
        else
           {
           FIg_erase(fp, NEW_FILE_TXT);
           FIg_erase(fp, FILE_INFO_GRP);
           }

        mode_change_flag = FALSE;

        break;

    case SIMILAR_MODE_BTN:     /* Member of group MODE_OF_OPERATION_GRP  */ 

        _pdm_debug("Entering SIMILAR_MODE_BTN",0);

        if (similar_mode == TRUE)
          break;

        PDUdismiss_subforms();

         /* TR 139417712 - MJG  terminate any attribute functions that might be
         waiting for input */
         responses[0] = TERMINATE;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

        _pdm_debug("ep_catalog = <%s>", ep_catalog);
        _pdm_debug("en_itemname = <%s>", en_itemname);
        _pdm_debug("ep_rev = <%s>", ep_rev);

        _pdm_debug("resetting PDU_hold_bufr", 0);
        if (PDU_hold_bufr)
          {
          MEMclose(&PDU_hold_bufr);
          PDU_hold_bufr = NULL;
          }

        mode_change_flag = TRUE;

        if (review_mode)
          {
          FIg_erase(fp, FILE_INFO_MCF);
          FIg_erase(fp, EXISTING_FILE_TXT);
          }

        if (new_mode || review_mode)
           FIg_erase(PDU_form_id,FILE_INFO_GRP);

        if (change_mode == TRUE)
           {
           FIg_erase(forms.part_operations_form_id, CHANGE_MODE_GRP);

           /* erase delete files toggle */
           FIg_erase(fp, DELETE_FILES_TGL);
           FIg_set_state_off(fp, DELETE_FILES_TGL);
           PDU_delete_files = FALSE;

           FIg_enable(PDU_form_id,EP_PROJECT_FLD);
           FIg_enable(PDU_form_id,EP_CATALOG_FLD);
           FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
           FIg_enable(PDU_form_id,EP_REV_FLD);
           FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
           FIg_enable(PDU_form_id,EP_DESC_FLD);
           FIg_enable(PDU_form_id,EP_PROJECT_BTN);
           FIg_enable(PDU_form_id,EP_CATALOG_BTN);
           FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
           FIg_enable(PDU_form_id,EP_REV_BTN);
           FIg_enable(PDU_form_id,FILE_INFO_MCF);
           FIg_enable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
           FIg_enable(PDU_form_id,NEW_MODE_BTN);
           FIg_enable(PDU_form_id,CHANGE_MODE_BTN);
           FIg_enable(PDU_form_id,SIMILAR_MODE_BTN);
           FIg_enable(PDU_form_id,REVIEW_MODE_BTN);

           if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
               (strcmp(ep_rev,"") != 0))
              {
              status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                             PDU_attr_bufr, PDU_data_bufr);
              _pdm_status("PDMcancel_modify_part",status);
      
              if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status,'s');
                 break;
                 }
              }
           }

        /* display similar mode file info pallette */
        FIg_reset(PDU_form_id,SIMILAR_MODE_MCF);
        FIg_display(PDU_form_id,NEW_FILE_TXT);
        FIg_display(PDU_form_id,SIMILAR_MODE_GRP);
        FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);
        FIg_set_state_off(forms.part_operations_form_id,SIMMODE_COPY_TGL);

        /* Display the Existing Part Palette */

        FIg_display(forms.part_operations_form_id, EXISTING_PART_BEZ);
        FIg_display(forms.part_operations_form_id, EXISTING_PART_GRP);

        /* Display the New Part Palette */

        FIg_display(forms.part_operations_form_id, NEW_PART_BEZ);
        FIg_display(forms.part_operations_form_id, NEW_PART_GRP);

        /* Disable all command except the ADD and SEARCH */

        FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_BTN);
        FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);
        FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);

        /* Enable the ADD and SEARCH */

        FIg_enable(forms.part_operations_form_id, ADD_BTN);
        FIg_enable(forms.part_operations_form_id, SEARCH_BTN);

        /* Erase the "Flag Operations Group" */
        FIg_erase(forms.part_operations_form_id, FLAG_OPERATIONS_GRP);

        _pdm_debug("np_project = <%s>", np_project);
        _pdm_debug("np_catalog = <%s>", np_catalog);
        _pdm_debug("nn_itemname = <%s>", nn_itemname);
        _pdm_debug("np_rev = <%s>", np_rev);
        _pdm_debug("np_desc = <%s>", np_desc);
        _pdm_debug("np_parttype = <%s>", np_parttype);
        _pdm_debug("ep_project = <%s>", ep_project);
        _pdm_debug("ep_catalog = <%s>", ep_catalog);
        _pdm_debug("en_itemname = <%s>", en_itemname);
        _pdm_debug("ep_rev = <%s>", ep_rev);
        _pdm_debug("ep_desc = <%s>", ep_desc);
        _pdm_debug("ep_parttype = <%s>", ep_parttype);

        PDU_simmode_copy = FALSE;
        PDU_simmode_checkin = FALSE;

        if (new_mode == TRUE)
           {
           _pdm_debug("inside new_mode", 0);
           if (PDMdebug_on)
             if (PDU_attr_bufr)
               MEMprint_buffer("PDU_attr_bufr", PDU_attr_bufr, PDU_DEBUG_FILE);
             else
               _pdm_debug("attr bufr is NULL", 0);

           new_mode = FALSE;
           similar_mode = TRUE;

           if ((np_project != NULL) && (strcmp(np_project,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,np_project,FALSE);
              PDUfill_in_string1(&ep_project,np_project);
              PDUfill_in_string1(&refresh->rev_project,np_project);
              }
           else if ((refresh->rev_project != NULL) &&
                    (strcmp(refresh->rev_project,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,
                             refresh->rev_project,FALSE);
              PDUfill_in_string1(&ep_project,refresh->rev_project);
              } 
           else
              {
              FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,"",FALSE);
              }

           /* Fill in CATALOG */
           if ((np_catalog != NULL) && (strcmp(np_catalog,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,np_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,np_catalog);
              PDUfill_in_string1(&refresh->rev_catalog,np_catalog);

              /* This was added because if Add Part failed, the part that was
                 not added is still in the new part palette and will be placed 
                 in the existing part palette. */

              if ((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0))
                 {
                 /* Check is the part exist in the catalog with at least
                    one revision */
                 status = PDMcheck_partnum_without_rev(np_catalog,nn_itemname);
                 _pdm_status("PDMcheck_partnum_without_rev",status);
                
                 if (status == PDM_E_PART_EXISTS)
                    {
                    _pdm_debug("The part exist so place it in the existing",0);

                    status = PDM_S_SUCCESS;

                    FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,nn_itemname,
                                   FALSE);
                    PDUfill_in_string1(&en_itemname,nn_itemname);
                    PDUfill_in_string1(&refresh->rev_partid,nn_itemname);

                    similar_mode = TRUE;
                    new_mode = FALSE;

                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);

                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }

                 if (((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0)) &&
                    ((np_rev != NULL) && (strcmp(np_rev,"") != 0)))
                    {
                    _pdm_debug("Part in new part palette does not exist",0);
                    FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"", FALSE);
                    FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"", FALSE);
                    FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"", FALSE);
                    }
                 }
              }
           else if ((refresh->rev_catalog != NULL) &&
                    (strcmp(refresh->rev_catalog,"") != 0))
              {
              /* Test for parametric catalogs */
 
              status = PDMquery_catalog_type(refresh->rev_catalog,type);
              _pdm_status("PDMquery_catalog_type",status);
 
              if (status != PDM_S_SUCCESS)
                 break;
 
              if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
                  (strcmp(type,"PXT") == 0))
                 {
                 msg = (char *) PDUtranslate_message(PDM_I_TRANSFER_PARAM_FORM);
                 FIg_set_text(fp,FI_MSG_FIELD,msg);
                 PDUmessage(PDM_I_TRANSFER_PARAM_FORM, 's');
 
                 sleep(7);
                 similar_mode = FALSE;
 
                 /* Erase the displayed form */
 
                 FIf_erase (fp);
                 FIf_delete (fp);
                 forms.part_operations_form_id = 0;

                 /* Display the parametric part form */
 
                 PDUparametric_part_form(refresh->rev_catalog);
 
                 break;
                 }


              FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,
                             refresh->rev_catalog,FALSE);
              PDUfill_in_string1(&np_catalog,refresh->rev_catalog);
              PDUfill_in_string1(&refresh->new_catalog,refresh->rev_catalog);
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                             refresh->rev_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);

              FIfld_get_num_rows(fp, ATTRIBUTE_VALUE_MCF, &max_rows);
              PDUremove_data(fp,ATTRIBUTE_VALUE_MCF, max_rows, 2);
              FIg_reset(fp,ATTRIBUTE_VALUE_MCF);
              FIfld_set_active_row(fp,ATTRIBUTE_VALUE_MCF, 0, 0);

              FIfld_set_text(fp,STORAGE_AREA_FLD,0,0,"", FALSE);
              FIfld_set_text(fp,STATE_NAME_FLD,0,0, "", FALSE);
              FIfld_set_text(fp,WORKFLOW_FLD,0,0,"", FALSE);
              FIfld_set_text(fp,ACL_NAME_FLD,0,0,"", FALSE);

              /* redisplay fields to get rid of underscores */
#ifdef sparc
            FIg_display(fp,WORKFLOW_FLD);
            FIg_display(fp,ACL_NAME_FLD);
#endif

              similar_mode = TRUE;
              new_mode = FALSE;

              if ((refresh->rev_partid != NULL) &&
                  (strcmp(refresh->rev_partid,"") != 0))
                 {
                 FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                refresh->rev_partid,FALSE);
                 PDUfill_in_string1(&en_itemname,refresh->rev_partid);
 
                 if ((refresh->rev_revision) &&
                     (strcmp(refresh->rev_revision, "") != 0))
                    {
                    if (PDU_save_catalog &&
                        PDU_save_partid &&
                        PDU_save_revision &&
                       (strcmp(refresh->rev_catalog, PDU_save_catalog) == 0) &&
                       (strcmp(refresh->rev_partid, PDU_save_partid) == 0) &&
                       (strcmp(refresh->rev_revision, PDU_save_revision) == 0))
                      {
                      /* go ahead and get the buffer info */
                      _pdm_debug("processing part from main form", 0);
                      FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,
                                     refresh->rev_revision,FALSE);
                      FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0,
                                     refresh->rev_parttype,FALSE);
                      FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,
                                     refresh->rev_description,FALSE);
                      PDUfill_in_string1(&ep_rev,refresh->rev_revision);
                      PDUfill_in_string1(&ep_parttype,refresh->rev_parttype);
                      PDUfill_in_string1(&ep_desc,refresh->rev_description);
 
                      PDU_save_project = NULL_STRING;
                      PDU_save_catalog = NULL_STRING;
                      PDU_save_partid = NULL_STRING;
                      PDU_save_revision = NULL_STRING;
                      PDU_save_description = NULL_STRING;
                      PDU_save_parttype = NULL_STRING;
 
                      pt_flag = FALSE;
 
                      status = PDUpull_bufr_info();
                      _pdm_status("PDUpull_bufr_info",status);

                      pt_flag = TRUE;
 
                      if (status != PDM_S_SUCCESS)
                         {
                         PDUmessage(status, 's');
                         break;
                         }
                      }
                    }
                 else
                    {
                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);
  
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                 }
              else
                 {
                 bufr_flag = TRUE;
   
                 if (PDU_ret_bufr)
                    {
                    MEMclose(&PDU_ret_bufr);
                    PDU_ret_bufr = NULL;
                    }
   
                 status = PDUvalid_catalog(np_project,np_catalog);
                 _pdm_debug("PDUvalid_catalog", status);
      
                 if (status != PDM_S_SUCCESS)
                   {
                   FIg_set_text(fp, NP_CATALOG_FLD, NULL_STRING);
                   np_catalog = NULL_STRING;
                   refresh->new_catalog = NULL_STRING;
                   PDUprocess_valid_catalog_status(status);
                   break;
                   }
   
                 bufr_flag = FALSE;
   
                 if (PDU_hold_bufr != NULL)
                    {
                    MEMclose(&PDU_hold_bufr);
                    PDU_hold_bufr = NULL;
                    }
   
                 MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_hold_bufr,1);

                 pt_flag = TRUE;
   
                 status = PDUpull_from_bufr();
                 _pdm_status("PDUpull_from_bufr",status);
   
                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status,'s');
                    msg = (char *) PDUtranslate_message(status);
                    FIg_set_text(fp,FI_MSG_FIELD,msg);
                    _pdm_debug("Error Status: %d", status);
                    mode_change_flag = FALSE;
                    break;
                    }
                 }
              }
           else
              {
              FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,"",FALSE);
              }

            /* check file permissions */
            if (PDU_attr_bufr)
              {
              status = PDUcheck_file_info_privileges(NULL, PDU_attr_bufr,
                           &filedesc_update, &filedesc_read, &filedesc_write,
                           &cofile_update, &cofile_read, &cofile_write,
                           &cifile_update, &cifile_read, &cifile_write,
                           &filetype_update, &filetype_read, &filetype_write);
              _pdm_status("PDUcheck_file_info_privileges", status);
              if (status != PDM_S_SUCCESS)
                _pdm_debug("failed to get file info permissions", 0);
     
              if (!cofile_write)
                 {
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 2, FI_REVIEW);
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
                 msg =(char *)PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
                 FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
                 FIg_disable(PDU_form_id, SIMMODE_COPY_TGL);
                 }
               if (!filedesc_write)
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
               if (!cifile_write)
                 {
                 _pdm_debug("disabling storage filename column", 0);
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
                 }
               if (!filetype_write)
                 FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
              FIg_display(PDU_form_id,SIMILAR_MODE_MCF);
              }
           }

        if ((change_mode == TRUE) || (review_mode == TRUE))
           {
           similar_mode = TRUE;
           change_mode = FALSE;
           review_mode = FALSE;

           FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
           FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
           FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"",FALSE);
           FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"",FALSE);
           FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD,0,0,"",FALSE);
           FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"",FALSE);
          
           /* FILL IN CATALOG */
           if ((ep_catalog != NULL) && (strcmp(ep_catalog,"") != 0))
              {
              FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,ep_catalog,FALSE);
              PDUfill_in_string1(&np_catalog,ep_catalog);
              PDUfill_in_string1(&refresh->new_catalog,ep_catalog);

              if ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0))
                 {
                 FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,en_itemname,
                                FALSE);
                 PDUfill_in_string1(&nn_itemname,en_itemname);
                 PDUfill_in_string1(&refresh->new_partid,en_itemname);
                 }
              else
                 {
                 FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"",FALSE);
                 FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,"",FALSE);
                 en_itemname = NULL_STRING;
                 ep_rev = NULL_STRING;
                 }

              _pdm_debug("np_project = <%s>", np_project);
              _pdm_debug("np_catalog = <%s>", np_catalog);
   
              FIfld_get_num_rows(fp, ATTRIBUTE_VALUE_MCF, &max_rows);
              PDUremove_data(fp,ATTRIBUTE_VALUE_MCF, max_rows, 2);
              FIg_reset(fp,ATTRIBUTE_VALUE_MCF);
              FIfld_set_active_row(fp,ATTRIBUTE_VALUE_MCF, 0, 0);

              FIfld_set_text(fp,STORAGE_AREA_FLD,0,0,"", FALSE);
              FIfld_set_text(fp,STATE_NAME_FLD,0,0, "", FALSE);
              FIfld_set_text(fp,WORKFLOW_FLD,0,0,"", FALSE);
              FIfld_set_text(fp,ACL_NAME_FLD,0,0,"", FALSE);

              /* redisplay fields to get rid of underscores */
#ifdef sparc
              FIg_display(fp,WORKFLOW_FLD);
              FIg_display(fp,ACL_NAME_FLD);
#endif

              bufr_flag = TRUE;

              if (PDU_ret_bufr)
                 {
                 MEMclose(&PDU_ret_bufr);
                 PDU_ret_bufr = NULL;
                 }

              status = PDUvalid_catalog(np_project,np_catalog);
              _pdm_debug("PDUvalid_catalog", status);
   
              if (status != PDM_S_SUCCESS)
                {
                FIg_set_text(fp, NP_CATALOG_FLD, NULL_STRING);
                np_catalog = NULL_STRING;
                refresh->new_catalog = NULL_STRING;
                PDUprocess_valid_catalog_status(status);
                break;
                }

              if( status == PDM_S_SUCCESS)
                 {
                 bufr_flag = FALSE;

                 PDUfill_in_string1(&refresh->new_catalog,np_catalog);

/*
                 if (PDU_hold_bufr != NULL)
                    {
                    MEMclose(&PDU_hold_bufr);
                    PDU_hold_bufr = NULL;
                    }

                 MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_hold_bufr,1);
*/

                 status = PDUpull_bufr_info_for_np();
                 _pdm_status("PDUpull_bufr_info_for_np",status);

                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status,'s');
                    msg = (char *) PDUtranslate_message(status);
                    FIg_set_text(fp,FI_MSG_FIELD,msg);
                    _pdm_debug("Error Status: %d", status);
                    mode_change_flag = FALSE;
                    break;
                    }

                 if (PDU_data_bufr)
                   {
                   status = PDUcheck_for_np_defaults(PDU_data_bufr);
                   _pdm_status("PDUcheck_for_np_defaults", status);
                   if (status != PDM_S_SUCCESS)
                    _pdm_debug("error checking for defaults for np_catalog", 0);
                   }

                 if (PDU_attr_bufr)
                   {
                   status = PDUcheck_parttype_privileges(PDU_attr_bufr, 
                                                   &update, &read, &write);
                   _pdm_status("PDUcheck_parttype_privileges", status);
                   if (status != PDM_S_SUCCESS)
                     _pdm_debug("error checking parttype privs for np_catalog", 0);
                   if (!write)
                     {
                     _pdm_debug("parttype is NO WRITE", 0);
                     FIg_disable(fp, NP_PARTTYPE_FLD);
                     FIg_disable(fp, NP_PARTTYPE_BTN);
                     FIg_disable(fp, EP_PARTTYPE_FLD);
                     FIg_disable(fp, EP_PARTTYPE_BTN);
                     }
                   }

                   if ((en_itemname) && (strlen(en_itemname)) &&
                       (ep_rev) && (strlen(ep_rev)))
                     {
                     status = PDUsetup_buffer_list(PDU_ep_bufr, 2, 0, 
                                &ep_data_bufr_row, &ep_data_bufr_col,
                                &ep_data_bufr_format, &ep_data_bufr);
  
                     _pdm_status("PDUsetup_buffer_list",status);
  
                     if (status != PDM_S_SUCCESS)
                        {
                        PDUmessage(status,'s');
                        break;
                        }
  
                     status = PDUget_col_number(ep_data_bufr,"n_status",
                                             ep_data_bufr_col, &n_status_col);
  
                     _pdm_status("PDUget_col_number", status);
  
                     if (status != PDM_S_SUCCESS)
                        {
                        PDUmessage(status,'s');
                        break;
                        }
                     }
                 }
              }
           }  /* end change or review mode */

        _pdm_debug("ep_catalog = <%s>", ep_catalog);
        _pdm_debug("en_itemname = <%s>", en_itemname);
        _pdm_debug("ep_rev = <%s>", ep_rev);

        PDUprocess_catalog_parttype();

        if (PDU_data_bufr)
          {
          status = PDUcheck_for_np_defaults(PDU_data_bufr);
          _pdm_status("PDUcheck_for_np_defaults", status);
          }

        FIg_set_state_off(fp,NEW_MODE_BTN);
        FIg_set_state_off(fp,CHANGE_MODE_BTN);
        FIg_set_state_off(fp,REVIEW_MODE_BTN);

        /* Set the Part Attribute Palette to allow for data entry */
        FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,0, FI_SINGLE_SELECT);
        FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,1, FI_INSERT);
        FIg_display(fp, ATTRIBUTE_VALUE_MCF);

        FIg_display(PDU_form_id,STORAGE_AREA_FLD);
        FIg_display(PDU_form_id,STORAGE_AREA_TXT);

        mode_change_flag = FALSE;

        break; 
        
    case CHANGE_MODE_BTN:     /* Member of group MODE_OF_OPERATION_GRP  */

       _pdm_debug("Entering CHANGE_MODE_BTN",0);

         /* The mode_of operation is CHANGE */

         if (change_mode == TRUE)
         break;
   
         PDUdismiss_subforms();

         /* TR 139417712 - MJG  terminate any attribute functions that might be
         waiting for input */
         responses[0] = TERMINATE;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

        FIg_display(fp,EP_PARTTYPE_BTN);

         mode_change_flag = TRUE;

       FIg_display(PDU_form_id,STORAGE_AREA_FLD);
       FIg_display(PDU_form_id,STORAGE_AREA_TXT);

       /* erase similar mode toggles */
       FIg_erase(PDU_form_id, SIMMODE_COPY_TGL);
       FIg_erase(PDU_form_id, SIMMODE_CHECKIN_TGL);

        /* Disable the ADD and DELETE FILES commands */

        FIg_disable(fp, ADD_BTN);
        FIg_disable(fp, DELETE_FILES_BTN);

        FIg_erase(fp,STORAGE_AREA_BTN);

        /* Enable all other commands */

        FIg_enable(fp, MOVE_STATE_BTN);
        FIg_enable(fp, SEARCH_BTN);
        FIg_enable(fp, DELETE_BTN);
        FIg_enable(fp, WHERE_USED_BTN);
        FIg_enable(fp, CHANGE_BTN);
        FIg_enable(fp, FLAG_CANCELFLAG_BTN);

        /* Enable existing part fields */

        FIg_enable(PDU_form_id,EP_PROJECT_FLD);
        FIg_enable(PDU_form_id,EP_CATALOG_FLD);
        FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
        FIg_enable(PDU_form_id,EP_REV_FLD);
        FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
        FIg_enable(PDU_form_id,EP_DESC_FLD);
        FIg_enable(PDU_form_id,EP_PROJECT_BTN);
        FIg_enable(PDU_form_id,EP_CATALOG_BTN);
        FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
        FIg_enable(PDU_form_id,EP_REV_BTN);
        FIg_enable(PDU_form_id,EP_DESC_BTN);

        FIg_reset(PDU_form_id,ATTRIBUTE_VALUE_MCF);

        /* Set the Part Attribute Palette to allow for data entry */
        FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,0, FI_SINGLE_SELECT);
        FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,1, FI_INSERT);

        /* Redisplay the gadgets after changing the field mode */
        FIg_display(fp, ATTRIBUTE_VALUE_MCF);

        /* Turn the list buttons for these fields off */
        FIg_erase(fp,ACL_NAME_BTN);
        
        /* Display the Existing Part Palette */
        FIg_display(fp, EXISTING_PART_BEZ);
        FIg_display(fp, EXISTING_PART_GRP);

        /* Erase the New Part Palette */
        FIg_erase(fp, NEW_PART_BEZ);
        FIg_erase(fp, NEW_PART_GRP);
       
        /* Erase the "New File Information" text on the File Information
           Palette */
        FIg_erase(fp, NEW_FILE_TXT);
        FIg_erase(fp, EXISTING_FILE_TXT);

        /* Erase the "Flag Operations Group" */
        FIg_erase(fp, FLAG_OPERATIONS_GRP);

        /* display delete files toggle */
        FIg_display(fp, DELETE_FILES_TGL);
        FIg_disable(fp, DELETE_FILES_TGL);
        FIg_set_state_off(fp, DELETE_FILES_TGL);
        PDU_delete_files = FALSE;

        _pdm_debug("np_project = <%s>", np_project);
        _pdm_debug("np_catalog = <%s>", np_catalog);
        _pdm_debug("nn_itemname = <%s>", nn_itemname);
        _pdm_debug("np_rev = <%s>", np_rev);
        _pdm_debug("np_desc = <%s>", np_desc);
        _pdm_debug("np_parttype = <%s>", np_parttype);
        _pdm_debug("ep_project = <%s>", ep_project);
        _pdm_debug("ep_catalog = <%s>", ep_catalog);
        _pdm_debug("en_itemname = <%s>", en_itemname);
        _pdm_debug("ep_rev = <%s>", ep_rev);
        _pdm_debug("ep_desc = <%s>", ep_desc);
        _pdm_debug("ep_parttype = <%s>", ep_parttype);

/*
        if ((change_mode == TRUE) || (review_mode == TRUE))
          {
*/
          if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
              (strcmp(ep_rev,"") != 0))
             {
              status = PDMcancel_modify_part(ep_catalog,
			                     en_itemname,
                                             ep_rev,
                                            PDU_attr_bufr, PDU_data_bufr);
             _pdm_status("PDMcancel_modify_part",status);
     
             if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status,'s');
                break;
                }
             }
          /*}*/

        _pdm_debug("clearing mcfs", 0);
        FIfld_get_num_rows(fp, ATTRIBUTE_VALUE_MCF, &max_rows);
        PDUremove_data(fp, ATTRIBUTE_VALUE_MCF, max_rows,2);
        FIg_reset(fp,ATTRIBUTE_VALUE_MCF);
        FIfld_set_active_row(fp,ATTRIBUTE_VALUE_MCF, 0, 0);

        FIfld_get_num_rows(fp, EXISTING_FILES_MCF, &max_rows);
        PDUremove_data(fp, EXISTING_FILES_MCF, max_rows,4);

        FIg_reset(fp, NEW_FILES_MCF);
        FIg_reset(fp, EXISTING_FILES_MCF);
        FIg_display(fp, NEW_FILES_MCF);
        FIg_display(fp, EXISTING_FILES_MCF);

        FIfld_set_text(fp, STORAGE_AREA_FLD,0,0,"", FALSE);
        FIfld_set_text(fp, STATE_NAME_FLD,0,0, "", FALSE);
        FIfld_set_text(fp, WORKFLOW_FLD,0,0,"",FALSE);
        FIfld_set_text(fp, ACL_NAME_FLD,0,0,"",FALSE);

        /* redisplay fields to get rid of underscores */
#ifdef sparc
        FIg_display(fp,WORKFLOW_FLD);
        FIg_display(fp,ACL_NAME_FLD);
#endif

        /* Display Existing Part Palette data */

        if (new_mode == TRUE)
           {
           new_mode = FALSE;
           change_mode = TRUE;

           /* Erase the FILE_INFO_MCF */
           FIg_erase(PDU_form_id,FILE_INFO_GRP);

           /* Display the CHANGE_MODE_GRP */
           FIg_display(PDU_form_id,CHANGE_MODE_GRP);

           /* Fill in PROJECT */
           if ((np_project != NULL) && (strcmp(np_project,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,np_project,FALSE);
              PDUfill_in_string1(&ep_project,np_project);
              PDUfill_in_string1(&refresh->rev_project,np_project);
              }
           else if ((refresh->rev_project != NULL) &&
                    (strcmp(refresh->rev_project,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,
                             refresh->rev_project,FALSE);
              PDUfill_in_string1(&ep_project,refresh->rev_project);
              }
           else
              {
              FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,"",FALSE);
              }

           /* Fill in CATALOG */
           if ((np_catalog != NULL) && (strcmp(np_catalog,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,np_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,np_catalog);
              PDUfill_in_string1(&refresh->rev_catalog,np_catalog);

              if (strcmp(ep_catalog, "pdmlibraries") == 0)
                {
                if ((!nn_itemname) || (nn_itemname && (!strlen(nn_itemname))))
                  {
                  FIg_set_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,"M");
                  PDUfill_in_string1(&ep_parttype, "M");
                  PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
                  }
                FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_BTN);
                FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);
                }
              if (strcmp(ep_catalog, "pdmseedfiles") == 0)
                {
                FIg_set_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,"G");
                PDUfill_in_string1(&ep_parttype, "G");
                PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
                FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);
                }

              /* This was added because if Add Part failed, the part that was
                 not added is still in the new part palette and will be placed
                 in the existing part palette. */

              if ((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0))
                 {
                 /* Check is the part exist in the catalog with at least
                    one revision */
                 status = PDMcheck_partnum_without_rev(np_catalog,nn_itemname);
                 _pdm_status("PDMcheck_partnum_without_rev",status);

                 if (status == PDM_E_PART_EXISTS)
                    {
                    _pdm_debug("The part exist so place it in the existing",0);

                    status = PDM_S_SUCCESS;

                    FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,nn_itemname,
                                   FALSE);
                    PDUfill_in_string1(&en_itemname,nn_itemname);
                    PDUfill_in_string1(&refresh->rev_partid,nn_itemname);

                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);

                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(PDM_E_CLEAR_FIELD,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }

                 if (((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0)) &&
                    ((np_rev != NULL) && (strcmp(np_rev,"") != 0)))
                    {
                    _pdm_debug("Part in new part palette does not exist",0);
                    FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"", FALSE);
                    FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"", FALSE);
                    FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"", FALSE);
                    }
                 }
              }
           else if ((refresh->rev_catalog != NULL) &&
                    (strcmp(refresh->rev_catalog,"") != 0))
              {
              /* Test for parametric catalogs */

              status = PDMquery_catalog_type(refresh->rev_catalog,type);
              _pdm_status("PDMquery_catalog_type",status);

              if (status != PDM_S_SUCCESS)
                 break;

              if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
                  (strcmp(type,"PXT") == 0))
                 {
                 msg = (char *) PDUtranslate_message(PDM_I_TRANSFER_PARAM_FORM);
                 FIg_set_text(fp,FI_MSG_FIELD,msg);
                 PDUmessage(PDM_I_TRANSFER_PARAM_FORM, 's');

                 sleep(7);
                 change_mode = FALSE;

                 /* Erase the displayed form */

                 FIf_erase (fp);
                 FIf_delete (fp);
                 forms.part_operations_form_id = 0;

                 /* Display the parametric part form */

                 PDUparametric_part_form(refresh->rev_catalog);

                 break;  
                 }

              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                             refresh->rev_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);
 
              if ((refresh->rev_partid != NULL) &&
                  (strcmp(refresh->rev_partid,"") != 0))
                 {
                 FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                refresh->rev_partid,FALSE);
                 PDUfill_in_string1(&en_itemname,refresh->rev_partid);

                 if ((refresh->rev_revision) && 
                     (strcmp(refresh->rev_revision, "") != 0))
                    {
                    if (PDU_save_catalog && 
                        PDU_save_partid && 
                        PDU_save_revision &&
                       (strcmp(refresh->rev_catalog, PDU_save_catalog) == 0) &&
                       (strcmp(refresh->rev_partid, PDU_save_partid) == 0) &&
                       (strcmp(refresh->rev_revision, PDU_save_revision) == 0))
                      {
                      /* go ahead and get the buffer info */
                      _pdm_debug("processing part from main form", 0);
                      FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,
                                     refresh->rev_revision,FALSE);
                      FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,
                                     refresh->rev_description,FALSE);
                      PDUfill_in_string1(&ep_rev,refresh->rev_revision);
                      PDUfill_in_string1(&ep_parttype,refresh->rev_parttype);
                      PDUfill_in_string1(&ep_desc,refresh->rev_description);

                      PDU_save_project = NULL_STRING;
                      PDU_save_catalog = NULL_STRING;
                      PDU_save_partid = NULL_STRING;
                      PDU_save_revision = NULL_STRING;
                      PDU_save_description = NULL_STRING;
                      PDU_save_parttype = NULL_STRING;

                      pt_flag = TRUE;
 
                      status = PDUpull_bufr_info();
                      _pdm_status("PDUpull_bufr_info",status);

                      if (status != PDM_S_SUCCESS)
                         {
                         PDUmessage(status, 's');
                         break;
                         }
                      }
                    }
                 else
                    {
                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);
   
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                 }
              }
           else
              {
              FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,"",FALSE);
              }

           /* Fill in PART NUMBER */
           if  ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0) &&
               (np_catalog == NULL) && (strcmp(np_catalog,"") == 0))
               {
               if ((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0))
                  {
                  FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,nn_itemname,
                                 FALSE);
                  PDUfill_in_string1(&en_itemname,nn_itemname);
                  PDUfill_in_string1(&refresh->rev_partid,nn_itemname);

                  status = PDUep_part_fld();
                  _pdm_status("PDUep_part_fld",status);

                  if (status != PDM_S_SUCCESS)
                     {
                     PDUmessage(status,'s');
                     mode_change_flag = FALSE;
                     break;
                     }
                  }
               }
           }
        else if (similar_mode == TRUE)
           {
           _pdm_debug("entering similar_mode", 0);
           similar_mode = FALSE;
           change_mode = TRUE;

           /* Erase the SIMILAR_MODE_GRP */

           FIg_erase(PDU_form_id,SIMILAR_MODE_GRP);

           /* Display the CHANGE_MODE_GRP */

           FIg_display(PDU_form_id,CHANGE_MODE_GRP);
           FIg_enable(PDU_form_id,CHANGE_MODE_GRP);

              if ((strcmp(ep_catalog,"") != 0) && 
                  (strcmp(en_itemname,"") != 0) &&
                  (strcmp(ep_rev,"") != 0))
                 {
                 status = PDMcancel_modify_part(ep_catalog,
			                        en_itemname,
                                                ep_rev,
                                                PDU_attr_bufr, PDU_data_bufr);
                 _pdm_status("PDMcancel_modify_part",status);

                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status,'s');
                    mode_change_flag = FALSE;
                    break;
                    }
                 }

           /* Fill in PART NUMBER */
           if  ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0))
               {
               if ((ep_rev != NULL) && (strcmp(ep_rev,"") != 0))
                 {
                 status = PDUpull_bufr_info();
                 _pdm_status("PDUpull_bufr_info",status);
 
                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status, 's');
                    mode_change_flag = FALSE;
                    break;
                    }
                 }
               else
                 {
                 status = PDUep_part_fld();
                 _pdm_status("PDUep_part_fld",status);

                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status,'s');
                    mode_change_flag = FALSE;
                    break;
                    }
                 }
               }
            else if ((refresh->rev_catalog != NULL) &&
                     (strcmp(refresh->rev_catalog,"") != 0))
               {
               FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                              refresh->rev_catalog,FALSE);
               PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);

               if ((refresh->rev_partid != NULL) &&
                   (strcmp(refresh->rev_partid,"") != 0))
                  {
                  FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                 refresh->rev_partid, FALSE);
                  PDUfill_in_string1(&en_itemname,refresh->rev_partid);

                  if ((refresh->rev_revision != NULL) &&
                      (strcmp(refresh->rev_revision,"") != 0))
                    {
                    FIg_set_text(PDU_form_id,EP_REV_FLD,refresh->rev_revision);
                    PDUfill_in_string1(&ep_rev,refresh->rev_revision);

                    status = PDUpull_bufr_info();
                    _pdm_status("PDUpull_bufr_info",status);
 
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status, 's');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                  else
                    {
                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);
  
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                  }
               }
            else
               {
               FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,"",FALSE);
               FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,"",FALSE);
               FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0,"",FALSE);
               FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,"",FALSE);
               }
           }
        else if (review_mode == TRUE)
           {
           change_mode = TRUE;
           review_mode = FALSE;

           /* Erase the FILE_INFO_GRP */
           FIg_erase(fp, FILE_INFO_GRP);
    
           /* Display the CHANGE_MODE_GRP */
           FIg_display(PDU_form_id,CHANGE_MODE_GRP);
           FIg_enable(PDU_form_id,CHANGE_MODE_GRP);

           if  ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0))
               {
               if ((ep_rev != NULL) && (strcmp(ep_rev,"") != 0))
                 {
                 status = PDUpull_bufr_info();
                 _pdm_status("PDUpull_bufr_info",status);
 
                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status, 's');
                    mode_change_flag = FALSE;
                    break;
                    }
                 }
               else
                 {
                 status = PDUep_part_fld();
                 _pdm_status("PDUep_part_fld",status);

                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status,'s');
                    mode_change_flag = FALSE;
                    break;
                    }
                 }
               }
            else if ((refresh->rev_catalog != NULL) &&
                     (strcmp(refresh->rev_catalog,"") != 0))
               {
               FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                              refresh->rev_catalog,FALSE);
               PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);

               if ((refresh->rev_partid != NULL) &&
                   (strcmp(refresh->rev_partid,"") != 0))
                  {
                  FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                 refresh->rev_partid, FALSE);
                  PDUfill_in_string1(&en_itemname,refresh->rev_partid);

                  if ((refresh->rev_revision != NULL) &&
                      (strcmp(refresh->rev_revision,"") != 0))
                    {
                    FIg_set_text(PDU_form_id,EP_REV_FLD,refresh->rev_revision);
                    PDUfill_in_string1(&ep_rev,refresh->rev_revision);

                    status = PDUpull_bufr_info();
                    _pdm_status("PDUpull_bufr_info",status);
 
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status, 's');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                  else
                    {
                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);
  
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                 }
              }
           else
              {
              FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,"",FALSE);
              }
           }

        change_mode = TRUE;
        new_mode = FALSE;
        similar_mode = FALSE;
        review_mode = FALSE;

        /* Set NEW, SIMILAR, and REVIEW mode buttons' state to OFF */

        FIg_set_state_off(fp,NEW_MODE_BTN);
        FIg_set_state_off(fp,SIMILAR_MODE_BTN);
        FIg_set_state_off(fp,REVIEW_MODE_BTN);

       FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"",FALSE);

       _pdm_debug("ep_project = <%s>", ep_project);
       _pdm_debug("ep_catalog = <%s>", ep_catalog);
       _pdm_debug("en_itemname = <%s>", en_itemname);
       _pdm_debug("ep_rev = <%s>", ep_rev);
       _pdm_debug("ep_desc = <%s>", ep_desc);
       _pdm_debug("ep_parttype = <%s>", ep_parttype);

       if ((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0))
          FIfld_pos_cursor(PDU_form_id,EP_CATALOG_FLD,0,0,0,0,0,0);
       else if ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0))
          FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);
       else if ((ep_rev == NULL) || (strcmp(ep_rev,"") == 0))
          FIfld_pos_cursor(PDU_form_id,EP_REV_FLD,0,0,0,0,0,0);
       else if ((ep_desc == NULL) || (strcmp(ep_desc,"") == 0))
          FIfld_pos_cursor(PDU_form_id,EP_DESC_FLD,0,0,0,0,0,0);

       if ((ep_catalog) && (strlen(ep_catalog)) &&
           (en_itemname) && (strlen(en_itemname)) &&
           (ep_rev) && (strlen(ep_rev)))
         FIg_enable(fp, MOVE_STATE_BTN);
       else
         FIg_disable(fp, MOVE_STATE_BTN);

       /* check file permissions */
       if (PDU_attr_bufr)
         {
         status = PDUcheck_file_info_privileges(NULL, PDU_attr_bufr,
                      &filedesc_update, &filedesc_read, &filedesc_write,
                      &cofile_update, &cofile_read, &cofile_write,
                      &cifile_update, &cifile_read, &cifile_write,
                      &filetype_update, &filetype_read, &filetype_write);
         _pdm_status("PDUcheck_file_info_privileges", status);
         if (status != PDM_S_SUCCESS)
           _pdm_debug("failed to get file info permissions", 0);

         if (!filedesc_update)
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,0, FI_REVIEW);
         else
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,0, FI_INSERT);

         if (!cofile_update)
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,1, FI_REVIEW);
         else
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,1, FI_INSERT);
         if (!cifile_update)
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,2, FI_REVIEW);
         else
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,2, FI_INSERT);

         if (!filetype_update)
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,3, FI_REVIEW);
         else
           FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,3, FI_INSERT);

         if (!cofile_write)
           {
           _pdm_debug("cofilename is not writable", 0);
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 0, FI_REVIEW);
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 1, FI_REVIEW);
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 2, FI_REVIEW);
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 3, FI_REVIEW);
           }
         if (!filedesc_write)
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 0, FI_REVIEW);
         if (!cifile_write)
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 2, FI_REVIEW);
         if (!filetype_write)
           FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 3, FI_REVIEW);

         FIg_display(PDU_form_id, EXISTING_FILES_MCF);
         FIg_display(PDU_form_id, NEW_FILES_MCF);
         }

       mode_change_flag = FALSE;

       break;

    case REVIEW_MODE_BTN:     /* Member of group MODE_OF_OPERATION_GRP  */

       _pdm_debug("Entering REVIEW_MODE_BTN",0);

       /* The mode_of operation is REVIEW */

       if (review_mode == TRUE)
          break;

       PDUdismiss_subforms();

         /* TR 139417712 - MJG  terminate any attribute functions that might be
         waiting for input */
         responses[0] = TERMINATE;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

        FIg_display(forms.part_operations_form_id,EP_PARTTYPE_BTN);

        mode_change_flag = TRUE;

       FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,1, FI_REVIEW);
       FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,0, FI_REVIEW);
       FIg_display(forms.part_operations_form_id, ATTRIBUTE_VALUE_MCF);

       if (similar_mode || change_mode)
         {
         if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
              (strcmp(ep_rev,"") != 0))
             {
             status = PDMcancel_modify_part(ep_catalog,
                                            en_itemname,
                                            ep_rev,
                                            PDU_attr_bufr, PDU_data_bufr);
             _pdm_status("PDMcancel_modify_part",status);
 
             if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status,'s');
                break;
                }
             }
         }

       _pdm_debug("clearing mcfs", 0);
       FIfld_get_num_rows(fp, ATTRIBUTE_VALUE_MCF, &max_rows);
       PDUremove_data(fp, ATTRIBUTE_VALUE_MCF, max_rows,2);
       FIg_reset(fp,ATTRIBUTE_VALUE_MCF);
       FIfld_set_active_row(fp,ATTRIBUTE_VALUE_MCF, 0, 0);

       FIfld_set_text(fp, STORAGE_AREA_FLD,0,0,"", FALSE);
       FIfld_set_text(fp, STATE_NAME_FLD,0,0, "", FALSE);
       FIfld_set_text(fp, WORKFLOW_FLD,0,0,"",FALSE);
       FIfld_set_text(fp, ACL_NAME_FLD,0,0,"",FALSE);

       /* redisplay fields to get rid of underscores */
#ifdef sparc
       FIg_display(fp,WORKFLOW_FLD);
       FIg_display(fp,ACL_NAME_FLD);
#endif

       if (change_mode == TRUE) /* The previous mode selected */
          {
          _pdm_debug("erasing gadgets from change mode", 0);
          FIfld_get_num_rows(fp, EXISTING_FILES_MCF, &max_rows);
          PDUremove_data(fp, EXISTING_FILES_MCF, max_rows,4);
   
          FIg_reset(fp, NEW_FILES_MCF);

          FIg_enable(PDU_form_id,EP_PROJECT_FLD);
          FIg_enable(PDU_form_id,EP_CATALOG_FLD);
          FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
          FIg_enable(PDU_form_id,EP_REV_FLD);
          FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
          FIg_enable(PDU_form_id,EP_DESC_FLD);
          FIg_enable(PDU_form_id,EP_PROJECT_BTN);
          FIg_enable(PDU_form_id,EP_CATALOG_BTN);
          FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
          FIg_enable(PDU_form_id,EP_REV_BTN);
          FIg_enable(PDU_form_id,EP_PARTTYPE_BTN);
          FIg_enable(PDU_form_id,ATTRIBUTE_VALUE_MCF);
          FIg_enable(PDU_form_id,NEW_MODE_BTN);
          FIg_enable(PDU_form_id,CHANGE_MODE_BTN);
          FIg_enable(PDU_form_id,SIMILAR_MODE_BTN);
          FIg_enable(PDU_form_id,REVIEW_MODE_BTN);
 
          /* erase delete files toggle */
          FIg_erase(fp, CHANGE_MODE_GRP);
          FIg_erase(fp, DELETE_FILES_TGL);
          FIg_set_state_off(fp, DELETE_FILES_TGL);
          PDU_delete_files = FALSE;
          }

       if (similar_mode)
          FIg_erase(fp, SIMILAR_MODE_GRP);
       
       FIg_erase(forms.part_operations_form_id, NEW_PART_BEZ);
       FIg_erase(forms.part_operations_form_id, NEW_PART_GRP);
       FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);

       FIg_display(PDU_form_id,STORAGE_AREA_TXT);
       FIg_display(PDU_form_id,STORAGE_AREA_FLD);

       /* Display the EP_PARTTYPE_BTN */
       FIg_display(forms.part_operations_form_id, EP_PARTTYPE_BTN);

       FIg_display(forms.part_operations_form_id, EXISTING_PART_BEZ);
       FIg_display(forms.part_operations_form_id, EXISTING_PART_GRP);

        FIg_erase(forms.part_operations_form_id, FLAG_OPERATIONS_GRP);
        FIg_display(PDU_form_id,FILE_INFO_GRP);
        FIg_display(forms.part_operations_form_id, EXISTING_FILE_TXT);

       FIg_enable(forms.part_operations_form_id,EP_PROJECT_FLD);
       FIg_enable(forms.part_operations_form_id,EP_PROJECT_BTN);
       FIg_enable(forms.part_operations_form_id,EP_CATALOG_FLD);
       FIg_enable(forms.part_operations_form_id,EP_CATALOG_BTN);
       FIg_enable(forms.part_operations_form_id,EP_PARTNUM_FLD);
       FIg_enable(forms.part_operations_form_id,EP_PARTNUM_BTN);

        FIg_disable(forms.part_operations_form_id, ADD_BTN);
        FIg_disable(forms.part_operations_form_id, CHANGE_BTN);
        FIg_disable(forms.part_operations_form_id, MOVE_STATE_BTN);
        FIg_disable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_BTN);
        FIg_disable(forms.part_operations_form_id, WHERE_USED_BTN);
        FIg_disable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
        FIg_disable(forms.part_operations_form_id, DELETE_FILES_BTN);

        FIg_enable(forms.part_operations_form_id, SEARCH_BTN);

        _pdm_debug("np_project = <%s>", np_project);
        _pdm_debug("np_catalog = <%s>", np_catalog);
        _pdm_debug("nn_itemname = <%s>", nn_itemname);
        _pdm_debug("np_rev = <%s>", np_rev);
        _pdm_debug("np_desc = <%s>", np_desc);
        _pdm_debug("np_parttype = <%s>", np_parttype);
        _pdm_debug("ep_project = <%s>", ep_project);
        _pdm_debug("ep_catalog = <%s>", ep_catalog);
        _pdm_debug("en_itemname = <%s>", en_itemname);
        _pdm_debug("ep_rev = <%s>", ep_rev);
        _pdm_debug("ep_desc = <%s>", ep_desc);
        _pdm_debug("ep_parttype = <%s>", ep_parttype);

        if (new_mode == TRUE)
           {
           new_mode = FALSE;
           review_mode = TRUE;

           /* Fill in PROJECT */
           if ((np_project != NULL) && (strcmp(np_project,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,np_project,FALSE);
              PDUfill_in_string1(&ep_project,np_project);
              PDUfill_in_string1(&refresh->rev_project,np_project);
              }
           else if ((refresh->rev_project != NULL) &&
                    (strcmp(refresh->rev_project,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,
                             refresh->rev_project,FALSE);
              PDUfill_in_string1(&ep_project,refresh->rev_project);
              }
           else
              {
              FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_PROJECT_FLD,0,0,"",FALSE);
              }

           /* Fill in CATALOG */
           if ((np_catalog != NULL) && (strcmp(np_catalog,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,np_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,np_catalog);
              PDUfill_in_string1(&refresh->rev_catalog,np_catalog);

              /* This was added because if Add Part failed, the part that was
                 not added is still in the new part palette and will be placed
                 in the existing part palette. */

              if ((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0))
                 {
                 /* Check is the part exist in the catalog with at least
                    one revision */
                 status = PDMcheck_partnum_without_rev(np_catalog,nn_itemname);
                 _pdm_status("PDMcheck_partnum_without_rev",status);

                 if (status == PDM_E_PART_EXISTS)
                    {
                    _pdm_debug("The part exist so place it in the existing",0);

                    status = PDM_S_SUCCESS;

                    FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,nn_itemname,
                                   FALSE);
                    PDUfill_in_string1(&en_itemname,nn_itemname);
                    PDUfill_in_string1(&refresh->rev_partid,nn_itemname);

                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);

                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(PDM_E_CLEAR_FIELD,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }

                 if (((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0)) &&
                    ((np_rev != NULL) && (strcmp(np_rev,"") != 0)))
                    {
                    _pdm_debug("Part in new part palette does not exist",0);
                    FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"", FALSE);
                    FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"", FALSE);
                    FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"", FALSE);
                    }
                 }

                 FIg_activate(forms.part_operations_form_id,FILE_INFO_MCF);
              }
           else if ((refresh->rev_catalog != NULL) &&
                    (strcmp(refresh->rev_catalog,"") != 0))
              {
              /* Test for parametric catalogs */

              status = PDMquery_catalog_type(refresh->rev_catalog,type);
              _pdm_status("PDMquery_catalog_type",status);

              if (status != PDM_S_SUCCESS)
                 break;

              if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
                  (strcmp(type,"PXT") == 0))
                 {
                 msg = (char *) PDUtranslate_message(PDM_I_TRANSFER_PARAM_FORM);
                 FIg_set_text(fp,FI_MSG_FIELD,msg);
                 PDUmessage(PDM_I_TRANSFER_PARAM_FORM, 's');

                 sleep(7);
                 review_mode = FALSE;

                 /* Erase the displayed form */

                 FIf_erase (forms.part_operations_form_id);
                 FIf_delete (forms.part_operations_form_id);
                 forms.part_operations_form_id = 0;

                 /* Display the parametric part form */

                 PDUparametric_part_form(refresh->rev_catalog);

                 break;
                 }

              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                             refresh->rev_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);

              if ((refresh->rev_partid != NULL) &&
                  (strcmp(refresh->rev_partid,"") != 0))
                 {
                 FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                refresh->rev_partid,FALSE);
                 PDUfill_in_string1(&en_itemname,refresh->rev_partid);

                 if ((refresh->rev_revision) &&
                     (strcmp(refresh->rev_revision, "") != 0))
                    {
                    if (PDU_save_catalog &&
                        PDU_save_partid &&
                        PDU_save_revision &&
                       (strcmp(refresh->rev_catalog, PDU_save_catalog) == 0) &&
                       (strcmp(refresh->rev_partid, PDU_save_partid) == 0) &&
                       (strcmp(refresh->rev_revision, PDU_save_revision) == 0))
                      {
                      /* go ahead and get the buffer info */
                      _pdm_debug("processing part from main form", 0);
                      FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,
                                     refresh->rev_revision,FALSE);
                      FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,
                                     refresh->rev_description,FALSE);
                      PDUfill_in_string1(&ep_rev,refresh->rev_revision);
                      PDUfill_in_string1(&ep_desc,refresh->rev_description);
 
 
                      PDU_save_project = NULL_STRING;
                      PDU_save_catalog = NULL_STRING;
                      PDU_save_partid = NULL_STRING;
                      PDU_save_revision = NULL_STRING;
                      PDU_save_description = NULL_STRING;
                      PDU_save_parttype = NULL_STRING;
 
                      pt_flag = TRUE;
 
                      status = PDUpull_bufr_info();
                      _pdm_status("PDUpull_bufr_info",status);
 
                      if (status != PDM_S_SUCCESS)
                         {
                         PDUmessage(status, 's');
                         mode_change_flag = FALSE;
                         break;
                         }
                      }
                    }
                 else
                    {
                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);
 
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                 }

              FIg_activate(forms.part_operations_form_id,FILE_INFO_MCF);
              }
           else
              {
              FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,"",FALSE);
              }

           /* Fill in PART NUMBER */
           if  ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0) &&
               (np_catalog == NULL) && (strcmp(np_catalog,"") == 0))
               {
               if ((nn_itemname != NULL) && (strcmp(nn_itemname,"") != 0))
                  {
                  FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,nn_itemname,
                                 FALSE);
                  PDUfill_in_string1(&en_itemname,nn_itemname);
                  PDUfill_in_string1(&refresh->rev_partid,nn_itemname);

                  status = PDUep_part_fld();
                  _pdm_status("PDUep_part_fld",status);

                  if (status != PDM_S_SUCCESS)
                     {
                     PDUmessage(status,'s');
                     mode_change_flag = FALSE;
                     break;
                     }
                  }

                  FIg_activate(forms.part_operations_form_id,FILE_INFO_MCF);
               }
           }
        else if (similar_mode == TRUE)
           {
           similar_mode = FALSE;
           review_mode = TRUE;

           /* Fill in PART NUMBER */
           if  ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0))
               {
               status = PDUep_part_fld();
               _pdm_status("PDUep_part_fld",status);

               if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status,'s');
                  mode_change_flag = FALSE;
                  break;
                  }
               }
            else if ((refresh->rev_catalog != NULL) &&
                     (strcmp(refresh->rev_catalog,"") != 0))
               {
               FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                              refresh->rev_catalog,FALSE);
               PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);

               if ((refresh->rev_partid != NULL) &&
                   (strcmp(refresh->rev_partid,"") != 0))
                  {
                  FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                 refresh->rev_partid, FALSE);
                  PDUfill_in_string1(&en_itemname,refresh->rev_partid);

                  if ((refresh->rev_revision != NULL) &&
                      (strcmp(refresh->rev_revision,"") != 0))
                     {
                     FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,
                                    refresh->rev_revision,FALSE);
                     PDUfill_in_string1(&ep_rev,refresh->rev_revision);

                     pt_flag = TRUE;

                     status = PDUpull_bufr_info();
                     _pdm_status("PDUpull_bufr_info",status);
             
                     if (status != PDM_S_SUCCESS)
                        {
                        PDUmessage(status, 's');
                        mode_change_flag = FALSE;
                        break;
                        }
                     }
                  else
                     {
                     status = PDUep_part_fld();
                     _pdm_status("PDUep_part_fld",status);
   
                     if (status != PDM_S_SUCCESS)
                        {
                        PDUmessage(status,'s');
                        mode_change_flag = FALSE;
                        break;
                        }
                     }
                  }
               }
            else
               {
               FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,"",FALSE);
               FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,"",FALSE);
               FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0,"",FALSE);
               FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,"",FALSE);
               }
           }
         else if (change_mode == TRUE)
            {
            change_mode = FALSE;
            review_mode = TRUE;

            if ((refresh->rev_catalog != NULL) &&
               (strcmp(refresh->rev_catalog,"") != 0))
              {
              FIfld_set_text(PDU_form_id,EP_CATALOG_FLD,0,0,
                             refresh->rev_catalog,FALSE);
              PDUfill_in_string1(&ep_catalog,refresh->rev_catalog);

              if ((refresh->rev_partid != NULL) &&
                  (strcmp(refresh->rev_partid,"") != 0))
                 {
                 FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,
                                refresh->rev_partid,FALSE);
                 PDUfill_in_string1(&en_itemname,refresh->rev_partid);

                 if ((refresh->rev_revision != NULL) &&
                     (strcmp(refresh->rev_revision,"") != 0))
                    {
                    FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,
                                   refresh->rev_revision,FALSE);
                    PDUfill_in_string1(&ep_rev,refresh->rev_revision);

                    status = PDUpull_bufr_info();
                    _pdm_status("PDUpull_bufr_info",status);
            
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status, 's');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                  else
                    {
                    status = PDUep_part_fld();
                    _pdm_status("PDUep_part_fld",status);
  
                    if (status != PDM_S_SUCCESS)
                       {
                       PDUmessage(status,'s');
                       mode_change_flag = FALSE;
                       break;
                       }
                    }
                 }

            FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,1, FI_REVIEW);
            FIfld_set_mode(fp,ATTRIBUTE_VALUE_MCF,0, FI_REVIEW);
            FIg_display(forms.part_operations_form_id, ATTRIBUTE_VALUE_MCF);
            }
         }

       review_mode = TRUE;
       new_mode = FALSE;
       similar_mode = FALSE;
       change_mode = FALSE;

       /* Set NEW, SIMILAR, and CHANGE mode buttons' state to OFF */

       FIg_set_state_off(forms.part_operations_form_id,NEW_MODE_BTN);
       FIg_set_state_off(forms.part_operations_form_id,SIMILAR_MODE_BTN);
       FIg_set_state_off(forms.part_operations_form_id,CHANGE_MODE_BTN);

       /* Turn the list buttons for these fields off */

       FIg_erase(forms.part_operations_form_id,STORAGE_AREA_BTN);
       FIg_erase(forms.part_operations_form_id,ACL_NAME_BTN);

       FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD,0,0,"",FALSE);
       FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"",FALSE);

       mode_change_flag = FALSE;

       if ((strcmp(ep_parttype,"n") != 0) &&
           (strcmp(ep_parttype,"N") != 0))
         {
         FIfld_set_mode(fp,FILE_INFO_MCF, 0, FI_REVIEW);
         FIfld_set_mode(fp,FILE_INFO_MCF, 1, FI_REVIEW);
         FIfld_set_mode(fp,FILE_INFO_MCF, 2, FI_REVIEW);
         FIfld_set_mode(fp,FILE_INFO_MCF, 3, FI_REVIEW);
         FIg_display(fp,FILE_INFO_MCF);
         }

       break;

    case PART_LISTING_MCF:     /* Member of group PART_LISTING_GRP  */

       _pdm_debug("Entering PART_LISTING_MCF",0);

         FIfld_get_num_rows( fp, PART_LISTING_MCF, &rows);
         FIfld_get_active_row(fp, PART_LISTING_MCF, &act_row, &pos);
         FIfld_get_select(forms.part_operations_form_id, PART_LISTING_MCF,                                act_row, column, &mcf_select);

         if (mcf_select == TRUE)
            {
            /* This puts the last selected row on top of the stack */

            PDUpush_into_stack(&PDU_stack,rows,act_row);

            PDUprint_stack(PDU_stack,rows);
            }
         if (mcf_select == FALSE)
            {
            /* This deletes the row from the stack that was unhighlighted and
               arranges the stack so the previously last selected row will
               become the last selected row */

            PDUdelete_from_stack(&PDU_stack,rows,act_row);

            PDUprint_stack(PDU_stack,rows); 
            }

         PDUget_top_of_stack(PDU_stack,&top);
   
         if (top != -1)
         {
         FIfld_set_active_row(fp,PART_LISTING_MCF,top,top);
         for (col_count = 0; col_count < 5; ++col_count)
            {
            column = col_count;
            FImcf_set_active_col(fp,PART_LISTING_MCF,column,column);

            FIfld_get_text_length(fp,PART_LISTING_MCF, top, column, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL, sizeof (char) * length + 1);
            FIfld_get_text(fp,PART_LISTING_MCF,top,column,length,
                           (unsigned char *)text, &select,&pos);
            if (col_count == 0)
               PDUfill_in_string1(&refresh->rev_catalog, text);
            else if (col_count == 1)
               PDUfill_in_string1(&refresh->rev_partid, text);
            else if (col_count == 2)
               PDUfill_in_string1(&refresh->rev_revision, text);
            else if (col_count == 3)
               PDUfill_in_string1(&refresh->rev_description, text);
            }

            PDUfill_in_string1(&refresh->rev_parttype,                                                         PDU_data_row[(PDU_ret_bufr->columns * top) + 3                                          ]);


            /* Place latest part data in the Existing and New Part Palette */

         FIfld_set_text( fp, EP_CATALOG_FLD, 0, 0, refresh->rev_catalog, FALSE);
         FIfld_set_text( fp, EP_PARTNUM_FLD, 0, 0, refresh->rev_partid, FALSE);
         FIfld_set_text( fp, EP_REV_FLD, 0, 0, refresh->rev_revision, FALSE);
         FIfld_set_text( fp, EP_PARTTYPE_FLD, 0, 0, refresh->rev_parttype,
                         FALSE);
         FIfld_set_text( fp, EP_DESC_FLD, 0, 0, refresh->rev_description,FALSE);
         FIfld_set_text( fp, NP_CATALOG_FLD, 0, 0, refresh->rev_catalog, FALSE);
         FIfld_set_text( fp, NP_PARTNUM_FLD, 0, 0, refresh->rev_partid, FALSE);
         FIfld_set_text( fp, NP_PARTTYPE_FLD, 0, 0, refresh->rev_parttype,
                         FALSE);
         FIfld_set_text( fp, NP_DESC_FLD, 0, 0, refresh->rev_description,FALSE);
         }

         /* copy all lines that have been selected into arrays */

         max_row = rows;

         if (rows != 0)
           {
           mcf_list_data = (char **) malloc (sizeof (char *) * 5);
           mcf_cat =       (char **) malloc (sizeof (char *) * rows);
           mcf_part =      (char **) malloc (sizeof (char *) * rows);
           mcf_rev =       (char **) malloc (sizeof (char *) * rows);
           mcf_desc =      (char **) malloc (sizeof (char *) * rows);
           mcf_flag =      (char **) malloc (sizeof (char *) * rows);

           memset((char *)mcf_list_data, NULL, sizeof (char *) * 5);
           memset((char *)mcf_cat,       NULL, sizeof (char *) * rows);
           memset((char *)mcf_part,      NULL, sizeof (char *) * rows);
           memset((char *)mcf_rev,       NULL, sizeof (char *) * rows);
           memset((char *)mcf_desc,      NULL, sizeof (char *) * rows);
           memset((char *)mcf_flag,      NULL, sizeof (char *) * rows);
           }

         for (rows = 0; rows < max_row; ++rows)
          {
          /* loop through columns for mcf */
          FIfld_set_active_row(forms.part_operations_form_id, PART_LISTING_MCF,                                rows, rows);
          for (col_count = 0; col_count < 5; ++col_count)
             {
             column = col_count;
             FImcf_set_active_col( fp, PART_LISTING_MCF, column, column);
             FIfld_get_select(forms.part_operations_form_id, PART_LISTING_MCF,                                rows, column, &mcf_select);
             if (mcf_select == TRUE)
               {
               ++selected_part_rows;

               FIfld_get_text_length(fp,PART_LISTING_MCF,rows,column,&length);
               text = (char *) malloc (sizeof (char) * length + 1);
               memset(text, NULL, sizeof (char) * length + 1);
               FIfld_get_text(fp,PART_LISTING_MCF,rows,column,length,
                              (unsigned char *)text, &select,&pos);

               /* Code to process text string "text" */
               if (col_count == 0)
                 if ((text == NULL) || (strcmp(text,"") == 0))
                   {
                   PDUfill_in_string(&mcf_cat[rows], text);
                   }
               if (col_count == 1)
                 if ((text == NULL) || (strcmp(text,"") == 0))
                   {
                   PDUfill_in_string(&mcf_part[rows], text);
                   }
               if (col_count == 2)
                 if ((text == NULL) || (strcmp(text,"") == 0))
                   {
                   PDUfill_in_string(&mcf_rev[rows], text);
                   }
               if (col_count == 3)
                 if ((text == NULL) || (strcmp(text,"") == 0))
                   {
                   PDUfill_in_string(&mcf_desc[rows], text);
                   }
               if (col_count == 4)
                 if ((text == NULL) || (strcmp(text,"") == 0))
                   {
                   PDUfill_in_string(&mcf_flag[rows], text);
                   }
               }
             }
          } 

         selected_part_rows = selected_part_rows/9;
         mcf_select = FALSE;

         break;

    case STORAGE_AREA_FLD:         /* Field Type:    ASCII    */

        /* Field is non-selectable at this time */

        break;

    case ACL_NAME_FLD:         /* Field Type:    ASCII    */

    /* The ACL_NAME_FLD is non-selectable */

         break;

    case WORKFLOW_FLD:         /* Field Type:    ASCII    */

    /* The WORKFLOW_FLD is non-selectable */
         
         break;

    case EP_PROJECT_FLD:     /* Member of group EXISTING_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering EP_PROJECT_FLD",0);

       status = PDUep_proj_fld();
       _pdm_status("PDUep_proj_fld",status);

       if (status == 0)
          break;
    
       PDUmessage(status,'s');

       break;

    case EP_CATALOG_FLD:     /* Member of group EXISTING_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering EP_CATALOG_FLD",0);

       status = PDUep_cat_fld();
       _pdm_status("PDUep_cat_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break; 

    case EP_PARTNUM_FLD:     /* Member of group EXISTING_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering EP_PARTNUM_FLD",0);

       status = PDUep_part_fld();
       _pdm_status("PDUep_part_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case EP_REV_FLD:     /* Member of group EXISTING_PART_GRP  */

       _pdm_debug("Entering EP_REV_FLD",0);

       status = PDUep_rev_fld();
       _pdm_status("PDUep_rev_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       if ((status == PDM_S_SUCCESS) &&
           (PDU_form_id != forms.part_operations_form_id))
          FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[4],0,0,0,0,0,0);

       break;

    case EP_PARTTYPE_FLD:     /* Member of group EXISTING_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering EP_PARTTYPE_FLD",0);

       status = PDUep_parttype_fld();
       _pdm_status("PDUep_parttype_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case EP_DESC_FLD:     /* Member of group EXISTING_PART_GRP  */
                             /* Field Type:    ASCII    */

       _pdm_debug("Entering EP_DESC_FLD",0);

       status = PDUep_desc_fld();
       _pdm_status("PDUep_desc_fld",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

      case EP_PARTTYPE_BTN:       /* Member of group EXISTING_PART_GRP  */

       _pdm_debug("Entering EP_PARTTYPE_BTN",0);

       PDU_active_button = EP_PARTTYPE_BTN;

       status = PDUep_parttype_btn();
       _pdm_status("PDUep_parttype_btn",status);

       if (status == 0)
          break;

       if ((status == PDM_S_SUCCESS) || (status == MEM_S_SUCCESS))
          FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[5],0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case EP_REV_BTN:     /* Member of group EXISTING_PART_GRP  */

       _pdm_debug("Entering EP_REV_BTN",0);

       PDU_active_button = EP_REV_BTN;

       status = PDUep_rev_btn();
       _pdm_status("PDUep_rev_btn",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case EP_PARTNUM_BTN:     /* Member of group EXISTING_PART_GRP  */

       /* call PDM function to retrieve a list of partids */

       _pdm_debug("Entering EP_PARTNUM_BTN",0);

       PDU_active_button = EP_PARTNUM_BTN;

       status = PDUep_part_btn();
       _pdm_status("PDUep_part_btn",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case EP_CATALOG_BTN:     /* Member of group EXISTING_PART_GRP  */ 

       _pdm_debug("Entering EP_CATALOG_BTN",0);

       PDU_active_button = EP_CATALOG_BTN;

       status = PDUep_cat_btn();
       _pdm_status("PDUep_cat_btn",status);

       if (status == 0)
          break;

       PDUmessage(status,'s');

       break;

    case EP_PROJECT_BTN:     /* Member of group EXISTING_PART_GRP  */
                             /* Sequenced to    */

       _pdm_debug("Entering EP_PROJECT_BTN",0);

       PDU_active_button = EP_PROJECT_BTN;

       status = PDUep_proj_btn();
       _pdm_status("PDUep_proj_btn",status);

       if (status == 0)
          break;

       if (status == PDM_S_SUCCESS)
          FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[1],0,0,0,0,0,0);

       PDUmessage(status,'s');

       break;

    case SIMILAR_MODE_MCF:

    _pdm_debug("ENTER CASE: SIMILAR_MODE_MCF",0);

    PDUmessage(PDM_E_CLEAR_FIELD,'s');

    _pdm_debug("np_catalog = <%s>", np_catalog);
    _pdm_debug("nn_itemname = <%s>", nn_itemname);
    _pdm_debug("np_rev = <%s>", np_rev);
    _pdm_debug("np_parttype = <%s>", np_parttype);
  
    cisaname_text = NULL_STRING;
    FIfld_get_text_length(fp,STORAGE_AREA_FLD, 0, 0, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(fp, STORAGE_AREA_FLD, 0, 0, length,(unsigned char *)text, 
                   &select, &pos);
    PDUfill_in_string1(&cisaname_text,text);
    _pdm_debug("cisaname_text = <%s>", cisaname_text);

    if ((similar_mode == TRUE) &&
        ((strcmp(np_parttype,"N") != 0) &&
        (strcmp(np_parttype,"n") != 0)))
       {
       if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0))
          {
          msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
          FIg_set_text(fp,FI_MSG_FIELD,msg);
          PDUmessage(PDM_I_ENTER_CATALOG, 's');
          FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
          break;
          }

       FIfld_get_active_row(fp,SIMILAR_MODE_MCF, &act_row,&pos);
       _pdm_debug("active row = %d", (char *)act_row);

       FImcf_get_active_col(fp,SIMILAR_MODE_MCF, &file_info_col,&pos);
       _pdm_debug("active column = %d", (char *)file_info_col);

       FIfld_get_text_length(fp,SIMILAR_MODE_MCF, act_row,file_info_col,
                             &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(fp, SIMILAR_MODE_MCF,act_row,file_info_col, 
                      length,(unsigned char *)text, &select, &pos);

       if (!text)
         PDUfill_in_string(&text, NULL_STRING);

       if (file_info_col == 0)
          {
          _pdm_debug("File Description Selected = <%s>", text);
          PDUfill_in_string1(&filedesc_text, text);

          if ((filedesc_text == NULL) || (strcmp(filedesc_text,"") == 0))
            {
            if (PDU_data_bufr && (act_row == 0))
              {
              _pdm_debug("resetting filedesc field in data buffer", 0);
              MEMbuild_array(PDU_data_bufr);
              PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
              PDUget_buffer_col(PDU_data_bufr, "p_filedesc", &column);
              MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
              if (PDU_data_bufr->rows > 1)
                MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
              }
            break;
            }

          string_len = strlen(filedesc_text);

          if (string_len > 40)
             {
             msg = (char *) PDUtranslate_message(PDM_E_FILE_DESC_TOO_LONG);
             FIg_set_text(fp,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_FILE_DESC_TOO_LONG, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,0,"",FALSE);
             break;
             }

          if (PDU_data_bufr && (act_row == 0))
            {
            _pdm_debug("resetting filedesc field in data buffer", 0);
            MEMbuild_array(PDU_data_bufr);
            PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
            PDUget_buffer_col(PDU_data_bufr, "p_filedesc", &column);
            MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
            if (PDU_data_bufr->rows > 1)
              MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
            }
          }
       else if (file_info_col == 2)
          {
          _pdm_debug("Local Filename Selected = <%s>", text);
/* MJG 11/22/95 - TR 139528293 - Exit if the user keys in an empty string */
          if ((!text) || ((text) && (!strlen(text))))
            {
            _pdm_debug("empty string", 0);
            PDU_add_files = FALSE;
            break;
            }

          PDUfill_in_string1(&cofile_text, text);

          FIfld_get_num_rows(fp, SIMILAR_MODE_MCF, &max_rows);
 
          /* Test to see if the local filename is unique to the part */
          for (i = 0; i < max_rows; ++i)
             {
             if (i != act_row)
             {
             FIfld_get_text_length(fp, SIMILAR_MODE_MCF, i,2, &max_row_length);
             max_row_text = (char *) malloc (sizeof (char) *
                            max_row_length + 1);
             memset(max_row_text,NULL,sizeof (char ) * max_row_length + 1);
             FIfld_get_text (fp, SIMILAR_MODE_MCF, i, 2, max_row_length+1, 
                             (unsigned char *)max_row_text, &select_flag,
                             &pos );

             if (strcmp(cofile_text,max_row_text) == 0)
                {
                msg = (char *)PDUtranslate_message(PDM_E_LOCAL_FILE_NOT_UNIQUE);
                FIg_set_text(fp,FI_MSG_FIELD,msg);
                PDUmessage(PDM_E_LOCAL_FILE_NOT_UNIQUE, 's');
                FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,2,"",FALSE);
                change_stat = FALSE;
                status = PDM_E_LOCAL_FILE_NOT_UNIQUE;
                break;
                }
             }
             }

          if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS) &&
             (status != MEM_S_SUCCESS))
             break;

/* Mychelle - 6/2/93 - Allow local filenames to be duplicated for Lincoln
   Electric and VDS */
/*
          if (PDU_simmode_copy == TRUE)
             {
             * The old local filenames have been listed. Check to make sure
                that the new local filename being entered is not the same
                as any of the old local filenames. Duplications would cause
                local file manager problems because if you checked in the new
                part that had a duplicat graphic file copied, it would delete
                the local copy of the file. This would leave the old part that
                had been copied to local to be without its file. *
             for (i = 0; i < max_rows; ++i)
                {
                FIfld_get_text_length(fp, SIMILAR_MODE_MCF, i ,1, &text_length);
                old_local_file = (char *) malloc (sizeof (char) *
                                 text_length + 1);
                FIfld_get_text (fp, SIMILAR_MODE_MCF, i, 1, text_length+1, 
                                (unsigned char *)old_local_file, &select_flag, 
                                &pos );
                _pdm_debug("old local file = <%s>", old_local_file);

                if (strcmp(cofile_text,old_local_file) == 0)
                   {
                msg = (char *)PDUtranslate_message(PDM_E_LOCAL_FILE_NOT_UNIQUE);
                   FIg_set_text(fp,FI_MSG_FIELD,msg);
                   PDUmessage(PDM_E_LOCAL_FILE_NOT_UNIQUE, 's');
                   FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,2,"",FALSE);
                   change_stat = FALSE;
                   break;
                   }
                }
             } 

          if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS) &&
             (status != MEM_S_SUCCESS))
             break;
*/

          string_len = strlen(cofile_text);

          if (string_len > 14)
             {
             msg = (char *)PDUtranslate_message(PDM_E_LOC_FN_TOO_LONG);
             FIg_set_text(fp,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_LOC_FN_TOO_LONG, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,2,"",FALSE);
             break;
             }

          status = PDUcheck_char(cofile_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_LOCFN);
             FIg_set_text(fp,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_LOCFN, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,2,"",FALSE);
             break;
             }

          PDU_add_files = TRUE;
          }
       else if (file_info_col == 3)
          {
          _pdm_debug("Storage Filename Selected = <%s>", text);
/* MJG 11/22/95 - TR 139528293 - Exit if the user keys in an empty string */
          if ((!text) || ((text) && (!strlen(text))))
            {
            _pdm_debug("empty string", 0);
            break;
            }

          PDUfill_in_string1(&cifile_text, text);

          string_len = strlen(cifile_text);

          if (string_len > 14)
             {
             msg = (char *)PDUtranslate_message(PDM_E_STG_FN_TOO_LONG);
             FIg_set_text(fp,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_STG_FN_TOO_LONG, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,3,"",FALSE);
             break;
             }

          status = PDUcheck_char(cifile_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_STGFN);
             FIg_set_text(fp,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_STGFN, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,3,"",FALSE);
             break;
             }

            FIfld_get_num_rows(fp, SIMILAR_MODE_MCF, &max_rows);

            /* Test to see if the storage filename is unique to the part */
            for (i = 0; i < max_rows; ++i)
                {
                if (i != act_row)
                {
                FIfld_get_text_length(fp,SIMILAR_MODE_MCF,i,3,&max_row_length);
                max_row_text = (char *) malloc (sizeof (char) *
                               max_row_length + 1);
                memset(max_row_text,NULL, (sizeof(char) * max_row_length + 1));
                FIfld_get_text (fp, SIMILAR_MODE_MCF, i, 3, max_row_length+1, 
                                (unsigned char *)max_row_text, &select_flag, 
                                &pos );

                if (strcmp(cifile_text,max_row_text) == 0)
                   {
                   FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,3,"",FALSE);
                   msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                   FIg_set_text(fp,FI_MSG_FIELD,msg);
                   PDUmessage(PDM_E_STG_FN_NOT_UNIQUE, 's');
                   status = PDM_E_STG_FN_NOT_UNIQUE;
                   break;
                   }
                }
                }

            if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS))
               break;

            /* Verify storage filename is unique */
            FIfld_get_text_length(fp,STORAGE_AREA_FLD, 0, 0, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL, sizeof (char) * length + 1);
            FIfld_get_text(fp,STORAGE_AREA_FLD,0,0,length,(unsigned char *)text, &select, &pos);
            PDUfill_in_string1(&cisaname_text,text);
            _pdm_debug("cisaname_text = <%s>", cisaname_text);
  
            msg = (char *)PDUtranslate_message(PDS_M_VALIDATE_STG_FILENAME);
            FIg_set_text(fp,FI_MSG_FIELD,msg);
            PDUmessage(PDS_M_VALIDATE_STG_FILENAME, 's');

            if ((cisaname_text == NULL) || (strcmp(cisaname_text, "") == 0) ||
                (cifile_text == NULL) || (strcmp(cifile_text, "") == 0))
              {
              _pdm_debug("cannot check for dup storage area, value is NULL", 0);
              }
            else
              {
              status = PDMrcheck_dup_sa_fname(np_catalog,nn_itemname,np_rev,
                                              cifile_text,cisaname_text);
              _pdm_status("PDMrcheck_dup_sa_fname",status);

              if (status != PDM_S_SUCCESS)
                 {
                 msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                 FIg_set_text(fp,FI_MSG_FIELD,msg);
                 PDUmessage(PDM_E_STG_FN_NOT_UNIQUE, 's');
                 FIfld_set_text(fp,SIMILAR_MODE_MCF,act_row,3,"",FALSE);
                 break;
                 }
              else if (status == PDM_S_SUCCESS)
                 FIg_set_text(fp,FI_MSG_FIELD,NULL_STRING);
                }
          }
       else if (file_info_col == 4)
          {
          _pdm_debug("Filetype Selected = <%s>", text);
          PDUfill_in_string1(&filetype_text, text);

          if ((filetype_text == NULL) || (strcmp(filetype_text,"") == 0))
            {
            if (PDU_data_bufr && (act_row == 0))
              {
              _pdm_debug("resetting filetype field in data buffer", 0);
              MEMbuild_array(PDU_data_bufr);
              PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
              PDUget_buffer_col(PDU_data_bufr, "n_filetype", &column);
              MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
              if (PDU_data_bufr->rows > 1)
                MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
              }
            break;
            }

          if ((strcmp(filetype_text,"M") == 0) ||
              (strcmp(filetype_text,"m") == 0))
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_FILETYPE);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_FILETYPE, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,4,"",FALSE);
             sleep(4);
             break;
             }

          string_len = strlen(filetype_text);

          if (string_len > 5)
             {
             msg = (char *)PDUtranslate_message(PDM_E_FILETYPE_TOO_LONG);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_FILETYPE_TOO_LONG, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,4,"",FALSE);
             break;
             }

          status = PDUcheck_char(filetype_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_FILETYPE);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_FILETYPE, 's');
             FIfld_set_text(fp, SIMILAR_MODE_MCF,act_row,4,"",FALSE);
             break;
             }

          if (PDU_data_bufr && (act_row == 0))
            {
            _pdm_debug("resetting filetype field in data buffer", 0);
            MEMbuild_array(PDU_data_bufr);
            PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
            PDUget_buffer_col(PDU_data_bufr, "n_filetype", &column);
            MEMwrite_data(PDU_data_bufr, text, 1, column + 1);
            if (PDU_data_bufr->rows > 1)
              MEMwrite_data(PDU_data_bufr, text, 2, column + 1);
            }
           }
        }

    break;

    case EXISTING_FILES_MCF:

    _pdm_debug("ENTER CASE: EXISTING_FILES_MCF",0);

    PDUmessage(PDM_E_CLEAR_FIELD,'s');

    _pdm_debug("ep_catalog = <%s>", ep_catalog);
    _pdm_debug("en_itemname = <%s>", en_itemname);
    _pdm_debug("ep_rev = <%s>", ep_rev);
  
    if ((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0))
       {
       msg = (char *)PDUtranslate_message(PDM_I_ENTER_CATALOG);
       FIg_set_text(fp,FI_MSG_FIELD, msg);
       PDUmessage(PDM_I_ENTER_CATALOG, 's');
       break;
       }

    if ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0))
       {
       msg = (char *)PDUtranslate_message(PDM_I_ENTER_PART);
       FIg_set_text(fp,FI_MSG_FIELD, msg);
       PDUmessage(PDM_I_ENTER_PART, 's');
       break;
       }

    /* check state of delete files toggle */
    FIg_get_state(fp, DELETE_FILES_TGL, &state);
    _pdm_debug("delete files toggle = %d", (char *)state);
    if (state)
      {
      _pdm_debug("checking to see if part is a member of an assembly", 0);
      
      status = PDMrget_imm_parents(refresh->rev_catalog,
           refresh->rev_partid, refresh->rev_revision, &ret_bufr);
      _pdm_status("PDMrget_imm_parents", status);

      if ((status != PDM_E_NO_PARENTS) && (status != SQL_I_NO_ROWS_FOUND))
        {
        FImcf_set_select(fp, EXISTING_FILES_MCF, active_row, FALSE);
        status = PDM_I_PART_IN_ASS;
        msg = (char *)PDUtranslate_message(status);
        FIg_set_text(fp,FI_MSG_FIELD, msg);
        PDUmessage(status, 's');
        change_stat = FALSE;
        break;
        }
      else 
        {
        status = PDM_S_SUCCESS;
        PDUmessage(PDM_S_SUCCESS, 's');
        }
      break;
      }

    FIfld_get_text_length(fp,STORAGE_AREA_FLD, 0, 0, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(fp, STORAGE_AREA_FLD, 0, 0, length,(unsigned char *)text, 
                   &select, &pos);
    PDUfill_in_string1(&cisaname_text,text);
    _pdm_debug("cisaname_text = <%s>", cisaname_text);
  
    status = MEMbuild_array(PDU_data_bufr);
    _pdm_status("MEMbuild_array",status);

    if (status != MEM_S_SUCCESS)
      { 
      status = PDM_E_BUILD_BUFFER_ARRAY;
      msg = (char *)PDUtranslate_message(status);
      FIg_set_text(fp,FI_MSG_FIELD, msg);
      PDUmessage(status, 's');
      }

    data_col = (char **) PDU_data_bufr->column_ptr;
    data_row = (char **) PDU_data_bufr->data_ptr;

    if (PDMdebug_on)
       MEMprint_buffers("PDU_data_bufr in Case FILE",PDU_data_bufr,
                        PDU_DEBUG_FILE);

    status = PDUget_col_number(PDU_data_bufr,"n_status",data_col,&n_status_col);
    _pdm_status("PDUget_col_number",status);

    if (status != PDM_S_SUCCESS)
       {
       PDUmessage(status,'s');
       break;
       }

    if (PDU_file_data_bufr)
       {
       status = MEMbuild_array(PDU_file_data_bufr);
       _pdm_status("MEMbuild_array",status);

       if (status != MEM_S_SUCCESS)
         { 
         status = PDM_E_BUILD_BUFFER_ARRAY;
         msg = (char *)PDUtranslate_message(status);
         FIg_set_text(fp,FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         }

       file_data_col = (char **) PDU_file_data_bufr->column_ptr;
       file_data_row = (char **) PDU_file_data_bufr->data_ptr;

       if (PDMdebug_on)
          MEMprint_buffers("PDU_file_data_bufr in Case FILE",
                           PDU_file_data_bufr,PDU_DEBUG_FILE);

       status = MEMbuild_array(PDU_sav_file_data_bufr);
       _pdm_status("MEMbuild_array",status);

       if (status != MEM_S_SUCCESS)
         { 
         status = PDM_E_BUILD_BUFFER_ARRAY;
         msg = (char *)PDUtranslate_message(status);
         FIg_set_text(fp,FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         }

       sav_file_data_col = (char **) PDU_sav_file_data_bufr->column_ptr;
       sav_file_data_row = (char **) PDU_sav_file_data_bufr->data_ptr;

       if (PDMdebug_on)
          MEMprint_buffers("PDU_sav_file_data_bufr in Case FILE",
                           PDU_sav_file_data_bufr,PDU_DEBUG_FILE);
       }

    if (strcmp(data_row[(PDU_data_bufr->columns * 0) + n_status_col],"I")
        != 0)
       {
       status = MEMbuild_array(PDU_add_data_bufr);
       _pdm_status("MEMbuild_array",status);

       if (status != MEM_S_SUCCESS)
         { 
         status = PDM_E_BUILD_BUFFER_ARRAY;
         msg = (char *)PDUtranslate_message(status);
         FIg_set_text(fp,FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         }

       add1_data_col = (char **) PDU_add_data_bufr->column_ptr;

       if (PDMdebug_on)
          MEMprint_buffers("PDU_add_data_bufr in Case FILE",
                           PDU_add_data_bufr,PDU_DEBUG_FILE);
       }

    FIfld_get_active_row(PDU_form_id,EXISTING_FILES_MCF,&active_row,&pos);
    _pdm_debug("active_row = %d", (char *)active_row);

    FImcf_get_active_col(fp,EXISTING_FILES_MCF, &file_info_col,&pos);
    _pdm_debug("active column = %d", (char *)file_info_col);

    /*This will change existing file data*/

    change_files_flag = TRUE;

    FIfld_get_text_length(fp,EXISTING_FILES_MCF, active_row,file_info_col,
                          &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(fp, EXISTING_FILES_MCF,active_row,file_info_col, 
                   length,(unsigned char *)text, &select, &pos);
    _pdm_debug("text = <%s>", text);

    if (file_info_col == 0)
       {
       _pdm_debug("processing FILE_DESC col", 0);

       if (text == NULL)
         break;

       _pdm_debug("File Description Selected = <%s>", text);
       filedesc_text = NULL_STRING;
       PDUfill_in_string1(&filedesc_text, text);
       _pdm_debug("filedesc_text = <%s>", filedesc_text);

       string_len = strlen(filedesc_text);

       if (string_len > 40)
          {
          msg = (char *)PDUtranslate_message(PDM_E_FILE_DESC_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_FILE_DESC_TOO_LONG, 's');
          FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,0,"",FALSE);
          break;
          }

       status = PDUget_col_number(PDU_file_data_bufr,"p_filedesc",
                                  file_data_col, &p_filedesc_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status = PDUget_col_number(PDU_file_data_bufr,"n_status",file_data_col,
                                  &n_status_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status = MEMwrite_data(PDU_file_data_bufr,filedesc_text,active_row + 1,
                              p_filedesc_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status, 's');
          break;
          }

       status = MEMwrite_data(PDU_file_data_bufr,"Y",active_row + 1,
                              n_status_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          break;
          }

       if (PDMdebug_on)
          MEMprint_buffer("PDU_file_data_bufr after writing filedesc_text",
                          PDU_file_data_bufr,PDU_DEBUG_FILE);
       }
    else if (file_info_col == 1)
       {
       _pdm_debug("processing LOCAL_FILENAME col", 0);

       if (text == NULL) 
          break;

       _pdm_debug("Local Filename Selected = <%s>", text);

       _pdm_debug("retrieving previous filename from buffer", 0);

       status = PDUget_buffer_col(PDU_file_data_bufr,"n_cofilename",
                                  &n_cofilenm_col);
       if (status != PDM_S_SUCCESS)
         {
         _pdm_debug("failed to get buffer column number", 0);
         break;
         }

       PDUfill_in_string1(&cofile_text, 
                 file_data_row[(PDU_file_data_bufr->columns * active_row) 
                               + n_cofilenm_col]);

       if (strcmp(text,"") == 0)
         {
         FIfld_set_text(fp, EXISTING_FILES_MCF, active_row,file_info_col,
                        cofile_text, FALSE);
         msg = (char *)PDUtranslate_message(PDM_E_CANNOT_BLANK_OUT_FN);
         FIg_set_text(fp,FI_MSG_FIELD, msg);
         PDUmessage(PDM_E_CANNOT_BLANK_OUT_FN, status);
         change_stat = FALSE;
         break;
         }
       else if (strcmp(text, cofile_text) != 0)
         {
         _pdm_debug("new filename has been entered; check where used", 0);
         status = PDMrget_imm_parents(refresh->rev_catalog,
              refresh->rev_partid, refresh->rev_revision, &ret_bufr);
         _pdm_status("PDMrget_imm_parents", status);
 
         if ((status != PDM_E_NO_PARENTS) && (status != SQL_I_NO_ROWS_FOUND))
           {
           FIfld_set_text(fp, EXISTING_FILES_MCF, active_row,file_info_col,
                          cofile_text, FALSE);
           msg = (char *)PDUtranslate_message(PDM_I_PART_IN_ASS);
           FIg_set_text(fp,FI_MSG_FIELD, msg);
           change_stat = FALSE;
           status = PDM_I_PART_IN_ASS;
           PDUmessage(status, 's');
           break;
           }
         else 
           {
           status = PDM_S_SUCCESS;
           PDUmessage(PDM_S_SUCCESS, 's');
           }
         }

       cofile_text = NULL_STRING;
       PDUfill_in_string1(&cofile_text, text);
       _pdm_debug("cofile_text = <%s>", cofile_text);

       FIfld_get_num_rows(forms.part_operations_form_id,EXISTING_FILES_MCF,
                          &max_rows);
 
       /* Test to see if the local filename is unique to the part */
       for (i = 0; i < max_rows; ++i)
          {
          if (i != active_row)
          {
          _pdm_debug("CALL: FIfld_get_text_length",0);
          FIfld_get_text_length(forms.part_operations_form_id,
                                         EXISTING_FILES_MCF, i,1,
                                         &max_row_length);

          max_row_text = (char *) malloc (sizeof (char) *
                         max_row_length + 1);
          memset(max_row_text,NULL,sizeof (char ) * max_row_length + 1);

          _pdm_debug("CALL: FIfld_get_text",0);
          FIfld_get_text (forms.part_operations_form_id,
                                   EXISTING_FILES_MCF, i, 1,
                                   max_row_length+1,
                                   (unsigned char *)max_row_text,
                                   &select_flag, &pos );

          if (strcmp(cofile_text,max_row_text) == 0)
             {
             msg = (char *)PDUtranslate_message(PDM_E_LOCAL_FILE_NOT_UNIQUE);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_LOCAL_FILE_NOT_UNIQUE, 's');
             FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,1,"",FALSE);
             status = PDM_E_LOCAL_FILE_NOT_UNIQUE;
             break;
             }
          }
          }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS) &&
          (status != MEM_S_SUCCESS))
          break;

       string_len = strlen(cofile_text);

       if (string_len > 14)
          {
          msg = (char *)PDUtranslate_message(PDM_E_LOC_FN_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_LOC_FN_TOO_LONG, 's');
          FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,1,"",FALSE);
          break;
          }

          status = PDUcheck_char(cofile_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_LOCFN);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_LOCFN, 's');
             FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,1,"",FALSE);
             break;
             }

       status = PDUget_col_number(PDU_file_data_bufr,"n_cofilename",
                                  file_data_col, &n_cofilenm_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status = PDUget_col_number(PDU_file_data_bufr,"n_status",file_data_col,
                                  &n_status_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status=MEMwrite_data(PDU_file_data_bufr,cofile_text,active_row + 1,
                            n_cofilenm_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          break;
          }

       status=MEMwrite_data(PDU_file_data_bufr,"Y",active_row + 1,
                            n_status_col+1);
       _pdm_status("MEMwrite_data",status);

       if (PDMdebug_on)
          MEMprint_buffer("PDU_file_data_bufr after writing cofile_text",
                          PDU_file_data_bufr,PDU_DEBUG_FILE);
       }
    else if (file_info_col == 2)
       {
       _pdm_debug("processing STORAGE_FILENAME col", 0);

       if (text == NULL)
         break;
       else if (strcmp(text,"") == 0)
         break;
/*
       if ((strcmp(text,"") == 0) && (PDU_file_data_bufr))
         {
         _pdm_debug("retrieving filename from buffer", 0);
         status = PDUget_buffer_col(PDU_file_data_bufr,"n_cifilename",
                                    &n_cifilenm_col);
         _pdm_status("PDUget_buffer_col", status);

         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("failed to get buffer column number", 0);
           break;
           }

         PDUfill_in_string1(&cifile_text, 
                file_data_row[(PDU_file_data_bufr->columns * active_row) + 
                n_cifilenm_col]);
         if (strcmp(text, cifile_text) != 0)
           {
           PDUmessage(status,'s');
           FIfld_set_text(fp, EXISTING_FILES_MCF, active_row,file_info_col,
                          cifile_text, FALSE);
           change_stat = FALSE;
           }
         break;
         }
*/

       _pdm_debug("Storage Filename Selected = <%s>", text);
       cifile_text = NULL_STRING;
       PDUfill_in_string1(&cifile_text, text);
       _pdm_debug("cifile_text = <%s>", cifile_text);

       string_len = strlen(cifile_text);

       if (string_len > 14)
          {
          msg = (char *)PDUtranslate_message(PDM_E_STG_FN_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_STG_FN_TOO_LONG,'s');
          FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,2,"",FALSE);
          break;
          }

          status = PDUcheck_char(cifile_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_STGFN);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_STGFN,'s');
             FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,2,"",FALSE);
             break;
             }

            FIfld_get_num_rows(forms.part_operations_form_id,EXISTING_FILES_MCF,
                               &max_rows);

            /* Test to see if the storage filename is unique to the part */
            /* Test the EXISTING_FILES_MCF */
            for (i = 0; i < max_rows; ++i)
                {
                if (i != active_row)
                {
                _pdm_debug("CALL: FIfld_get_text_length",0);
                FIfld_get_text_length(forms.part_operations_form_id,
                                               EXISTING_FILES_MCF, i,2,
                                               &max_row_length);

                max_row_text = (char *) malloc (sizeof (char) *
                               max_row_length + 1);
                memset(max_row_text,NULL, (sizeof(char) * max_row_length + 1));

                _pdm_debug("CALL: FIfld_get_text",0);
                FIfld_get_text (forms.part_operations_form_id,
                                         EXISTING_FILES_MCF, i, 2,
                                         max_row_length+1, 
                                         (unsigned char *)max_row_text,
                                         &select_flag, &pos );

                if (strcmp(cifile_text,max_row_text) == 0)
                   {
                   msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                   FIg_set_text(fp,FI_MSG_FIELD, msg);
                   PDUmessage(PDM_E_STG_FN_NOT_UNIQUE,'s');
                   FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,2,"",FALSE);
                   status = PDM_E_STG_FN_NOT_UNIQUE;
                   break;
                   }
                }
                }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS))
          break;

       /* Test to see if the storage filename entered is one of the original
          storage filenames that was in the PDU_file_data_bufr before being
          overwritten by new storage filenames. This is done in case a user
          enters a new storage filename and then decides they want the
          original back.
          The test is in PDU_sav_file_data_bufr. */

       status = PDUget_col_number(PDU_sav_file_data_bufr,"n_cifilename",
                                  sav_file_data_col, &n_cifilenm_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          _pdm_debug("failed while retrieving column number", 0);
          break;
          }

       for (i = 0; i < PDU_sav_file_data_bufr->rows; ++i)
           {
           if (strcmp(sav_file_data_row[(PDU_sav_file_data_bufr->columns * i) +
               n_cifilenm_col],cifile_text) == 0) 
              {
              found = 1;
              break;
              }
           }
   
        if (found == 1)
           {
           _pdm_debug("This storage filename was an original storage file",0);
           }
        else
           {
           /* Verify that the storage filename is unique */
           _pdm_debug("cisaname_text = <%s>", cisaname_text);
  
           msg = (char *)PDUtranslate_message(PDS_M_VALIDATE_STG_FILENAME);
           FIg_set_text(fp,FI_MSG_FIELD, msg);
           PDUmessage(PDS_M_VALIDATE_STG_FILENAME,'s');

            if ((cisaname_text == NULL) || (strcmp(cisaname_text, "") == 0) ||
                (cifile_text == NULL) || (strcmp(cifile_text, "") == 0))
              {
              _pdm_debug("cannot check for dup storage area, value is NULL", 0);
              }
            else
              {
              status = PDMrcheck_dup_sa_fname(ep_catalog,en_itemname,ep_rev,
                                              cifile_text,cisaname_text);
              _pdm_status("PDMrcheck_dup_sa_fname",status);

              if (status != PDM_S_SUCCESS)
                 {
                 msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                 FIg_set_text(fp,FI_MSG_FIELD, msg);
                 PDUmessage(PDM_E_STG_FN_NOT_UNIQUE,'s');
                 FIfld_set_text(PDU_form_id,EXISTING_FILES_MCF,active_row,2,"",
                                FALSE);
                 break;
                 }
              else if (status == PDM_S_SUCCESS)
                 FIg_set_text(fp,FI_MSG_FIELD,NULL_STRING);
              }
           }
 
       status = PDUget_col_number(PDU_file_data_bufr,"n_cifilename",
                                  file_data_col, &n_cifilenm_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }
 
       status = PDUget_col_number(PDU_file_data_bufr,"n_status",file_data_col,
                                  &n_status_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status=MEMwrite_data(PDU_file_data_bufr,cifile_text,active_row + 1,
                            n_cifilenm_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          break;
          }

       status=MEMwrite_data(PDU_file_data_bufr,"Y",active_row + 1,
                            n_status_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          break;
          }

       if (PDMdebug_on)
          MEMprint_buffer("PDU_file_data_bufr after writing cifile_text",
                          PDU_file_data_bufr,PDU_DEBUG_FILE);
       }
    else if (file_info_col == 3)
       {
       _pdm_debug("processing FILE_TYPE col", 0);

       if (text == NULL)
         break;

       _pdm_debug("Filetype Selected = <%s>", text);
       filetype_text = NULL_STRING;
       PDUfill_in_string1(&filetype_text, text);
       _pdm_debug("filetype_text = <%s>", filetype_text);

       if ((strcmp(filetype_text,"M") == 0) ||
           (strcmp(filetype_text,"m") == 0))
          {
          msg = (char *)PDUtranslate_message(PDM_E_INVALID_FILETYPE);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          FIfld_set_text(forms.part_operations_form_id,
                         EXISTING_FILES_MCF,active_row,3,"",FALSE);
          sleep(4);
          break;
          }

       string_len = strlen(filetype_text);

       if (string_len > 5)
          {
          msg = (char *)PDUtranslate_message(PDM_E_FILETYPE_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_FILETYPE_TOO_LONG,'s');
          FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,3,"",FALSE);
          break;
          }

          status = PDUcheck_char(filetype_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_FILETYPE_TOO_LONG);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_FILETYPE_TOO_LONG,'s');
             FIfld_set_text(fp, EXISTING_FILES_MCF,active_row,3,"",FALSE);
             break;
             }

       status = PDUget_col_number(PDU_file_data_bufr,"n_filetype",file_data_col,
                                  &n_filetype_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status = PDUget_col_number(PDU_file_data_bufr,"n_status",file_data_col,
                                  &n_status_col);
       _pdm_status("PDUget_col_number",status);

       if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status,'s');
          break;
          }

       status=MEMwrite_data(PDU_file_data_bufr,filetype_text,active_row+1,
                            n_filetype_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          break;
          }

       status=MEMwrite_data(PDU_file_data_bufr,"Y",active_row + 1,
                            n_status_col+1);
       _pdm_status("MEMwrite_data",status);

       if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          msg = (char *)PDUtranslate_message(status);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(status,'s');
          break;
          }

       if (PDMdebug_on)
          MEMprint_buffer("PDU_file_data_bufr after writing filetype_text",
                          PDU_file_data_bufr,PDU_DEBUG_FILE);
       }

    /* This writes the checked in storage area name (cisaname) that
       is selected on the from to the PDU_file_data_bufr.*/

    PDUget_col_number(PDU_file_data_bufr,"n_cisaname",file_data_col,
                      &n_cisaname_col);

    _pdm_debug("cisaname_text = <%s>", cisaname_text);
  

    status = MEMwrite_data(PDU_file_data_bufr,cisaname_text,active_row+1,
                           n_cisaname_col+1);
    _pdm_status("MEMwrite_data",status);

    if (status != MEM_S_SUCCESS)
       {
       status = PDM_E_WRITE_BUFFER;
       msg = (char *)PDUtranslate_message(status);
       FIg_set_text(fp,FI_MSG_FIELD, msg);
       PDUmessage(status,'s');
       break;
       }
 
    break;

    case NEW_FILES_MCF:

    _pdm_debug("ENTER CASE: NEW_FILES_MCF",0);

    _pdm_debug("ep_catalog = <%s>", ep_catalog);
    _pdm_debug("en_itemname = <%s>", en_itemname);
    _pdm_debug("ep_rev = <%s>", ep_rev);
  
    FIfld_get_text_length(fp,STORAGE_AREA_FLD, 0, 0, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(fp, STORAGE_AREA_FLD, 0, 0, length, 
                   (unsigned char *)text, &select, &pos);
    PDUfill_in_string1(&cisaname_text,text);
    _pdm_debug("cisaname_text = <%s>", cisaname_text);
  
    /* This will allow the user to enter any number of files.
       The files will be processed from the NEW_FILES_MCF in the
       PDUchg_part.c file after the CHANGE_BTN is selected. */

    add_files_flag = TRUE;

    FIfld_get_active_row(forms.part_operations_form_id,NEW_FILES_MCF,
                         &act_row,&pos);
    _pdm_debug("active row = %d", (char *)act_row);

    FImcf_get_active_col(forms.part_operations_form_id,NEW_FILES_MCF,
                         &file_info_col,&pos);
    _pdm_debug("file_info_col = %d", (char *)file_info_col);

    FIfld_get_text_length(fp,NEW_FILES_MCF, act_row,file_info_col, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(fp, NEW_FILES_MCF,act_row,file_info_col, 
                   length,(unsigned char *)text, &select, &pos);

    if (file_info_col == 0)
       {
       _pdm_debug("processing FILE DESCRIPTION", 0);
       if ((text == NULL) || (strcmp(text,"") == 0))
          break;

       _pdm_debug("File Description Selected = <%s>", text);
       filedesc_text = NULL_STRING;
       PDUfill_in_string1(&filedesc_text, text);

       string_len = strlen(filedesc_text);
       _pdm_debug("STRING_LEN = <%d>",(char *)string_len);

       if (string_len > 40)
          {
          msg = (char *)PDUtranslate_message(PDM_E_FILE_DESC_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_FILE_DESC_TOO_LONG,'s');
          FIfld_set_text(fp, NEW_FILES_MCF,act_row,0,"",FALSE);
          break;
          }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS))
          {
          _pdm_debug("File description failed",0);
          break;
          }
       _pdm_debug("After File Description",0);
       }
    else if (file_info_col == 1)
       {
       _pdm_debug("processing CHECKOUT FILENAME", 0);
       if ((text == NULL) || (strcmp(text,"") == 0))
          break;
         
       _pdm_debug("Local Filename Selected = <%s>", text);
       PDUfill_in_string1(&cofile_text, text);

       FIfld_get_num_rows(forms.part_operations_form_id,NEW_FILES_MCF,
                          &max_rows);
 
       /* Test to see if the local filename is unique to the part */
       /* Test the NEW_FILES_MCF */

       for (i = 0; i < max_rows; ++i)
          {
          if (i != act_row)
          {
          _pdm_debug("CALL: FIfld_get_text_length",0);
          FIfld_get_text_length(forms.part_operations_form_id,
                                         NEW_FILES_MCF, i,1,
                                         &max_row_length);

          max_row_text = (char *) malloc (sizeof (char) *
                         max_row_length + 1);
          memset(max_row_text,NULL,sizeof (char ) * max_row_length + 1);

          _pdm_debug("CALL: FIfld_get_text",0);
          FIfld_get_text (forms.part_operations_form_id,
                                   NEW_FILES_MCF, i, 1,
                                   max_row_length+1, 
                                   (unsigned char *)max_row_text,
                                   &select_flag, &pos );

          if (strcmp(cofile_text,max_row_text) == 0)
             {
             msg = (char *)PDUtranslate_message(PDM_E_LOCAL_FILE_NOT_UNIQUE);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_LOCAL_FILE_NOT_UNIQUE,'s');
             FIfld_set_text(fp, NEW_FILES_MCF,act_row,1,"",FALSE);
             status = PDM_E_LOCAL_FILE_NOT_UNIQUE;
             break;
             }
          }
          }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS) &&
          (status != MEM_S_SUCCESS))
          break;

       FIfld_get_num_rows(forms.part_operations_form_id,EXISTING_FILES_MCF,
                          &max_rows);

       /* Test the EXISTING_FILES_MCF to check for duplicate local filenames */
       for (i = 0; i < max_rows; ++i)
           {
          _pdm_debug("CALL: FIfld_get_text_length",0);
          FIfld_get_text_length(forms.part_operations_form_id,
                                         EXISTING_FILES_MCF, i,1,
                                         &max_row_length);

          max_row_text = (char *) malloc (sizeof (char) *
                         max_row_length + 1);
          memset(max_row_text,NULL,sizeof (char ) * max_row_length + 1);

          _pdm_debug("CALL: FIfld_get_text",0);
          FIfld_get_text (forms.part_operations_form_id,
                                   EXISTING_FILES_MCF, i, 1,
                                   max_row_length+1, 
                                   (unsigned char *)max_row_text,
                                   &select_flag, &pos );

          if (strcmp(cofile_text,max_row_text) == 0)
             {
             msg = (char *)PDUtranslate_message(PDM_E_LOCAL_FILE_NOT_UNIQUE);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_LOCAL_FILE_NOT_UNIQUE,'s');
             FIfld_set_text(fp, NEW_FILES_MCF,act_row,1,"",FALSE);
             status = PDM_E_LOCAL_FILE_NOT_UNIQUE;
             break;
             }
           }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS) &&
          (status != MEM_S_SUCCESS))
          break;

       string_len = strlen(cofile_text);
       _pdm_debug("STRING_LEN = <%d>",(char *)string_len);

       if (string_len > 14)
          {
          msg = (char *)PDUtranslate_message(PDM_E_LOC_FN_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_LOC_FN_TOO_LONG,'s');
          FIfld_set_text(fp, NEW_FILES_MCF,act_row,1,"",FALSE);
          break;
          }

          status = PDUcheck_char(cofile_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_LOCFN);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_LOCFN,'s');
             FIfld_set_text(fp, NEW_FILES_MCF,act_row,1,"",FALSE);
             break;
             }

       _pdm_debug("After local filename",0);
       }
    else if (file_info_col == 2)
       {
       _pdm_debug("processing CHECKIN FILENAME", 0);
       if ((text == NULL) || (strcmp(text,"") == 0))
          break;

       _pdm_debug("Storage Filename Selected = <%s>", text);
       cifile_text = NULL_STRING;
       PDUfill_in_string1(&cifile_text, text);

       string_len = strlen(cifile_text);

       if (string_len > 14)
          {
          msg = (char *)PDUtranslate_message(PDM_E_STG_FN_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_STG_FN_TOO_LONG,'s');
          FIfld_set_text(fp, NEW_FILES_MCF,act_row,2,"",FALSE);
          break;
          }

          status = PDUcheck_char(cifile_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_STGFN);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_STGFN,'s');
             FIfld_set_text(fp, NEW_FILES_MCF,act_row,2,"",FALSE);
             break;
             }

            FIfld_get_num_rows(forms.part_operations_form_id, NEW_FILES_MCF,
                               &max_rows);

            /* Test to see if the storage filename is unique to the part */
            /* Test the NEW_FILES_MCF */

            for (i = 0; i < max_rows; ++i)
                {
                if (i != act_row)
                {
                _pdm_debug("CALL: FIfld_get_text_length",0);
                FIfld_get_text_length(forms.part_operations_form_id,
                                               NEW_FILES_MCF, i,2,
                                               &max_row_length);

                max_row_text = (char *) malloc (sizeof (char) *
                               max_row_length + 1);
                memset(max_row_text,NULL, (sizeof(char) * max_row_length + 1));

                _pdm_debug("CALL: FIfld_get_text",0);
                FIfld_get_text (forms.part_operations_form_id,
                                         NEW_FILES_MCF, i, 2,
                                         max_row_length+1, 
                                         (unsigned char *)max_row_text,
                                         &select_flag, &pos );

                if (strcmp(cifile_text,max_row_text) == 0)
                   {
                   FIfld_set_text(fp, NEW_FILES_MCF,act_row,2,"",FALSE);
                   msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                   FIg_set_text(fp,FI_MSG_FIELD, msg);
                   PDUmessage(PDM_E_STG_FN_NOT_UNIQUE,'s');
                   status = PDM_E_STG_FN_NOT_UNIQUE;
                   break;
                   }
                }
                }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS)) 
          break;

            /* Test the EXISTING_FILES_MCF */

            if (PDU_file_data_bufr != NULL)
               {
            FIfld_get_num_rows(forms.part_operations_form_id,EXISTING_FILES_MCF,
                               &max_rows);

            for (i = 0; i < max_rows; ++i)
                {
                _pdm_debug("CALL: FIfld_get_text_length",0);
                FIfld_get_text_length(forms.part_operations_form_id,
                                               EXISTING_FILES_MCF, i,2,
                                               &max_row_length);

                max_row_text = (char *) malloc (sizeof (char) *
                               max_row_length + 1);
                memset(max_row_text,NULL, (sizeof(char) * max_row_length + 1));

                _pdm_debug("CALL: FIfld_get_text",0);
                FIfld_get_text (forms.part_operations_form_id,
                                         EXISTING_FILES_MCF, i, 2,
                                         max_row_length+1, 
                                         (unsigned char *)max_row_text,
                                         &select_flag, &pos );

                if (strcmp(cifile_text,max_row_text) == 0)
                   {
                   msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
                   FIg_set_text(fp,FI_MSG_FIELD, msg);
                   PDUmessage(PDM_E_STG_FN_NOT_UNIQUE,'s');
                   FIfld_set_text(fp, NEW_FILES_MCF,act_row,2,"",FALSE);
                   status = PDM_E_STG_FN_NOT_UNIQUE;
                   break;
                   }
                }

       if ((status != PDM_S_SUCCESS) && (status != FI_SUCCESS))
          break;
                }

       /* Verify that the storage filename is unique */
       FIfld_get_text_length(fp,STORAGE_AREA_FLD, 0, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(fp,STORAGE_AREA_FLD,0,0,length,(unsigned char *)text, 
                      &select, &pos);
       PDUfill_in_string1(&cisaname_text,text);
       _pdm_debug("cisaname_text = <%s>", cisaname_text);
  
       msg = (char *)PDUtranslate_message(PDS_M_VALIDATE_STG_FILENAME);
       FIg_set_text(fp,FI_MSG_FIELD, msg);
       PDUmessage(PDS_M_VALIDATE_STG_FILENAME,'s');

       if ((cisaname_text == NULL) || (strcmp(cisaname_text, "") == 0) ||
           (cifile_text == NULL) || (strcmp(cifile_text, "") == 0))
         {
         _pdm_debug("cannot check for dup storage area, value is NULL", 0);
         }
       else
         {
         status = PDMrcheck_dup_sa_fname(ep_catalog,en_itemname,ep_rev,
                                       cifile_text,cisaname_text);
         _pdm_status("PDMrcheck_dup_sa_fname",status);

         if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_STG_FN_NOT_UNIQUE);
            FIg_set_text(fp,FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_STG_FN_NOT_UNIQUE,'s');
            FIfld_set_text(PDU_form_id,NEW_FILES_MCF,act_row,2,"",FALSE);
            break;
            }
         else if (status == PDM_S_SUCCESS)
            FIg_set_text(fp,FI_MSG_FIELD,NULL_STRING);
         }
       }
    else if (file_info_col == 3)
       {
       _pdm_debug("processing FILE TYPE", 0);

       if ((text == NULL) || (strcmp(text,"") == 0))
          break;

       PDUfill_in_string1(&filetype_text, text);
       filetype_text = NULL_STRING;
       _pdm_debug("Filetype Selected = <%s>", text);

       if ((strcmp(filetype_text,"M") == 0) ||
           (strcmp(filetype_text,"m") == 0))
          {
          msg = (char *)PDUtranslate_message(PDM_E_INVALID_FILETYPE);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_INVALID_FILETYPE,'s');
          FIfld_set_text(fp, NEW_FILES_MCF,act_row,3,"",FALSE);
          sleep(4);
          break;
          }

       string_len = strlen(filetype_text);

       if (string_len > 5)
          {
          msg = (char *)PDUtranslate_message(PDM_E_FILETYPE_TOO_LONG);
          FIg_set_text(fp,FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_FILETYPE_TOO_LONG,'s');
          FIfld_set_text(fp, NEW_FILES_MCF,act_row,3,"",FALSE);
          break;
          }

          status = PDUcheck_char(filetype_text,&spec_char);
          _pdm_status("PDUcheck_char",status);

          if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_FILETYPE);
             FIg_set_text(fp,FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_INVALID_CHAR_IN_FILETYPE,'s');
             FIfld_set_text(fp, NEW_FILES_MCF,act_row,3,"",FALSE);
             break;
             }
       }

    break;

    case VALUE_LIST_FIELD:

    _pdm_debug("ENTER CASE: VALUE_LIST_FIELD",0);

         list_row = value - 1;
         FIfld_get_active_row(fp, ATTRIBUTE_VALUE_MCF, &row, &pos);
         FIfld_set_text(fp, ATTRIBUTE_VALUE_MCF, row, 1, 
                        PDU_value_list[list_row], FALSE);
         _pdm_debug("value selected = <%s>", PDU_value_list[list_row]);
        
         /* set value_text to value selected */

         FIfld_set_select(fp, ATTRIBUTE_VALUE_MCF, row, 0, FALSE);
         FImcf_set_active_col(forms.part_operations_form_id,
                              ATTRIBUTE_VALUE_MCF, 0,0);

         FIfld_get_text_length(fp,ATTRIBUTE_VALUE_MCF, row,0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, ATTRIBUTE_VALUE_MCF,row,0,length,
                        (unsigned char *)text,&select,&pos);

         PDUfill_in_string(&attr_text, text);
         _pdm_debug("attr_text = <%s>", attr_text);
         attr_text = attr_text + 1;
         _pdm_debug("attr_text = <%s>", attr_text);

         status = MEMbuild_array(PDU_attr_bufr);
         _pdm_status("MEMbuild_array",status);

         if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_BUILD_BUFFER_ARRAY;
           msg = (char *)PDUtranslate_message(status);
           FIg_set_text(fp,FI_MSG_FIELD, msg);
           PDUmessage(status,'s');
           break;
           }

         PDU_attr_data_col = (char **) PDU_attr_bufr->column_ptr;
         PDU_attr_data_row = (char **) PDU_attr_bufr->data_ptr;

         PDUget_col_number(PDU_attr_bufr,"n_name",PDU_attr_data_col,
                           &n_name_col);
         PDUget_col_number(PDU_attr_bufr,"n_synonym",PDU_attr_data_col,
                           &n_syn_col);

         for (i = 0; i < PDU_attr_bufr->rows; i++)
            {
            if (strcmp(PDU_attr_data_row[(PDU_attr_bufr->columns * i) +
                       n_syn_col], attr_text) == 0)
               {
               status = MEMwrite_data(PDU_data_bufr,PDU_value_list[list_row],
                                      1,i + 1);
               if (status != MEM_S_SUCCESS)
                  {
                  status = PDM_E_WRITE_BUFFER;
                  msg = (char *)PDUtranslate_message(status);
                  FIg_set_text(fp,FI_MSG_FIELD, msg);
                  PDUmessage(status,'s');
                  break;
                  }
               else
                  {
                  found = 1;
                  }
               }
            else if (strcmp(PDU_attr_data_row[(PDU_attr_bufr->columns * i) +
                            n_name_col], attr_text) == 0)
               {
               status = MEMwrite_data(PDU_data_bufr,PDU_value_list[list_row],
                                      1,i + 1);
               if (status != MEM_S_SUCCESS)
                  {
                  status = PDM_E_WRITE_BUFFER;
                  msg = (char *)PDUtranslate_message(status);
                  FIg_set_text(fp,FI_MSG_FIELD, msg);
                  PDUmessage(status,'s');
                  break;
                  }
               else
                  {
                  found = 1;
                  }
               }
            if (found == 1)
                break;
            }

        break;

  } /* END switch ( g_label ) */

  _pdm_debug("LEAVING notification routine",0);

return (1);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the Part Operations
   Form. */

int PDUpart_form()
{
  int  sts = PDM_S_SUCCESS;
  int  list_size = 0;
  part_operations_created = FALSE;
  part_operations_displayed = FALSE;

/* If PART_FORM name is changed the actual form name in ../config/english/forms
   must be changed as well as in PDUform_def.h */

  sts = FIf_new(PART_FORM, "part_form", 
                part_operations_notification_routine, 
                &forms.part_operations_form_id);

 /* create the GRpulldown_list */

   GRcreate_pull_down_list(PART_FORM, forms.part_operations_form_id,
                 VALUE_LIST_FIELD,MAX_ROWS,VIS_ROWS,PDU_value_list, list_size,
                  1, &PDU_value_pulldown);

  part_operations_created = TRUE;

  /* Call function to initialize the Part Operations Form */

  PDUpart_operations_init();
 
  FIf_set_location(forms.part_operations_form_id, 0, 115);

  /* Display the pdm_review form and set the displayed flag to TRUE. */

  sts = FIf_display(forms.part_operations_form_id);
  part_operations_displayed = TRUE;
  PDU_form_id = forms.part_operations_form_id;

  return(sts);
}

int PDUcancel_modify_part()

  {
  int status = PDM_S_SUCCESS;
  int *fn;
  void PDMcancel_modify();

  _pdm_debug("In the function PDUcancel_modify_part", 0);

  new_mode = FALSE;
  change_mode = FALSE;
  similar_mode = FALSE;
  review_mode = FALSE;

   status = PDMcancel_modify_part(refresh->act_catalog,
                                  refresh->act_partid,
                                  refresh->act_revision,
                                  PDU_attr_bufr, PDU_data_bufr);

   _pdm_status("PDMcancel_modify_part",status);

   fn = (int *)PDMcancel_modify;
   exitdel(fn);

   return(status);
   }

int PDUprocess_valid_catalog_status(status)
int  status;
{
Form fp;
char *msg = NULL;

     _pdm_debug("in the function PDUprocess_valid_catalog_status", 0);
     PDUmessage(status, 's');
     mode_change_flag = FALSE;
     fp = forms.part_operations_form_id;

     msg = (char *) PDUtranslate_message(status);
     FIg_set_text(fp,FI_MSG_FIELD, msg);

   return(1);
}

void PDUreset_part_form_flags()
{
end_np_cat_btn_flag = FALSE;
end_np_part_btn_flag = FALSE;
end_np_parttype_btn_flag = FALSE;
end_ep_proj_btn_flag = FALSE;
end_ep_cat_btn_flag = FALSE;
end_ep_part_fld_flag = FALSE;
end_ep_part_btn_flag = FALSE;
end_ep_rev_btn_flag = FALSE;
end_ep_desc_fld_flag = FALSE;
end_ep_desc_btn_flag = FALSE;
end_move_to_state_btn_flag = FALSE;
end_ep_parttype_btn_flag = FALSE;
end_stg_area_btn_flag = FALSE;
pdu_hold_stg_bufr_flag = FALSE;
pdu_ep_stg_bufr_flag = FALSE;
pdu_hold_acl_bufr_flag = FALSE;
pdu_ep_acl_bufr_flag = FALSE;
PDU_list_cat = FALSE;
PDU_add_files = FALSE;
PDU_simmode_copy = FALSE;
PDU_simmode_checkin = FALSE;
mode_change_flag = FALSE;
part_operations_created = FALSE;
part_operations_displayed = FALSE;
change_part = FALSE;
checked_in = FALSE;
enter_part = FALSE;
new_mode = FALSE;
similar_mode = FALSE;
change_mode = FALSE;
review_mode = FALSE;
new_file = FALSE;
pt_flag = FALSE;
bufr_flag = FALSE;
existing_file = FALSE;
np_cat_btn_flag = FALSE;
ep_part_fld_flag = FALSE;
ep_part_btn_flag = FALSE;
ep_rev_btn_flag = FALSE;
ep_desc_flag = FALSE;
acl_flag = FALSE;
workflow_flag = FALSE;
change_files_flag = FALSE;
add_files_flag = FALSE;
PDU_delete_files = FALSE;
change_stat = FALSE;
new_part_flag = FALSE;
end_acl_wf_btn_flag = FALSE;
PDU_simmode_cat_bufr = FALSE;
PDU_part_flagged = FALSE;
}

void PDUclose_part_form_buffers()
{
  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }
  if (PDU_ep_bufr)
    {
    MEMclose(&PDU_ep_bufr);
    PDU_ep_bufr = NULL;
    }
  if (PDU_display_buffer)
    {
    MEMclose(&PDU_display_buffer);
    PDU_display_buffer = NULL;
    }
  if (PDU_design_parts_bufr)
    {
    MEMclose(&PDU_design_parts_bufr);
    PDU_design_parts_bufr = NULL;
    }
  if (PDU_ep_data_bufr)
    {
    MEMclose(&PDU_ep_data_bufr);
    PDU_ep_data_bufr = NULL;
    }
  if (PDU_attr_bufr)
    {
    MEMclose(&PDU_attr_bufr);
    PDU_attr_bufr = NULL;
    }
  if (PDU_data_bufr)
    {
    MEMclose(&PDU_data_bufr);
    PDU_data_bufr = NULL;
    }
  if (PDU_acl_bufr)
    {
    MEMclose(&PDU_acl_bufr);
    PDU_acl_bufr = NULL;
    }
  if (PDU_stg_bufr)
    {
    MEMclose(&PDU_stg_bufr);
    PDU_stg_bufr = NULL;
    }
  if (PDU_file_data_bufr)
    {
    MEMclose(&PDU_file_data_bufr);
    PDU_file_data_bufr = NULL;
    }
  if (PDU_states_bufr)
    {
    MEMclose(&PDU_states_bufr);
    PDU_states_bufr = NULL;
    }
  if (PDU_sav_file_data_bufr)
    {
    MEMclose(&PDU_sav_file_data_bufr);
    PDU_sav_file_data_bufr = NULL;
    }
  if (PDU_list_bufr)
    {
    MEMclose(&PDU_list_bufr);
    PDU_list_bufr = NULL;
    }
  if (PDU_hold_bufr)
    {
    MEMclose(&PDU_hold_bufr);
    PDU_hold_bufr = NULL;
    }
  if (PDU_part_frm_search_bufr)
    {
    MEMclose(&PDU_part_frm_search_bufr);
    PDU_part_frm_search_bufr = NULL;
    }
  if (PDU_copyof_ret_bufr)
    {
    MEMclose(&PDU_copyof_ret_bufr);
    PDU_copyof_ret_bufr = NULL;
    }
  if (states_bufr)
    {
    MEMclose(&states_bufr);
    states_bufr = NULL;
    }
}
