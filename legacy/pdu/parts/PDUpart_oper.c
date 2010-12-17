#include <stdio.h>
#include <FI.h>
#include <tools.h>
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUforms.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDMcommand.h"
#include "part_gadgets.h"
#include "PDUform_def.h"
#include "NFMerrordef.h"
#include "PDMmessage.h"
#include <PDUproto.h>
#include <PDMproto.h>

/* The #DEFINES for the gadgets on this form are in part_gadgets.h */

/* Externs */

extern int    PDM_debug_on;
extern int    mode_change_flag;
extern int    PDU_active_button;
extern int    PDU_class_level;
extern int    PDU_command;
extern int    PDU_refresh_gadgets[7];
extern int    PDU_part_checked_in;
extern int    PDU_simmode_copy;
extern int    PDU_simmode_checkin;
extern int    PDU_disable_move_state_btn;
extern int    PDU_func_bufr_exists;
extern char * calloc();
extern char * realloc();
extern char  *trans_name;
extern char *** PDU_update_struct;
extern char ** PDU_data_col;
extern char ** PDU_data_row;
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern int FIg_get_type();
extern Form   place_part_f;
extern Form   ModifyPartForm;
extern Form PDU_form_id;
extern MEMptr   PDU_copyof_ret_bufr;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_data_bufr;
extern MEMptr PDU_states_bufr;
extern MEMptr states_bufr;
extern MEMptr PDU_attr_bufr;
extern MEMptr PDU_add_data_bufr;
extern MEMptr add_data_bufr;
extern MEMptr PDU_file_data_bufr;
extern MEMptr PDU_cat_class_bufr;
extern MEMptr PDU_stg_bufr;
extern MEMptr PDU_display_buffer;
extern struct PDUrefresh    *refresh;
extern struct PDUforms      forms;
extern int *PDU_gadget_labels;
extern int PDUinit_stack();
extern int PDUpush_into_stack();
extern int PDUdelete_form_stack();
extern int PDUget_top_of_stack();
extern int * PDU_stack;
extern int PDUprint_stack();
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
extern char     *PDU_save_parttype;
extern int      part_operations_created;
extern int      part_operations_displayed;
extern int      enter_part;
extern int      new_mode;
extern int      similar_mode;
extern int      change_mode;
extern int      review_mode;
extern int      new_file;
extern int      pt_flag;
extern int      bufr_flag;
extern int      acl_flag;
extern int      workflow_flag;
extern int      existing_file;
extern int      np_cat_btn_flag;
extern int      ep_part_fld_flag;
extern int      ep_part_btn_flag;
extern int      ep_rev_btn_flag;
extern int      ep_desc_flag;
extern int      change_part;
extern MEMptr   new_data_bufr;
extern char     ** new_data_row;
extern char     ** new_data_col;
extern int      PDMdebug_on;
extern int      single_flag;
extern int      end_move_to_state_btn_flag;
extern MEMptr   PDU_part_frm_search_bufr;
extern char     *PDU_template_catalog;
extern short    PDU_localfn_newfiles_disable;
extern short    PDU_multiple_revs;
extern short    PDU_never_checked_in;
extern int      new_part_flag;
extern int      all_flag;
extern int      no_headings;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_cat_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_parttype_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_stg_area_btn_flag;
extern int      end_acl_wf_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_simmode_cat_bufr;
extern int      PDU_part_flagged;
extern char  ** headings;
extern char   * search_str;
extern MEMptr   PDU_hold_bufr;
extern MEMptr   PDU_ep_bufr;
extern MEMptr   PDU_hold_stg_bufr;
extern MEMptr   PDU_hold_acl_bufr;
extern MEMptr   PDU_ep_stg_bufr;
extern MEMptr   PDU_ep_acl_bufr;

/* This function process the existing project field. */

int PDUep_proj_fld()

{
   int       length, select, pos;
   int       status = PDM_S_SUCCESS;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_proj_fld",0);

   ep_project = NULL_STRING;
   refresh->rev_project = NULL_STRING;

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[0], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_project,text);
   _pdm_debug("ep_project = <%s>", ep_project);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   if ((ep_project == NULL) || (strcmp(ep_project,"") == 0))
      return(0);

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

/* 10/18/93 - Per Kumar, if the catalog is entered first, it does not have to
   be validated for mapping to the project */

   /*if (change_mode)*/
     status = PDUvalid_project(ep_project,"");
     _pdm_status("PDUvalid_project",status);

   if (status != PDM_S_SUCCESS)
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[0],0,0,"",FALSE);

   else if (status == PDM_S_SUCCESS)
      PDUfill_in_string1(&refresh->rev_project,ep_project);

   if ((status == PDM_S_SUCCESS) && (!refresh->rev_catalog))
      FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[1],0,0,0,0,0,0);
   else if ((status == PDM_S_SUCCESS) && (strcmp(refresh->rev_catalog, "")==0))
      FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[1],0,0,0,0,0,0);

   return(status);
}

/* This function processes the existing catalog field. */

int PDUep_cat_fld()

{
   int       length = 0, select, pos;
   int       status = PDM_S_SUCCESS;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_cat_fld",0);

      /* Blank out following fields */

   if (PDU_form_id != forms.bom_contents_form_id)
     {
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
  
     en_itemname = NULL_STRING;
     ep_rev = NULL_STRING;
     ep_desc = NULL_STRING;
  
     refresh->rev_partid = NULL_STRING;
     refresh->rev_revision = NULL_STRING;
     refresh->rev_description = NULL_STRING;
     }

   if (PDU_form_id == forms.part_operations_form_id)
      {
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,"",FALSE);
      refresh->rev_parttype = NULL_STRING;
      ep_parttype = NULL_STRING;
      }

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   if (length == 0)
     return(0);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   if ((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0)) 
      return(0);

   PDU_simmode_cat_bufr = FALSE;

/*
   if (((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) &&
       (similar_mode == TRUE))
      {
      bufr_flag = TRUE;
      PDU_simmode_cat_bufr = TRUE;
      }
   else
      bufr_flag = FALSE;
*/
   bufr_flag = FALSE;

   if ((PDU_form_id != forms.report_form_id) &&
       (PDU_form_id != forms.bom_contents_form_id) &&
       (PDU_form_id != forms.cat_name_form_id) &&
       (PDU_form_id != forms.define_lib_form_id) &&
       (PDU_form_id != forms.topdown_form_id) &&
       (PDU_form_id != forms.seed_form_form_id))
      {
      _pdm_debug("Getting project from fields", 0);
      FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[0], 0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                     (unsigned char *)text, &select, &pos);
      PDUfill_in_string1(&ep_project,text);
      }
   else
      {
      PDUfill_in_string1(&ep_project,"");
      _pdm_debug("Defaulting project to blank", 0);
      }

   _pdm_debug("ep_project = <%s>", ep_project);

   status = PDUprocess_ep_catalog();

   if (status != PDM_S_SUCCESS)
      {
      FIg_set_text(PDU_form_id, PDU_refresh_gadgets[1], "");
      ep_catalog = NULL_STRING;
      refresh->rev_catalog = NULL_STRING;
      PDUmessage(status, 's');
      }

   return(status);
}

/* This function processes the existing part number field when the catalog has
   already been entered or if the part number is entered and then the catalog
   is selected from a list. */

int PDUep_part_fld()

{
   int       length, select, pos;
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_part_fld",0);

   if ((change_mode == TRUE) || (review_mode == TRUE) || (similar_mode == TRUE))
      {
      if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
          (strcmp(ep_rev,"") != 0))
         {
         status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return(status);
            }
         }
      }

   /* Blank out following fields */

   if (PDU_form_id != forms.bom_contents_form_id)
     {
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
  
     ep_rev = NULL_STRING;
     ep_desc = NULL_STRING;
  
     refresh->rev_partid = NULL_STRING;
     refresh->rev_revision = NULL_STRING;
     refresh->rev_description = NULL_STRING;
     }

   if ((PDU_form_id != forms.topdown_form_id) &&
       (PDU_form_id != forms.seed_form_form_id) &&
       (PDU_form_id != forms.bom_contents_form_id) &&
       (PDU_form_id != forms.report_form_id) &&
       (PDU_form_id != forms.cat_name_form_id) &&
       (PDU_form_id != forms.define_lib_form_id))
     {
     FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[0], 0, 0, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL_STRING, sizeof (char) * length + 1);
     FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                    (unsigned char *)text, &select, &pos);
     PDUfill_in_string1(&ep_project,text);
     }
   else
     PDUfill_in_string1(&ep_project,"");
   _pdm_debug("ep_project = <%s>", ep_project);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[2], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&en_itemname,text);
   _pdm_debug("en_itemname = <%s>", en_itemname);

   if ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0)) 
      return(0);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[3], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[3], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_rev,text);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   if (PDU_form_id == forms.part_operations_form_id)
     {
     FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[4], 0, 0, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL_STRING, sizeof (char) * length + 1);
     FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[4], 0, 0, length, 
                    (unsigned char *)text, &select, &pos);
     PDUfill_in_string1(&ep_parttype,text);
     _pdm_debug("ep_parttype = <%s>", ep_parttype);
     }
   else 
     {
     ep_parttype = NULL_STRING;
     _pdm_debug("ep_parttype = <%s>", ep_parttype);
     }

   if (PDU_form_id == forms.part_operations_form_id)
      {
      if (((refresh->rev_catalog != NULL) && 
          (strcmp(refresh->rev_catalog,"") != 0)) &&
          ((refresh->rev_partid != NULL) && 
           (strcmp(refresh->rev_partid,"") != 0)) &&
          ((refresh->rev_revision != NULL) && 
          (strcmp(refresh->rev_revision,"") != 0)) &&
          (mode_change_flag == FALSE))
         {
         if ((strcmp(ep_catalog,refresh->rev_catalog) == 0) &&
             (strcmp(en_itemname,refresh->rev_partid) == 0) &&
             (strcmp(ep_rev,refresh->rev_revision) == 0))
            {
            msg = (char *) PDUtranslate_message(PDM_E_ATTRS_ALREADY_LISTED);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
            return(PDM_E_ATTRS_ALREADY_LISTED);
            }
         }
      }

   if (strcmp(ep_catalog,"") != 0)  
      {
      /* The catalog has already been entered. */

      if ((strcmp(ep_rev,"") != 0) && (strcmp(ep_parttype,"") != 0) &&
         (PDU_form_id == forms.part_operations_form_id))
         {
         /* In this case, we don't want to fill in the part type so we set
            pt_flag to FALSE. */

         _pdm_debug("Case where ep_rev and ep_parttype have a value",0);

         pt_flag = FALSE;

         status = PDUpull_bufr_info();
         _pdm_status("PDUpull_bufr_info",status);

         pt_flag = TRUE;

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
         }
      else if ((strcmp(ep_rev,"") != 0) && (strcmp(ep_parttype,"") == 0) &&
              (PDU_form_id == forms.part_operations_form_id))
         {
         /* In this case, we want to fill in part type. */

         _pdm_debug("Case ep_rev has a value and ep_parttype does not",0);

         pt_flag = TRUE;
         status = PDUpull_bufr_info();
         _pdm_status("PDUpull_bufr_info",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
         }
      else if ((strcmp(ep_rev,"") == 0) || 
              (PDU_form_id == forms.local_files_form_id) ||
              (PDU_form_id == forms.ex_file_form_id) ||
              (PDU_form_id == forms.report_form_id) ||
              (PDU_form_id == forms.topdown_form_id) ||
              (PDU_form_id == forms.where_used_form_id) ||
              (PDU_form_id == forms.seed_form_form_id))
         {
         /* The existing revision has no value so we must send the catalog and
            part number to get the latest revision, parttype, and description*/
    
         _pdm_debug("Case the ep_rev has no value",0);

         status = PDUvalid_partnum(ep_catalog,en_itemname);
         _pdm_status("PDUvalid_partnum",status);

         if (status != PDM_S_SUCCESS)
            {
            FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
            FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[2],0,0,0,0,0,0);
            PDUmessage(status, 's');
            return(status);
            }
         else
            {
            _pdm_debug("writing to refresh", 0);
            PDUfill_in_string(&refresh->rev_partid,en_itemname);

            /* Pull Revision, Part Type, and Description from buffer */
            if (PDU_ret_bufr && (PDU_ret_bufr->rows > 1))
              {
              PDU_multiple_revs = TRUE;
              if (PDU_display_buffer)
                {
                MEMclose(&PDU_display_buffer);
                PDU_display_buffer = NULL;
                }
              status = MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_display_buffer,0);
              _pdm_status("MEMsplit_copy_buffer", status);
              if (status != MEM_S_SUCCESS)
                {
                PDU_multiple_revs = FALSE;
                PDUmessage(PDM_E_COPY_BUFFER, 's');
                return(status);
                }
              if (PDMdebug_on)
                MEMprint_buffer("PDU_display_buffer", PDU_display_buffer,
                                 PDU_DEBUG_FILE);
              status = PDUprocess_ep_rev_btn();
              _pdm_status("PDUprocess_ep_rev_btn", 0);
              }
            else
              {
              status = PDUpull_rev_pt_desc();
              _pdm_status("PDUpull_rev_pt_desc",status);
  
              if (status != PDM_S_SUCCESS)
                 {
                FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
                 PDUmessage(status, 's');
                 return(status);
                 }

              if (PDU_form_id == forms.part_operations_form_id)
                 {
                 _pdm_debug("Entering case for part form only", 0);
        
                 pt_flag = TRUE;
                 status = PDUpull_bufr_info();
        
                 if (status != PDM_S_SUCCESS)
                    {
                    PDUmessage(status, 's');
                    return(status);
                    }
                 }
              }
            }
         }
      }
   else if (strcmp(ep_catalog,"") == 0)
      {

      /* The catalog has not been entered therefore a list of catalogs 
         containing the part number will be given. */

      end_ep_part_fld_flag = TRUE;

      if (search_str)
         {
         free(search_str);
         search_str = NULL;
         }
      search_str = (char *) malloc (sizeof (char) * 100);
      sprintf(search_str,"n_itemname = '%s'", en_itemname);

      if (strcmp(ep_project,"") != 0)
         {
         status = PDMcatalog_list(ep_project, search_str);
         _pdm_status("PDMcatalog_list",status);

         if (status != PDM_S_SUCCESS)
            {
            FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
            PDUmessage(status, 's');
            return(status);
            }
         }

      else
         {
         status = PDMcatalog_list(NULL, search_str);
         _pdm_status("PDMcatalog_list",status);

         if (status != PDM_S_SUCCESS)
            {
            FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
            PDUmessage(status, 's');
            return(status);
            }
         }

      if (search_str)
         {
         free(search_str);
         search_str = NULL;
         }

      /* Put code here that puts a buffer into a single form and then
         when user selects a catalog, puts it into the field. */

      PDU_command = PDC_M_SEARCH_ACROSS_CATS;

      PDUsetup_single_buffer(PDU_ret_bufr);

      if (PDU_form_id == forms.part_operations_form_id)
         PDU_gadget_labels[0] = EP_CATALOG_FLD;

      if (PDU_form_id == forms.local_files_form_id)
         PDU_gadget_labels[0] = CATALOG_FLD;

      if (PDU_form_id == forms.ex_file_form_id)
         PDU_gadget_labels[0] = EX_CATALOG_FLD;

      if (PDU_form_id == forms.report_form_id)
         PDU_gadget_labels[0] = CATALOG_NAME;

      if (PDU_form_id == forms.topdown_form_id)
         PDU_gadget_labels[0] = TD_CATALOG;

      if (PDU_form_id == forms.where_used_form_id)
         PDU_gadget_labels[0] = W_CATALOG;

      PDU_update_struct[0] = &refresh->rev_catalog;

      all_flag = TRUE;
      no_headings = 1;
      headings = (char **) malloc (sizeof (char *) * no_headings);
      memset(headings, NULL, sizeof (char *) * no_headings);

      PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
  
      PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUfree_string_array(&headings, no_headings);

      PDU_active_button = PDU_gadget_labels[0];

      status = PDUsingle_list_form();
      _pdm_status("PDUsingle_list_form",status);

      if (single_flag == TRUE)
         {
         single_flag = FALSE;
         return(PDM_S_SUCCESS);
         } 

      if (status == PDM_S_SUCCESS)
         return(0);
      }
   return(status);
}

/* This function processes the existing revision fields. */

int PDUep_rev_fld()
{
   int       length, select, pos;
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_rev_fld",0);

   if ((change_mode == TRUE) || (review_mode == TRUE) || (similar_mode == TRUE))
      {
      if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
          (strcmp(ep_rev,"") != 0))
         {
         status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return(status);
            }
         }
      }

     if (refresh->rev_catalog)
       PDUfill_in_string(&ep_catalog, refresh->rev_catalog);
     else
       {
       FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL_STRING, sizeof (char) * length + 1);
       FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                      (unsigned char *)text, &select, &pos);
       PDUfill_in_string1(&ep_catalog,text);
       }
     if (refresh->rev_partid)
       PDUfill_in_string(&en_itemname, refresh->rev_partid);
     else
       {
       FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[2], 0, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL_STRING, sizeof (char) * length + 1);
       FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, length, 
                      (unsigned char *)text, &select, &pos);
       PDUfill_in_string1(&en_itemname,text);
       }

   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("en_itemname = <%s>", en_itemname);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[3], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[3], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_rev,text);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   if ((ep_rev == NULL) || (strcmp(ep_rev,"") == 0)) 
      return(0);

   if (strcmp(ep_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
      return(PDM_I_ENTER_CATALOG);
      }
   else if (strcmp(en_itemname,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
      return(PDM_I_ENTER_PART);
      }
   else if ((strcmp(ep_catalog,"") != 0) &&
            (strcmp(en_itemname,"") != 0) &&
            (strcmp(ep_rev,"") != 0))
      {
      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }

      status = PDUcheck_partnum(ep_catalog,en_itemname,ep_rev);
      _pdm_status("PDUcheck_partnum",status);

      if (status != PDM_S_SUCCESS)
         {
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
         FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[3],0,0,0,0,0,0);
         return(status);
         }

      if (status == PDM_S_SUCCESS)
        {
        _pdm_debug("writing to refresh", 0);
        PDUfill_in_string1(&refresh->rev_revision, ep_rev);
        }

      status = PDMget_pt_desc(ep_catalog,en_itemname,ep_rev);
      _pdm_status("PDMget_pt_desc",status);

      if (status != PDM_S_SUCCESS)
         {
         status = PDM_E_RET_PARTTYPE_DESC;
         msg = (char *) PDUtranslate_message(PDM_E_RET_PARTTYPE_DESC);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         return(status);
         }

       status = PDUpull_pt_desc();
       _pdm_status("PDUpull_pt_desc",status);

      if (status != PDM_S_SUCCESS)
         {
         status = PDM_E_DSP_PARTTYPE_DESC;
         msg = (char *) PDUtranslate_message(PDM_E_DSP_PARTTYPE_DESC);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         return(status);
         }

      if (PDU_form_id == forms.part_operations_form_id)
         {
         /* Display the file info palette */
         if ((strcmp(ep_parttype,"N") != 0) &&
            (strcmp(ep_parttype,"n") != 0))
            {
            if (change_mode == TRUE)
               FIg_display(PDU_form_id,CHANGE_MODE_GRP);
            else if (review_mode == TRUE)
               FIg_display(PDU_form_id,FILE_INFO_GRP);
            }
         else if ((strcmp(ep_parttype,"N") == 0) ||
                 (strcmp(ep_parttype,"n") == 0))
            {
            if (change_mode == TRUE)
               FIg_erase(PDU_form_id,CHANGE_MODE_GRP);
            else if (review_mode == TRUE)
               FIg_erase(PDU_form_id,FILE_INFO_GRP);

            FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);
            FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);
            }

         /* Then send catalog, partnum, and revision to get attr_bufr and
            data_bufr which contain the Part Attribute Info, File Info,
            Storage Area name, Part Type and ACL Info.
            Call PDMget_part_data. */

         status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);

         if (status != PDM_S_SUCCESS)
            {
            msg = (char *) PDUtranslate_message(status);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
            return(status);
            }

         status = PDUpull_bufr_info();
         _pdm_status("PDUpull_bufr_info",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
         }
      }
   return(status);
}

/* This function processes the existing part type field. */

