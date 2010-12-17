#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <PDUerror.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUforms.h>
#include "PDUform_def.h"
#include <MEMerrordef.h>
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "exdef.h"


/* Gadgets */

#define GROUP1        15
#define PARTS_IN_OS   16
#define PLACE_OPT     17
#define GROUP2        21


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

extern struct PDUforms forms;
extern struct PDUrefresh *refresh;
extern Form   PDU_calling_form;
extern struct PDUlist_parts_info *PDU_list_parts_info;
extern MEMptr PDU_design_parts_bufr;
extern char *PDU_to_usageid;
extern char *PDU_usage_id;
extern char *PDU_assy_catalog;
extern char *PDU_assy_partid;
extern char *PDU_assy_revision;
extern int PDU_command;
extern int PDU_selected_rows;
extern short PDU_list_parts;
extern short PDU_attach;

extern int PDU_design_listing_form_displayed;

int design_parts_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             length;
  int             select;
  int             pos;
  int             status;
  static   char   *text;
  int             i, row;
  int             num_rows;
  int             sel_flag;
  int             act_row;
  int             act_pos;
  int             responses[1];
  char            *strings[1];
  char		  *msg;

  _pdm_debug("design_parts_notification_routine", 0);
  switch ( g_label )
  {

    case PARTS_IN_OS:     /* Member of group GROUP1  */
                             /* Sequenced to    */
         if (PDU_command == PDC_M_POSITION_PARTS)
           {
           FIfld_get_active_row(fp, PARTS_IN_OS, &act_row, &act_pos);
           FIfld_get_select(fp, PARTS_IN_OS, act_row, 0, &sel_flag);
           if (sel_flag)
             {
             FIg_enable(fp, PLACE_OPT);
             FImcf_set_active_col(fp, PARTS_IN_OS, 0,0);
             FIfld_get_text_length(fp,PARTS_IN_OS,act_row,0,&length);
             text = (char *) malloc (sizeof (char) * length + 1);
             memset(text, NULL, sizeof (char) * length + 1);
             FIfld_get_text(fp,PARTS_IN_OS,act_row,0,length,
                            (unsigned char*)text,&select,&pos);
             PDUfill_in_string(&refresh->rev_catalog, text);

             FImcf_set_active_col(fp, PARTS_IN_OS, 4,4);
             FIfld_get_text_length(fp,PARTS_IN_OS,act_row,4,&length);
             text = (char *) malloc (sizeof (char) * length + 1);
             memset(text, NULL, sizeof (char) * length + 1);
             FIfld_get_text(fp,PARTS_IN_OS,act_row,4,length,
                            (unsigned char*)text,&select,&pos);
             PDUfill_in_string(&PDU_usage_id, text);

             status = PDUretrieve_placement_attrs(PDU_usage_id);
             _pdm_status("PDUretrieve_placement_attrs", status);
             PDU_attach = TRUE;
             }
           else
             FIg_disable(fp, PLACE_OPT);
           }
         break;

    case PLACE_OPT:    

         FIg_set_state_off(fp, PLACE_OPT);
         PDU_calling_form = forms.design_parts_form_id;

         /*status = PDUretrieve_placement_attrs(PDU_usage_id);
         _pdm_status("PDUretrieve_placement_attrs", status);*/

         status = PDUdesign_options_form();
         _pdm_status("PDUdesign_options_form", status);

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         PDU_list_parts = FALSE;
         FIf_delete ( fp );
         FIf_display ( forms.design_form_id );

         PDU_design_listing_form_displayed = FALSE;
         responses[0] = RESET;
         strings[0] = "",
         PDUprepare_queue(responses, strings, 1);

         break;

    case FI_CVT_TO_PERM_WIN:

         break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         value = 0.0;
         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("list_form");

         break;

    case FI_EXECUTE:

          FIfld_get_num_rows(fp, PARTS_IN_OS, &num_rows);
          sel_flag = FALSE;
          for (i = 0; i < num_rows; i++)
            {
            row = i;
            FIfld_get_select(fp, PARTS_IN_OS, row, 0, &sel_flag);
            if (sel_flag)
              {
              _pdm_debug("row = <%d>", (char *)i);
              break;
              }
            }

          if (!sel_flag)
            {
            msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          status = PDUload_list_parts_info();
          _pdm_status("PDUload_list_parts_info", status);

         FIf_cvrt_to_perm_win(forms.design_parts_form_id);

          /* Process form data */
         responses[0] = MOVE_ON;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          _pdm_debug("case FI_ACCEPT",0);
          FIfld_get_num_rows(fp, PARTS_IN_OS, &num_rows);
          sel_flag = FALSE;
          for (i = 0; i < num_rows; i++)
            {
            row = i;
            FIfld_get_select(fp, PARTS_IN_OS, row, 0, &sel_flag);
            if (sel_flag)
              {
              if (i == 0)
                _pdm_debug("selected row = <%d>", 0);
              else
               _pdm_debug("selected row = <%d>", (char *)i);
              break;
              }
            }

          if (!sel_flag)
            {
            msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          status = PDUload_list_parts_info();
          _pdm_status("PDUload_list_parts_info", status);

          /* Erase the displayed form */

         if (PDU_command == PDC_M_POSITION_PARTS)
         {
         if ((PDU_to_usageid) && (strcmp(PDU_to_usageid, "") != 0))
           PDUfill_in_string(&PDU_to_usageid, NULL);
         PDUfill_in_string(&PDU_to_usageid, PDU_usage_id);
         _pdm_debug("to usageid = <%s>", PDU_to_usageid);
         }

         FIf_delete ( fp );
         PDU_design_listing_form_displayed = FALSE;

          /* Process form data */
         responses[0] = MOVE_ON;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int design_parts_listing_form()
{
  int  status;
  short  flag;
  struct PDUlist_parts_info *head;

 status = FIf_new(DESIGN_PARTS_FORM, "design_listing",
                design_parts_notification_routine,
                &forms.design_parts_form_id);

  PDU_selected_rows = 0;
  if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
    PDUfill_in_string(&PDU_usage_id, NULL);

  /*if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    PDUfill_in_string(&refresh->rev_catalog, NULL);

  if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
    PDUfill_in_string(&refresh->rev_partid, NULL);

  if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
    PDUfill_in_string(&refresh->rev_revision, NULL);*/

  if ((PDU_assy_catalog) && (strcmp(PDU_assy_catalog, "") != 0))
    PDUfill_in_string(&PDU_assy_catalog, NULL);

  if ((PDU_assy_partid) && (strcmp(PDU_assy_partid, "") != 0))
    PDUfill_in_string(&PDU_assy_partid, NULL);

  if ((PDU_assy_revision) && (strcmp(PDU_assy_revision, "") != 0))
    PDUfill_in_string(&PDU_assy_revision, NULL);

  if (PDU_design_parts_bufr)
    MEMclose(&PDU_design_parts_bufr);

  if (PDU_command == PDC_M_ATTACH_PART)
    flag = 1;
  else if (PDU_command == PDC_M_DETACH_PART)
    flag = 2;
  else if (PDU_command == PDC_M_POSITION_PARTS)
    flag = 3;
  else if (PDU_command == PDC_M_CREATE_TOP_DOWN)
    flag = 4;
    /* ALR  1/3/93   Added flag for checking highlight of positionless parts */ 
  else if (PDU_command == PDC_M_LOCATE_REV_PRTS)
    flag = 5;
  else 
    flag = 0;

  if (PDU_command != PDC_M_POSITION_PARTS)
    FIg_erase(forms.design_parts_form_id, PLACE_OPT);
  else
    FIg_disable(forms.design_parts_form_id, PLACE_OPT);

  _pdm_debug("flag = <%d>", (char *)flag);
  status = PDUlist_all_parts_in_os(flag, &PDU_design_parts_bufr);
  _pdm_status("PDUlist_all_parts_in_os", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUlist_all_parts_in_os failed", 0);
      return(status);
     }

  status = PDUload_design_parts_listing_form();
  _pdm_status("PDUload_design_parts_listing_form", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* Free PDU_list_parts_info */
  if (PDU_list_parts_info)
     {
      head = PDU_list_parts_info;

      while (PDU_list_parts_info)
            {
             PDU_list_parts_info = PDU_list_parts_info->next;
             free(head);
             head = PDU_list_parts_info;
            }
     }

  PDU_list_parts_info = NULL;

  if ((PDU_command == PDC_M_REPLACE_PART) || 
       (PDU_command == PDC_M_REPLACE_PPART) ||
       (PDU_command == PDC_M_COPY_PART_PTR) ||
       (PDU_command == PDC_M_COPY_PPART) ||
       (PDU_command == PDC_M_POSITION_PARTS) ||
       (PDU_command == PDC_M_LOCATE_REV_PRTS) )
    {
   FIfld_set_mode(forms.design_parts_form_id, PARTS_IN_OS, 0, FI_SINGLE_SELECT);
   FIfld_set_mode(forms.design_parts_form_id, PARTS_IN_OS, 1, FI_SINGLE_SELECT);
   FIfld_set_mode(forms.design_parts_form_id, PARTS_IN_OS, 2, FI_SINGLE_SELECT);
   FIfld_set_mode(forms.design_parts_form_id, PARTS_IN_OS, 3, FI_SINGLE_SELECT);
   FIfld_set_mode(forms.design_parts_form_id, PARTS_IN_OS, 4, FI_SINGLE_SELECT);
    }
  status = FIf_display(forms.design_parts_form_id);
 
  PDU_design_listing_form_displayed = TRUE;

  return(status);

}

int PDUdesign_parts_listing_form()

{
  int status;

  status = design_parts_listing_form();
  _pdm_status("design_parts_listing_form", status);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
 }

int PDUupdate_design_parts_listing_form()

  {
  int status;
  int flag;
  struct PDUlist_parts_info *head;
  
  _pdm_debug("In PDUupdate_design_parts_listing_form", 0);
  
  if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
    PDUfill_in_string(&PDU_usage_id, NULL);

  /*if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    PDUfill_in_string(&refresh->rev_catalog, NULL);

  if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
    PDUfill_in_string(&refresh->rev_partid, NULL);

  if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
    PDUfill_in_string(&refresh->rev_revision, NULL);*/

  if ((PDU_assy_catalog) && (strcmp(PDU_assy_catalog, "") != 0))
    PDUfill_in_string(&PDU_assy_catalog, NULL);

  if ((PDU_assy_partid) && (strcmp(PDU_assy_partid, "") != 0))
    PDUfill_in_string(&PDU_assy_partid, NULL);

  if ((PDU_assy_revision) && (strcmp(PDU_assy_revision, "") != 0))
    PDUfill_in_string(&PDU_assy_revision, NULL);

  if (PDU_design_parts_bufr)
    MEMclose(&PDU_design_parts_bufr);

  if (PDU_command == PDC_M_ATTACH_PART)
    flag = 1;
  else if (PDU_command == PDC_M_DETACH_PART)
    flag = 2;
  else if (PDU_command == PDC_M_POSITION_PARTS)
    flag = 3;
  else 
    flag = 0;

  if (PDU_command != PDC_M_POSITION_PARTS)
    FIg_erase(forms.design_parts_form_id, PLACE_OPT);

  _pdm_debug("flag = <%d>", (char *)flag);
  status = PDUlist_all_parts_in_os(flag, &PDU_design_parts_bufr);
  _pdm_status("PDUlist_all_parts_in_os", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUlist_all_parts_in_os failed", 0);
      return(status);
     }

  FIg_reset(forms.design_parts_form_id, PARTS_IN_OS);

  status = PDUload_design_parts_listing_form();
  _pdm_status("PDUload_design_parts_listing_form", status);

  /* Free PDU_list_parts_info */
  if (PDU_list_parts_info)
     {
      head = PDU_list_parts_info;

      while (PDU_list_parts_info)
            {
             PDU_list_parts_info = PDU_list_parts_info->next;
             free(head);
             head = PDU_list_parts_info;
            }
     }

  PDU_list_parts_info = NULL;
  return(PDM_S_SUCCESS);
}

int PDUload_design_parts_listing_form()
{
extern int    PDMdebug_on;
int           all_flag = FALSE;
int           no_headings;
int           status = PDM_S_SUCCESS;
char          *msg;

_pdm_debug("In the function PDUload_part_listing_form", 0);

  if (PDU_design_parts_bufr == NULL)
    {
    msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_FOUND);
    FIg_set_text(forms.design_form_id, FI_MSG_FIELD,msg);
    FIf_display(forms.design_form_id);
    status = PDM_E_NO_PARTS_FOUND;
    return(status);
    }
  else if (PDU_design_parts_bufr->rows == 0) 
    {
    msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_FOUND);
    FIg_set_text(forms.design_form_id, FI_MSG_FIELD,msg);
    FIf_display(forms.design_form_id);
    status = PDM_E_NO_PARTS_FOUND;
    return(status);
    }

  /* initialize part listing form */

  MEMprint_buffer("parts list", PDU_design_parts_bufr, PDU_DEBUG_FILE);

  PDUsetup_single_buffer(PDU_design_parts_bufr);

  all_flag = TRUE;
  no_headings = 5;

  PDUsetup_popup_list(NULL, no_headings, all_flag, PDU_design_parts_bufr);

  PDUbufr_to_mcf(PDU_design_parts_bufr, forms.design_parts_form_id, 
                 PARTS_IN_OS);

  if (PDU_design_parts_bufr)
    MEMclose(&PDU_design_parts_bufr);
  return(status);

}  /* end PDUload_design_parts_listing_form */

int PDUload_list_parts_info()

  {
  int length;
  int select;
  int pos;
  int num_rows;
  int sel_flag;
  int i;
  int j;
  char *text = NULL;
  struct PDUlist_parts_info *temp;
  struct PDUlist_parts_info *tail;

  _pdm_debug("In PDUload_list_parts_info", 0);

   FIfld_get_num_rows(forms.design_parts_form_id, PARTS_IN_OS, &num_rows);
   _pdm_debug("num_rows = <%d>", (char *)num_rows);

  for (i = 0; i < num_rows; i = i + 1)
    {
    _pdm_debug("i = %d", (char *)i);
    FIfld_get_select(forms.design_parts_form_id, PARTS_IN_OS, i, 0, &sel_flag);
    FIfld_set_active_row(forms.design_parts_form_id, PARTS_IN_OS, i, 0);
    if (sel_flag)
      {
      _pdm_debug("Selected row = <%d>", (char *)i);
      temp = (struct PDUlist_parts_info *) 
              malloc(sizeof(struct PDUlist_parts_info));
  
      /* Initialize temp fields */
      temp->catalog_name = NULL;
      temp->part_id = NULL;
      temp->revision = NULL;
      temp->usage_id = NULL;
      temp->next = NULL;

      for (j = 0; j < 5; j++)
        {
        FImcf_set_active_col(forms.design_parts_form_id, PARTS_IN_OS, j, j);
        FIfld_get_text_length(forms.design_parts_form_id,PARTS_IN_OS,i,j,
                              &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(forms.design_parts_form_id,PARTS_IN_OS,i,j,length,
                       (unsigned char*)text,
                       &select, &pos);

        if (j == 0)
          PDUfill_in_string(&temp->catalog_name, text);
        else if (j == 1)
          PDUfill_in_string(&temp->part_id, text);
        else if (j == 2)
          PDUfill_in_string(&temp->revision, text);
        else if (j == 4)
          PDUfill_in_string(&temp->usage_id, text);
        }
     /* Add node to the end of PDU_list_parts_info */
     if (PDU_list_parts_info)
        {
         /* Get to the end of list */
         tail = PDU_list_parts_info;
         while (tail->next)
               {
                tail = tail->next;
               }

         /* Add part to path link list */
         tail->next = temp;
        }

     else
        {
         /* This is the first node in the list */
         PDU_list_parts_info = temp;
        }

     PDU_selected_rows = PDU_selected_rows + 1;
     }
   }

  return(PDM_S_SUCCESS);
  }