int PDUep_parttype_fld()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int             p_parttype_col;
   int             length, select, pos;
   int             stat_col = 0;
   char         ** data_col;
   char         ** data_row;
   char         ** add_data_row;
   char         ** add_data_col;
   char         ** add_data_format;
   char            type[5];
   char            *file_stat = NULL;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_parttype_fld",0);

   if (change_mode)
     {
     _pdm_debug("saving current parttype", 0);
     PDUfill_in_string1(&PDU_save_parttype, refresh->rev_parttype);
     }

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[4], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[4], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_parttype,text);
   _pdm_debug("ep_parttype = <%s>", ep_parttype);

   if (strcmp(ep_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      return(PDM_I_ENTER_CATALOG);
      }

   status = PDMquery_catalog_type(ep_catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   _pdm_debug("catalog type = <%s>", type);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (strcmp(type,"C") == 0)
      {
      if ((strcmp(ep_parttype,"D") != 0) &&
         (strcmp(ep_parttype,"d") != 0) &&
         (strcmp(ep_parttype,"M") != 0) &&
         (strcmp(ep_parttype,"m") != 0) &&
         (strcmp(ep_parttype,"G") != 0) &&
         (strcmp(ep_parttype,"g") != 0) &&
         (strcmp(ep_parttype,"N") != 0) &&
         (strcmp(ep_parttype,"n") != 0))
         {
         msg = (char *) PDUtranslate_message(PDM_I_STAND_PARTTYPE);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,msg);
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,"G",FALSE);
         PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
         FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[5],0,0,0,0,0,0);
         return(PDM_I_STAND_PARTTYPE);
         }
      }

   if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
       (strcmp(type,"EID") == 0) || (strcmp(type,"PXT") == 0))
      {
      if ((strcmp(ep_parttype,"P") != 0) && (strcmp(ep_parttype,"p") != 0))
         {
         msg = (char *) PDUtranslate_message(PDM_I_PARAM_PARTTYPE);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,msg);
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,"P",FALSE);
         PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
         FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[5],0,0,0,0,0,0);
         return(PDM_I_PARAM_PARTTYPE);
         }
      else
         return(PDM_S_SUCCESS);
      }

   if (strcmp(type,"EXT") == 0)
      {
      if ((strcmp(ep_parttype,"D") != 0) &&
         (strcmp(ep_parttype,"d") != 0) &&
         (strcmp(ep_parttype,"G") != 0) &&
         (strcmp(ep_parttype,"g") != 0) &&
         (strcmp(ep_parttype,"N") != 0) &&
         (strcmp(ep_parttype,"n") != 0))
         {
         msg = (char *) PDUtranslate_message(PDM_E_EXT_PARTTYPE);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,"G",FALSE);
         PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
         FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[5],0,0,0,0,0,0);
         return(PDM_E_EXT_PARTTYPE);
         }
      }

      PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
      FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[5],0,0,0,0,0,0);

      if ((PDU_form_id == forms.part_operations_form_id) &&
         (change_mode == TRUE) && PDU_data_bufr)
         {

         if ((en_itemname && (strcmp(en_itemname, "") == 0)) ||
             (ep_rev && (strcmp(ep_rev, "") == 0)))
           return(PDM_S_SUCCESS);
         else if ((!en_itemname) || (!ep_rev))
           return(PDM_S_SUCCESS);
 
         status = MEMbuild_array(PDU_data_bufr);
         _pdm_status("MEMbuild_array",status);

         if (status != MEM_S_SUCCESS)
            {
            status = PDM_E_BUILD_BUFFER_ARRAY;
            msg = (char *) PDUtranslate_message(status);
            FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
            PDUmessage(status, 's');
            return(status);
            }

         data_col = (char **) PDU_data_bufr->column_ptr;
         data_row = (char **) PDU_data_bufr->data_ptr;

         status = PDUget_col_number(PDU_data_bufr,"p_parttype",data_col,
                                    &p_parttype_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }

         if ((strcmp(data_row[(PDU_data_bufr->columns * 0) + p_parttype_col],
              ep_parttype) == 0)) 
            {
            return(0);
            /* This is because the part type is the same as what was already
               entered. */
            }
         else if ((strcmp(ep_parttype,"N") != 0) &&
                 (strcmp(ep_parttype,"n") != 0))
            {
            status=MEMwrite_data(PDU_data_bufr,ep_parttype,1,p_parttype_col+1);
            _pdm_status("MEMwrite_data", status);
            _pdm_debug("AFTER THE MEMwrite_data for ep_parttype",0);

            if (status != MEM_S_SUCCESS)
               {
               status = PDM_E_WRITE_BUFFER;
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
               return(status);
               }

            FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);

            FIg_display(PDU_form_id,CHANGE_MODE_GRP);
            FIg_display(PDU_form_id,DELETE_FILES_TGL);

            if (PDU_data_bufr)
              {
              _pdm_debug("checking file status", 0);
              status = MEMbuild_array(PDU_data_bufr);
              if (status != MEM_S_SUCCESS)
                {
                status = PDM_E_BUILD_BUFFER_ARRAY;
                PDUmessage(status, 's');
                return(status);
                }

              PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
              status = PDUget_buffer_col(PDU_data_bufr, "n_status", &stat_col);
              if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status, 's');
                return(status);
                }

              _pdm_debug("stat_col = %d", (char *)stat_col);

              PDUfill_in_string(&file_stat,
                      data_row[(PDU_data_bufr->columns * 0) + stat_col]);
              _pdm_debug("file_stat = %s", file_stat);

              if (strcmp(file_stat, "I") == 0)
                {
                _pdm_debug("part is checked in; returning SUCCESS", 0);
                return(PDM_S_SUCCESS);
                }
              }
          
            status = PDMget_add_buffer(ep_catalog,en_itemname,ep_rev);
            _pdm_status("PDMget_add_buffer",status);

            if ((status != PDM_S_SUCCESS) || (add_data_bufr == NULL))
               {
               FIg_erase(PDU_form_id,CHANGE_MODE_GRP);
               FIg_erase(PDU_form_id,DELETE_FILES_TGL);

               if (add_data_bufr == NULL)
                 status = PDM_E_NULL_BUFFER;
               PDUmessage(status,'s');
               if (!PDU_save_parttype)
                 PDU_save_parttype = NULL_STRING;
               PDUfill_in_string1(&ep_parttype, PDU_save_parttype);
               FIg_set_text(PDU_form_id,PDU_refresh_gadgets[4],ep_parttype);
               return(status);
               }

            status = PDUsetup_buffer_list(add_data_bufr, 2, 0, &add_data_row,
                                          &add_data_col,&add_data_format,
                                          &PDU_add_data_bufr);
            _pdm_status("PDUsetup_buffer_list", 0);

            if (status != PDM_S_SUCCESS)
               {
               FIg_erase(PDU_form_id,CHANGE_MODE_GRP);
               FIg_erase(PDU_form_id,DELETE_FILES_TGL);

               PDUmessage(status,'s');
               if (!PDU_save_parttype)
                 PDU_save_parttype = NULL_STRING;
               PDUfill_in_string1(&ep_parttype, PDU_save_parttype);
               FIg_set_text(PDU_form_id,PDU_refresh_gadgets[4],ep_parttype);
               return(status);
               }

            PDUmessage(status, 's');

            if (PDMdebug_on)
                MEMprint_buffer("ADD_DATA_BUFR",PDU_add_data_bufr,
                                 PDU_DEBUG_FILE);

            if ((change_mode == TRUE) && (PDU_file_data_bufr == NULL))
               FIg_disable(PDU_form_id,EXISTING_FILES_MCF);
            else
               FIg_enable(PDU_form_id,EXISTING_FILES_MCF);
            }
         else if ((strcmp(ep_parttype,"N") == 0) ||
                 (strcmp(ep_parttype,"n") == 0))
            {
            if (PDU_file_data_bufr == NULL)
               {
               status=MEMwrite_data(PDU_data_bufr,ep_parttype,1,
                                    p_parttype_col+1);
               _pdm_status("MEMwrite_data", status);
               _pdm_debug("AFTER THE MEMwrite_data for ep_parttype",0);

               if (status != MEM_S_SUCCESS)
                  {
                  status = PDM_E_WRITE_BUFFER;
                  msg = (char *) PDUtranslate_message(status);
                  FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
                  return(status);
                  }

               FIg_erase(PDU_form_id,DELETE_FILES_TGL);
               FIg_erase(PDU_form_id,CHANGE_MODE_GRP);

               FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);
               FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);
               }
            else
               {
               status = PDM_E_DELETE_FILES_FOR_NG;
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
               PDUmessage(status, 's');
               FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,"G",FALSE);
               }
            }
         }

      if (PDU_form_id == forms.part_operations_form_id && review_mode)
        {
         if ((strcmp(ep_parttype,"N") != 0) &&
             (strcmp(ep_parttype,"n") != 0))
           {
           FIg_display(PDU_form_id,FILE_INFO_GRP);
           FIg_display(forms.part_operations_form_id, EXISTING_FILE_TXT);
           }
         else if ((strcmp(ep_parttype,"N") == 0) ||
                  (strcmp(ep_parttype,"n") == 0))
           {
           FIg_erase(PDU_form_id,FILE_INFO_GRP);
           FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);
           }
        }

   if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

   return(status);
}

/* This function processes the existing description field. */

int PDUep_desc_fld()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   int       n_itemdesc_col;
   char   ** data_col;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_desc_fld",0);
 
   if ((PDU_form_id != forms.topdown_form_id) &&
       (PDU_form_id != forms.seed_form_form_id) &&
       (PDU_form_id != forms.bom_contents_form_id) &&
       (PDU_form_id != forms.report_form_id) &&
       (PDU_form_id != forms.cat_name_form_id) &&
       (PDU_form_id != forms.define_lib_form_id))
      {
      FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[0], 0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                     (unsigned char *)text, &select, &pos);
      PDUfill_in_string1(&ep_project,text);
      }
   else
      PDUfill_in_string1(&ep_project,"");

   _pdm_debug("ep_project = <%s>", ep_project);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[5], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[5], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_desc,text);
   _pdm_debug("ep_desc = <%s>", ep_desc);

   if ((ep_desc == NULL) || (strcmp(ep_desc,"") == 0)) 
      return(0);

   if (strcmp(ep_catalog,"") != 0)
      {
      status = PDUvalid_desc(ep_desc);
      _pdm_status("PDUvalid_desc",status);

      if (status != PDM_S_SUCCESS)
         {
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
         PDUmessage(status,'s');
         return(status);
         }

      if (status == PDM_S_SUCCESS)
         {
         if (change_mode == TRUE)
            {
            status = MEMbuild_array(PDU_data_bufr);
            _pdm_status("MEMbuild_array",status);

            if (status != MEM_S_SUCCESS)
               {
               status = PDM_E_BUILD_BUFFER_ARRAY;
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
               PDUmessage(status, 's');
               return(status);
               }

            if (PDMdebug_on)
              MEMprint_buffer("PDU_data_bufr", PDU_data_bufr, PDU_DEBUG_FILE);

            data_col = (char **) PDU_data_bufr->column_ptr;

            status = PDUget_col_number(PDU_data_bufr,"n_itemdesc",data_col,
                                       &n_itemdesc_col);
            _pdm_status("PDUget_col_number",status);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            status=MEMwrite_data(PDU_data_bufr,ep_desc,1,n_itemdesc_col+1);
            _pdm_debug("AFTER THE MEMwrite_data for ep_desc",0);

            if (status != MEM_S_SUCCESS)
               {
               status = PDM_E_WRITE_BUFFER;
               msg = (char *) PDUtranslate_message(status);
               FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
               PDUmessage(status, 's');
               return(status);
               }
            else
               {
               PDUfill_in_string1(&refresh->rev_description,ep_desc);
               status = PDM_S_SUCCESS;
               PDUmessage(status,'s');
               return(status);
               }
            }
         else
            {
            /* Then send the catalog name and description to PDM to get the 
               partnum, revision, and part type. */

            status = PDUpull_pn_rev_pt();
            _pdm_status("PDUpull_pn_rev_pt",status);
 
            if (status != PDM_S_SUCCESS)
               {
               FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
               FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[5],0,0,0,0,0,0);
               PDUmessage(status,'s');
               return(status);
               }

            if (status == PDM_S_SUCCESS)
               {
               PDUfill_in_string1(&refresh->rev_description,ep_desc);
               FIfld_pos_cursor(PDU_form_id,FILE_INFO_MCF,0,0,0,0,0,0);
               PDUmessage(status,'s');
               }
            }
         }
      else if (strcmp(ep_catalog,"") == 0)
         {
         status = PDM_I_ENTER_PART;
         msg = (char *) PDUtranslate_message(status);
         FIg_set_text(PDU_form_id, FI_MSG_FIELD ,msg);
         PDUmessage(status, 's');
         }
     }
return(status);
}

/* This function processes the existing part type button */

int PDUep_parttype_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   char      type[5];
   static char *text = NULL;

   _pdm_debug("Entering PDUep_parttype_btn",0);

   PDUdismiss_subforms();

   if (change_mode)
     {
     _pdm_debug("saving current parttype", 0);
     PDUfill_in_string1(&PDU_save_parttype, refresh->rev_parttype);
     }

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[4], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[4], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_parttype,text);
   _pdm_debug("ep_parttype = <%s>", ep_parttype);

   end_ep_parttype_btn_flag = TRUE;

   if (strcmp(ep_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,msg);
      if (PDU_form_id == forms.part_operations_form_id)
        FIg_set_state_off(PDU_form_id, EP_PARTTYPE_BTN);
      end_ep_parttype_btn_flag = FALSE;
      return(PDM_I_ENTER_CATALOG);
      }

   if (strcmp(np_catalog,"pdmlibriaries") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_E_MACRO_PARTTYPE);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"M",FALSE);
      PDUfill_in_string1(&np_parttype, "M");
      PDUfill_in_string1(&refresh->new_parttype,np_parttype);
      FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);
      FIfld_pos_cursor(PDU_form_id,NP_DESC_FLD,0,0,0,0,0,0);
      return(PDM_E_MACRO_PARTTYPE);
      }

   status = PDMquery_catalog_type(ep_catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   _pdm_debug("catalog type = <%s>", type);

   if (status != PDM_S_SUCCESS)
      return(status);

   if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
       (strcmp(type,"EID") == 0) || (strcmp(type,"PXT") == 0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_PARAM_PARTTYPE);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"P",FALSE);
      PDUfill_in_string1(&np_parttype, "P");
      PDUfill_in_string1(&refresh->new_parttype,np_parttype);
      FIfld_pos_cursor(PDU_form_id,NP_DESC_FLD,0,0,0,0,0,0);
      return(PDM_I_PARAM_PARTTYPE);
      }
   else if (strcmp(type,"C") == 0)
      {
      /* This buffer needs to contain 1 column with "D", "M", "G", and "N"
         hardcoded for the listing. */

         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         status = PDUlist_dmgn_bufr(&PDU_ret_bufr);
         _pdm_status("PDUlist_agn_bufr",status);

         if (status != PDM_S_SUCCESS)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           return(status);
           }

         if (PDMdebug_on)
             MEMprint_buffer("PDU_ret_bufr from PDUlist_dmgn_bufr",
                             PDU_ret_bufr,PDU_DEBUG_FILE);
      }
   else if (strcmp(type,"EXT") == 0)
      {
      /* This buffer needs to contain 1 column with "D", "G", and "N". */

         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         status = PDUlist_pgn_bufr(&PDU_ret_bufr);
         _pdm_status("PDUlist_pgn_bufr",status);

         if (status != PDM_S_SUCCESS)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           return(status);
           }

         if (PDMdebug_on)
            MEMprint_buffer("PDU_ret_bufr from PDUlist_pgn_bufr",
                            PDU_ret_bufr,PDU_DEBUG_FILE);
       }

      if (PDU_ret_bufr)
        PDUsetup_single_buffer(PDU_ret_bufr);
      else
        {
        status = PDM_E_NULL_BUFFER;
        return(status);
        }

      PDU_gadget_labels[0] = EP_PARTTYPE_FLD;

      PDU_update_struct[0] = &refresh->rev_parttype;

      all_flag = TRUE;
      no_headings = 1;
      headings = (char **) malloc (sizeof (char *) * no_headings);
      memset(headings, NULL, sizeof (char *) * no_headings);

      PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUfree_string_array(&headings, no_headings);

      status = PDUsingle_list_form();
      _pdm_status("PDUsingle_list_form",status);

      if (single_flag == TRUE)
         {
         single_flag = FALSE;
         return(PDM_S_SUCCESS);
         }

      if (status == PDM_S_SUCCESS)
         return(0);

   return(status);
}

/* This function processes the existing revision button */

int PDUep_rev_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;

   _pdm_debug("Entering PDUep_rev_btn",0);

   PDUdismiss_subforms();

   if ((change_mode == TRUE) || (review_mode == TRUE) || (similar_mode == TRUE))
      {
      if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
          (strcmp(ep_rev,"") != 0))
         {
         status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return(status);
            }
         }
      }

   _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
   _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);

   if ((refresh->rev_catalog && refresh->rev_partid &&
      ((strcmp(refresh->rev_catalog, "") == 0) ||
       (strcmp(refresh->rev_partid, "") == 0)))  ||
       (!refresh->rev_catalog || !refresh->rev_partid))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      if (PDU_active_button != -1)
        {
        FIg_set_state_off(PDU_form_id, PDU_active_button);
        FIg_display(PDU_form_id, PDU_active_button);
        PDU_active_button = -1;
        }
      return(PDM_I_ENTER_PART);
      }
   else if (refresh->rev_catalog && refresh->rev_partid &&
           (strcmp(refresh->rev_catalog, "") != 0) &&
           (strcmp(refresh->rev_partid, "") != 0))
      {
      PDUfill_in_string(&ep_catalog, refresh->rev_catalog);
      PDUfill_in_string(&en_itemname, refresh->rev_partid);
      status = PDUprocess_ep_rev_btn();
      _pdm_status("PDUprocess_ep_rev_btn", status);
      }

   return(status);
}
 
/* This function processes the existing part number button */

int PDUep_part_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_part_btn",0);

   PDUdismiss_subforms();

   if ((change_mode == TRUE) || (review_mode == TRUE)) 
      {
      if ((strcmp(ep_catalog,"") != 0) &&
          (strcmp(en_itemname,"") != 0) &&
          (strcmp(ep_rev,"") != 0))
         {
         status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);

         if (status != PDM_S_SUCCESS)
            return(status);
         }
      }

   /* Blank out following fields */

   if (PDU_form_id != forms.bom_contents_form_id)
     {
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
  
     ep_rev = NULL_STRING;
     ep_desc = NULL_STRING;
  
     refresh->rev_revision = NULL_STRING;
     refresh->rev_description = NULL_STRING;
     }

   PDUmessage(PDM_E_CLEAR_FIELD,'s');

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[2], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&en_itemname,text);
   _pdm_debug("en_itemname = <%s>", en_itemname);

   if (strcmp(ep_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
      if (PDU_active_button != -1)
        {
        FIg_set_state_off(PDU_form_id, PDU_active_button);
        FIg_display(PDU_form_id, PDU_active_button);
        PDU_active_button = -1;
        }
      return(PDM_I_ENTER_CATALOG);
      }

   else
      {
      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }
 
      status = PDMparts_listing(ep_catalog);
      _pdm_status("PDMparts_listing",status);

      if (status != PDM_S_SUCCESS)
         {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
         PDUmessage(status, 's');
         return(status);
         }

      if (PDU_ret_bufr == NULL)
         {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
         msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_FOUND);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
         }
      }

   end_ep_part_btn_flag = TRUE;
   pt_flag = TRUE;

   PDUsetup_single_buffer(PDU_ret_bufr);

   if (PDU_form_id == forms.part_operations_form_id)
      {
      _pdm_debug("setting gadget labels for part form", 0);
      PDU_gadget_labels[0] = EP_PARTNUM_FLD;
      PDU_gadget_labels[1] = EP_REV_FLD;
      PDU_gadget_labels[2] = EP_DESC_FLD;
      }

   if (PDU_form_id == forms.seed_form_form_id)
      {
      PDU_gadget_labels[0] = NFC_PART_FLD;
      PDU_gadget_labels[1] = NFC_REV_FLD;
      PDU_gadget_labels[2] = NFC_DESC_FLD;
      PDU_update_struct[0] = &refresh->rev_partid;
      PDU_update_struct[1] = &refresh->rev_revision;
      PDU_update_struct[2] = &refresh->rev_description;
      }

   if (PDU_form_id == forms.local_files_form_id)
      {
      PDU_gadget_labels[0] = PARTNUM_FLD;
      PDU_gadget_labels[1] = PART_REV_FLD;
      PDU_gadget_labels[2] = PART_DESC_FLD;
      }
   if (PDU_form_id == forms.ex_file_form_id)
      {
      PDU_gadget_labels[0] = EX_PARTNUM_FLD;
      PDU_gadget_labels[1] = EX_REVISION_FLD;
      PDU_gadget_labels[2] = EX_DESCRIPTION;
      }
   if (PDU_form_id == forms.report_form_id)
      {
      PDU_gadget_labels[0] = PART_NUM;
      PDU_gadget_labels[1] = REVISION_NAME;
      PDU_gadget_labels[2] = DESCRIPTION_NAME;
      }
   if (PDU_form_id == forms.topdown_form_id)
      {
      _pdm_debug("setting gadget labels for topdown form", 0);
      PDU_gadget_labels[0] = TD_PARTID;
      PDU_gadget_labels[1] = TD_REVISION;
      PDU_gadget_labels[2] = TD_DESC;
      }
   if (PDU_form_id == forms.where_used_form_id)
      {
      PDU_gadget_labels[0] = W_PARTID;
      PDU_gadget_labels[1] = W_REVISION;
      PDU_gadget_labels[2] = W_DESC;
      }
   if (PDU_form_id != forms.seed_form_form_id)
      {
      PDU_update_struct[0] = &refresh->rev_partid;
      PDU_update_struct[1] = &refresh->rev_revision;
      PDU_update_struct[2] = &refresh->rev_parttype;
      PDU_update_struct[3] = &refresh->rev_description;
      } 

   all_flag = FALSE;
   no_headings = 3;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);

   PDUfill_in_string(&headings[0], "n_itemname");
   PDUfill_in_string(&headings[1], "n_itemrev");
   PDUfill_in_string(&headings[2], "n_itemdesc");

   PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings,no_headings);

   if (PDU_form_id != forms.seed_form_form_id)
      {
      all_flag = FALSE;
      no_headings = 4;
      headings = (char **) malloc (sizeof (char *) * no_headings);
      memset(headings, NULL, sizeof (char *) * no_headings);

      PDUfill_in_string(&headings[0], "n_itemname");
      PDUfill_in_string(&headings[1], "n_itemrev");
      PDUfill_in_string(&headings[2], "p_parttype");
      PDUfill_in_string(&headings[3], "n_itemdesc");
      }
   else if (PDU_form_id == forms.seed_form_form_id)
      {
      all_flag = FALSE;
      no_headings = 3;
      headings = (char **) malloc (sizeof (char *) * no_headings);
      memset(headings, NULL, sizeof (char *) * no_headings);

      PDUfill_in_string(&headings[0], "n_itemname");
      PDUfill_in_string(&headings[1], "n_itemrev");
      PDUfill_in_string(&headings[2], "n_itemdesc");
      }

   PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings,no_headings);

   msg = (char *)PDUtranslate_message(PDM_I_PARTS_LISTS);
   status = PDUmcf_list_form(msg);
   _pdm_status("PDUmcf_list_form",status);

   if (single_flag == TRUE)
      {
      single_flag = FALSE;
      return(PDM_S_SUCCESS);
      }
 
   if (status == PDM_S_SUCCESS)
      return(0);

   return(status);
}

/* This function processes the existing catalog button */

int PDUep_cat_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
char *row = NULL;
MEMptr input_buffer = NULL;
int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUep_cat_btn",0);

   PDUdismiss_subforms();

   /* Blank out following fields */

   if (PDU_form_id != forms.bom_contents_form_id)
     {
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,"",FALSE);
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
  
     en_itemname = NULL_STRING;
     ep_rev = NULL_STRING;
     ep_desc = NULL_STRING;
  
     refresh->rev_partid = NULL_STRING;
     refresh->rev_revision = NULL_STRING;
     refresh->rev_description = NULL_STRING;
     }

   if (PDU_form_id == forms.part_operations_form_id)
      {
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,"",FALSE);
      refresh->rev_parttype = NULL_STRING;
      ep_parttype = NULL_STRING;
      }

   PDU_simmode_cat_bufr = FALSE;

/*
   if (((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) &&
       (similar_mode == TRUE))
      {
      bufr_flag = TRUE;
      PDU_simmode_cat_bufr = TRUE;
      }
   else
      bufr_flag = FALSE;
*/

   bufr_flag = FALSE;
   _pdm_debug("getting text from project and catalog fields", 0);

   if ((PDU_form_id != forms.report_form_id) &&
       (PDU_form_id != forms.bom_contents_form_id) &&
       (PDU_form_id != forms.cat_name_form_id) &&
       (PDU_form_id != forms.define_lib_form_id) &&
       (PDU_form_id != forms.seed_form_form_id) &&
       (PDU_form_id != forms.topdown_form_id))
      {
      FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[0], 0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                     (unsigned char *)text, &select, &pos);
      PDUfill_in_string1(&ep_project,text);
      }
   else
      PDUfill_in_string1(&ep_project,"");

   _pdm_debug("ep_project = <%s>", ep_project);

   /* call PDM function to retrieve a list of catalogs */

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   end_ep_cat_btn_flag = TRUE;

      PDU_class_level = 0;
      status = PDUformat_classification_buffer(&input_buffer);
      _pdm_status("PDUformat_classification_buffer", status);

      if (status != PDM_S_SUCCESS)
        {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
        return(status);
        }

      row = (char *)malloc(input_buffer->row_size);
      memset(row, NULL, input_buffer->row_size);
      sprintf(row, "\1\1");
      status = MEMwrite(input_buffer, row);
      _pdm_status("MEMwrite", status);

     if (status != MEM_S_SUCCESS)
       {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
       return(status);
       }

      if (!change_mode)
       PDUload_exec_structure(refresh->rev_project, "", "", "", "", "", "",0,0);
      else
       PDUload_exec_structure("", "", "", "", "", "", "",0,0);

      _pdm_status("PDUload_exec_structure", status);
      _pdm_debug("calling PDMquery_classification", 0);
      if (PDU_cat_class_bufr)
        {
        MEMclose(&PDU_cat_class_bufr);
        PDU_cat_class_bufr = NULL;
        }
      status = PDMquery_classification(input_buffer, &PDU_cat_class_bufr);
       _pdm_status("PDMquery_classification", status);

      if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
        {
        msg = (char *) PDUtranslate_message(PDM_E_NO_CATALOGS);
        FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        return(status);
        }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);

      /* call function to load classes and catalogs into one buffer */
      if (PDU_ret_bufr)
        {
        MEMclose(&PDU_ret_bufr);
        PDU_ret_bufr = NULL;
        }
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr, 
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
        {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
        return(status);
        }
      if ((PDU_ret_bufr) && (PDU_ret_bufr->rows == 0))
        {
        FIg_set_state_off(PDU_form_id, PDU_active_button);
        PDUmessage(PDM_E_NO_CATALOG_MAP, 's');
        return(PDM_E_NO_CATALOG_MAP);
        }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

   PDUsetup_single_buffer(PDU_ret_bufr);

   if (PDU_form_id == forms.part_operations_form_id)
      {
      PDU_gadget_labels[0] = EP_CATALOG_FLD;
      PDU_update_struct[0] = &refresh->rev_catalog;
      }

   if (PDU_form_id == forms.seed_form_form_id)
      {
      PDU_gadget_labels[0] = NFC_CATALOG_FLD;
      PDU_update_struct[0] = &refresh->rev_catalog;
      }

   if (PDU_form_id == forms.local_files_form_id)
      PDU_gadget_labels[0] = CATALOG_FLD;

   if (PDU_form_id == forms.ex_file_form_id)
      PDU_gadget_labels[0] = EX_CATALOG_FLD;

   if (PDU_form_id == forms.report_form_id)
      PDU_gadget_labels[0] = CATALOG_NAME;

   if ((PDU_form_id == forms.cat_name_form_id) && 
       (PDU_command == PDC_M_MODIFY_CATALOG))
      PDU_gadget_labels[0] = CATFLD;
   else if (PDU_form_id == forms.cat_name_form_id)
      PDU_gadget_labels[0] = TEMP_CATALOG;

   if (PDU_form_id == forms.define_lib_form_id)
      PDU_gadget_labels[0] = CAT_NAME_FLD;

   if (PDU_form_id == forms.bom_contents_form_id)
      PDU_gadget_labels[0] = CAT_NAME;

   if (PDU_form_id == forms.topdown_form_id)
      PDU_gadget_labels[0] = TD_CATALOG;

   if (PDU_form_id == forms.where_used_form_id)
      PDU_gadget_labels[0] = W_CATALOG;

   PDU_update_struct[0] = &refresh->rev_catalog;

   if ((PDU_form_id == forms.cat_name_form_id) &&
       (PDU_command != PDC_M_MODIFY_CATALOG))
     PDU_update_struct[0] = &PDU_template_catalog;

   all_flag = TRUE;
   no_headings = 1;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);
   PDUfill_in_string(&headings[0], "n_name");

   PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

   all_flag = FALSE;
   PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings, no_headings);

   status = PDUclass_cat_list_form();
   _pdm_status("PDUsingle_list_form",status);

   if (single_flag == TRUE)
      {
      single_flag = FALSE;
      return(PDM_S_SUCCESS);
      }

   if (status == PDM_S_SUCCESS)
      return(0);

   return(status);
}

/* This function processes the existing project button */

int PDUep_proj_btn()

{
   int       status = PDM_S_SUCCESS;
   int       length, select, pos;
   static char *text = NULL;
   char      *msg = NULL;

   _pdm_debug("Entering PDUep_proj_btn",0);

   PDUdismiss_subforms();

   ep_project = NULL_STRING;
   refresh->rev_project = NULL_STRING;

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[0], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_project,text);
   _pdm_debug("ep_project = <%s>", ep_project);

   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   /* call PDM function to retrieve a list of projects */

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   if (similar_mode == TRUE)
      {
      if (strcmp(ep_catalog,"") != 0)
         {
         status = PDMproject_catalog_listing("",ep_catalog,"");
         _pdm_status("PDMproject_catalog_listing",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (PDU_ret_bufr == NULL)
            {
            msg = (char *) PDUtranslate_message(PDM_E_NO_PROJECTS);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
            }
         }
      else
         {
         status = PDMproject_catalog_listing("","","proj_list");
         _pdm_status("PDMproject_catalog_listing",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (PDU_ret_bufr == NULL)
            {
            msg = (char *) PDUtranslate_message(PDM_E_NO_PROJECTS);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
            }
         }
      }
   else
      {
      status = PDMproject_catalog_listing("","","proj_list");
      _pdm_status("PDMproject_catalog_listing",status);

      if (status != PDM_S_SUCCESS)
         {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
         return(status);
         }

      if (PDU_ret_bufr == NULL)
        {
         if (PDU_active_button != -1)
           {
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           PDU_active_button = -1;
           }
        msg = (char *) PDUtranslate_message(PDM_E_NO_PROJECTS);
        FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
        }
      }
      
   end_ep_proj_btn_flag = TRUE;

   PDUsetup_single_buffer(PDU_ret_bufr);

   if (PDU_form_id == forms.part_operations_form_id)
      PDU_gadget_labels[0] = EP_PROJECT_FLD;

   if (PDU_form_id == forms.local_files_form_id)
      PDU_gadget_labels[0] = PROJECT_FLD;

   if (PDU_form_id == ModifyPartForm)
      PDU_gadget_labels[0] = PROJECT;

   if (PDU_form_id == place_part_f)
      PDU_gadget_labels[0] = PROJECT;

   if (PDU_form_id == forms.parametric_parts_form_id)
      PDU_gadget_labels[0] = PROJECT_NAME;

    /* ALR   TR 139314868 */
    if (PDU_form_id == forms.ex_file_form_id)
      PDU_gadget_labels[0] = EX_PROJECT_FLD;

   PDU_update_struct[0] = &refresh->rev_project;

   all_flag = TRUE;

   no_headings = 1;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);

   PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings, no_headings);

   status = PDUsingle_list_form();
   _pdm_status("PDUsingle_list_form",status);

   if (single_flag == TRUE)
      {
      single_flag = FALSE;
      return(PDM_S_SUCCESS);
      }

   if (status == PDM_S_SUCCESS)
      return(0);

   return(status);
}

/* This function processes the new project field. */

int PDUnp_proj_fld()

{
   int       status = PDM_S_SUCCESS;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_proj_fld",0);

   np_project = NULL_STRING;
   refresh->new_project = NULL_STRING;

   FIfld_get_text_length(forms.part_operations_form_id,NP_PROJECT_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PROJECT_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_project,text);
   _pdm_debug("np_project = <%s>", np_project);

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char*)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   if ((np_project == NULL) || (strcmp(np_project,"") == 0))
      return(0);

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   status = PDUvalid_project(np_project,"");
   _pdm_status("PDUvalid_project",status);

   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,NP_PROJECT_FLD,0,0,"",FALSE);
      return(status);
      }

   if (status == PDM_S_SUCCESS)
      PDUfill_in_string1(&refresh->new_project,np_project);
   if ((status == PDM_S_SUCCESS) && (!np_project))
      FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
   else if ((status == PDM_S_SUCCESS) && (strcmp(np_project, "") == 0))
      FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);

   return(status);
}

/* This function processes the new catalog fields */

int PDUnp_cat_fld()

{
   int       status = PDM_S_SUCCESS;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_cat_fld",0);

   FIg_enable(forms.part_operations_form_id,NP_PARTTYPE_BTN);

   /* Blank out following fields */

   FIfld_set_text(forms.part_operations_form_id,NP_PARTNUM_FLD,0,0, "",FALSE);
   FIfld_set_text(forms.part_operations_form_id,NP_REV_FLD,0,0, "",FALSE);
   FIfld_set_text(forms.part_operations_form_id,NP_PARTTYPE_FLD,0,0, "",FALSE);
   FIfld_set_text(forms.part_operations_form_id,NP_DESC_FLD,0,0, "",FALSE);

   nn_itemname = NULL_STRING;
   np_rev = NULL_STRING;
   np_parttype = NULL_STRING;
   np_desc = NULL_STRING;

   refresh->new_partid = NULL_STRING;
   refresh->new_revision = NULL_STRING;
   refresh->new_parttype = NULL_STRING;
   refresh->new_description = NULL_STRING;

   FIfld_get_text_length(forms.part_operations_form_id,NP_PROJECT_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PROJECT_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_project,text);
   _pdm_debug("np_project = <%s>", np_project);

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) 
      return(0);

   end_np_cat_btn_flag = FALSE;

   status = PDUprocess_np_catalog();

   if (status != PDM_S_SUCCESS)
      {
      FIg_set_text(forms.part_operations_form_id, NP_CATALOG_FLD, "");
      refresh->new_catalog = NULL_STRING;
      np_catalog = NULL_STRING;
      }

   return(status);
} 

/* This function processes the new part number field. */

int PDUnp_part_fld()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_part_fld",0);

   end_np_part_btn_flag = FALSE;
   end_np_cat_btn_flag = FALSE;

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   FIfld_get_text_length(forms.part_operations_form_id,NP_PARTNUM_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTNUM_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&nn_itemname,text);
   _pdm_debug("nn_itemname = <%s>", nn_itemname);

   if ((nn_itemname == NULL) || (strcmp(nn_itemname,"") == 0))
      return(0);

   if (strcmp(np_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"",FALSE);
      return(PDM_I_ENTER_CATALOG);
      }
   else
      {
      new_part_flag = TRUE; /* Used in PDUvalid_partnum */
      status = PDUvalid_partnum(np_catalog,nn_itemname);
      _pdm_status("PDUvalid_partnum",status);
      new_part_flag = FALSE;
      }

   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"",FALSE);
      PDUmessage(status,'s');
      return(status);
      }

   if (status == PDM_S_SUCCESS)
      {
      PDUfill_in_string1(&refresh->new_partid,nn_itemname);
      PDUmessage(status,'s');
      }
   _pdm_debug("Leaving PDUnp_part_fld", 0);
   return(status);
}

/* This function processes the new revision field. */

int PDUnp_rev_fld()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_rev_fld",0);

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   FIfld_get_text_length(forms.part_operations_form_id,NP_PARTNUM_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTNUM_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&nn_itemname,text);
   _pdm_debug("nn_itemname = <%s>", nn_itemname);

   FIfld_get_text_length(forms.part_operations_form_id,NP_REV_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_REV_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_rev,text);
   _pdm_debug("np_rev = <%s>", np_rev);

   FIfld_get_text_length(forms.part_operations_form_id,NP_PARTTYPE_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTTYPE_FLD, 0, 0, 
                  length,(unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_parttype,text);
   _pdm_debug("np_parttype = <%s>", np_parttype);

   if ((np_rev == NULL) || (strcmp(np_rev,"") == 0))
      return(0);

   if ((strcmp(np_catalog,"") == 0) || (strcmp(nn_itemname,"") == 0))
      {
      FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"",FALSE);
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      return(PDM_I_ENTER_PART);
      }
   else if (strcmp(np_rev,"") != 0)
      {
      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }
      status = PDUvalid_rev(np_rev);
      _pdm_status("PDUvalid_rev",status);

      if (status != PDM_S_SUCCESS)
         {
         FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"",FALSE);
         PDUmessage(status, 's');
         return(status);
         }

      status = PDUcheck_partnum(np_catalog,nn_itemname,np_rev);
      _pdm_status("PDUcheck_partnum",status);

      if (status == PDM_S_SUCCESS)
         {
         msg = (char *) PDUtranslate_message(PDM_E_PART_EXISTS);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
         FIfld_set_text(forms.part_operations_form_id,NP_REV_FLD,0,0,"", FALSE);
         return(PDM_E_PART_EXISTS);
         } 
      else if (status == PDM_E_PARTREV_NOT_FOUND)
         {
         PDUfill_in_string1(&refresh->new_revision,np_rev);
         return(PDM_S_SUCCESS);
         }
      else if (status != PDM_S_SUCCESS)
         {
         msg = (char *) PDUtranslate_message(PDM_E_INVALID_CHAR_IN_PART);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
         FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,"", FALSE);
         FIfld_set_text(PDU_form_id,NP_REV_FLD,0,0,"", FALSE);
         }
      }

   return(status);
}

/* This function processes the new part type field. */

int PDUnp_parttype_fld()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select;
   int       pos = 0;
   int       n_cofilenm_col = 0;
   int       n_cifilenm_col = 0;
   int       n_filetype_col = 0;
   short     display_file_info = FALSE;
   char **   data_col;
   char      type[5];
   static char *text = NULL;

   _pdm_debug("PDUnp_parttype_fld",0);

   if (PDU_save_parttype && (strcmp(PDU_save_parttype, "G") != 0))
     display_file_info = TRUE;

   _pdm_debug("np_catalog = <%s>", np_catalog);
   if (strcmp(np_catalog,"") == 0)
      {
      _pdm_debug("catalog name has not been entered", 0);
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
      return(PDM_I_ENTER_CATALOG);
      }

   FIfld_get_text_length(forms.part_operations_form_id,NP_PARTTYPE_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTTYPE_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_parttype,text);
   _pdm_debug("np_parttype = <%s>", np_parttype);

   if (strcmp(np_catalog,"pdmlibraries") == 0)
      {
      if ((strcmp(np_parttype, "M") != 0) && (strcmp(np_parttype, "m") != 0))
        {
        msg = (char *) PDUtranslate_message(PDM_E_MACRO_PARTTYPE);
        FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,msg);
        FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"M",FALSE);
        PDUfill_in_string1(&np_parttype, "M");
        PDUfill_in_string1(&refresh->new_parttype,np_parttype);
        FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);
        return(PDM_E_MACRO_PARTTYPE);
        }
      }

   status = PDMquery_catalog_type(np_catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   _pdm_debug("catalog type = <%s>", type);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (strcmp(type,"C") == 0)
      {
      if ((strcmp(np_parttype,"D") != 0) &&
         (strcmp(np_parttype,"d") != 0) &&
         (strcmp(np_parttype,"M") != 0) &&
         (strcmp(np_parttype,"m") != 0) &&
         (strcmp(np_parttype,"G") != 0) &&
         (strcmp(np_parttype,"g") != 0) &&
         (strcmp(np_parttype,"N") != 0) &&
         (strcmp(np_parttype,"n") != 0))
         {
         msg = (char *) PDUtranslate_message(PDM_I_STAND_PARTTYPE);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
         FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"G",FALSE);
         PDUfill_in_string1(&np_parttype,"G");
         PDUfill_in_string1(&refresh->new_parttype,np_parttype);
         return(PDM_I_STAND_PARTTYPE);
         }
      else
         {
         PDUfill_in_string1(&refresh->new_parttype,np_parttype);
         }
      }
 
   if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
       (strcmp(type,"EID") == 0) || (strcmp(type,"PXT") == 0))
      {
      if ((strcmp(np_parttype,"P") != 0) && (strcmp(np_parttype,"p") != 0))
         {
         msg = (char *) PDUtranslate_message(PDM_I_PARAM_PARTTYPE);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
         FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"P",FALSE);
         PDUfill_in_string1(&np_parttype,"P");
         PDUfill_in_string1(&refresh->new_parttype,np_parttype);
         return(PDM_I_PARAM_PARTTYPE);
         }
      else
         {
         PDUfill_in_string1(&refresh->new_parttype,np_parttype);
         return(PDM_S_SUCCESS);
         }
      }

   if (strcmp(type,"EXT") == 0)
      {
      if ((strcmp(np_parttype,"D") != 0) &&
         (strcmp(np_parttype,"d") != 0) &&
         (strcmp(np_parttype,"G") != 0) &&
         (strcmp(np_parttype,"g") != 0) &&
         (strcmp(np_parttype,"N") != 0) &&
         (strcmp(np_parttype,"n") != 0))
         {
         msg = (char *) PDUtranslate_message(PDM_E_EXT_PARTTYPE);
         FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
         FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"G",FALSE);
         PDUfill_in_string1(&np_parttype,"G");
         PDUfill_in_string1(&refresh->new_parttype,np_parttype);
         return(PDM_E_EXT_PARTTYPE);
         }
      else
         {
         PDUfill_in_string1(&refresh->new_parttype,np_parttype);
         }
      }

   if ((strcmp(np_parttype,"N") == 0) || (strcmp(np_parttype,"n") == 0))
      {
      _pdm_debug("entering case for parttype = N", 0);

      msg = (char *) PDUtranslate_message(PDM_E_ADD_FILES_NG_PART);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);

      FIfld_set_text(forms.part_operations_form_id,FILE_INFO_MCF,0,0,"",FALSE);
      FIfld_set_text(forms.part_operations_form_id,FILE_INFO_MCF,0,1,"",FALSE);
      FIfld_set_text(forms.part_operations_form_id,FILE_INFO_MCF,0,2,"",FALSE);

      /*FIg_erase(PDU_form_id,FILE_INFO_BEZ);*/
      FIg_erase(PDU_form_id,FILE_INFO_GRP);
      FIg_erase(PDU_form_id,NEW_FILE_TXT);
      FIg_erase(PDU_form_id,EXISTING_FILE_TXT);

      if (similar_mode)
        {
        FIg_erase(PDU_form_id,SIMILAR_MODE_GRP);
        FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);
        FIg_erase(PDU_form_id,SIMMODE_COPY_TGL);
        PDU_simmode_checkin = FALSE;
        PDU_simmode_copy = FALSE;
        }

      /* Blank out the fields in the data buffer */
      status = MEMbuild_array(PDU_data_bufr);
      _pdm_status("MEMbuild_array",status);

      if (status != MEM_S_SUCCESS)
         {
         status = PDM_E_BUILD_BUFFER_ARRAY;
         msg = (char *) PDUtranslate_message(status);
         FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         return(status);
         }

      data_col = (char **) PDU_data_bufr->column_ptr;

      status = PDUget_col_number(PDU_data_bufr,"n_cofilename",data_col,
                        &n_cofilenm_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status=MEMwrite_data(PDU_data_bufr,"",1,n_cofilenm_col+1);
      _pdm_status("MEMwrite_data",status);
      _pdm_debug("AFTER THE MEMwrite_data for cofile",0);

      if (status != MEM_S_SUCCESS)
         {
         status = PDM_E_WRITE_BUFFER;
         msg = (char *) PDUtranslate_message(status);
         FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
         }

      status = PDUget_col_number(PDU_data_bufr,"n_cifilename",data_col,
                        &n_cifilenm_col);
      if (status == PDM_E_COL_NOT_IN_BUFFER)
        n_cifilenm_col = -1;
      else if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      if (n_cifilenm_col != -1)
        {
        status=MEMwrite_data(PDU_data_bufr,"",1,n_cifilenm_col+1);
        _pdm_status("MEMwrite_data",status);
        _pdm_debug("AFTER THE MEMwrite_data for cifile",0);
  
        if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_WRITE_BUFFER;
           msg = (char *) PDUtranslate_message(status);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
           }
        }

      status = PDUget_col_number(PDU_data_bufr,"n_filetype",data_col,
                        &n_filetype_col);
      if (status == PDM_E_COL_NOT_IN_BUFFER)
        n_filetype_col = -1;
      else if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      if (n_filetype_col != -1)
        {
        status=MEMwrite_data(PDU_data_bufr,"",1,n_filetype_col+1);
        _pdm_status("MEMwrite_data",status);
        _pdm_debug("AFTER THE MEMwrite_data for filetype",0);
  
        if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_WRITE_BUFFER;
           msg = (char *) PDUtranslate_message(status);
           FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
           }
        }
      }
   else if ((strcmp(np_parttype,"G") == 0) || (strcmp(np_parttype,"g") == 0))
      {
      _pdm_debug("entering case for parttype = G", 0);
      FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);

      if (display_file_info == TRUE)
        {
        if (new_mode)
          {
          /*FIg_display(PDU_form_id,FILE_INFO_BEZ);*/
          FIg_display(PDU_form_id,FILE_INFO_GRP);
          FIg_display(PDU_form_id,NEW_FILE_TXT);
          }
        else if (similar_mode)
          {
          FIg_display(PDU_form_id,SIMILAR_MODE_GRP);
          FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);
          FIg_display(PDU_form_id,NEW_FILE_TXT);
          PDU_simmode_checkin = FALSE;
          PDU_simmode_copy = FALSE;
          }
        }

      if (PDU_stg_bufr != NULL)
         {
         if (PDU_stg_bufr->rows < 2)
            FIg_erase(forms.part_operations_form_id,STORAGE_AREA_BTN);
         }
      }

   if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

   return(status);
}

/* This function processes the new description field. */

int PDUnp_desc_fld()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_desc_fld",0);

   np_desc = NULL_STRING;
   refresh->new_description = NULL_STRING;

   FIfld_get_text_length(forms.part_operations_form_id,NP_DESC_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_DESC_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_desc,text);
   _pdm_debug("np_desc = <%s>", np_desc);

   if ((np_desc == NULL) || (strcmp(np_desc,"") == 0))
      return(0);

   if (strcmp(np_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"",FALSE);
      PDUmessage(PDM_I_ENTER_CATALOG, 's');
      return(PDM_I_ENTER_CATALOG);
      }
   else
      {
      status = PDUvalid_desc(np_desc);
      _pdm_status("PDUvalid_desc",status);
      }

   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,NP_DESC_FLD,0,0,"",FALSE);
      return(status);
      }

   if (status == PDM_S_SUCCESS)
      PDUfill_in_string1(&refresh->new_description,np_desc);

   return(PDM_S_SUCCESS);
}

/* This function processes the new project button. */

int PDUnp_proj_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_proj_btn",0);

   PDUdismiss_subforms();

   np_project = NULL_STRING;
   refresh->new_project = NULL_STRING;

   FIfld_get_text_length(forms.part_operations_form_id,NP_PROJECT_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PROJECT_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_project,text);
   _pdm_debug("np_project = <%s>", np_project);

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   /* call PDM function to retrieve a list of projects */

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

/*
   if (strcmp(np_catalog,"") != 0)
      {
      status = PDMproject_catalog_listing("",np_catalog,"");
      _pdm_status("PDMproject_catalog_listing",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if (PDU_ret_bufr == NULL)
        {
        msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
        FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
        }
      }
   else
*/
      status = PDMproject_catalog_listing("","","proj_list");
      _pdm_status("PDMproject_catalog_listing",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if ((PDU_ret_bufr == NULL) || (PDU_ret_bufr->rows == 0))
        {
        msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
        FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
        }

   PDUsetup_single_buffer(PDU_ret_bufr);

   PDU_form_id = forms.part_operations_form_id;
   PDU_gadget_labels[0] = NP_PROJECT_FLD;

   PDU_update_struct[0] = &refresh->new_project;

   all_flag = FALSE;

   no_headings = 1;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);

   PDUfill_in_string(&headings[0], "n_projectname");

   PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings, no_headings);

   status = PDUsingle_list_form();
   _pdm_status("PDUsingle_list_form",status);

   if (status == PDM_S_SUCCESS)
      return(0);

   return(status);
}

/* This function processes the new catalog button. */

int PDUnp_cat_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
char *row = NULL;
MEMptr input_buffer = NULL;
int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_cat_btn",0);

   PDUdismiss_subforms();

   FIg_enable(forms.part_operations_form_id,NP_PARTTYPE_BTN);

   /* Blank out following fields */

   FIfld_set_text(forms.part_operations_form_id,NP_PARTNUM_FLD,0,0, "",FALSE);
   FIfld_set_text(forms.part_operations_form_id,NP_REV_FLD,0,0, "",FALSE);
   FIfld_set_text(forms.part_operations_form_id,NP_DESC_FLD,0,0, "",FALSE);

   nn_itemname = NULL_STRING;
   np_rev = NULL_STRING;
   np_desc = NULL_STRING;

   refresh->new_partid = NULL_STRING;
   refresh->new_revision = NULL_STRING;
   refresh->new_description = NULL_STRING;

   FIfld_get_text_length(forms.part_operations_form_id,NP_PROJECT_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PROJECT_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_project,text);
   _pdm_debug("np_project = <%s>", np_project);

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   bufr_flag = TRUE;

   /* call PDM function to retrieve a list of catalogs */

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   end_np_cat_btn_flag = TRUE;

      PDU_class_level = 0;
      status = PDUformat_classification_buffer(&input_buffer);
      _pdm_status("PDUformat_classification_buffer", status);

      if (status != PDM_S_SUCCESS)
        return(status);

      row = (char *)malloc(input_buffer->row_size);
      memset(row, NULL, input_buffer->row_size);
      sprintf(row, "\1\1");
      status = MEMwrite(input_buffer, row);
      _pdm_status("MEMwrite", status);

     if (status != MEM_S_SUCCESS)
       return(status);
      PDUload_exec_structure(refresh->new_project, "", "", "", "", "",
                                      "", 0, 0);
      _pdm_status("PDUload_exec_structure", status);
      _pdm_debug("calling PDMquery_classification", 0);
      if (PDU_cat_class_bufr)
        MEMclose(&PDU_cat_class_bufr);
      status = PDMquery_classification(input_buffer, &PDU_cat_class_bufr);
       _pdm_status("PDMquery_classification", status);

      if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
        {
        msg = (char *) PDUtranslate_message(PDM_E_NO_CATALOGS);
        FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
        if (PDU_cat_class_bufr)
          MEMclose(&PDU_cat_class_bufr);
        return(status);
        }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr, 
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
        return(status);
      if ((PDU_ret_bufr) && (PDU_ret_bufr->rows == 0))
        {
        PDUmessage(PDM_E_NO_CATALOG_MAP, 's');
        return(PDM_E_NO_CATALOG_MAP);
        }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

   PDUsetup_single_buffer(PDU_ret_bufr);

   PDU_form_id = forms.part_operations_form_id;
   PDU_gadget_labels[0] = NP_CATALOG_FLD;

   PDU_update_struct[0] = &refresh->new_catalog;

   all_flag = TRUE;
   no_headings = 1;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);
   PDUfill_in_string(&headings[0], "n_name");

   PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

   all_flag = FALSE;
   PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings, no_headings);

   status = PDUclass_cat_list_form();
   _pdm_status("PDUclass_cat_list_form",status);

   if (single_flag == TRUE)
      {
      single_flag = FALSE;
      return(PDM_S_SUCCESS);
      }

   if (status == PDM_S_SUCCESS)
      return(0);

   return(status);
}

/* This function processes the new part number button */

int PDUnp_part_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_part_btn",0);

   PDUdismiss_subforms();

   end_np_part_btn_flag = FALSE;

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   FIfld_get_text_length(forms.part_operations_form_id,NP_PARTNUM_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTNUM_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&nn_itemname,text);
   _pdm_debug("nn_itemname = <%s>", nn_itemname);

   FIg_set_text(forms.part_operations_form_id, NP_REV_FLD, "");
   FIg_set_text(forms.part_operations_form_id, NP_DESC_FLD, "");

   np_rev = NULL_STRING;
   np_desc = NULL_STRING;

   refresh->new_revision = NULL_STRING;
   refresh->new_description = NULL_STRING;

   if (strcmp(np_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      return(PDM_I_ENTER_CATALOG);
      }
   else
      {
      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }

   end_np_cat_btn_flag = FALSE;

      status = PDMparts_listing(np_catalog);
      _pdm_status("PDMparts_listing",status);

      if (status != PDM_S_SUCCESS)
         {
         FIg_set_state_off(PDU_form_id, NP_PARTNUM_BTN);
         return(status);
         }

      if (PDU_ret_bufr == NULL)
         {
         msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_FOUND);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         }
      }

   end_np_part_btn_flag = TRUE;

   PDUsetup_single_buffer(PDU_ret_bufr);

   PDU_form_id = forms.part_operations_form_id;

   PDU_gadget_labels[0] = NP_PARTNUM_FLD;

   PDU_update_struct[0] = &refresh->new_partid;

   all_flag = FALSE;
   no_headings = 3;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);

   PDUfill_in_string(&headings[0], "n_itemname");
   PDUfill_in_string(&headings[1], "n_itemrev");
   PDUfill_in_string(&headings[2], "n_itemdesc");

   PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings,no_headings);

   all_flag = FALSE;
   no_headings = 1;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);

   PDUfill_in_string(&headings[0], "n_itemname");

   PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

   PDUfree_string_array(&headings,no_headings);

   msg = (char *)PDUtranslate_message(PDM_I_PARTS_LISTS);
   status = PDUmcf_list_form(msg);
   _pdm_status("PDUmcf_list_form",status);

   if (single_flag == TRUE)
      {
      single_flag = FALSE;
      return(PDM_S_SUCCESS);
      }

   if (status == PDM_S_SUCCESS)
      return(0);

   return(status);
}

/* This function processes the new part type button. */

int PDUnp_parttype_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int       length, select, pos;
   char      type[5];
   static char *text = NULL;

   _pdm_debug("Entering PDUnp_parttype_btn",0);

   PDUdismiss_subforms();

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   FIfld_get_text_length(forms.part_operations_form_id,NP_PARTTYPE_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTTYPE_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_parttype,text);
   _pdm_debug("np_parttype = <%s>", np_parttype);

   end_np_parttype_btn_flag = TRUE;

   if (strcmp(np_catalog,"") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      return(PDM_I_ENTER_CATALOG);
      }

   if (strcmp(np_catalog,"pdmlibraries") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_E_MACRO_PARTTYPE);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"M",FALSE);
      PDUfill_in_string1(&np_parttype, "M");
      PDUfill_in_string1(&refresh->new_parttype,np_parttype);
      FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);
      FIfld_pos_cursor(PDU_form_id,NP_DESC_FLD,0,0,0,0,0,0);
      return(PDM_E_MACRO_PARTTYPE);
      }

   status = PDMquery_catalog_type(np_catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   _pdm_debug("catalog type = <%s>", type);

   if (status != PDM_S_SUCCESS)
      return(status);

   if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
       (strcmp(type,"EID") == 0) || (strcmp(type,"PXT") == 0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_PARAM_PARTTYPE);
      FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,NP_PARTTYPE_FLD, 0,0,"P",FALSE);
      PDUfill_in_string1(&np_parttype, "P");
      PDUfill_in_string1(&refresh->new_parttype,np_parttype);
      FIfld_pos_cursor(PDU_form_id,NP_DESC_FLD,0,0,0,0,0,0);
      return(PDM_I_PARAM_PARTTYPE);
      }
   else if (strcmp(type,"C") == 0)
      {
      /* This buffer needs to contain 1 column with "D", "M", "G", and "N" 
         hardcoded for the listing. */

         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         status = PDUlist_dmgn_bufr(&PDU_ret_bufr);
         _pdm_status("PDUlist_agn_bufr",status);

         if (status != PDM_S_SUCCESS)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           return(status);
           }

         if (PDMdebug_on)
             MEMprint_buffer("PDU_ret_bufr from PDUlist_dmgn_bufr",
                             PDU_ret_bufr,PDU_DEBUG_FILE);
      }
   else if (strcmp(type,"EXT") == 0)
      {
      /* This buffer needs to contain 1 column with "P", "G", and "N". */

         if (PDU_ret_bufr)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         status = PDUlist_pgn_bufr(&PDU_ret_bufr);
         _pdm_status("PDUlist_pgn_bufr",status);

         if (status != PDM_S_SUCCESS)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           return(status);
           }

         if (PDMdebug_on)
            MEMprint_buffer("PDU_ret_bufr from PDUlist_pgn_bufr",
                            PDU_ret_bufr,PDU_DEBUG_FILE);
      }
   else if ((strcmp(type,"") == 0) || (strcmp(type," ") == 0))
      {
      _pdm_debug("catalog type is NULL", 0);
      status = PDM_E_CAT_TYPE_EMPTY;
      PDUmessage(status, 's');
      return(status);
      }

      if (PDU_ret_bufr)
        PDUsetup_single_buffer(PDU_ret_bufr);
      else
        {
        status = PDM_E_NULL_BUFFER;
        return(status);
        }

      PDU_form_id = forms.part_operations_form_id;
      PDU_gadget_labels[0] = NP_PARTTYPE_FLD;

      PDU_update_struct[0] = &refresh->new_parttype;

      all_flag = TRUE;
      no_headings = 1;
      headings = (char **) malloc (sizeof (char *) * no_headings);
      memset(headings, NULL, sizeof (char *) * no_headings);

      PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUfree_string_array(&headings, no_headings);

      status = PDUsingle_list_form();
      _pdm_status("PDUsingle_list_form",status);

      if (single_flag == TRUE)
         {
         single_flag = FALSE;
         return(PDM_S_SUCCESS);
         }

      if (status == PDM_S_SUCCESS)
         return(0);

   return(status);
}

/* Pull out the partnum, revision, and parttype. */

int PDUpull_pn_rev_pt()

{
   int       status = PDM_S_SUCCESS;
  char         ** ret_bufr_row;
  char         ** ret_bufr_col;
  char         ** ret_bufr_format;
  int             n_itemname_col;
  int             p_rev_col;
  int             p_parttype_col;
 
   _pdm_debug("Entering PDUpull_pn_rev_pt",0);

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   status = PDUget_part_from_desc(ep_catalog,ep_desc);
   _pdm_status("PDUget_part_from_desc",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (status == PDM_S_SUCCESS)
      {
      /* Pull Latest Part number, Revision, and Part type from buffer. */

      PDUsetup_buffer_list(PDU_ret_bufr,1,0,&ret_bufr_row,&ret_bufr_col,
                           &ret_bufr_format,&PDU_ret_bufr);

      status = PDUget_col_number(PDU_ret_bufr,"n_itemname",ret_bufr_col,
                                 &n_itemname_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(PDU_ret_bufr,"n_itemrev",ret_bufr_col,
                                 &p_rev_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(PDU_ret_bufr,"p_parttype",ret_bufr_col,
                                 &p_parttype_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,
                     ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                     n_itemname_col],FALSE);
      _pdm_debug("writing to refresh", 0);
      PDUfill_in_string(&refresh->rev_partid,
                ret_bufr_row[(PDU_ret_bufr->columns * 0) + n_itemname_col]);
      PDUfill_in_string(&refresh->rev_revision,
                ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_rev_col]);
      PDUfill_in_string(&refresh->rev_parttype,
                ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col]);
      PDUfill_in_string1(&en_itemname, 
                        ret_bufr_row[(PDU_ret_bufr->columns * 0) +                                      n_itemname_col]);

      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,
                     ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                     p_rev_col],FALSE);

      PDUfill_in_string1(&ep_rev,
                           ret_bufr_row[(PDU_ret_bufr->columns * 0) +                                      p_rev_col]);

      if (PDU_form_id == forms.part_operations_form_id)
         {
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,
                        ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                        p_parttype_col],FALSE);
         PDUfill_in_string(&refresh->rev_parttype,
                           ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                                         p_parttype_col]);
         PDUfill_in_string1(&ep_parttype,
                           ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                                         p_parttype_col]);
         } 
      }
   return(status);
}

/* Pull out the part type and description when an existing part's revision
   is changed.*/

int PDUpull_pt_desc()

{
   int       status = PDM_S_SUCCESS;
char   ** ret_bufr_row;
char   ** ret_bufr_col;
int       p_parttype_col;
int       n_itemdesc_col;

   _pdm_debug("Entering PDUpull_pt_desc",0);

   MEMbuild_array(PDU_ret_bufr);

   PDUsetup_buffer(PDU_ret_bufr,ROW,&ret_bufr_row);
   PDUsetup_buffer(PDU_ret_bufr,COL,&ret_bufr_col);

   status = PDUget_col_number(PDU_ret_bufr,"p_parttype",
                              ret_bufr_col,&p_parttype_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   status = PDUget_col_number(PDU_ret_bufr,"n_itemdesc",
                              ret_bufr_col,&n_itemdesc_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,
                  ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                  p_parttype_col],FALSE);
   FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,
                  ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                  n_itemdesc_col],FALSE);

   PDUfill_in_string(&refresh->rev_description,
             ret_bufr_row[(PDU_ret_bufr->columns * 0) + n_itemdesc_col]);
   PDUfill_in_string1(&ep_desc,
             ret_bufr_row[(PDU_ret_bufr->columns * 0) + n_itemdesc_col]);
   PDUfill_in_string(&refresh->rev_parttype,
             ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col]);
   PDUfill_in_string1(&ep_parttype,
             ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col]);
   return(status);
}

/* Pull out the revision, part type, and description. */

int PDUpull_rev_pt_desc()

{
   int       status = PDM_S_SUCCESS;
char   ** ret_bufr_row;
char   ** ret_bufr_col;
int       p_rev_col;
int       p_parttype_col;
int       n_itemdesc_col;

   _pdm_debug("Entering PDUpull_rev_pt_desc",0);

   MEMbuild_array(PDU_ret_bufr);

   PDUsetup_buffer(PDU_ret_bufr,ROW,&ret_bufr_row);
   PDUsetup_buffer(PDU_ret_bufr,COL,&ret_bufr_col);

   status = PDUget_col_number(PDU_ret_bufr,"n_itemrev",
                              ret_bufr_col,&p_rev_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   status = PDUget_col_number(PDU_ret_bufr,"p_parttype",
                              ret_bufr_col,&p_parttype_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   status = PDUget_col_number(PDU_ret_bufr,"n_itemdesc",
                              ret_bufr_col,&n_itemdesc_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[3],0,0,
                  ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_rev_col],FALSE);

   _pdm_debug("writing to refresh",0);
   PDUfill_in_string(&refresh->rev_revision,
                ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_rev_col]);
   PDUfill_in_string(&refresh->rev_description,
                ret_bufr_row[(PDU_ret_bufr->columns * 0) + n_itemdesc_col]);
   PDUfill_in_string(&refresh->rev_parttype,
                ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col]);

   PDUfill_in_string1(&ep_rev,
                      ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_rev_col]);

   if (PDU_form_id == forms.part_operations_form_id)
      {
/*
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,
           0,ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col],FALSE);
*/
      PDUfill_in_string1(&ep_parttype,
                   ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col]);
      }
   else if (PDU_form_id != forms.seed_form_form_id) 
      {
      _pdm_debug("writing to refresh",0);
      PDUfill_in_string(&refresh->rev_parttype,
             ret_bufr_row[(PDU_ret_bufr->columns * 0) + p_parttype_col]);
      }

      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,
                     ret_bufr_row[(PDU_ret_bufr->columns * 0) +
                     n_itemdesc_col],FALSE);

   PDUfill_in_string1(&ep_desc,
                   ret_bufr_row[(PDU_ret_bufr->columns * 0) + n_itemdesc_col]);

   return(status);
}

/* Send catalog, partnum, and revision to get attr_bufr and
   data_bufr which contain the Part Attribute Info, File Info,
   Storage Area name, part type, and ACL Info. Call PDMget_part_data.
   Find out what errors are return. */

int PDUpull_bufr_info()

{
   int       status = PDM_S_SUCCESS;
   short     update = 1;
   short     read = 1;
   short     write = 1;
   MEMptr    buffer = NULL;
   MEMptr    temp_bufr = NULL;
   char      *msg = NULL;
   extern  void  PDUcleanup_attr_retrieval();

   _pdm_debug("IN the function PDUpull_bufr_info",0);

   PDUfill_in_string1(&en_itemname, refresh->rev_partid);
   PDUfill_in_string1(&ep_rev, refresh->rev_revision);

   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("en_itemname = <%s>", en_itemname);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   if (((similar_mode  == TRUE) &&
      (strcmp(ep_catalog,np_catalog) != 0)) ||
      ((similar_mode == TRUE) &&
       (strcmp(ep_catalog,np_catalog) == 0) &&
       (strcmp(en_itemname,"") != 0))) 
      {
      _pdm_debug("entering case for similar mode", 0);
      PDUdisable_part_form_gadgets();
 
      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }

      /* This appended list of buffers will not contain a acl or storage bufr */
      status = PDMget_part_data(ep_catalog,en_itemname,ep_rev);
      _pdm_status("PDUget_part_data",status);

      if (status != PDM_S_SUCCESS)
         {
         PDUcleanup_attr_retrieval();
 
         if (ep_catalog && en_itemname && ep_rev &&
            (strlen(ep_catalog)) && (strlen(en_itemname)) && (strlen(ep_rev)))
           FIg_enable(PDU_form_id,SIMMODE_COPY_TGL);
         else
           FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);

         PDUmessage(status,'s');
         return(status);
         }
      }
   else if ((change_mode == TRUE) || (review_mode == TRUE))
      {
      _pdm_debug("entering case for change or review mode", 0);
      if (PDU_form_id == forms.part_operations_form_id)
         {
         PDUdisable_part_form_gadgets();
         FIg_erase(forms.part_operations_form_id,STORAGE_AREA_BTN);

         if (review_mode == TRUE)
            FIg_disable(PDU_form_id,FILE_INFO_MCF);
  
         if (change_mode == TRUE)
             FIg_disable(PDU_form_id,DELETE_FILES_TGL);
         }

      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }

      /* This appended buffer list will contain an acl and storage buffer */

      PDU_part_flagged = FALSE;

      status = PDMget_existing_data(ep_catalog,en_itemname,ep_rev);
      _pdm_status("PDUget_existing_data",status);

      if (review_mode)
        PDUunlock_item(ep_catalog, en_itemname, ep_rev);

      if ((change_mode) &&
         ((status == PDM_E_PART_FLAGGED_FOR_ARCHIVE) ||
          (status == PDM_E_PART_ARCHIVED) ||
          (status == PDM_E_PART_FLAGGED_FOR_BACKUP) ||
          (status == PDM_E_PART_FLAGGED_FOR_DELETE) ||
          (status == PDM_E_ITEM_FLAG_ARCHIVE) ||
          (status == PDM_E_ITEM_FLAG_BACKUP) ||
          (status == PDM_E_ITEM_FLAG_DELETE) ||
          (status == PDM_E_PART_FLAGGED_FOR_RESTORE)))
         {
         _pdm_debug("Item is flagged",0);
         PDU_part_flagged = TRUE;
         PDUmessage(status,'s');
         msg = (char *) PDUtranslate_message(PDM_E_CANCEL_FLAG_BEFORE_MOD);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);

         FIg_enable(PDU_form_id,FLAG_CANCELFLAG_BTN); 
         FIg_enable(PDU_form_id,FI_HELP);
         FIg_enable(PDU_form_id,FI_CANCEL);
         FIg_enable(PDU_form_id,FI_RESET);

         return(status);
         }
      if ((review_mode) &&
         ((status == PDM_E_PART_FLAGGED_FOR_ARCHIVE) ||
          (status == PDM_E_PART_ARCHIVED) ||
          (status == PDM_E_PART_FLAGGED_FOR_BACKUP) ||
          (status == PDM_E_PART_FLAGGED_FOR_DELETE) ||
          (status == PDM_E_PART_FLAGGED_FOR_RESTORE)))
         {
         status = PDM_S_SUCCESS;
         PDUmessage(status, 's');
         }
      else if (status != PDM_S_SUCCESS)
         {
         _pdm_debug("part is not flagged and status != SUCCESS", 0);
         PDUcleanup_attr_retrieval();
         return(status);
         }
      }

   if (status == PDM_S_SUCCESS)
      {
      if (PDU_ep_bufr != NULL)
         {
         MEMclose(&PDU_ep_bufr);
         PDU_ep_bufr = NULL;
         }

      status = MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_ep_bufr,1);
      _pdm_debug("MEMsplit_copy_buffer", status);
      if (status != MEM_S_SUCCESS)
        {
        status = PDM_E_COPY_BUFFER;
        PDUmessage(status, 's');
        PDUcleanup_attr_retrieval();
        return(status);
        }

      PDUfill_in_string1(&refresh->rev_partid,en_itemname);

      if ((change_mode == TRUE) || (review_mode == TRUE))
         {
         pt_flag = TRUE;
         status = PDUpull_from_bufr();
         _pdm_status("PDUpull_from_bufr",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUcleanup_attr_retrieval();
            PDUmessage(status,'s');
            return(status);
            }

         if (change_mode == TRUE)
            {   
            PDUenable_part_form_gadgets();
            FIg_disable(PDU_form_id,EP_PROJECT_FLD);
            FIg_disable(PDU_form_id,EP_PROJECT_BTN);
            FIg_disable(PDU_form_id,EP_CATALOG_FLD);
            FIg_disable(PDU_form_id,EP_CATALOG_BTN);
            FIg_disable(PDU_form_id,EP_PARTNUM_BTN);

            _pdm_debug("checking parttype for n_update", 0);
	    status = MEMsplit_copy_buffer(PDU_attr_bufr, &temp_bufr, 0);
            _pdm_debug("MEMsplit_copy_buffer", status);
            if (status != MEM_S_SUCCESS)
              {
              status = PDM_E_COPY_BUFFER;
              PDUcleanup_attr_retrieval();
              return(status);
              }
            status = PDUcheck_parttype_privileges(temp_bufr, 
                                                   &update, &read, &write);
            _pdm_status("PDUcheck_parttype_privileges", status);
            if (status != PDM_S_SUCCESS)
              _pdm_debug("error checking parttype privs", 0);
            if (temp_bufr)
              MEMclose(&temp_bufr);

            if (update)
              {
              FIg_enable(PDU_form_id,EP_PARTTYPE_FLD);
              FIg_enable(PDU_form_id,EP_PARTTYPE_BTN);
              }
            else
              {
              FIg_disable(PDU_form_id,EP_PARTTYPE_FLD);
              FIg_disable(PDU_form_id,EP_PARTTYPE_BTN);
              }

            if (PDU_file_data_bufr && (!PDU_part_checked_in) && 
                                      (!PDU_never_checked_in))
               FIg_disable(PDU_form_id,EXISTING_FILES_MCF);
            else if (PDU_file_data_bufr && (PDU_part_checked_in    ||
                                            PDU_never_checked_in))
               FIg_enable(PDU_form_id,EXISTING_FILES_MCF);
            else
               FIg_disable(PDU_form_id,EXISTING_FILES_MCF);

            if (PDU_part_checked_in == TRUE)
               FIg_disable(PDU_form_id,NEW_FILES_MCF);
            else if (!PDU_part_checked_in)
               FIg_disable(PDU_form_id, DELETE_FILES_TGL);
            else if (PDU_localfn_newfiles_disable == TRUE)
               FIg_disable(PDU_form_id,NEW_FILES_MCF);

            if (PDU_never_checked_in)
              {
              FIg_enable(PDU_form_id, DELETE_FILES_TGL);
              PDU_never_checked_in = FALSE;
              }

            if (PDU_disable_move_state_btn == TRUE)
               FIg_disable(PDU_form_id,MOVE_STATE_BTN);
            else if (PDU_disable_move_state_btn == FALSE)
               FIg_enable(PDU_form_id,MOVE_STATE_BTN);
            }
         else if (review_mode == TRUE)
            {
            PDUenable_part_form_gadgets();
            FIg_disable(PDU_form_id,EP_PROJECT_FLD);
            FIg_disable(PDU_form_id,EP_PROJECT_BTN);
            FIg_disable(PDU_form_id,EP_CATALOG_FLD);
            FIg_disable(PDU_form_id,EP_CATALOG_BTN);
            FIg_disable(PDU_form_id,EP_PARTNUM_FLD);
            FIg_disable(PDU_form_id,EP_PARTNUM_BTN);

            FIg_disable(PDU_form_id, EP_DESC_FLD);
            FIg_disable(PDU_form_id, EP_PARTTYPE_FLD);
            FIg_disable(PDU_form_id, EP_PARTTYPE_BTN);

            FIg_erase(PDU_form_id, DELETE_FILES_TGL);

            FIfld_set_mode(PDU_form_id, FILE_INFO_MCF, 0, FI_REVIEW);
            FIfld_set_mode(PDU_form_id, FILE_INFO_MCF, 1, FI_REVIEW);
            FIfld_set_mode(PDU_form_id, FILE_INFO_MCF, 2, FI_REVIEW);
            FIfld_set_mode(PDU_form_id, FILE_INFO_MCF, 3, FI_REVIEW);
            }
         }
      else if (similar_mode == TRUE)
         {
         if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0))
            {
            status = PDUpull_from_bufr();
            _pdm_status("PDUpull_from_bufr",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            else
               FIfld_pos_cursor(PDU_form_id,NP_CATALOG_FLD,0,0,0,0,0,0);
            }
         else if ((strcmp(ep_catalog,np_catalog) == 0) &&
             (strcmp(en_itemname,"") == 0))
            {
            status = PDUpull_from_bufr();
            _pdm_status("PDUpull_from_bufr",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            else
               FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
            }
         else if ((strcmp(ep_catalog,np_catalog) == 0) &&
                  (strcmp(en_itemname,"") != 0))
            {
            status = PDUpull_when_diff();
            _pdm_status("PDUpull_when_diff",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            else
               FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
            }
         else if (strcmp(ep_catalog,np_catalog) != 0)
            {
            status = PDUpull_when_diff();
            _pdm_status("PDUpull_when_diff",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            else
               FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
            }

         PDUenable_part_form_gadgets();
         FIg_disable(PDU_form_id,EP_PROJECT_FLD);
         FIg_disable(PDU_form_id,EP_PROJECT_BTN);
         FIg_disable(PDU_form_id,EP_CATALOG_FLD);
         FIg_disable(PDU_form_id,EP_CATALOG_BTN);
         FIg_disable(PDU_form_id,EP_PARTNUM_FLD);
         FIg_disable(PDU_form_id,EP_PARTNUM_BTN);

         FIg_disable(PDU_form_id, EP_DESC_FLD);

         if (refresh->new_catalog && 
             (strcmp(refresh->new_catalog, "pdmlibraries") == 0))
           FIg_disable(PDU_form_id, NP_PARTTYPE_BTN);

         _pdm_debug("setting copy toggle", 0);
         if (ep_catalog && en_itemname && ep_rev &&
            (strlen(ep_catalog)) && (strlen(en_itemname)) && (strlen(ep_rev)))
          {
          _pdm_debug("checking for associated files", 0);
          status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &buffer);
          _pdm_status("PDMget_filenames", status);
 
          if (( status != PDM_S_SUCCESS ) || (!buffer))
            FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
          else if (buffer && (buffer->rows == 0))
            FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
          else
            FIg_enable(PDU_form_id,SIMMODE_COPY_TGL);
          MEMclose(&buffer);
          status = PDM_S_SUCCESS;
          }
        else
          FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);

        _pdm_debug("checking parttype for n_update", 0);
        status = MEMsplit_copy_buffer(PDU_attr_bufr, &temp_bufr, 0);
        _pdm_debug("MEMsplit_copy_buffer", status);
        if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_COPY_BUFFER;
          PDUcleanup_attr_retrieval();
          return(status);
          }
        status = PDUcheck_parttype_privileges(temp_bufr, 
                                               &update, &read, &write);
        _pdm_status("PDUcheck_parttype_privileges", status);
        if (status != PDM_S_SUCCESS)
          _pdm_debug("error checking parttype privs", 0);
        if (temp_bufr)
          MEMclose(&temp_bufr);

        if (!write)
          {
          _pdm_debug("parttype is NO WRITE", 0);
          FIg_disable(PDU_form_id, NP_PARTTYPE_FLD);
          FIg_disable(PDU_form_id, NP_PARTTYPE_BTN);
          FIg_disable(PDU_form_id, EP_PARTTYPE_FLD);
          FIg_disable(PDU_form_id, EP_PARTTYPE_BTN);
          }
        if (!read)
          {
          _pdm_debug("parttype is NO READ", 0);
          FIg_set_text(PDU_form_id, EP_PARTTYPE_FLD, NULL_STRING);
          }
         }

     _pdm_debug("checking parttype", 0);
     if (ep_parttype && ((strcmp(ep_parttype, "N") == 0) ||
                         (strcmp(ep_parttype, "n") == 0)))
       {
       _pdm_debug("erasing file pallette for nongraphic part", 0);
       FIg_erase(PDU_form_id,EXISTING_FILE_TXT);
       if (change_mode)
         {
         FIg_erase(PDU_form_id,CHANGE_MODE_GRP);
         FIg_erase(PDU_form_id,NEW_FILE_TXT);
         FIg_erase(PDU_form_id,DELETE_FILES_TGL);
         }
       else if (review_mode)
         {
         FIg_erase(PDU_form_id,FILE_INFO_MCF);
         }
       else if (similar_mode)
         {
         FIg_erase(PDU_form_id,SIMILAR_MODE_GRP);
         FIg_erase(PDU_form_id,NEW_FILE_TXT);
         }
       }

     PDUmessage(status,'s');
     }

return(status);
}

int PDUpull_bufr_info_for_np()

{
   int       status = PDM_S_SUCCESS;
   int           length, select, pos;
   static char *text = NULL;

   _pdm_debug ("Entering PDUpull_bufr_info_for_np",0);

   FIfld_get_text_length(forms.part_operations_form_id, NP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);

   FIfld_get_text_length(forms.part_operations_form_id, NP_PARTNUM_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, NP_PARTNUM_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&nn_itemname,text);
   _pdm_debug("nn_itemname = <%s>", nn_itemname);

   FIfld_get_text_length(forms.part_operations_form_id, EP_CATALOG_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, EP_CATALOG_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(forms.part_operations_form_id, EP_PARTNUM_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, EP_PARTNUM_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&en_itemname,text);
   _pdm_debug("en_itemname = <%s>", en_itemname);

         if ((similar_mode != TRUE) ||
             (strcmp(en_itemname,"") == 0))
            {
            status = PDUpull_from_bufr();
            _pdm_status("PDUpull_from_bufr",status);
      
            if (status != PDM_S_SUCCESS)
               return(status);
            }

         else if ((similar_mode == TRUE) &&
                  (strcmp(ep_catalog,np_catalog) == 0) &&
                  (strcmp(en_itemname,"") == 0))
            {
            status = PDUpull_from_bufr();
            _pdm_status("PDUpull_from_bufr",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            }

         else if ((similar_mode == TRUE) &&
                  (strcmp(ep_catalog,np_catalog) == 0) &&
                  (strcmp(en_itemname,"") != 0))
            {
            status = PDUpull_when_diff();
            _pdm_status("PDUpull_when_diff",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            }

         else if ((similar_mode == TRUE) &&
                  (strcmp(ep_catalog,np_catalog) != 0))
            {
            status = PDUpull_when_diff();
            _pdm_status("PDUpull_when_diff",status);

            if (status != PDM_S_SUCCESS)
               return(status);
            }
if (new_mode == TRUE)
   {
   FIg_display(PDU_form_id,FILE_INFO_MCF);
   FIg_erase(PDU_form_id,DELETE_FILES_TGL);
   FIg_disable(PDU_form_id,DELETE_FILES_TGL);
   }
else if ((similar_mode == TRUE) && (ep_parttype) && 
         (strcmp(ep_parttype, "N") != 0) && (strcmp(ep_parttype, "n") != 0))
   {
   _pdm_debug("displaying SIMILAR_MODE_MCF", 0);
   FIg_display(PDU_form_id,SIMILAR_MODE_MCF);
   }
  
return(status);
}

/* Then, if there is a project, send the project, catalog, partnum,
   and revision back to test whether the part is in the project
   (catalog would have already been tested). If not, display error
   message. */

int PDUpart_in_project_test()

{
   int       status = PDM_S_SUCCESS;
   _pdm_debug("Entering PDUpart_in_project_test",0);

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   status = PDMpart_in_project(ep_project,ep_catalog,en_itemname,ep_rev);
   _pdm_status("PDM_part_in_project",status);

   if (status == PDM_S_SUCCESS)
      {
      return(PDM_S_SUCCESS);
      }

   else if (status == PDM_I_NO_ROWS_FOUND)
      {
      return(PDM_I_NO_ROWS_FOUND);
      }
   return(status);
}

/* This function processes the ACL_NAME_BTN and the WORKFLOW_BTN. */

int PDUacl_workflow_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
  MEMptr          hold_attr_bufr;
  MEMptr          ep_attr_bufr;
  char         ** hold_bufr_row;
  char         ** hold_bufr_col;
  char         ** hold_bufr_format;
  char         ** ep_bufr_row;
  char         ** ep_bufr_col;
  char         ** ep_bufr_format;
  char         ** acl_bufr_row;
  char         ** acl_bufr_col;
  char         ** acl_bufr_format;
  int             n_name_col;
  int             n_valueno_col;
  int             i;
  int             list_buffer_no = 0;
  int             length, select, pos;
  static char *text = NULL;

   _pdm_debug("Entering PDUacl_workflow_btn",0);

   PDUdismiss_subforms();

   end_acl_wf_btn_flag = TRUE;
   if ((new_mode == TRUE) || (similar_mode == TRUE))
      {
      FIfld_get_text_length(forms.part_operations_form_id, NP_CATALOG_FLD, 
                            0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                     length, (unsigned char *)text, &select, &pos);
      PDUfill_in_string1(&np_catalog,text);
      _pdm_debug("np_catalog = <%s>", np_catalog);

      if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) 
         {
         msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         return(PDM_I_ENTER_CATALOG);
         }

      /* This flag set so PDUbufr_to_form and PDUbufr_to_form_fields will
         use the correct buffer. This will be called from PDUsgl_list_form. */

      pdu_hold_acl_bufr_flag = TRUE;

      status = PDUsetup_buffer_list(PDU_hold_bufr,1,0,&hold_bufr_row,
                                    &hold_bufr_col,&hold_bufr_format,
                                    &hold_attr_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

     status = PDUget_col_number(hold_attr_bufr,"n_name",hold_bufr_col,&n_name_col);
     if (status != PDM_S_SUCCESS)
       {
       PDUmessage(status, 's');
       return(status);
       }

     status = PDUget_col_number(hold_attr_bufr,"n_valueno",hold_bufr_col,&n_valueno_col);
     if (status != PDM_S_SUCCESS)
       {
       PDUmessage(status, 's');
       return(status);
       }

      for (i = 0; i < hold_attr_bufr->rows; ++i)
          {
          if (strcmp(hold_bufr_row[(hold_attr_bufr->columns * i) +
                     n_name_col],"n_aclno") == 0)
             {
             list_buffer_no = atoi(hold_bufr_row[(hold_attr_bufr->columns * i) +
                                   n_valueno_col]);
             break;
             }
          }

      status = PDUsetup_buffer_list(PDU_hold_bufr, 3, list_buffer_no,
                                    &acl_bufr_row,&acl_bufr_col,
                                    &acl_bufr_format,&PDU_hold_acl_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if (PDMdebug_on)
         MEMprint_buffer("PDU_hold_acl_bufr",PDU_hold_acl_bufr,PDU_DEBUG_FILE);

      if (status == PDM_S_SUCCESS)
         {
         PDUsetup_single_buffer(PDU_hold_acl_bufr);

         PDU_form_id = forms.part_operations_form_id;

         PDU_gadget_labels[0] = ACL_NAME_FLD;
         PDU_gadget_labels[1] = WORKFLOW_FLD;

         all_flag = FALSE;
         no_headings = 3;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_aclname");
         PDUfill_in_string(&headings[1], "n_aclno");
         PDUfill_in_string(&headings[2], "n_workflowname");

         PDUsetup_popup_list(headings,no_headings,all_flag,PDU_hold_acl_bufr);

         PDUfree_string_array(&headings,no_headings);

         all_flag = FALSE;
         no_headings = 2;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_aclname");
         PDUfill_in_string(&headings[1], "n_workflowname");

         PDUsetup_form_fields(headings,no_headings,all_flag,PDU_hold_acl_bufr);

         PDUfree_string_array(&headings,no_headings);

         msg = (char *)PDUtranslate_message(PDM_I_ACL_LIST);
         status = PDUmcf_list_form(msg);
         _pdm_status("PDUmcf_list_form",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (single_flag == TRUE)
            {
            single_flag = FALSE;
            return(PDM_S_SUCCESS);
            }

         if (status == PDM_S_SUCCESS)
            return(0);
         }
      }
   else if ((change_mode == TRUE) || (review_mode == TRUE))
      {
      FIfld_get_text_length(forms.part_operations_form_id, EP_CATALOG_FLD, 
                            0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(forms.part_operations_form_id, EP_CATALOG_FLD, 0, 0, 
                     length, (unsigned char *)text, &select, &pos);
      PDUfill_in_string1(&ep_catalog,text);
      _pdm_debug("ep_catalog = <%s>", ep_catalog);

      FIfld_get_text_length(forms.part_operations_form_id, EP_PARTNUM_FLD, 
                            0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(forms.part_operations_form_id, EP_PARTNUM_FLD, 0, 0, 
                     length, (unsigned char *)text, &select, &pos);
      PDUfill_in_string1(&en_itemname,text);
      _pdm_debug("en_itemname = <%s>", en_itemname);

      if (((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0)) &&
         ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0))) 
         {
         msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         return(PDM_I_ENTER_PART);
         }

      /* This flag set so PDUbufr_to_form and PDUbufr_to_form_fields will
         use the correct buffer. This will be called from PDUsgl_list_form. */

      pdu_ep_acl_bufr_flag = TRUE;

      status = PDUsetup_buffer_list(PDU_ep_bufr,1,0,&ep_bufr_row,
                                    &ep_bufr_col,&ep_bufr_format,
                                    &ep_attr_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      status = PDUget_col_number(ep_attr_bufr,"n_name",ep_bufr_col,&n_name_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(ep_attr_bufr,"n_valueno",ep_bufr_col,&n_valueno_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      for (i = 0; i < ep_attr_bufr->rows; ++i)
          {
          if (strcmp(ep_bufr_row[(ep_attr_bufr->columns * i) +
                     n_name_col],"n_aclno") == 0)
             {
             list_buffer_no = atoi(ep_bufr_row[(ep_attr_bufr->columns *
                                   i) + n_valueno_col]);
             break;
             }
          }

      status = PDUsetup_buffer_list(PDU_ep_bufr, 3, list_buffer_no,
                                    &acl_bufr_row, &acl_bufr_col,
                                    &acl_bufr_format,&PDU_ep_acl_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if (PDMdebug_on)
         MEMprint_buffer("PDU_ep_acl_bufr",PDU_ep_acl_bufr,PDU_DEBUG_FILE);

      if (status == PDM_S_SUCCESS)
         {
         PDUsetup_single_buffer(PDU_ep_acl_bufr);

         PDU_form_id = forms.part_operations_form_id;

         PDU_gadget_labels[0] = ACL_NAME_FLD;
         PDU_gadget_labels[1] = WORKFLOW_FLD;

         all_flag = FALSE;
         no_headings = 3;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_aclname");
         PDUfill_in_string(&headings[1], "n_aclno");
         PDUfill_in_string(&headings[2], "n_workflowname");

         PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ep_acl_bufr);

         PDUfree_string_array(&headings,no_headings);

         all_flag = FALSE;
         no_headings = 2;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_aclname");
         PDUfill_in_string(&headings[1], "n_workflowname");

         PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ep_acl_bufr);

         PDUfree_string_array(&headings,no_headings);

         msg = (char *)PDUtranslate_message(PDM_I_ACL_LIST);
         status = PDUmcf_list_form(msg);
         _pdm_status("PDUmcf_list_form",status);

         if (single_flag == TRUE)
            {
            single_flag = FALSE;
            return(PDM_S_SUCCESS);
            }

         if (status == PDM_S_SUCCESS)
            return(0);

         }
      }
   return(status);
}

/* This function is to process the STORAGE_AREA_BTN. */

int PDUstg_area_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
  MEMptr          hold_attr_bufr;
  MEMptr          ep_attr_bufr;
  char         ** hold_bufr_row;
  char         ** hold_bufr_col;
  char         ** hold_bufr_format;
  char         ** ep_bufr_row;
  char         ** ep_bufr_col;
  char         ** ep_bufr_format;
  char         ** stg_bufr_row;
  char         ** stg_bufr_col;
  char         ** stg_bufr_format;
  int             n_name_col;
  int             n_valueno_col;
  int             list_buffer_no = 0;
  int             i;

   _pdm_debug("Entering PDUstg_area_btn",0);

   PDUdismiss_subforms();

   end_stg_area_btn_flag = TRUE;
   pdu_hold_stg_bufr_flag = FALSE;
   pdu_ep_stg_bufr_flag = FALSE;

   if ((new_mode == TRUE) || (similar_mode == TRUE))
      {
      _pdm_debug("np_catalog = <%s>", np_catalog);

      if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0)) 
         {
         msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         return(PDM_I_ENTER_CATALOG);
         }

      /* This flag set so PDUbufr_to_form and PDUbufr_to_form_fields will
         use the correct buffer. This will be called from PDUsgl_list_form. */

      pdu_hold_stg_bufr_flag = TRUE;

      status = PDUsetup_buffer_list(PDU_hold_bufr,1,0,&hold_bufr_row,
                                    &hold_bufr_col,&hold_bufr_format,
                                    &hold_attr_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      status = PDUget_col_number(hold_attr_bufr,"n_name",hold_bufr_col,&n_name_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(hold_attr_bufr,"n_valueno",hold_bufr_col,
                        &n_valueno_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      for (i = 0; i < hold_attr_bufr->rows; ++i)
          {
          if (strcmp(hold_bufr_row[(hold_attr_bufr->columns * i) +
                     n_name_col],"n_cisano") == 0)
             {
             list_buffer_no = atoi(hold_bufr_row[(hold_attr_bufr->columns * i) +
                                   n_valueno_col]);
             break;
             }
          }

      status = PDUsetup_buffer_list(PDU_hold_bufr, 3, list_buffer_no,
                                    &stg_bufr_row, &stg_bufr_col,
                                    &stg_bufr_format,&PDU_hold_stg_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if (status == PDM_S_SUCCESS)
         {
         PDUsetup_single_buffer(PDU_hold_stg_bufr);

         PDU_form_id = forms.part_operations_form_id;

         PDU_gadget_labels[0] = STORAGE_AREA_FLD;

         all_flag = FALSE;
         no_headings = 1;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_saname");

         PDUsetup_popup_list(headings,no_headings,all_flag,PDU_hold_stg_bufr);

         PDUsetup_form_fields(headings,no_headings,all_flag,PDU_hold_stg_bufr);

         PDUfree_string_array(&headings,no_headings);

         PDU_active_button = STORAGE_AREA_BTN;

         status = PDUsingle_list_form();
         _pdm_status("PDUsingle_list_form",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (single_flag == TRUE)
            {
            single_flag = FALSE;
            return(PDM_S_SUCCESS);
            }

         if (status == PDM_S_SUCCESS)
            return(0);
         }
      }
   else if ((change_mode == TRUE) || (review_mode == TRUE))
      {
      _pdm_debug("ep_catalog = <%s>", ep_catalog);
      _pdm_debug("en_itemname = <%s>", en_itemname);

      if (((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0)) &&
         ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0))) 
         {
         msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         return(PDM_I_ENTER_PART);
         }

      /* This flag set so PDUbufr_to_form and PDUbufr_to_form_fields will
         use the correct buffer. This will be called from PDUsgl_list_form. */

      pdu_ep_stg_bufr_flag = TRUE;
  
      status =  PDUsetup_buffer_list(PDU_ep_bufr,1,0,&ep_bufr_row,
                                     &ep_bufr_col,&ep_bufr_format,
                                     &ep_attr_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      status = PDUget_col_number(ep_attr_bufr,"n_name",ep_bufr_col,&n_name_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(ep_attr_bufr,"n_valueno",ep_bufr_col,&n_valueno_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }


      for (i = 0; i < ep_attr_bufr->rows; ++i)
          {
          if (strcmp(ep_bufr_row[(ep_attr_bufr->columns * i) + n_name_col],
              "n_cisano") == 0)
             {
             list_buffer_no = atoi(ep_bufr_row[(ep_attr_bufr->columns * i) +
                                   n_valueno_col]);
             break;
             }
          }

      status = PDUsetup_buffer_list(PDU_ep_bufr, 3, list_buffer_no,
                                    &stg_bufr_row, &stg_bufr_col,
                                    &stg_bufr_format,&PDU_ep_stg_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if (status == PDM_S_SUCCESS)
         {
         PDUsetup_single_buffer(PDU_ep_stg_bufr);

         PDU_form_id = forms.part_operations_form_id;

         PDU_gadget_labels[0] = STORAGE_AREA_FLD;

         all_flag = FALSE;

         no_headings = 1;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_saname");

         PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ep_stg_bufr);

         PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ep_stg_bufr);

         PDUfree_string_array(&headings,no_headings);

         PDU_active_button = STORAGE_AREA_BTN;

         status = PDUsingle_list_form();
         _pdm_status("PDUsingle_list_form",status);

         if (single_flag == TRUE)
            {
            single_flag = FALSE;
            return(PDM_S_SUCCESS);
            }

         if (status == PDM_S_SUCCESS)
            return(0);

         }
      }
   return(status);
}

/*This function is called for PDUep_part_fld after a catalog has been selected*/

int PDUend_ep_part_fld()

{
   int       status = PDM_S_SUCCESS;
   int             length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUend_ep_part_fld",0);

   end_ep_part_fld_flag = FALSE;

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

/*
   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&en_itemname,text);
   _pdm_debug("en_itemname = <%s>", en_itemname);
*/

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   status = PDUvalid_partnum(ep_catalog,en_itemname);
   _pdm_status("PDUvalid_partnum",status);

   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
      PDUmessage(status,'s');
      return(status);
      }

   PDUfill_in_string(&refresh->rev_catalog,ep_catalog);

   status = PDUpull_rev_pt_desc();
   _pdm_status("PDUpull_rev_pt_desc",status);

   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
      FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[2],0,0,0,0,0,0);
      return(status);
      }

   if (status == PDM_S_SUCCESS)
      PDUfill_in_string1(&refresh->rev_partid,en_itemname);
         
   if (PDU_form_id == forms.part_operations_form_id)
      {
      /* Then send catalog, partnum, and revision to get attr_bufr and
         data_bufr which contain the Part Attribute Info, File Info,
         Storage Area name, part type, and ACL Info.
         Call PDMget_part_data. */

      status = PDUpull_bufr_info();

      if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }
      }

  if ((PDU_command == PDC_M_SEARCH_ACROSS_CATS) &&
      (PDU_form_id == forms.local_files_form_id))
    {
    status = PDUcheck_file_commands();
    _pdm_status("PDUcheck_file_commands", status);
    }

  if (status != PDM_S_SUCCESS)
     {
     FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[2],0,0,"",FALSE);
     return(status);
     }

   return(status);
}

/*This function is called for PDUep_desc_fld after a catalog has been selected*/

int PDUend_ep_desc_fld()

{
   int       status = PDM_S_SUCCESS;
   int             length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUend_ep_desc_fld",0);

   end_ep_desc_fld_flag = FALSE;
   end_ep_desc_btn_flag = FALSE;

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&en_itemname,text);
   _pdm_debug("en_itemname = <%s>", en_itemname);

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[3], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[3], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_rev,text);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   if ((strcmp(en_itemname,"") == 0) && (strcmp(ep_rev,"") == 0))   
      {
      status = PDUpull_pn_rev_pt();
      _pdm_status("PDUpull_pn_rev_pt",status);

      if (status != PDM_S_SUCCESS)
         {
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
         return(status);
         }
      }

   if (PDU_form_id == forms.part_operations_form_id)
      {
      /* Then send catalog, partnum, and revision to get attr_bufr and
         data_bufr which contain the Part Attribute Info, File Info,
         Storage Area name, and ACL Info. Call PDMget_part_data. */

      status = PDUpull_bufr_info();
      _pdm_status("PDUpull_bufr_info",status);

      if (status != PDM_S_SUCCESS)
         {  
         FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,"",FALSE);
         PDUmessage(status, 's');
         return(status);
         }
      }
   return(status);
}

/* This function is called after PDUstg_area_btn when a storage area has been
   selected. The call is made from PDUbufr_to_form or PDUbufr_to_form_fields
   depending on if there is only one storage area in the buffer. */

int  PDUend_stg_area_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
  MEMptr          hold_attr_bufr;
  MEMptr          hold_stg_bufr;
  MEMptr          ep_attr_bufr;
  MEMptr          ep_stg_bufr;
  char         ** hold_bufr_row;
  char         ** hold_bufr_col;
  char         ** hold_bufr_format;
  char         ** ep_bufr_row;
  char         ** ep_bufr_col;
  char         ** ep_bufr_format;
  char         ** stg_bufr_row;
  char         ** stg_bufr_col;
  char         ** stg_bufr_format;
  int             i;
  int             n_name_col;
  int             n_valueno_col;
  int             n_cisano_col;
  int             hold_n_saname_col;
  int             hold_n_sano_col;
  int             ep_n_saname_col;
  int             ep_n_sano_col;
  int             list_buffer_no = 0;
  int             length, select, pos;
  int             row = 0;
  int             num_rows = 0;
  char          * saname_text = NULL;
  char         ** data_col;
  char         ** data_row;
  static char          * filename = NULL;
  static char *text = NULL;

      _pdm_debug("ENTER FUNCTION: PDUend_stg_area_btn",0);

      end_stg_area_btn_flag = FALSE;
      pdu_hold_stg_bufr_flag = FALSE;
      pdu_ep_stg_bufr_flag = FALSE;

      if (PDU_active_button != -1)
        {
        FIg_set_state_off(PDU_form_id, PDU_active_button);
        FIg_display(PDU_form_id, PDU_active_button);
        PDU_active_button = -1;
        }

      FIfld_get_text_length(PDU_form_id, STORAGE_AREA_FLD, 0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL_STRING, sizeof (char) * length + 1);
      FIfld_get_text(PDU_form_id, STORAGE_AREA_FLD, 0, 0, length, 
                     (unsigned char *)text, &select, &pos);
      PDUfill_in_string(&saname_text,text);
      _pdm_debug("saname_text = <%s>", saname_text);

      if ((new_mode == TRUE) || (similar_mode == TRUE))
         {
         status = PDUsetup_buffer_list(PDU_hold_bufr,1,0,&hold_bufr_row,
                                       &hold_bufr_col,&hold_bufr_format,
                                       &hold_attr_bufr);
         _pdm_status("PDUsetup_buffer_list",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         status = PDUget_col_number(hold_attr_bufr,"n_name",hold_bufr_col,
                           &n_name_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }

         status = PDUget_col_number(hold_attr_bufr,"n_valueno",hold_bufr_col,
                           &n_valueno_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }

         for (i = 0; i < hold_attr_bufr->rows; ++i)
            {
            if (strcmp(hold_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col],"n_cisano") == 0)
               {
               list_buffer_no = atoi(hold_bufr_row[(hold_attr_bufr->columns * i)                                + n_valueno_col]);
               break;
               }
            }

         status = PDUsetup_buffer_list(PDU_hold_bufr, 3, list_buffer_no,
                                       &stg_bufr_row, &stg_bufr_col,
                                       &stg_bufr_format,&hold_stg_bufr);
         _pdm_status("PDUsetup_buffer_list",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (status == PDM_S_SUCCESS)
            {
            status = PDUget_col_number(hold_stg_bufr,"n_sano",
                                       stg_bufr_col, &hold_n_sano_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            status = PDUget_col_number(hold_stg_bufr,"n_saname",
                                       stg_bufr_col, &hold_n_saname_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            for (i = 0; i < hold_stg_bufr->rows; ++i)
               {
               if (strcmp(saname_text,stg_bufr_row[(hold_stg_bufr->columns * i)
                   + hold_n_saname_col]) == 0)
                  {
                  break;
                  }
               }

            status = MEMbuild_array(PDU_data_bufr);
            _pdm_status("MEMbuild_array",status);

            if (status != MEM_S_SUCCESS)
              {
              status = PDM_E_BUILD_BUFFER_ARRAY;
              msg = (char *) PDUtranslate_message(status);
              FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
              return(status);
              }

            data_col = (char **) PDU_data_bufr->column_ptr;
            data_row = (char **) PDU_data_bufr->data_ptr;

            status = PDUget_col_number(PDU_data_bufr,"n_cisano",data_col,
                              &n_cisano_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            status = MEMwrite_data(PDU_data_bufr,
                                   stg_bufr_row[(hold_stg_bufr->columns * i)                                       + hold_n_sano_col],1, n_cisano_col +1);
            }
         }
      else if ((change_mode == TRUE) || (review_mode == TRUE))
         {
         status =  PDUsetup_buffer_list(PDU_ep_bufr,1,0,&ep_bufr_row,
                                        &ep_bufr_col,&ep_bufr_format,
                                        &ep_attr_bufr);
         _pdm_status("PDUsetup_buffer_list",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         status = PDUget_col_number(ep_attr_bufr,"n_name",ep_bufr_col,&n_name_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

         status = PDUget_col_number(ep_attr_bufr,"n_valueno",ep_bufr_col,&n_valueno_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }


         for (i = 0; i < ep_attr_bufr->rows; ++i)
            {
            if (strcmp(ep_bufr_row[(ep_attr_bufr->columns * i) + n_name_col],
               "n_cisano") == 0)
               {
               list_buffer_no = atoi(ep_bufr_row[(ep_attr_bufr->columns * i) +
                                     n_valueno_col]);
               break;
               }
            }

         status = PDUsetup_buffer_list(PDU_ep_bufr, 3, list_buffer_no,
                                       &stg_bufr_row, &stg_bufr_col,
                                       &stg_bufr_format,&ep_stg_bufr);
         _pdm_status("PDUsetup_buffer_list",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (status == PDM_S_SUCCESS)
            {
            status = PDUget_col_number(ep_stg_bufr,"n_saname",stg_bufr_col,
                                       &ep_n_saname_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            status = PDUget_col_number(ep_stg_bufr,"n_sano",stg_bufr_col,
                                       &ep_n_sano_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            for (i = 0; i <ep_stg_bufr->rows; ++i)
               {
               if (strcmp(saname_text,stg_bufr_row[(ep_stg_bufr->columns * i)
                   + ep_n_saname_col]) == 0)
                  {
                  break;
                  }
               }

            status = MEMbuild_array(PDU_data_bufr);
            _pdm_status("MEMbuild_array",status);

            if (status != MEM_S_SUCCESS)
              {
              status = PDM_E_BUILD_BUFFER_ARRAY;
              msg = (char *) PDUtranslate_message(status);
              FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
              return(status);
              }

            data_col = (char **) PDU_data_bufr->column_ptr;
            data_row = (char **) PDU_data_bufr->data_ptr;

            status = PDUget_col_number(PDU_data_bufr,"n_cisano",data_col,
                              &n_cisano_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            status = MEMwrite_data(PDU_data_bufr,
                                   stg_bufr_row[(ep_stg_bufr->columns * i)
                                   + ep_n_sano_col],1, n_cisano_col +1);
            } 
         }

   if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

   _pdm_debug("verifying storage area filenames", 0);
   if (new_mode)
     {
     FIfld_get_num_rows(PDU_form_id, FILE_INFO_MCF, &num_rows);
     _pdm_debug("num_rows = %d", num_rows);
     for (row = 0; row < num_rows; ++row)
        {
        FIfld_get_text_length(PDU_form_id,FILE_INFO_MCF, row, 2, &length);
        filename = (char *) malloc (sizeof (char) * length + 1);
        memset(filename, NULL, sizeof (char) * length + 1);
        FIfld_get_text(PDU_form_id, FILE_INFO_MCF, row, 2, length,
                       (unsigned char *)filename, &select, &pos);
        _pdm_debug("filename = <%s>", filename);

        if (!filename)
          break;

        if (filename && (strlen(filename)))
          {
          msg = (char *)PDUtranslate_message(PDS_M_VALIDATE_STG_FILENAME);
          FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
          status = PDMrcheck_dup_sa_fname(np_catalog,nn_itemname,np_rev,
                                          filename,saname_text);
          _pdm_status("PDMrcheck_dup_sa_fname",status);
          FIg_set_text(PDU_form_id, FI_MSG_FIELD, NULL_STRING);
          PDUmessage(status, 's');
          if (status != PDM_S_SUCCESS)
            {
            msg = (char *) PDUtranslate_message(status);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
            FIfld_set_text(PDU_form_id,FILE_INFO_MCF,row,2,"",FALSE);
            return(status);
            }
          else if (status == PDM_S_SUCCESS)
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,NULL_STRING);
          }
        }
     }
   if (change_mode)
     {
     FIfld_get_num_rows(PDU_form_id, NEW_FILES_MCF, &num_rows);
     for (row = 0; row < num_rows; ++row)
        {
        FIfld_get_text_length(PDU_form_id,NEW_FILES_MCF, row, 2, &length);
        filename = (char *) malloc (sizeof (char) * length + 1);
        memset(filename, NULL, sizeof (char) * length + 1);
        FIfld_get_text(PDU_form_id, NEW_FILES_MCF, row, 2, length,
                       (unsigned char *)filename, &select, &pos);

        if (!filename)
          break;

        if (filename && (strlen(filename)))
          {
          status = PDMrcheck_dup_sa_fname(ep_catalog,en_itemname,ep_rev,
                                          filename,saname_text);
          _pdm_status("PDMrcheck_dup_sa_fname",status);
          PDUmessage(status, 's');
          if (status != PDM_S_SUCCESS)
            {
            msg = (char *) PDUtranslate_message(status);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
            FIfld_set_text(PDU_form_id,NEW_FILES_MCF,row,2,"",FALSE);
            return(status);
            }
          else if (status == PDM_S_SUCCESS)
            FIg_set_text(PDU_form_id,FI_MSG_FIELD,NULL_STRING);
          }
        }

     FIfld_get_num_rows(PDU_form_id, EXISTING_FILES_MCF, &num_rows);
     for (row = 0; row < num_rows; ++row)
        {
        FIfld_get_text_length(PDU_form_id,EXISTING_FILES_MCF, row, 2, &length);
        filename = (char *) malloc (sizeof (char) * length + 1);
        memset(filename, NULL, sizeof (char) * length + 1);
        FIfld_get_text(PDU_form_id, EXISTING_FILES_MCF, row, 2, length,
                       (unsigned char *)filename, &select, &pos);

        if (!filename)
          break;

        if (filename && (strlen(filename)))
          {
          status = PDMrcheck_dup_sa_fname(ep_catalog,en_itemname,ep_rev,
                                          filename,saname_text);
          _pdm_status("PDMrcheck_dup_sa_fname",status);
          PDUmessage(status, 's');
          if (status != PDM_S_SUCCESS)
            {
            msg = (char *) PDUtranslate_message(status);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
            FIfld_set_text(PDU_form_id,EXISTING_FILES_MCF,row,2,"",FALSE);
            return(status);
            }
          else if (status == PDM_S_SUCCESS)
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, NULL_STRING);
          }
        }
     }
   if (similar_mode)
     {
     FIfld_get_num_rows(PDU_form_id, SIMILAR_MODE_MCF, &num_rows);
     for (row = 0; row < num_rows; ++row)
        {
        FIfld_get_text_length(PDU_form_id,SIMILAR_MODE_MCF, row, 3, &length);
        filename = (char *) malloc (sizeof (char) * length + 1);
        memset(filename, NULL, sizeof (char) * length + 1);
        FIfld_get_text(PDU_form_id, SIMILAR_MODE_MCF, row, 3, length,
                       (unsigned char *)filename, &select, &pos);

        if (!filename)
          break;

        if (filename && (strlen(filename)))
          {
          status = PDMrcheck_dup_sa_fname(np_catalog,nn_itemname,np_rev,
                                          filename,saname_text);
          _pdm_status("PDMrcheck_dup_sa_fname",status);
          PDUmessage(status, 's');
          if (status != PDM_S_SUCCESS)
            {
            msg = (char *) PDUtranslate_message(status);
            FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
            FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,row,3,"",FALSE);
            return(status);
            }
          else if (status == PDM_S_SUCCESS)
            FIg_set_text(forms.part_operations_form_id,FI_MSG_FIELD,"");
          }
        }
     }

   return(status);
}

/*This function is called after PDUacl_workflow_btn when an acl or workflow has   been selected. The call is made from PDUbufr_to_form or PDUbufr_to_form_fields
   depending on if there is only one acl or workflow in the buffer. */

int  PDUend_acl_wf_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
  MEMptr          hold_attr_bufr;
  MEMptr          hold_acl_bufr;
  MEMptr          ep_attr_bufr;
  MEMptr          ep_acl_bufr;
  char         ** hold_bufr_row;
  char         ** hold_bufr_col;
  char         ** hold_bufr_format;
  char         ** ep_bufr_row;
  char         ** ep_bufr_col;
  char         ** ep_bufr_format;
  char         ** acl_bufr_row;
  char         ** acl_bufr_col;
  char         ** acl_bufr_format;
  int             i;
  int             n_name_col;
  int             n_valueno_col;
  int             n_aclno_col;
  int             hold_n_aclno_col;
  int             hold_n_aclname_col;
  int             ep_n_aclno_col;
  int             ep_n_aclname_col;
  int             list_buffer_no = 0;
  int             length, select, pos;
  char          * acl_text = NULL;
  char         ** data_col;
  char         ** data_row;
  static char *text = NULL;

         _pdm_debug("ENTER FUNCTION: PDUend_acl_wf_btn",0);

         FIfld_get_text_length(PDU_form_id, ACL_NAME_FLD, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL_STRING, sizeof (char) * length + 1);
         FIfld_get_text(PDU_form_id, ACL_NAME_FLD, 0, 0, length, 
                        (unsigned char *)text, &select, &pos);
         PDUfill_in_string(&acl_text,text);
         _pdm_debug("acl_text = <%s>", acl_text);

         if ((new_mode == TRUE) || (similar_mode == TRUE))
            {
            FIfld_get_text_length(forms.part_operations_form_id, NP_CATALOG_FLD,
                                  0, 0, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL_STRING, sizeof (char) * length + 1);
            FIfld_get_text(forms.part_operations_form_id, NP_CATALOG_FLD, 0, 0, 
                           length, (unsigned char *)text, &select, &pos);
            PDUfill_in_string1(&np_catalog,text);
            _pdm_debug("np_catalog = <%s>", np_catalog);

            if ((np_catalog == NULL) || (strcmp(np_catalog,"") == 0))
               {
               msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
               return(PDM_I_ENTER_CATALOG);
               }

            status = PDUsetup_buffer_list(PDU_hold_bufr,1,0,&hold_bufr_row,
                                          &hold_bufr_col,&hold_bufr_format,
                                          &hold_attr_bufr);
            _pdm_status("PDUsetup_buffer_list",status);

            if (status != PDM_S_SUCCESS)
               return(status);

            status = PDUget_col_number(hold_attr_bufr,"n_name",hold_bufr_col,
                              &n_name_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            status = PDUget_col_number(hold_attr_bufr,"n_valueno",hold_bufr_col,
                              &n_valueno_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            for (i = 0; i < hold_attr_bufr->rows; ++i)
               {
               if (strcmp(hold_bufr_row[(hold_attr_bufr->columns * i) +
                          n_name_col],"n_aclno") == 0)
                  {
                  list_buffer_no = atoi(hold_bufr_row[(hold_attr_bufr->columns *                                   i) + n_valueno_col]);
                  break;
                  }
               }

            status = PDUsetup_buffer_list(PDU_hold_bufr, 3, list_buffer_no,
                                          &acl_bufr_row,&acl_bufr_col,
                                          &acl_bufr_format,&hold_acl_bufr);
            _pdm_status("PDUsetup_buffer_list",status);

            if (status != PDM_S_SUCCESS)
               return(status);

            if (status == PDM_S_SUCCESS)
               {
               status = PDUget_col_number(hold_acl_bufr,"n_aclname",
                                          acl_bufr_col, &hold_n_aclname_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

               status = PDUget_col_number(hold_acl_bufr,"n_aclno",acl_bufr_col,
                                          &hold_n_aclno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

               for (i = 0; i < hold_acl_bufr->rows; ++i)
                  {
                  if (strcmp(acl_text,acl_bufr_row[(hold_acl_bufr->columns * i)                       + hold_n_aclname_col]) == 0)
                     {
                     break;
                     }
                  }

               if (PDMdebug_on)
                  MEMprint_buffer("PDU_data_bufr before writing acl",
                                  PDU_data_bufr,PDU_DEBUG_FILE);

               status = MEMbuild_array(PDU_data_bufr);
               _pdm_status("MEMbuild_array",status);

               if (status != MEM_S_SUCCESS)
                 {
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 msg = (char *) PDUtranslate_message(status);
                 FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                 return(status);
                 }

               data_col = (char **) PDU_data_bufr->column_ptr;
               data_row = (char **) PDU_data_bufr->data_ptr;

               status = PDUget_col_number(PDU_data_bufr,"n_aclno",data_col,
                                 &n_aclno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

               status = MEMwrite_data(PDU_data_bufr,
                                      acl_bufr_row[(hold_acl_bufr->columns * i)                                       + hold_n_aclno_col],1, n_aclno_col + 1);
               _pdm_status("MEMwrite_data",status);

               if (PDMdebug_on)
                  MEMprint_buffer("PDU_data_bufr after writing acl",
                                  PDU_data_bufr,PDU_DEBUG_FILE);

               if (status != MEM_S_SUCCESS)
                 {
                 status = PDM_E_WRITE_BUFFER;
                 msg = (char *) PDUtranslate_message(status);
                 FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                 return(status);
                 }
               }
            }
         else if ((change_mode == TRUE) || (review_mode == TRUE))
            {
            FIfld_get_text_length(forms.part_operations_form_id, EP_CATALOG_FLD,
                                  0, 0, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL_STRING, sizeof (char) * length + 1);
            FIfld_get_text(forms.part_operations_form_id, EP_CATALOG_FLD, 0, 0, 
                           length, (unsigned char *)text, &select, &pos);
            PDUfill_in_string1(&ep_catalog,text);
            _pdm_debug("ep_catalog = <%s>", ep_catalog);

            FIfld_get_text_length(forms.part_operations_form_id, EP_PARTNUM_FLD,
                                  0, 0, &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL_STRING, sizeof (char) * length + 1);
            FIfld_get_text(forms.part_operations_form_id, EP_PARTNUM_FLD, 0, 0, 
                           length, (unsigned char *)text, &select, &pos);
            PDUfill_in_string1(&en_itemname,text);
            _pdm_debug("en_itemname = <%s>", en_itemname);

            if (((ep_catalog == NULL) || (strcmp(ep_catalog,"") == 0)) &&
               ((en_itemname == NULL) || (strcmp(en_itemname,"") == 0))) 
               {
               msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
               return(PDM_I_ENTER_PART);
               }

            status = PDUsetup_buffer_list(PDU_ep_bufr,1,0,&ep_bufr_row,
                                          &ep_bufr_col,&ep_bufr_format,
                                          &ep_attr_bufr);
            _pdm_status("PDUsetup_buffer_list",status);

            if (status != PDM_S_SUCCESS)
               return(status);

            status = PDUget_col_number(ep_attr_bufr,"n_name",ep_bufr_col,&n_name_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

            status = PDUget_col_number(ep_attr_bufr,"n_valueno",ep_bufr_col,
                              &n_valueno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

            for (i = 0; i < ep_attr_bufr->rows; ++i)
               {
               if (strcmp(ep_bufr_row[(ep_attr_bufr->columns * i) +
                          n_name_col],"n_aclno") == 0)
                  {
                  list_buffer_no = atoi(ep_bufr_row[(ep_attr_bufr->columns *
                                        i) + n_valueno_col]);
                  break;
                  }
               }

           status = PDUsetup_buffer_list(PDU_ep_bufr, 3, list_buffer_no,
                                         &acl_bufr_row, &acl_bufr_col,
                                         &acl_bufr_format,&ep_acl_bufr);
           _pdm_status("PDUsetup_buffer_list",status);

           if (status != PDM_S_SUCCESS)
              return(status);

           if (status == PDM_S_SUCCESS)
              {
              status = PDUget_col_number(ep_acl_bufr,"n_aclname",acl_bufr_col,
                                         &ep_n_aclname_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

              status = PDUget_col_number(ep_acl_bufr,"n_aclno",acl_bufr_col,
                                         &ep_n_aclno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

              for (i = 0; i < ep_acl_bufr->rows; ++i)
                 {
                 if (strcmp(acl_text,acl_bufr_row[(ep_acl_bufr->columns * i)
                     + ep_n_aclname_col]) == 0)
                    {
                    break;
                    }
                 }

               if (PDMdebug_on)
                  MEMprint_buffer("PDU_data_bufr before writing acl",
                                  PDU_data_bufr,PDU_DEBUG_FILE);

              status = MEMbuild_array(PDU_data_bufr);
              _pdm_status("MEMbuild_array",status);

              if (status != MEM_S_SUCCESS)
                 {
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 msg = (char *) PDUtranslate_message(status);
                 FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                 return(status);
                 }

              data_col = (char **) PDU_data_bufr->column_ptr;
              data_row = (char **) PDU_data_bufr->data_ptr;

              status = PDUget_col_number(PDU_data_bufr,"n_aclno",data_col,
                                &n_aclno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return(status);
                 }

               status = MEMwrite_data(PDU_data_bufr,
                                      acl_bufr_row[(ep_acl_bufr->columns * i)
                                      + ep_n_aclno_col],1, n_aclno_col + 1);
               _pdm_status("MEMwrite_data",status);

               if (status != MEM_S_SUCCESS)
                 {
                 status = PDM_E_BUILD_BUFFER_ARRAY;
                 msg = (char *) PDUtranslate_message(status);
                 FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
                 return(status);
                 }

               if (PDMdebug_on)
                  MEMprint_buffer("PDU_data_bufr after writing acl",
                                  PDU_data_bufr,PDU_DEBUG_FILE);
              }
           }
 
   if ((status == PDM_S_SUCCESS) || (status == MEM_S_SUCCESS))
      return(PDM_S_SUCCESS);
   else
      return(status);
}

/* This function is called for PDUep_proj_btn after a project has been selected
   and there is a catalog, part number, and revision. */

int PDUend_ep_proj_btn()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int             length, select, pos;
   static char *text = NULL;

   _pdm_debug("Entering PDUend_ep_proj_btn",0);

   end_ep_proj_btn_flag = FALSE;

   if ((PDU_form_id == ModifyPartForm) || (PDU_form_id == place_part_f))
     return(PDM_S_SUCCESS);

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[0], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_project,text);
   _pdm_debug("ep_project = <%s>", ep_project);

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[2], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&en_itemname,text);
   _pdm_debug("en_itemname = <%s>", en_itemname);

   FIfld_get_text_length(PDU_form_id, PDU_refresh_gadgets[3], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[3], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_rev,text);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) && 
       (strcmp(ep_rev,"") != 0))
      {
      /* Then, if there is a project, send the project, catalog, partnum,
         and revision back to test whether the part is in the project
         (catalog would have already been tested). If not, display error
         message. */

      if (strcmp(ep_project,"") != 0)
         {
         status = PDMpart_in_project(ep_project,ep_catalog,en_itemname,ep_rev);
         _pdm_status("PDMpart_in_project",status);

          if (status == PDM_I_NO_ROWS_FOUND)
             {
             status = PDM_S_SUCCESS;
             }
          else if (status == PDM_S_SUCCESS)
             {
             msg = (char *) PDUtranslate_message(PDM_E_PART_ASSOC_WITH_PROJECT);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
             }
         }
      }

   if (ep_catalog && (!(strlen(ep_catalog))))
     FIfld_pos_cursor(PDU_form_id, PDU_refresh_gadgets[1], 0,0,0,0,0,0);

   return(status);
}

int PDUend_move_to_state_btn()

{
   int       status = PDM_S_SUCCESS;
   int       length, select, pos;
   char    * state_name = NULL;
   static char *text = NULL;
   int       *fn;

   _pdm_debug("ENTER FUNCTION: PDUend_move_to_state_btn",0);

   end_move_to_state_btn_flag = FALSE;

   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("en_itemname = <%s>", en_itemname);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   FIfld_get_text_length(forms.part_operations_form_id, STATE_NAME_FLD, 
                         0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id, STATE_NAME_FLD, 0, 0, 
                  length, (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&state_name,text);
   _pdm_debug("state_name = <%s>", state_name);

   status = PDUmake_transition(state_name);
   _pdm_status("PDUmake_transition", status);

   PDUmessage(status,'s');

   PDUupdate_part_form_change_mode();

   if (PDU_states_bufr)
     {
     MEMclose(&PDU_states_bufr);
     PDU_states_bufr = NULL;
     }

   if (status == PDM_S_SUCCESS)
     {
     fn = (int *)PDMcancel_modify;
     exitdel(fn);
     }

   return(status);
}

/* This function will get the part field data for the part being added or
   changed.*/

int PDUget_part_field_info()

{
   int       status = PDM_S_SUCCESS;
   char      *msg = NULL;
   int      n_itemname_col = 0;
   int      p_rev_col = 0;
   int      p_parttype_col = 0;
   int      n_itemdesc_col = 0;
   int      length, select, pos;
   char  ** data_col;
   static char *text = NULL;

   _pdm_debug("in the function PDUget_part_field_info", 0);

   if ((new_mode == TRUE) || (similar_mode == TRUE))
      {
      _pdm_debug("np_catalog = <%s>", np_catalog);
      _pdm_debug("nn_itemname = <%s>", nn_itemname);
      _pdm_debug("np_rev = <%s>", np_rev);
      _pdm_debug("np_parttype = <%s>", np_parttype);
      _pdm_debug("np_desc = <%s>", np_desc);

      if (!np_desc)
        {
        FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[5],0,0,&length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL_STRING, sizeof (char) * length + 1);
        FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[5], 0, 0, length,
                       (unsigned char *)text, &select, &pos);
        PDUfill_in_string1(&ep_desc,text);
        _pdm_debug("ep_desc = <%s>", ep_desc);

        if (ep_desc && (strlen(ep_desc)))
          {
          _pdm_debug("copying existing desc to new desc", 0);
          PDUfill_in_string(&np_desc, ep_desc);
          FIg_set_text(PDU_form_id, NP_DESC_FLD, np_desc);
          }
        }
      else if (strcmp(np_desc, "") == 0)
        {
        FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[5],0,0,&length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL_STRING, sizeof (char) * length + 1);
        FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[5], 0, 0, length,
                       (unsigned char *)text, &select, &pos);
        PDUfill_in_string1(&ep_desc,text);
        _pdm_debug("ep_desc = <%s>", ep_desc);

        if (ep_desc && (strlen(ep_desc)))
          {
          _pdm_debug("copying existing desc to new desc", 0);
          PDUfill_in_string(&np_desc, ep_desc);
          FIg_set_text(PDU_form_id, NP_DESC_FLD, np_desc);
          }
        }

      status = MEMbuild_array(PDU_data_bufr);
      _pdm_status("MEMbuild_array",status);

      if (status != MEM_S_SUCCESS)
        {
        status = PDM_E_BUILD_BUFFER_ARRAY;
        msg = (char *) PDUtranslate_message(status);
        FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
        return(status);
        }

      data_col = (char **) PDU_data_bufr->column_ptr;

      status = PDUget_col_number(PDU_data_bufr,"n_itemname",data_col,
                                 &n_itemname_col);
      _pdm_status("PDUget_col_number",status);

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(PDU_data_bufr,"n_itemrev",data_col,
                                 &p_rev_col);
      _pdm_status("PDUget_col_number",status);

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

      status = PDUget_col_number(PDU_data_bufr,"p_parttype",data_col,
                                 &p_parttype_col);
      _pdm_status("PDUget_col_number",status);

      if (status != PDM_S_SUCCESS)
         {
         p_parttype_col = -1;
         status = PDM_S_SUCCESS;
         }

      status = PDUget_col_number(PDU_data_bufr,"n_itemdesc",data_col,
                                 &n_itemdesc_col);
      _pdm_status("PDUget_col_number",status);

      if (status != PDM_S_SUCCESS)
         {
         n_itemdesc_col = -1;
         status = PDM_S_SUCCESS;
         }

      if (status == PDM_S_SUCCESS)
         {
         status = MEMwrite_data(PDU_data_bufr,nn_itemname,1,
                                n_itemname_col + 1);
         status = MEMwrite_data(PDU_data_bufr,np_rev,1,p_rev_col + 1);
         if (p_parttype_col != -1)
           status = MEMwrite_data(PDU_data_bufr,np_parttype,1,
                                  p_parttype_col + 1);
         if (n_itemdesc_col != -1)
           {
           _pdm_debug("adding description to buffer", 0);
           if (new_mode)
             status = MEMwrite_data(PDU_data_bufr,np_desc,1,n_itemdesc_col+1);
           else if (similar_mode)
             {
             if (np_desc && (strlen(np_desc)))
               status = MEMwrite_data(PDU_data_bufr,np_desc,1,n_itemdesc_col+1);
             else 
               status = MEMwrite_data(PDU_data_bufr,ep_desc,1,n_itemdesc_col+1);
             }
           }
      
         if (status != MEM_S_SUCCESS)
            return(status);
         }
    
      if (status == MEM_S_SUCCESS)
         status = PDM_S_SUCCESS;
      }
   else if ((change_mode == TRUE) || (review_mode == TRUE))
      {
      _pdm_debug("ep_catalog = <%s>", ep_catalog);
      _pdm_debug("en_itemname = <%s>", en_itemname);
      _pdm_debug("ep_rev = <%s>", ep_rev);
      _pdm_debug("ep_parttype = <%s>", ep_parttype);
      _pdm_debug("ep_desc = <%s>", ep_desc);

      if ((ep_desc) && (strlen(ep_desc) == 0))
         {
         FIfld_get_text_length(PDU_form_id,EP_DESC_FLD, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL_STRING, sizeof (char) * length + 1);
         FIfld_get_text(PDU_form_id, EP_DESC_FLD, 0, 0, length, 
                        (unsigned char *)text, &select, &pos);
         PDUfill_in_string1(&ep_desc,text);
         _pdm_debug("ep_desc = <%s>", ep_desc);
         }

      status = MEMbuild_array(PDU_data_bufr);
      _pdm_status("MEMbuild_array",status);

      if (status != MEM_S_SUCCESS)
        {
        status = PDM_E_BUILD_BUFFER_ARRAY;
        msg = (char *) PDUtranslate_message(status);
        FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
        return(status);
        }

      data_col = (char **) PDU_data_bufr->column_ptr;

      status = PDUget_col_number(PDU_data_bufr,"p_parttype",data_col,
                                 &p_parttype_col);
      if (status == PDM_S_SUCCESS)
         {
         status = MEMwrite_data(PDU_data_bufr,ep_parttype,1,
                                p_parttype_col + 1);
         if (status != MEM_S_SUCCESS)
            return(status);
         }
      else
        status = PDM_S_SUCCESS;

      status = PDUget_col_number(PDU_data_bufr,"n_itemdesc",data_col,
                                 &n_itemdesc_col);
      if (status == PDM_S_SUCCESS)
         {
         status = MEMwrite_data(PDU_data_bufr,ep_desc,1,n_itemdesc_col + 1);
         if (status != MEM_S_SUCCESS)
            return(status);
         }

      if (status == MEM_S_SUCCESS)
         status = PDM_S_SUCCESS;
      }
   return(status);
}

void PDMcancel_modify()

{
   int       status = PDM_S_SUCCESS;
    status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                   PDU_attr_bufr, PDU_data_bufr);
    _pdm_status("PDMcancel_modify_part",status);
}

int PDUupdate_part_form_after_select()

{
   int       status = PDM_S_SUCCESS;
   char      type[5];
   char      *msg = NULL;

   _pdm_debug("ENTERING: PDUupdate_part_form_after_select",0);

   PDU_form_id = forms.part_operations_form_id;

   _pdm_debug("resetting refresh gadgets", 0);
   PDU_refresh_gadgets[0] = EP_PROJECT_FLD;
   PDU_refresh_gadgets[1] = EP_CATALOG_FLD;

   if (refresh->status == PDM_E_CMD_CANCELLED)
     {
     status = PDM_E_CMD_CANCELLED;
     FIf_display(forms.part_operations_form_id);
     PDUmessage(status, 's');
 
     if (review_mode || similar_mode || change_mode)
       {
       _pdm_debug("ep_catalog = <%s>", ep_catalog);
       PDUfill_in_string1(&refresh->rev_catalog, ep_catalog);
       PDUfill_in_string1(&refresh->rev_partid, en_itemname);
       PDUfill_in_string1(&refresh->rev_revision, ep_rev);
       PDUfill_in_string1(&refresh->rev_parttype, ep_parttype);
       PDUfill_in_string1(&refresh->rev_description, ep_desc);
       }
     else if (new_mode)
       {
       _pdm_debug("np_catalog = <%s>", np_catalog);
       PDUfill_in_string1(&refresh->new_catalog, np_catalog);
       PDUfill_in_string1(&refresh->new_partid, nn_itemname);
       PDUfill_in_string1(&refresh->new_revision, np_rev);
       PDUfill_in_string1(&refresh->new_parttype, np_parttype);
       PDUfill_in_string1(&refresh->new_description, np_desc);
       }
     return(status);
     }

   FIf_display(forms.part_operations_form_id);

   if (review_mode || similar_mode || change_mode)
     {
     _pdm_debug("cancelling the previous part", 0);
     if ((strcmp(ep_catalog,"") != 0) && (strcmp(en_itemname,"") != 0) &&
          (strcmp(ep_rev,"") != 0))
         {
         status = PDMcancel_modify_part(ep_catalog, en_itemname, ep_rev,
                                        PDU_attr_bufr, PDU_data_bufr);
         _pdm_status("PDMcancel_modify_part",status);
 
         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return(status);
            }
         }

     _pdm_debug("copying new part to ep fields", 0);
     PDUfill_in_string1(&ep_catalog, refresh->rev_catalog);
     PDUfill_in_string1(&en_itemname, refresh->rev_partid);
     PDUfill_in_string1(&ep_rev, refresh->rev_revision);
     }
   else if (new_mode)
     {
     PDUfill_in_string1(&np_catalog, refresh->rev_catalog);
     PDUfill_in_string1(&nn_itemname, refresh->rev_partid);

     _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
     _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);

     PDUfill_in_string1(&refresh->new_catalog, refresh->rev_catalog);
     PDUfill_in_string1(&refresh->new_partid, refresh->rev_partid);

     FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,refresh->rev_catalog, FALSE);
     FIfld_set_text(PDU_form_id,NP_PARTNUM_FLD,0,0,refresh->rev_partid, FALSE);

     status = PDUprocess_np_catalog();
     _pdm_status("PDUprocess_np_catalog", 0);
     return(status);
     }

   _pdm_debug("Test if catalog is valid for part form",0);
   status = PDMquery_catalog_type(refresh->rev_catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   _pdm_debug("catalog type = <%s>", type);

   if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

   if ((strcmp(type,"CID") == 0) || (strcmp(type,"EID") == 0))
     {
      msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_EID);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      PDUfill_in_string1(&refresh->rev_catalog,NULL_STRING);
      np_catalog = NULL_STRING;
      FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
      PDUmessage(PDM_I_INVALID_CATALOG, 's');
      return(PDM_I_INVALID_CATALOG);
     }

   if ((strcmp(type,"P") == 0) || (strcmp(type,"PXT") == 0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_TRANSFER_PARAM_FORM);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      PDUmessage(PDM_I_TRANSFER_PARAM_FORM, 's');

      sleep(7);
      change_mode = FALSE;
      review_mode = FALSE;

      /* Display the parametric part form */
      PDUparametric_part_form(refresh->rev_catalog);

      return(status);
      }

   if (strcmp(type,"EID") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_EID);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(PDU_form_id,EP_CATALOG_FLD, 0,0,"",FALSE);
      FIfld_pos_cursor(PDU_form_id,EP_CATALOG_FLD,0,0,0,0,0,0);
      return(PDM_I_INVALID_CATALOG);
      }

   if (review_mode || similar_mode || change_mode)
      {
      PDU_form_id = forms.part_operations_form_id;
      _pdm_debug("setting text for new part", 0);
      _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
      _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
      _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
      FIg_set_text(PDU_form_id,PDU_refresh_gadgets[1], refresh->rev_catalog);
      FIg_set_text(PDU_form_id,PDU_refresh_gadgets[2], refresh->rev_partid);
      FIg_set_text(PDU_form_id,PDU_refresh_gadgets[3],refresh->rev_revision);

      _pdm_debug("calling PDMget_pt_desc", 0);
      status = PDMget_pt_desc(refresh->rev_catalog,refresh->rev_partid,
                              refresh->rev_revision);
      _pdm_status("PDMget_pt_desc",status);

      if (status != PDM_S_SUCCESS)
         {
         msg = (char *) PDUtranslate_message(PDM_E_RET_PARTTYPE_DESC);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         return(PDM_E_RET_PARTTYPE_DESC);
         }

      status = PDUpull_pt_desc();
      _pdm_status("PDUpull_pt_desc",status);

      if (status != PDM_S_SUCCESS)
         {
         msg = (char *) PDUtranslate_message(PDM_E_DSP_PARTTYPE_DESC);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         return(PDM_E_DSP_PARTTYPE_DESC);
         }

      status = PDUpull_bufr_info();
      _pdm_status("PDUpull_bufr_info",status);

      if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }
      }

return(status);
}

int PDUprocess_ep_catalog()
{
   int    status = PDM_S_SUCCESS;
   char      *msg = NULL;
   char   type[5];
   int    select, pos, length;
   int    num_rows = 0;
   static char *text = NULL_STRING;

   _pdm_debug("in the function PDUprocess_ep_catalog", 0);

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   /* get the catalog */
   FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[1], 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(PDU_form_id, PDU_refresh_gadgets[1], 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog,text);
   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("refresh->rev_project = <%s>", refresh->rev_project);

   if (PDU_form_id == forms.part_operations_form_id)
     {
     status = PDMquery_catalog_type(ep_catalog,type);
     _pdm_status("PDMquery_catalog_type",status);
  
     if (status != PDM_S_SUCCESS)
        return(status);
  
     _pdm_debug("catalog type = <%s>", type);
  
     if ((strcmp(type,"CID") == 0) || (strcmp(type,"EID") == 0))
       {
        msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_EID);
        FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
        PDUfill_in_string1(&refresh->rev_catalog,NULL_STRING);
        np_catalog = NULL_STRING;
        FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
        PDUmessage(PDM_I_INVALID_CATALOG, 's');
        return(PDM_I_INVALID_CATALOG);
       }

     if ((strcmp(type,"P") == 0) || (strcmp(type,"PXT") == 0))
        {
        msg = (char *) PDUtranslate_message(PDM_I_TRANSFER_PARAM_FORM);
        FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
        PDUfill_in_string1(&refresh->rev_catalog,ep_catalog);
        FIg_set_text(forms.part_operations_form_id,EP_CATALOG_FLD,"");
        PDUmessage(PDM_I_TRANSFER_PARAM_FORM, 's');
        sleep(7);
        change_mode = FALSE;
        review_mode = FALSE;
        similar_mode = FALSE;
  
        /* Erase the part form */
        FIf_erase (forms.part_operations_form_id);
        FIf_delete (forms.part_operations_form_id);
        forms.part_operations_form_id = 0;
  
        /* Display the parametric part form */
        PDUparametric_part_form(refresh->rev_catalog);
        return(PDM_S_SUCCESS);
        }
  
     if (strcmp(type,"EID") == 0)
        {
        msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_EID);
        FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
        FIg_set_text(forms.part_operations_form_id,EP_CATALOG_FLD,"");
        FIfld_pos_cursor(PDU_form_id,EP_CATALOG_FLD,0,0,0,0,0,0);
        _pdm_debug("catalog type = EID; returning 0", 0);
        return(PDM_I_INVALID_CATALOG);
        }
     }
  
   if (change_mode)
     {
     /* allow selection of catalog that is not mapped to project */
     status = PDUvalid_catalog("",ep_catalog);
     _pdm_status("PDUvalid_catalog",status);
     }
   else
     {
     status = PDUvalid_catalog(ep_project,ep_catalog);
     _pdm_status("PDUvalid_catalog",status);
     }

   bufr_flag = FALSE;

   if (status != PDM_S_SUCCESS)
      return(status);

/*
   if ((status == PDM_S_SUCCESS) && (PDU_simmode_cat_bufr == TRUE))
      {
      PDUmessage(PDM_E_CLEAR_FIELD,'s');

      if (PDU_ep_bufr != NULL)
         {
         MEMclose(&PDU_ep_bufr);
         PDU_ep_bufr = NULL;
         }

      MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_ep_bufr,1);
      }
*/

   PDUmessage(PDM_E_CLEAR_FIELD,'s');
  
   _pdm_debug("writing to refresh", 0);
   PDUfill_in_string1(&refresh->rev_catalog,ep_catalog);

   /* Set cursor to the part number field */
   if (PDU_form_id != forms.bom_contents_form_id)
      FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[2],0,0,0,0,0,0);

   if (similar_mode && PDU_simmode_copy)
     {
     _pdm_debug("resetting simmode copy area", 0);
     FIg_set_state_off(PDU_form_id, SIMMODE_COPY_TGL);
     FIg_disable(PDU_form_id, SIMMODE_COPY_TGL);

     FIg_set_state_off(PDU_form_id, SIMMODE_CHECKIN_TGL);
     FIg_erase(PDU_form_id, SIMMODE_CHECKIN_TGL);

     FIfld_get_num_rows(PDU_form_id, SIMILAR_MODE_MCF, &num_rows);
     PDUremove_data(PDU_form_id, SIMILAR_MODE_MCF, num_rows, 5);
     }

   return(status);
}

int PDUprocess_np_catalog()
{
   int    status = PDM_S_SUCCESS;
   char      *msg = NULL;
   char   type[5];
   int    select, pos, length;
   static char *text = NULL_STRING;
   Form    form;
   char    **data_col;
   int     n_cofilenm_col = 0;
   int     n_cifilenm_col = 0;
   int     n_filetype_col = 0;
   short   update = 1;
   short   read = 1;
   short   write = 1;

   form = forms.part_operations_form_id;

   _pdm_debug("in the function PDUprocess_np_catalog", 0);

   /* get the catalog */
   FIfld_get_text_length(form,NP_CATALOG_FLD, 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(form, NP_CATALOG_FLD, 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog = <%s>", np_catalog);
   _pdm_debug("refresh->new_project = <%s>", refresh->new_project);

   status = PDMquery_catalog_type(np_catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   _pdm_debug("catalog type = <%s>", type);

   if ((strcmp(type,"CID") == 0) || (strcmp(type,"EID") == 0))
     {
      msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_EID);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      PDUfill_in_string1(&refresh->rev_catalog,NULL_STRING);
      np_catalog = NULL_STRING;
      FIfld_set_text(form,NP_CATALOG_FLD,0,0,"",FALSE);
      PDUmessage(PDM_I_INVALID_CATALOG, 's');
      return(PDM_I_INVALID_CATALOG);
     }

   if ((strcmp(type,"P") == 0)|| (strcmp(type,"PXT") == 0))
      {
      msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_P);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      PDUfill_in_string1(&refresh->rev_catalog,np_catalog);
      FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
      PDUmessage(PDM_I_TRANSFER_PARAM_FORM, 's');

      sleep(7);
      new_mode = FALSE;

      /* Erase the displayed form */
      FIf_erase (form);
      FIf_delete (form);
      forms.part_operations_form_id = 0;

      /* Display the parametric part form */
      PDUparametric_part_form(refresh->rev_catalog);
      
      return(status);
      }

   if (strcmp(type,"EID") == 0)
      {
      msg = (char *) PDUtranslate_message(PDM_E_CATALOG_TYPE_EID);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      FIfld_set_text(form,NP_CATALOG_FLD,0,0,"",FALSE);
      FIfld_pos_cursor(form,NP_CATALOG_FLD,0,0,0,0,0,0);
      _pdm_debug("catalog type is EID, returning 0", 0);
      return(0);
      }

   bufr_flag = TRUE;

   if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

   status = PDUvalid_catalog(refresh->new_project,np_catalog);
   _pdm_status("PDUvalid_catalog",status);

   bufr_flag = FALSE;

   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
      np_catalog = NULL_STRING;
      refresh->new_catalog = NULL_STRING;
      /*if (similar_mode == TRUE)*/
         FIfld_pos_cursor(form,NP_CATALOG_FLD,0,0,0,0,0,0);
      return(status);
      }

   /* Update the refresh structure */
   PDUfill_in_string1(&refresh->new_catalog,np_catalog);

   if (PDU_hold_bufr != NULL)
      {
      MEMclose(&PDU_hold_bufr);
      PDU_hold_bufr = NULL;
      } 

   MEMsplit_copy_buffer(PDU_ret_bufr,&PDU_hold_bufr,1);

   pt_flag = TRUE;

   status = PDUpull_bufr_info_for_np();
   _pdm_status("PDUpull_bufr_info_for_np",status);
 
   if (status != PDM_S_SUCCESS)
      {
      FIfld_set_text(PDU_form_id,NP_CATALOG_FLD,0,0,"",FALSE);
      PDUmessage(status, 's');
      return(status);
      }

   if (strcmp(np_catalog,"pdmlibraries") == 0)
      {
      FIg_set_text(forms.part_operations_form_id,NP_PARTTYPE_FLD,"M");
      PDUfill_in_string1(&np_parttype, "M");
      PDUfill_in_string1(&refresh->new_parttype,np_parttype);
      FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);
      FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
      return(PDM_S_SUCCESS);
      }

   if (strcmp(np_catalog,"pdmseedfiles") == 0)
      {
      FIg_set_text(forms.part_operations_form_id,NP_PARTTYPE_FLD,"G");
      PDUfill_in_string1(&np_parttype, "G");
      PDUfill_in_string1(&refresh->new_parttype,np_parttype);
      FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,0,0);
      return(PDM_S_SUCCESS);
      }

   status = PDUcheck_for_np_defaults(PDU_data_bufr);
   _pdm_status("PDUcheck_for_np_defaults", status);
   if (status != PDM_S_SUCCESS)
     _pdm_debug("error checking for defaults for np_catalog", 0);
     
   _pdm_debug("np_parttype = <%s>", np_parttype);
   if ((strcmp(np_parttype, "N") == 0) || (strcmp(np_parttype, "n") == 0))
     {
      _pdm_debug("entering case for parttype = N", 0);

      msg = (char *) PDUtranslate_message(PDM_E_ADD_FILES_NG_PART);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);

      FIfld_set_text(forms.part_operations_form_id,FILE_INFO_MCF,0,0,"",FALSE);
      FIfld_set_text(forms.part_operations_form_id,FILE_INFO_MCF,0,1,"",FALSE);
      FIfld_set_text(forms.part_operations_form_id,FILE_INFO_MCF,0,2,"",FALSE);

      /*FIg_erase(PDU_form_id,FILE_INFO_BEZ);*/
      FIg_erase(PDU_form_id,FILE_INFO_GRP);
      FIg_erase(PDU_form_id,NEW_FILE_TXT);
      FIg_erase(PDU_form_id,EXISTING_FILE_TXT);

      /* Blank out the fields in the data buffer */
      status = MEMbuild_array(PDU_data_bufr);
      _pdm_status("MEMbuild_array",status);

      if (status != MEM_S_SUCCESS)
         {
         status = PDM_E_BUILD_BUFFER_ARRAY;
         msg = (char *) PDUtranslate_message(status);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
         PDUmessage(status, 's');
         return(status);
         }

      data_col = (char **) PDU_data_bufr->column_ptr;

      status = PDUget_col_number(PDU_data_bufr,"n_cofilename",data_col,
                        &n_cofilenm_col);
      if (status == PDM_S_SUCCESS)
        {
        status=MEMwrite_data(PDU_data_bufr,"",1,n_cofilenm_col+1);
        _pdm_status("MEMwrite_data",status);
        _pdm_debug("AFTER THE MEMwrite_data for cofile",0);
  
        if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_WRITE_BUFFER;
           msg = (char *) PDUtranslate_message(status);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
           }
        }
  
      status = PDUget_col_number(PDU_data_bufr,"n_cifilename",data_col,
                        &n_cifilenm_col);
      if (status == PDM_S_SUCCESS)
        {
        status=MEMwrite_data(PDU_data_bufr,"",1,n_cifilenm_col+1);
        _pdm_status("MEMwrite_data",status);
        _pdm_debug("AFTER THE MEMwrite_data for cifile",0);
  
        if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_WRITE_BUFFER;
           msg = (char *) PDUtranslate_message(status);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
           }
        }

      status = PDUget_col_number(PDU_data_bufr,"n_filetype",data_col,
                        &n_filetype_col);
      if (status == PDM_S_SUCCESS)
        {
        status=MEMwrite_data(PDU_data_bufr,"",1,n_filetype_col+1);
        _pdm_status("MEMwrite_data",status);
        _pdm_debug("AFTER THE MEMwrite_data for filetype",0);
  
        if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_WRITE_BUFFER;
           msg = (char *) PDUtranslate_message(status);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
           }
        }
     }
   else if ((strcmp(np_parttype, "G") == 0) || (strcmp(np_parttype, "g") == 0))
     {
     if (similar_mode != TRUE)
        {
        FIg_display(forms.part_operations_form_id,FILE_INFO_GRP);
        FIg_display(forms.part_operations_form_id,NEW_FILE_TXT);
        /*FIg_display(forms.part_operations_form_id,FILE_INFO_BEZ);*/
        }
     else if (similar_mode)
        {
        FIg_display(PDU_form_id,SIMILAR_MODE_GRP);
        FIg_display(PDU_form_id,SIMMODE_COPY_TGL);
        FIg_display(PDU_form_id,NEW_FILE_TXT);
        FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);
        if ((ep_parttype) && ((strcmp(ep_parttype, "N") == 0) ||
           (strcmp(ep_parttype, "n") == 0)))
          FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
        }
     }

   status = PDUcheck_parttype_privileges(PDU_attr_bufr, &update, &read, &write);
   _pdm_status("PDUcheck_parttype_privileges", status);
   if (status != PDM_S_SUCCESS)
     _pdm_debug("error checking parttype privs for np_catalog", 0);

   if (!write)
     {
     _pdm_debug("parttype is NO WRITE", 0);
     FIg_disable(form, NP_PARTTYPE_FLD);
     FIg_disable(form, NP_PARTTYPE_BTN);

     if (similar_mode && (ep_catalog) && (strcmp(ep_catalog, np_catalog) == 0))
       {
       _pdm_debug("disabling EP fields for similar mode", 0);
       FIg_disable(form, EP_PARTTYPE_FLD);
       FIg_disable(form, EP_PARTTYPE_BTN);
       }
     }
     
   FIfld_get_text_length(form,NP_CATALOG_FLD, 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(form, NP_CATALOG_FLD, 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog (before pos_cursor) = <%s>", np_catalog);

/*   if (PDU_func_bufr_exists == FALSE) */
      FIfld_pos_cursor(PDU_form_id,NP_PARTNUM_FLD,0,0,0,0,1,1);

   FIfld_get_text_length(form,NP_CATALOG_FLD, 0, 0, &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL_STRING, sizeof (char) * length + 1);
   FIfld_get_text(form, NP_CATALOG_FLD, 0, 0, length, 
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog,text);
   _pdm_debug("np_catalog (after pos_cursor) = <%s>", np_catalog);

  return(status);
}

int PDUprocess_ep_rev_btn()
{
  int   status = PDM_S_SUCCESS;

      _pdm_debug("in the function PDUprocess_ep_rev_btn", 0);

      if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }

      end_ep_rev_btn_flag = TRUE;
      pt_flag = TRUE;

      status = PDMrev_listing(ep_catalog,en_itemname);
      _pdm_status("PDMrev_listing",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      PDUsetup_single_buffer(PDU_ret_bufr);

      if (PDU_form_id == forms.part_operations_form_id)
         PDU_gadget_labels[0] = EP_REV_FLD;

      if (PDU_form_id == forms.seed_form_form_id)
         PDU_gadget_labels[0] = NFC_REV_FLD;

      if (PDU_form_id == forms.local_files_form_id)
         PDU_gadget_labels[0] = PART_REV_FLD;

      if (PDU_form_id == forms.ex_file_form_id)
         PDU_gadget_labels[0] = EX_REVISION_FLD;

      if (PDU_form_id == forms.report_form_id)
         PDU_gadget_labels[0] = REVISION_NAME;

      if (PDU_form_id == forms.topdown_form_id)
         PDU_gadget_labels[0] = TD_REVISION;

      if (PDU_form_id == forms.where_used_form_id)
         PDU_gadget_labels[0] = W_REVISION;

      PDU_update_struct[0] = &refresh->rev_revision;

      all_flag = TRUE;
      no_headings = 1;
      headings = (char **) malloc (sizeof (char *) * no_headings);
      memset(headings, NULL, sizeof (char *) * no_headings);

      PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

      PDUfree_string_array(&headings, no_headings);

      status = PDUsingle_list_form();
      _pdm_status("PDUsingle_list_form",status);

      if (single_flag == TRUE)
         {
         single_flag = FALSE;
         return(PDM_S_SUCCESS);
         }

      if (status == PDM_S_SUCCESS)
         return(0);

  return(status);
}


int PDUpull_pt_desc_for_rev()

{
   int       status = PDM_S_SUCCESS;
char   ** data_row;
int       p_parttype_col;
int       n_itemdesc_col;
int       row = 0;
int       rev_col = 0;
char   *revision = NULL;

   _pdm_debug("Entering PDUpull_pt_desc_for_rev",0);

   _pdm_debug("resetting PDU_ret_bufr with part info", 0);

       if (PDU_ret_bufr)
         {
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         }
       if (PDU_display_buffer)
         {
         status = MEMsplit_copy_buffer(PDU_display_buffer, &PDU_ret_bufr, 0);
         _pdm_status("MEMsplit_copy_buffer", status);
         if (status != MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_COPY_BUFFER, 's');
           return(PDM_E_COPY_BUFFER);
           }
         MEMclose(&PDU_display_buffer);
         PDU_display_buffer = NULL;
         }
       else
         _pdm_debug("PDU_display_buffer = NULL!!!", 0);

   MEMbuild_array(PDU_ret_bufr);

   PDUsetup_buffer(PDU_ret_bufr,ROW,&data_row);

   status = PDUget_buffer_col(PDU_ret_bufr,"n_itemrev", &rev_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   status = PDUget_buffer_col(PDU_ret_bufr,"p_parttype", &p_parttype_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   status = PDUget_buffer_col(PDU_ret_bufr,"n_itemdesc", &n_itemdesc_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return(status);
        }

   PDUfill_in_string1(&ep_rev, refresh->rev_revision);
   _pdm_debug("ep_rev = <%s>", ep_rev);

   for (row = 0; row < PDU_ret_bufr->rows; ++row)
      {
      PDUfill_in_string(&revision,
                        data_row[(PDU_ret_bufr->columns * row) + rev_col]);
      if (strcmp(revision, ep_rev) == 0)
        {
        FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,
                  data_row[(PDU_ret_bufr->columns * row) +
                  p_parttype_col],FALSE);
        FIfld_set_text(PDU_form_id,PDU_refresh_gadgets[5],0,0,
                  data_row[(PDU_ret_bufr->columns * row) +
                  n_itemdesc_col],FALSE);

         PDUfill_in_string(&refresh->rev_description,
                   data_row[(PDU_ret_bufr->columns * row) + n_itemdesc_col]);
         PDUfill_in_string1(&ep_desc,
                   data_row[(PDU_ret_bufr->columns * row) + n_itemdesc_col]);
         PDUfill_in_string(&refresh->rev_parttype,
                   data_row[(PDU_ret_bufr->columns * row) + p_parttype_col]);
         PDUfill_in_string1(&ep_parttype,
                   data_row[(PDU_ret_bufr->columns * row) + p_parttype_col]);
         }
      }
   return(status);
}

int PDUend_ep_rev_btn()
{
   int  status = PDM_S_SUCCESS;
   char *msg = NULL;

   _pdm_debug("in the function PDUend_ep_rev_btn", 0);

   PDUfill_in_string1(&ep_rev, refresh->rev_revision);

   status = PDMget_pt_desc(ep_catalog,en_itemname,ep_rev);
   _pdm_status("PDMget_pt_desc",status);

   if (status != PDM_S_SUCCESS)
      {
      status = PDM_E_RET_PARTTYPE_DESC;
      msg = (char *) PDUtranslate_message(PDM_E_RET_PARTTYPE_DESC);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      return(status);
      }

    status = PDUpull_pt_desc();
    _pdm_status("PDUpull_pt_desc",status);

   if (status != PDM_S_SUCCESS)
      {
      status = PDM_E_DSP_PARTTYPE_DESC;
      msg = (char *) PDUtranslate_message(PDM_E_DSP_PARTTYPE_DESC);
      FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
      return(status);
      }

   return(status);
}

int PDUcheck_for_np_defaults(data_bufr)
MEMptr   data_bufr;
{
   int   status = PDM_S_SUCCESS;
   int   rev_col = 0;
   int   desc_col = 0;
   int   parttype_col = 0;
   int   column = 0;
   char  *string = NULL;
   char  **data_row;
   char  *revision = NULL;
   char  *desc = NULL;
   char  *parttype = NULL;

   _pdm_debug("in the function PDUcheck_for_np_defaults", 0);

   if (!data_bufr)
     return(PDM_E_NULL_BUFFER);

   _pdm_debug("checking for defaulted revision", 0);
   MEMbuild_array(data_bufr);
   PDUsetup_buffer(data_bufr, ROW, &data_row);
   status = PDUget_buffer_col(data_bufr, "n_itemrev", &rev_col);
   if (status == PDM_S_SUCCESS)
     {
     PDUfill_in_string(&revision, data_row[(data_bufr->columns*0)+rev_col]);
     if ((revision != NULL) && (strcmp(revision, "") != 0))
       {
       _pdm_debug("default revision = <%s>", revision);
       PDUfill_in_string(&refresh->new_revision, revision);
       PDUfill_in_string(&np_rev, revision);
       FIg_set_text(PDU_form_id, NP_REV_FLD, refresh->new_revision);
       }
     else
       _pdm_debug("revision is not defaulted", 0);
     }
   else
     {
     _pdm_debug("revision column is not in buffer", 0);
     _pdm_debug("setting revision field to review mode", 0);
     FIg_disable(PDU_form_id, NP_REV_FLD);
     }

   _pdm_debug("checking for defaulted description", 0);
   MEMbuild_array(data_bufr);
   PDUsetup_buffer(data_bufr, ROW, &data_row);
   status = PDUget_buffer_col(data_bufr, "n_itemdesc", &desc_col);
   if (status == PDM_S_SUCCESS)
     {
     PDUfill_in_string(&desc, data_row[(data_bufr->columns*0)+desc_col]);
     if ((desc != NULL) && (strcmp(desc, "") != 0))
       {
       _pdm_debug("default desc = <%s>", desc);
       PDUfill_in_string(&refresh->new_description, desc);
       PDUfill_in_string(&np_desc, desc);
       FIg_set_text(PDU_form_id, NP_DESC_FLD, refresh->new_description);
       }
     else
       _pdm_debug("description is not defaulted", 0);
     }
   else
     {
     _pdm_debug("description column is not in buffer", 0);
     _pdm_debug("setting desc field to review mode", 0);
     FIg_disable(PDU_form_id, NP_DESC_FLD);
     }

   _pdm_debug("checking for defaulted filetype", 0);
   MEMbuild_array(data_bufr);
   PDUsetup_buffer(data_bufr, ROW, &data_row);
   status = PDUget_buffer_col(data_bufr, "n_filetype", &column);
   if (status == PDM_S_SUCCESS)
     {
     PDUfill_in_string(&string, data_row[(data_bufr->columns*0)+column]);
     if ((string != NULL) && (strcmp(string, "") != 0))
       {
       _pdm_debug("default filetype = <%s>", string);
       if (new_mode)
         FIfld_set_text(PDU_form_id, FILE_INFO_MCF, 0, 3, string, FALSE);
       else if (similar_mode)
         FIfld_set_text(PDU_form_id, SIMILAR_MODE_MCF, 0, 4, string, FALSE);
       }
     else
       _pdm_debug("filetype is not defaulted", 0);
     }
   else
     {
     _pdm_debug("filetype column is not in buffer", 0);
     }

   _pdm_debug("checking for defaulted filedesc", 0);
   MEMbuild_array(data_bufr);
   PDUsetup_buffer(data_bufr, ROW, &data_row);
   status = PDUget_buffer_col(data_bufr, "p_filedesc", &column);
   if (status == PDM_S_SUCCESS)
     {
     PDUfill_in_string(&string, data_row[(data_bufr->columns*0)+column]);
     if ((string != NULL) && (strcmp(string, "") != 0))
       {
       _pdm_debug("default filedesc = <%s>", string);
       FIfld_set_text(PDU_form_id, FILE_INFO_MCF, 0, 0, string, FALSE);
       }
     else
       _pdm_debug("filedesc is not defaulted", 0);
     }
   else
     {
     _pdm_debug("filedesc column is not in buffer", 0);
     }

   _pdm_debug("checking for default parttype", 0);
   MEMbuild_array(data_bufr);
   PDUsetup_buffer(data_bufr, ROW, &data_row);
   status = PDUget_buffer_col(data_bufr, "p_parttype", &parttype_col);
   if (status == PDM_S_SUCCESS)
     {
     PDUfill_in_string(&parttype, data_row[(data_bufr->columns*0)+parttype_col]);
     if ((parttype != NULL) && (strcmp(parttype, "") != 0))
       {
       _pdm_debug("default parttype = <%s>", parttype);
       PDUfill_in_string(&refresh->new_parttype, parttype);
       PDUfill_in_string(&np_parttype, parttype);
       FIg_set_text(PDU_form_id, NP_PARTTYPE_FLD, refresh->new_parttype);
       }
     else
       _pdm_debug("parttype is not defaulted", 0);
     }
   else
     {
     _pdm_debug("parttype column is not in buffer", 0);
     _pdm_debug("setting desc field to review mode", 0);
     FIg_disable(PDU_form_id, NP_PARTTYPE_BTN);
     FIg_disable(PDU_form_id, NP_PARTTYPE_FLD);
     }

   if (string) free(string);
   if (revision) free(revision);
   if (desc) free(desc);
   if (parttype) free(parttype);

   return(status);
}

int PDUcheck_parttype_for_update(attr_bufr)
MEMptr   attr_bufr;
{
  int  status = PDM_S_SUCCESS;
  int  attr_row = 0;
  int  update_col = 0;
  char *update = NULL;
  char **data_row;

  _pdm_debug("in the function PDUcheck_parttype_for_update", 0);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(attr_bufr, ROW, &data_row);

  attr_row = PDUfind_attr_in_buffer(attr_bufr, "p_parttype");
  if (attr_row != -1)
    {
    status = PDUget_buffer_col(attr_bufr, "n_update", &update_col);
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }
    PDUfill_in_string(&update,
           data_row[(attr_bufr->columns * attr_row)+update_col]);
    _pdm_debug("update = <%s>", update);
    if (strcmp(update, "N") == 0)
      {
      _pdm_debug("parttype is NO UPDATE", 0);
      if (update)
        free(update);
      return(0);
      }
    else
      {
      _pdm_debug("parttype is UPDATABLE", 0);
      if (update)
        free(update);
      return(1);
      }
    }
  else
    {
    _pdm_debug("parttype not found in attr_bufr", 0);
    return(1);
    }
}

void PDUcleanup_attr_retrieval()
{
	 PDUenable_part_form_gadgets();

         PDUfill_in_string1(&en_itemname,"");
         PDUfill_in_string1(&ep_rev,"");
         PDUfill_in_string1(&ep_parttype,"");
         PDUfill_in_string1(&ep_desc,"");

         PDUfill_in_string1(&refresh->rev_partid,"");
         PDUfill_in_string1(&refresh->rev_revision,"");
         PDUfill_in_string1(&refresh->rev_parttype,"");
         PDUfill_in_string1(&refresh->rev_description,"");

         FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0,"",FALSE);
         FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0,"",FALSE);
         FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0,"",FALSE);
         FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0,"",FALSE);

         FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);

         return;
}
